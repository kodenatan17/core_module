/// Read-only view of what the current session is allowed to do.
///
/// Roles (Warga, Pengurus RT, Pengurus RW, Admin) are modelled as permissions
/// rather than as separate modules, so a domain keeps exactly one owner: the
/// resident-facing and the pengurus-facing halves of Iuran both live in
/// `finance_module`, gated by permissions declared here.
///
/// Implemented by `authentication_module`, registered by the shell, and read by
/// both the shell (to filter [HomeSection]s and nav items) and feature modules
/// (to guard their own routes).
abstract interface class SessionPermissions {
  /// Permissions held by the current session. Empty when signed out.
  Set<String> get permissions;

  /// Whether the session holds [permission].
  bool has(String permission);

  /// Whether the session holds every permission in [required].
  ///
  /// An empty list is always satisfied.
  bool hasAll(Iterable<String> required);

  /// Emits whenever the permission set changes (login, logout, role change).
  ///
  /// The shell listens so home sections and navigation re-evaluate without a
  /// restart.
  Stream<Set<String>> get changes;
}

/// Permission identifiers shared across modules.
///
/// Modules own their own strings, but the ones the shell or several modules
/// reference are collected here so a typo can't silently hide a feature.
abstract final class Permissions {
  // ── Finance ────────────────────────────────────────
  /// View the RT/RW cash ledger — Admin/Pengurus only.
  static const String kasRead = 'kas.read';

  /// Record, edit, or delete a cash movement.
  static const String kasWrite = 'kas.write';

  /// Approve a resident's payment confirmation.
  static const String iuranValidate = 'iuran.validate';

  // ── Events ─────────────────────────────────────────
  /// Create, edit, or delete an event.
  static const String eventManage = 'event.manage';

  // ── Forum ──────────────────────────────────────────
  /// Moderate posts and comments.
  static const String forumModerate = 'forum.moderate';
}
