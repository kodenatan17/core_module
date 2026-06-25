abstract interface class CrashlyticsService {
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  });

  Future<void> log(String message);

  Future<void> setUserId(String id);

  Future<void> setCustomKey(String key, Object value);
}
