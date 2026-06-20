import 'module_version.dart';
import 'module_permission.dart';
import 'module_dependency.dart';

/// Self-describing metadata every module exposes.
///
/// The manifest allows the shell, AI agents, and developers to
/// understand a module without reading its implementation.
class ModuleManifest {
  /// Unique identifier (e.g. "resident", "finance").
  final String name;

  /// Human-readable display name.
  final String displayName;

  /// Current semantic version.
  final ModuleVersion version;

  /// One-line description of what this module does.
  final String description;

  // ── Compatibility ──────────────────────────────────

  /// Minimum shell version required by this module.
  final ModuleVersion minShellVersion;

  /// Recommended shell version (optional).
  final ModuleVersion? recommendedShellVersion;

  // ── Dependencies ───────────────────────────────────

  /// Other modules this module depends on.
  final List<ModuleDependency> dependencies;

  // ── Permissions ────────────────────────────────────

  /// Permissions this module requires.
  final List<ModulePermission> permissions;

  // ── Feature Flags ──────────────────────────────────

  /// Default values for feature flags this module owns.
  final Map<String, bool> featureFlags;

  // ── Capabilities ───────────────────────────────────

  /// What this module provides (e.g. "resident.crud", "resident.search").
  final List<String> provides;

  // ── Build Metadata ─────────────────────────────────

  /// Build number (optional).
  final String? buildNumber;

  /// Environment this manifest describes.
  final String? environment;

  const ModuleManifest({
    required this.name,
    required this.displayName,
    required this.version,
    required this.description,
    this.minShellVersion = const ModuleVersion(1, 0, 0),
    this.recommendedShellVersion,
    this.dependencies = const [],
    this.permissions = const [],
    this.featureFlags = const {},
    this.provides = const [],
    this.buildNumber,
    this.environment,
  });

  @override
  String toString() => 'ModuleManifest($name $version)';
}
