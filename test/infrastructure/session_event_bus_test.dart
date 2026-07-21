import 'dart:async';
import 'package:core_module/infrastructure/services/session_event_bus.dart';
import 'package:test/test.dart';

void main() {
  group('SessionEventBus', () {
    late SessionEventBus bus;

    setUp(() {
      bus = SessionEventBus();
    });

    tearDown(() {
      bus.dispose();
    });

    test('should emit SessionExpired event', () async {
      final events = <SessionEvent>[];
      final sub = bus.stream.listen(events.add);

      bus.emit(SessionExpired());
      await Future<void>.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first, isA<SessionExpired>());

      await sub.cancel();
    });

    test('should emit TokenRefreshed event with tokens', () async {
      final events = <SessionEvent>[];
      final sub = bus.stream.listen(events.add);

      bus.emit(TokenRefreshed(accessToken: 'acc', refreshToken: 'ref'));
      await Future<void>.delayed(Duration.zero);

      expect(events.length, 1);
      final event = events.first as TokenRefreshed;
      expect(event.accessToken, 'acc');
      expect(event.refreshToken, 'ref');

      await sub.cancel();
    });

    test('should deliver events to multiple listeners', () async {
      final events1 = <SessionEvent>[];
      final events2 = <SessionEvent>[];

      final sub1 = bus.stream.listen(events1.add);
      final sub2 = bus.stream.listen(events2.add);

      bus.emit(SessionExpired());
      await Future<void>.delayed(Duration.zero);

      expect(events1.length, 1);
      expect(events2.length, 1);

      await sub1.cancel();
      await sub2.cancel();
    });

    test('should not throw when emitting after dispose', () async {
      bus.dispose();
      expect(() => bus.emit(SessionExpired()), returnsNormally);
    });
  });
}
