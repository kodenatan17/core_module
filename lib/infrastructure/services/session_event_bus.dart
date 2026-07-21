import 'dart:async';
import 'package:injectable/injectable.dart';

/// Events related to global session lifecycle.
sealed class SessionEvent {}

/// Triggered when refresh token fails completely and user must re-login.
class SessionExpired extends SessionEvent {}

/// Triggered when token refresh succeeds.
class TokenRefreshed extends SessionEvent {
  final String accessToken;
  final String refreshToken;

  TokenRefreshed({required this.accessToken, required this.refreshToken});
}

/// A lightweight event bus for cross-layer session communication.
///
/// Connects infrastructure layer (interceptor) with presentation layer (bloc).
@singleton
class SessionEventBus {
  final _controller = StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get stream => _controller.stream;

  void emit(SessionEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
