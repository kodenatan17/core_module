import 'package:core_module/core/constants/core_hive_constants.dart';
import 'package:test/test.dart';

void main() {
  group('CoreHiveEntityCode', () {
    test('should have correct entity codes', () {
      expect(CoreHiveEntityCode.userPreference, 0);
      expect(CoreHiveEntityCode.locale, 1);
      expect(CoreHiveEntityCode.notificationContentData, 2);
    });
  });

  group('CoreHiveBoxName', () {
    test('should have correct box names', () {
      expect(CoreHiveBoxName.userPreferenceBox, 'userPreferenceBox');
      expect(CoreHiveBoxName.authBox, 'authBox');
      expect(CoreHiveBoxName.notificationBox, 'notificationBox');
      expect(CoreHiveBoxName.usersBox, 'usersBox');
    });

    test('should have correct token keys', () {
      expect(CoreHiveBoxName.accessTokenKey, 'accessToken');
      expect(CoreHiveBoxName.refreshTokenKey, 'refreshToken');
      expect(CoreHiveBoxName.agoraIdKey, 'agoraId');
      expect(CoreHiveBoxName.fcmTokenKey, 'fcmToken');
    });
  });
}
