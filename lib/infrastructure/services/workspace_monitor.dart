import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';

import 'pae_indexer.dart';

/// Watches the workspace for file changes and triggers re-indexing only for
/// changed files.
@singleton
class WorkspaceMonitor {
  final PaeIndexer _indexer;
  Timer? _debounce;
  DateTime _lastScan = DateTime.now();

  WorkspaceMonitor(this._indexer);

  /// Start watching [workspaceRoot] for `.dart` file changes.
  ///
  /// Polls every [pollInterval] and triggers incremental re-index on changes.
  void start({String workspaceRoot = '.', Duration pollInterval = const Duration(seconds: 30)}) {
    _debounce?.cancel();
    _debounce = Timer.periodic(pollInterval, (_) => _poll(workspaceRoot));
  }

  Future<void> _poll(String workspaceRoot) async {
    try {
      final dir = Directory(workspaceRoot);
      if (!dir.existsSync()) return;

      final changedFiles = <String>[];

      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final stat = await entity.stat();
          if (stat.modified.isAfter(_lastScan)) {
            changedFiles
                .add(entity.path.replaceFirst('$workspaceRoot/', ''));
          }
        }
      }

      if (changedFiles.isNotEmpty) {
        _lastScan = DateTime.now();
        await _indexer.indexFiles(changedFiles, workspaceRoot: workspaceRoot);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[WorkspaceMonitor] poll error: $e');
    }
  }

  /// Stop watching.
  void stop() {
    _debounce?.cancel();
    _debounce = null;
  }

  @disposeMethod
  void dispose() {
    stop();
  }
}
