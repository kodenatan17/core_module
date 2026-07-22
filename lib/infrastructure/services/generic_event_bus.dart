import 'dart:async';
import 'package:injectable/injectable.dart';

/// Generic transport for domain events.
///
/// Core Module menyediakan EventBus sebagai Generic Infrastructure.
/// EventBus tidak mengetahui business event apapun.
/// Semua Business Event (seperti AuthEvent) harus didefinisikan di module
/// masing-masing dan dikirim melalui transport ini.
@singleton
class EventBus {
  final _controller = StreamController<Object>.broadcast();

  /// Publish sebuah event ke semua subscriber yang mendengarkan tipe [T].
  void publish<T>(T event) {
    if (_controller.isClosed) return;
    _controller.add(event as Object);
  }

  /// Subscribe untuk menerima event bertipe [T].
  Stream<T> on<T>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
