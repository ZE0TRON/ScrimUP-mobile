import 'package:flutter/material.dart';
import './InitializeApp.dart';
import './account/login.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        navigatorObservers: <NavigatorObserver>[observer],
        onGenerateRoute: (settings) {
          final session = settings.arguments;
          switch (settings.name) {
            case "/":
              return new MaterialPageRoute(
                  builder: (context) => InitiliazeApp(analytics, observer));
            case "/login":
              return new MaterialPageRoute(
                  builder: (context) => LoginScreen(session));
          }
        },
        theme: new ThemeData.dark().copyWith(
            cursorColor: Colors.white,
            buttonTheme: ButtonThemeData(
                buttonColor: Colors.orangeAccent,
                highlightColor: Colors.orange,
                textTheme: ButtonTextTheme.primary),
            buttonColor: Colors.orangeAccent,
            accentColor: Colors.orangeAccent,
            highlightColor: Colors.orangeAccent,
            primaryColorLight: Colors.orangeAccent,
            primaryColor: Colors.orangeAccent,
            textSelectionColor: Colors.orangeAccent,
            inputDecorationTheme: InputDecorationTheme(
                helperStyle: TextStyle(color: Colors.orangeAccent),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orangeAccent)))),
        debugShowCheckedModeBanner: false,
        home: new InitiliazeApp(analytics, observer));
  }
}

void main() => runApp(MyApp());
