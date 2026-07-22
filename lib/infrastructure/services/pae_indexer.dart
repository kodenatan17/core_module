import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/core_hive_constants.dart';

/// Status of the indexing process.
enum IndexingStatus { idle, indexing, ready, error }

/// A lightweight snippet of context matched against a query.
class ContextSnippet {
  final String filePath;
  final String content;
  final double relevance;

  const ContextSnippet({
    required this.filePath,
    required this.content,
    required this.relevance,
  });
}

/// Hive-stored index entry for a file.
class PaeIndexEntry {
  final String filePath;
  final int lastModified;
  final String contentHash;
  final List<String> tokens;

  const PaeIndexEntry({
    required this.filePath,
    required this.lastModified,
    required this.contentHash,
    required this.tokens,
  });

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'lastModified': lastModified,
        'contentHash': contentHash,
        'tokens': tokens,
      };

  factory PaeIndexEntry.fromJson(Map<String, dynamic> json) =>
      PaeIndexEntry(
        filePath: json['filePath'] as String,
        lastModified: json['lastModified'] as int,
        contentHash: json['contentHash'] as String,
        tokens: (json['tokens'] as List).cast<String>(),
      );
}

/// Indexes workspace files for prompt-aware execution (PAE) queries.
///
/// Runs tokenization in an isolate. Stores entries in a Hive box.
/// Exposes query results as [ContextSnippet] via [query].
@singleton
class PaeIndexer {
  final _statusController = StreamController<IndexingStatus>.broadcast();
  Box<String>? _indexBox;

  Stream<IndexingStatus> get status => _statusController.stream;

  @postConstruct
  Future<void> init() async {
    _statusController.add(IndexingStatus.idle);
  }

  /// Open (or retrieve) the PAE index box.
  Future<Box<String>> _ensureBox() async {
    if (_indexBox == null || !_indexBox!.isOpen) {
      _indexBox = await Hive.openBox<String>(CoreHiveBoxName.paeIndexBox);
    }
    return _indexBox!;
  }

  /// Full workspace scan — tokenizes all `.dart` files found under [workspaceRoot].
  Future<void> indexWorkspace({String workspaceRoot = '.'}) async {
    _statusController.add(IndexingStatus.indexing);

    try {
      final box = await _ensureBox();
      final dir = Directory(workspaceRoot);
      final dartFiles = await _collectDartFiles(dir);

      for (final file in dartFiles) {
        final relativePath = file.path.replaceFirst('$workspaceRoot/', '');
        await _indexSingleFile(file, relativePath, workspaceRoot, box);
      }

      _statusController.add(IndexingStatus.ready);
      _statusController.add(IndexingStatus.idle);
    } catch (e) {
      // ignore: avoid_print
      print('[PaeIndexer] indexWorkspace error: $e');
      _statusController.add(IndexingStatus.error);
    }
  }

  /// Index only the specified [filePaths] (relative to [workspaceRoot]).
  Future<void> indexFiles(List<String> filePaths,
      {String workspaceRoot = '.'}) async {
    _statusController.add(IndexingStatus.indexing);

    try {
      final box = await _ensureBox();

      for (final relativePath in filePaths) {
        final file = File('$workspaceRoot/$relativePath');
        if (!await file.exists()) continue;
        await _indexSingleFile(file, relativePath, workspaceRoot, box);
      }

      _statusController.add(IndexingStatus.ready);
      _statusController.add(IndexingStatus.idle);
    } catch (e) {
      // ignore: avoid_print
      print('[PaeIndexer] indexFiles error: $e');
      _statusController.add(IndexingStatus.error);
    }
  }

  /// Index a single file and store in Hive.
  Future<void> _indexSingleFile(
      File file, String relativePath, String workspaceRoot, Box<String> box,
      ) async {
    final stat = await file.stat();
    final metaKey = 'pae:$relativePath:meta';
    final dataKey = 'pae:$relativePath:data';
    final currentHash = '${stat.modified.millisecondsSinceEpoch}';

    final existingHash = box.get(metaKey);
    if (existingHash == currentHash) return; // unchanged

    final content = await file.readAsString();
    final tokens = await Isolate.run(() => _tokenizeInIsolate(content));

    final entry = PaeIndexEntry(
      filePath: relativePath,
      lastModified: stat.modified.millisecondsSinceEpoch,
      contentHash: currentHash,
      tokens: tokens,
    );

    await box.put(metaKey, currentHash);
    await box.put(dataKey, jsonEncode(entry.toJson()));
  }

  /// Naive query — returns top snippet matching [prompt] tokens.
  Future<ContextSnippet?> query(String prompt) async {
    final box = await _ensureBox();
    final queryTokens = _tokenize(prompt).toSet();
    if (queryTokens.isEmpty) return null;

    ContextSnippet? best;
    var bestScore = 0.0;

    for (final key in box.keys) {
      if (!(key as String).endsWith(':data')) continue;

      final raw = box.get(key);
      if (raw == null) continue;

      final entry = PaeIndexEntry.fromJson(
        Map<String, dynamic>.from(
          const JsonDecoder()
              .cast<String, Map<String, dynamic>>()
              .convert(raw),
        ),
      );

      final matchCount =
          entry.tokens.where((t) => queryTokens.contains(t)).length;
      if (matchCount == 0) continue;

      final score = matchCount / queryTokens.length;
      if (score > bestScore) {
        bestScore = score;
        final content = await _readFileContent(entry.filePath);
        best = ContextSnippet(
          filePath: entry.filePath,
          content: content,
          relevance: score,
        );
      }
    }

    return best;
  }

  Future<List<File>> _collectDartFiles(Directory dir) async {
    final files = <File>[];
    try {
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          files.add(entity);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[PaeIndexer] collectDartFiles error: $e');
    }
    return files;
  }

  /// Tokenize on the current isolate (used for query — lightweight).
  List<String> _tokenize(String text) {
    return text
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .map((t) => t.toLowerCase())
        .toList();
  }

  /// Tokenize in a separate isolate (used for indexing — CPU-bound).
  static List<String> _tokenizeInIsolate(String text) {
    return text
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .map((t) => t.toLowerCase())
        .toList();
  }

  Future<String> _readFileContent(String relativePath) async {
    try {
      return await File(relativePath).readAsString();
    } catch (e) {
      // ignore: avoid_print
      print('[PaeIndexer] readFileContent error: $e');
      return '';
    }
  }

  @disposeMethod
  void dispose() {
    _statusController.close();
  }
}
