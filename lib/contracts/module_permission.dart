/// A permission a module requires or exposes.
class ModulePermission {
  final String name;
  final String description;

  const ModulePermission({
    required this.name,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      other is ModulePermission && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ModulePermission($name)';
}
