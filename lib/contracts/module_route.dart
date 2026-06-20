/// Describes a route a module owns.
///
/// Modules return these from their manifest to declare what routes
/// they expose without requiring GoRouter at the contract level.
class ModuleRouteDefinition {
  /// Route path (e.g. "/resident", "/resident/:id").
  final String path;

  /// Unique route name for navigation.
  final String name;

  /// Human-readable description.
  final String description;

  /// Whether this route requires authentication.
  final bool requiresAuth;

  const ModuleRouteDefinition({
    required this.path,
    required this.name,
    this.description = '',
    this.requiresAuth = true,
  });

  @override
  String toString() => 'ModuleRoute($name: $path)';
}
