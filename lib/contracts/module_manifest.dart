import 'module_version.dart';
import 'module_dependency.dart';
import 'module_priority.dart';

/// Self-describing metadata every module exposes.
///
/// The manifest is a **runtime module contract** — the shell uses it to decide
/// when to initialize, whether to show in navigation, and how to resolve
/// feature flags when remote sources are unavailable.
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

  // ── Initialization Strategy ─────────────────────────

  /// When this module initializes.
  ///
  /// - [ModuleInitializationStrategy.eager]: at startup (blocking)
  /// - [ModuleInitializationStrategy.warmup]: after first frame (background)
  /// - [ModuleInitializationStrategy.lazy]: on first access
  final ModuleInitializationStrategy initializationStrategy;

  /// Whether the app can function without this module.
  ///
  /// - [StartupBehavior.required]: module is essential
  /// - [StartupBehavior.optional]: module is additional
  final StartupBehavior startupBehavior;

  // ── Default Visibility ─────────────────────────────

  /// Whether this module is enabled by default (no remote flags).
  final bool defaultEnabled;

  /// Whether this module's menu item is visible by default.
  final bool defaultVisible;

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
    this.initializationStrategy = ModuleInitializationStrategy.lazy,
    this.startupBehavior = StartupBehavior.optional,
    this.defaultEnabled = true,
    this.defaultVisible = true,
    this.buildNumber,
    this.environment,
  });

  @override
  String toString() => 'ModuleManifest($name $version)';
}
