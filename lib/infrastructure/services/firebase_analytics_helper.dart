import 'package:flutter/foundation.dart';

class FirebaseAnalyticsHelper {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsHelper(this._analytics);

  Future<void> screenView({
    required String screenName,
    required String eventCategory,
  }) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      await _analytics.logEvent(
        name: 'screen_view_category',
        parameters: {'screen_name': screenName, 'category': eventCategory},
      );
      debugPrint('Analytics: screen view "$screenName" ($eventCategory) logged.');
    } catch (e) {
      debugPrint('Analytics: failed to log screen view "$screenName": $e');
    }
  }
}
