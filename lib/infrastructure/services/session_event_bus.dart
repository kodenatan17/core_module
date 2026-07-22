import 'dart:async';
import 'package:injectable/injectable.dart';

/// Events fired on the [SessionEventBus].
sealed class SessionEvent {}

/// Fired when the session has expired and cannot be refreshed.
class SessionExpired extends SessionEvent {}

/// Fired after a token refresh completes successfully.
class TokenRefreshed extends SessionEvent {
  final String accessToken;
  final String refreshToken;

  TokenRefreshed({required this.accessToken, required this.refreshToken});
}

/// Dedicated bus for low-level session lifecycle events.
///
/// Used by [RefreshTokenInterceptor] and legacy network clients.
/// New code should use [EventBus] directly.
@singleton
class SessionEventBus {
  final _controller = StreamController<SessionEvent>.broadcast();

  /// The raw broadcast stream of [SessionEvent] objects.
  Stream<SessionEvent> get stream => _controller.stream;

  /// Emit a [SessionEvent] to all subscribers.
  void emit(SessionEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
