import 'package:go_router/go_router.dart';

import 'module_manifest.dart';
import 'module_priority.dart';
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

  // ── Lifecycle ──────────────────────────────────────

  /// One-time async initialization.
  ///
  /// Called after dependency injection is set up.
  /// Use for DB migrations, preloading, API init, etc.
  Future<void> initialize();

  /// Whether this module has been initialized already.
  bool get isInitialized;

  /// Release resources held by this module.
  ///
  /// Called when the module is disposed (app shutdown or hot-reload).
  /// Resets [isInitialized] to false.
  void dispose();

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

  /// Module initialization strategy (shorthand).
  ModuleInitializationStrategy get strategy => manifest.initializationStrategy;

  /// Startup behavior (shorthand).
  StartupBehavior get startupBehavior => manifest.startupBehavior;

  /// Whether the module is enabled by default.
  bool get defaultEnabled => manifest.defaultEnabled;

  /// Whether the module is visible by default.
  bool get defaultVisible => manifest.defaultVisible;
}
