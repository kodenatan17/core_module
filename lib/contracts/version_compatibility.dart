import 'module_version.dart';
import 'module_manifest.dart';

// ── Result Types ─────────────────────────────────────

/// Severity of a compatibility check result.
enum CompatibilitySeverity { ok, warning, blocking }

/// Result of checking a module's compatibility.
class CompatibilityResult {
  final bool compatible;
  final String? reason;
  final CompatibilitySeverity severity;

  const CompatibilityResult({
    required this.compatible,
    this.reason,
    required this.severity,
  });

  bool get isOk => severity == CompatibilitySeverity.ok;
  bool get isWarning => severity == CompatibilitySeverity.warning;
  bool get isBlocking => severity == CompatibilitySeverity.blocking;

  @override
  String toString() =>
      'CompatibilityResult(${compatible ? "OK" : "FAIL"}: $reason)';
}

// ── Compatibility Checker ────────────────────────────

/// Checks version compatibility between shell and modules.
class VersionCompatibility {
  final ModuleVersion shellVersion;

  const VersionCompatibility({required this.shellVersion});

  /// Check a single module's manifest against the shell version.
  CompatibilityResult checkModule(ModuleManifest manifest) {
    // Module requires minimum shell version
    if (shellVersion < manifest.minShellVersion) {
      return CompatibilityResult(
        compatible: false,
        reason:
            'Module "${manifest.name}" requires shell '
            '${manifest.minShellVersion.asString} but shell is '
            '${shellVersion.asString}',
        severity: CompatibilitySeverity.blocking,
      );
    }

    // Check recommended version (non-blocking)
    if (manifest.recommendedShellVersion != null &&
        shellVersion < manifest.recommendedShellVersion!) {
      return CompatibilityResult(
        compatible: true,
        reason:
            'Module "${manifest.name}" recommends shell '
            '${manifest.recommendedShellVersion!.asString}',
        severity: CompatibilitySeverity.warning,
      );
    }

    return const CompatibilityResult(
      compatible: true,
      severity: CompatibilitySeverity.ok,
    );
  }

  /// Check all given manifests and return results.
  List<CompatibilityResult> checkAll(List<ModuleManifest> manifests) {
    return manifests.map(checkModule).toList();
  }

  /// Whether all given manifests are compatible (no blocking issues).
  bool areAllCompatible(List<ModuleManifest> manifests) {
    return checkAll(manifests).every((r) => !r.isBlocking);
  }
}
