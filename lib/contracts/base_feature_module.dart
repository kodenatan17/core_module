import 'feature_module.dart';

/// Abstract base implementation of [FeatureModule].
///
/// Handles the common lifecycle boilerplate ([initialize], [dispose],
/// [isInitialized]) so subclasses only need to provide identity,
/// manifest, dependency setup, and routes.
abstract class BaseFeatureModule extends FeatureModule {
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  @override
  void dispose() {
    _initialized = false;
  }
}
