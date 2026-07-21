import 'dart:io';
import 'package:core_module/core_module.dart';
import 'package:core_module/infrastructure/services/session_event_bus.dart';
import 'package:core_module/contracts/auth/auth_token_manager.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenManager _tokenManager;
  final SessionEventBus _sessionEventBus;
  final Dio _dio;
  final List<String> _whitelistPaths;

  AuthInterceptor({
    required AuthTokenManager tokenManager,
    required SessionEventBus sessionEventBus,
    required Dio dio,
    List<String> whitelistPaths = const [],
  })  : _tokenManager = tokenManager,
        _sessionEventBus = sessionEventBus,
        _dio = dio,
        _whitelistPaths = whitelistPaths;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_whitelistPaths.contains(options.path)) {
      return handler.next(options);
    }

    if (await _tokenManager.isSessionActive()) {
      final token = await _tokenManager.getAccessToken();
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['X-Device-Type'] = Platform.isIOS ? 'IOS' : 'ANDROID';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 && err.response?.statusCode != 400) {
      return handler.next(err);
    }

    final message = _extractErrorMessage(err.response?.data);
    if (!_isTokenExpiredError(message)) {
      return handler.next(err);
    }

    // Prevent loop: skip if already on a refresh endpoint
    if (err.requestOptions.path.contains('refresh-token')) {
      return handler.next(err);
    }

    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return handler.reject(err);
      }

      final result = await _tokenManager.refreshToken(refreshToken);
      if (result == null) {
        await _tokenManager.clearSession();
        _sessionEventBus.emit(SessionExpired());
        return handler.reject(err);
      }

      await _tokenManager.saveTokens(result.accessToken, result.refreshToken);
      _sessionEventBus.emit(TokenRefreshed(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      ));

      // Retry original request
      final retryResponse = await _retryRequest(err.requestOptions, result.accessToken);
      return handler.resolve(retryResponse);
    } catch (e) {
      await _tokenManager.clearSession();
      _sessionEventBus.emit(SessionExpired());
      return handler.reject(err);
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options, String newToken) async {
    final retryOptions = Options(
      method: options.method,
      headers: {...options.headers, 'Authorization': 'Bearer $newToken'},
    );
    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: retryOptions,
    );
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['status'] is Map<String, dynamic> && data['status']['message'] is String) return data['status']['message'];
      if (data['message'] is String) return data['message'];
    }
    return null;
  }

  bool _isTokenExpiredError(String? message) {
    if (message == null) return false;
    final lower = message.toLowerCase();
    return lower == 'unauthorized' || lower == 'the token is expired' || lower == 'invalid or expired token';
  }
}
