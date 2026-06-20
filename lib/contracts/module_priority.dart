/// Defines when a module initializes during app lifecycle.
///
/// Controls whether a module initializes at startup, after first frame,
/// or on-demand when first accessed.
enum ModuleInitializationStrategy {
  /// Initialized at startup — session-critical (auth, resident, notification).
  ///
  /// Use for modules the user interacts with immediately after login.
  eager,

  /// Initialized after first frame in background.
  ///
  /// Use for modules visible in navigation but not needed instantly.
  warmup,

  /// Initialized on first route access or feature usage.
  ///
  /// Use for rarely-accessed modules (reports, analytics, admin).
  lazy,
}

/// Whether the module must be available for the app to function.
///
/// - [required]: module is essential; the app needs it.
/// - [optional]: module is nice-to-have; app works without it.
enum StartupBehavior {
  /// Module is essential for core app function.
  required,

  /// Module is optional; failure doesn't block the app.
  optional,
}
