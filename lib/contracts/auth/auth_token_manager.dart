abstract class AuthTokenManager {
  Future<bool> isSessionActive();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<void> clearSession();
  Future<AuthTokenRefreshResult?> refreshToken(String currentRefreshToken);
}

class AuthTokenRefreshResult {
  final String accessToken;
  final String refreshToken;
  AuthTokenRefreshResult({required this.accessToken, required this.refreshToken});
}
