abstract interface class AnalyticsService {
  Future<void> logScreenView({required String screenName, String? screenClass});
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> setUserId(String? id);
  Future<void> setUserProperty({required String name, required String? value});
}
