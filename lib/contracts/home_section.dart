import 'package:flutter/widgets.dart';

/// A card a feature module contributes to the shell's home screen.
///
/// The shell composes the home screen from the sections every enabled module
/// hands it — it never imports a module's widgets. Because [builder] is a
/// closure created inside the owning module, the shell only ever names types
/// from `core_module`, keeping the `public_api` boundary intact.
///
/// See `solutioning/architecture/07-route-self-registration.md` for the rule
/// this upholds: "The shell never imports module page widgets."
class HomeSection {
  /// Unique identifier, namespaced by module (e.g. "finance.iuran_summary").
  final String id;

  /// Name of the module contributing this section. Must match
  /// [FeatureModule.name] so the shell can drop sections of disabled modules.
  final String moduleName;

  /// Sort weight — sections render in ascending order across all modules.
  ///
  /// Modules pick from a shared scale so the home feed keeps a stable order
  /// without any module knowing about the others: profile 10, finance 20-30,
  /// events 40, forum 50.
  final int order;

  /// Permissions the session must hold for this section to render.
  ///
  /// Empty means every signed-in user sees it. Evaluated by the shell against
  /// [SessionPermissions]; this is how role-scoped cards (e.g. "Saldo Kas RT",
  /// which is Admin/Pengurus only) stay inside their owning module instead of
  /// forcing a separate admin module.
  final List<String> requiredPermissions;

  /// Builds the card. Created inside the owning module.
  final WidgetBuilder builder;

  const HomeSection({
    required this.id,
    required this.moduleName,
    required this.order,
    required this.builder,
    this.requiredPermissions = const [],
  });

  @override
  String toString() => 'HomeSection($id, order: $order)';
}
