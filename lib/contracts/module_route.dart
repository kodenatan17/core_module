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

  /// Permissions required to access this route.
  final List<String> requiredPermissions;

  const ModuleRouteDefinition({
    required this.path,
    required this.name,
    this.description = '',
    this.requiresAuth = true,
    this.requiredPermissions = const [],
  });

  @override
  String toString() => 'ModuleRoute($name: $path)';
}
