import 'package:go_router/go_router.dart';

import 'module_manifest.dart';
import 'module_permission.dart';
import 'module_version.dart';

/// Every feature module in the application must implement this contract.
///
/// This is the central abstraction for the MFE-Ready Modular Monolith.
/// Each module self-describes, self-registers, and owns its routes.
abstract class FeatureModule {
  // ── Identity ───────────────────────────────────────

  /// Unique module identifier (e.g. "resident", "finance").
  String get name;

  /// Human-readable display name.
  String get displayName;

  /// Current semantic version.
  ModuleVersion get version;

  // ── Metadata ───────────────────────────────────────

  /// Full manifest with all metadata.
  ModuleManifest get manifest;

  // ── Permissions ────────────────────────────────────

  /// Permissions this module requires.
  List<ModulePermission> get permissions;

  // ── Lifecycle ──────────────────────────────────────

  /// One-time async initialization.
  ///
  /// Called after dependency injection is set up.
  /// Use for DB migrations, preloading, API init, etc.
  Future<void> initialize();

  /// Set up dependency injection for this module.
  ///
  /// Called before [initialize()] during app bootstrap.
  void setupDependencies();

  // ── Routes ─────────────────────────────────────────

  /// Routes owned by this module.
  ///
  /// Returns GoRouter route configurations so the shell can
  /// compose them without knowing individual module routes.
  List<RouteBase> get routes;

  // ── Helpers ────────────────────────────────────────

  /// Whether this module is compatible with a given shell version.
  bool isCompatibleWithShell(ModuleVersion shellVersion) {
    return shellVersion >= manifest.minShellVersion;
  }

  /// Default feature flag value.
  bool defaultValueFor(String flagName) {
    return manifest.featureFlags[flagName] ?? false;
  }
}
