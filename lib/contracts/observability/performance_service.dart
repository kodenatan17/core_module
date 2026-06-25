abstract interface class PerformanceService {
  Future<PerformanceTrace?> startTrace(String name);
}

abstract interface class PerformanceTrace {
  Future<void> stop();
  void incrementMetric(String name, int value);
  void setMetric(String name, int value);
  void putAttribute(String name, String value);
}
