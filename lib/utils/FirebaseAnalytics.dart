import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

Future<void> sendAnalyticsEvent(FirebaseAnalytics analytics, String eventName,
    Map<String, dynamic> eventParams) async {
  await analytics.logEvent(name: eventName, parameters: eventParams);
  print("event logged");
}
