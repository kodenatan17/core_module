import 'package:flutter/material.dart';

/// Layout tokens the app shell publishes and every module reads.
///
/// The shell owns branding — a module "must not own application branding"
/// (`modular_architecture/SKILL.md`) — but modules still need typed access to
/// the shell's spacing scale, otherwise cards contributed by different modules
/// drift apart visually. The token *contract* therefore lives in core_module
/// (a plain data class, no widgets, consistent with `adr_core_module_no_ui`)
/// while the shell supplies the values through [ThemeData.extensions].
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  /// Corner radius for cards and surfaces.
  final double radius;

  /// Horizontal padding around a screen's content.
  final EdgeInsets screenPadding;

  const AppSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.radius = 16,
    this.screenPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? radius,
    EdgeInsets? screenPadding,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      radius: radius ?? this.radius,
      screenPadding: screenPadding ?? this.screenPadding,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xs: _lerp(xs, other.xs, t),
      sm: _lerp(sm, other.sm, t),
      md: _lerp(md, other.md, t),
      lg: _lerp(lg, other.lg, t),
      xl: _lerp(xl, other.xl, t),
      radius: _lerp(radius, other.radius, t),
      screenPadding:
          EdgeInsets.lerp(screenPadding, other.screenPadding, t) ??
              screenPadding,
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Shorthand so pages read `context.spacing.md` instead of digging through
/// [Theme.of]. Falls back to the defaults when no shell theme is installed,
/// which keeps module widget tests runnable without booting the shell.
extension AppThemeContext on BuildContext {
  AppSpacing get spacing =>
      Theme.of(this).extension<AppSpacing>() ?? const AppSpacing();

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get texts => Theme.of(this).textTheme;
}
