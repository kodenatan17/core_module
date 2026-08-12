import 'package:flutter/widgets.dart';

/// A navigation entry a feature module contributes to the shell's navigation.
///
/// Same idea as [HomeSection]: the shell renders the bar, modules decide what
/// belongs in it. Without this the shell would have to hard-code which features
/// exist, which is exactly the coupling the module registry removes
/// (`solutioning/architecture/07-route-self-registration.md`).
class ModuleNavItem {
  /// Unique identifier, namespaced by module (e.g. "iuran").
  final String id;

  /// Name of the module contributing this entry. Must match
  /// [FeatureModule.name] so entries of disabled modules disappear.
  final String moduleName;

  /// Label shown under the icon.
  final String label;

  final IconData icon;

  /// Icon shown when the entry is the active destination.
  final IconData? selectedIcon;

  /// Destination path. Must be a route the contributing module owns.
  final String path;

  /// Sort weight — entries render in ascending order across all modules.
  final int order;

  /// Permissions required to see this entry. Empty means everyone.
  final List<String> requiredPermissions;

  const ModuleNavItem({
    required this.id,
    required this.moduleName,
    required this.label,
    required this.icon,
    required this.path,
    required this.order,
    this.selectedIcon,
    this.requiredPermissions = const [],
  });

  @override
  String toString() => 'ModuleNavItem($id → $path)';
}
