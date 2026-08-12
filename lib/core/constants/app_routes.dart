/// Route paths shared across the shell and feature modules.
///
/// Modules navigate to each other by path string, never by import — the path
/// is a convention, not a dependency (`solutioning/architecture/
/// 07-route-self-registration.md`). These constants exist so that convention
/// is checked by the compiler instead of by hand.
///
/// Paths are named after the **feature**, not the package that currently ships
/// it. `resident_module` owns every path below its own section today; if a
/// feature is later extracted into its own module, the paths — and therefore
/// any deep link already in the wild — do not change.
abstract final class AppRoutes {
  // ── Shell-owned ────────────────────────────────────
  /// Shown while the session is still being resolved on cold start.
  static const String splash = '/splash';

  /// Home feed, composed from module-contributed home sections.
  static const String home = '/';

  /// Module launcher grid.
  static const String menu = '/menu';

  // ── authentication_module ──────────────────────────
  static const String login = '/login';
  static const String otpVerify = '/register-verify';

  // ── Profil & hunian ────────────────────────────────
  static const String resident = '/resident';
  static const String residentHousehold = '/resident/household';

  // ── Iuran (tagihan warga) ──────────────────────────
  static const String iuran = '/iuran';

  static String iuranDetail(String id) => '/iuran/$id';

  // ── Kas RT/RW (Admin/Pengurus) ─────────────────────
  static const String kas = '/kas';
  static const String kasHistory = '/kas/history';

  // ── Acara / agenda bulanan ─────────────────────────
  static const String acara = '/acara';

  static String acaraDetail(String id) => '/acara/$id';

  // ── Pengumuman / bulletin ──────────────────────────
  static const String pengumuman = '/pengumuman';

  static String pengumumanDetail(String id) => '/pengumuman/$id';

  /// Paths reachable without a session — everything else sits behind the
  /// shell's auth guard.
  static const Set<String> public = {splash, login, otpVerify};
}

/// Named routes, for `context.goNamed` / `pushNamed`.
///
/// Names are namespaced by feature for the same reason paths are.
abstract final class AppRouteNames {
  static const String splash = 'splash';
  static const String home = 'home';
  static const String menu = 'menu';

  static const String login = 'auth.login';
  static const String otpVerify = 'auth.otpVerify';

  static const String resident = 'resident.profile';
  static const String residentHousehold = 'resident.household';

  static const String iuran = 'iuran.list';
  static const String iuranDetail = 'iuran.detail';

  static const String kas = 'kas.overview';
  static const String kasHistory = 'kas.history';

  static const String acara = 'acara.list';
  static const String acaraDetail = 'acara.detail';

  static const String pengumuman = 'pengumuman.list';
  static const String pengumumanDetail = 'pengumuman.detail';
}
