import 'module_version.dart';

/// Declares a dependency on another module.
class ModuleDependency {
  final String moduleName;
  final ModuleVersion minVersion;
  final bool optional;

  const ModuleDependency({
    required this.moduleName,
    required this.minVersion,
    this.optional = false,
  });

  @override
  String toString() =>
      'ModuleDependency($moduleName: ^$minVersion${optional ? " (optional)" : ""})';
}
