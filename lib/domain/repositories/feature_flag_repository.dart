/// Single source of truth for feature flag resolution.
///
/// Resolution order:
/// 1. Remote override (e.g. GrowthBook)  — highest priority
/// 2. Local cached flags                  — medium priority
/// 3. Module manifest defaults            — fallback
///
/// The repository MUST never throw or block startup.
/// If remote is unavailable, use cache, then manifest defaults.
abstract class FeatureFlagRepository {
  /// Get all currently effective flags (remote → cache → defaults).
  Map<String, bool> resolveFlags();

  /// Get a single flag value.
  bool isEnabled(String flagName);

  /// Load flags from local cache (instant, non-blocking).
  Future<void> loadCached();

  /// Refresh flags from remote source in background.
  ///
  /// Returns `true` if remote fetch succeeded, `false` if unavailable.
  Future<bool> refreshRemote();

  /// Persist flags to local cache.
  Future<void> saveFlags(Map<String, bool> flags);
}
