import 'package:ScrimUp/account/LaunchHello.dart';
import 'package:ScrimUp/game/JoinCreateTeam.dart';
import 'Strategies.dart';
import 'utils/FirstLaunch.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import "./utils/session.dart";
import './account/login.dart';
import './availability/TeamAvailability.dart';
import './game/GameSelect.dart';
import './utils/Snackbars.dart';
import 'utils/FirstLaunch.dart';

class _InitiliazeState extends State<InitiliazeApp> {
  bool haveSession = false;
  bool isTokenSetted = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isFirstLaunch = false;
  bool isFirstLaunchChecked = false;
  bool sessionLoaded = false;
  bool verified = true;
  bool leaderLoaded = false;
  bool isAvatarLoaded = false;
  bool gamesLoaded = false;
  Session session;
  String _errorMessage;
  double isLeader = 0;
  var games;
  var teams;
  String FCMToken;
  _InitiliazeState(this.session);
  Future<String> get _localPath async {
    print("Getting local path");
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    try {
      print("Getting file");
      return File('$path/session.data');
    } catch (e) {
      return null;
    }
  }

  void checkFirstLaunch() async {
    bool firstLaunch = await firstLaunchFile();
    setState(() {
      isFirstLaunch = firstLaunch;
      isFirstLaunchChecked = true;
    });
  }

  void getGames(response) {
    setState(() {
      games = [];
      teams = [];
      for (int i = 0; i < response["games"].length; i++) {
        games.add(response["games"][i]["name"]);
        teams.add(response["games"][i]["team"]);
      }
      gamesLoaded = true;
    });
  }

  void loadLeader(response) {
    setState(() {
      isLeader = response["success"] ? 1.0 : 0.0;
      leaderLoaded = true;
    });
  }

  Future<bool> loadSession(Session session) async {
    print("Load session called");
    bool hSession = false;
    _firebaseMessaging.getToken().then((token) async {
      if (token == null) {
        print("null token");
        FCMToken = "adsfadf";
      } else {
        FCMToken = token;
      }
      session.FCMToken = FCMToken;
      print("Token taken");
      try {
        final file = await _localFile;
        if (file == null) {
          print("file null");
          hSession = false;
          return false;
        }
        print("file found");
        // Read the file
        String contents = await file.readAsString();
        session.cookie = contents;
        var sessionCheckUrl = "/account/isSessionActive";
        print("Checking session");
        var response = await session.get(sessionCheckUrl);
        if (response["success"]) {
          if (!response["verified"]) {
            verified = false;
          }
          hSession = true;
          return true;
        } else {
          var temp = await file.delete();
          hSession = false;
          return false;
        }
      } catch (e) {
        hSession = false;
        return false;
      }
    });
    await Future.delayed(Duration(seconds: 3));
    if (session.FCMToken == null) {
      session.FCMToken = "null";
    }
    return hSession;
  }

  void sessionDoneReading(bool haveSess) {
    setState(() {
      print("Session done reading");
      this.haveSession = haveSess;
      this.sessionLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _firebaseMessaging.requestNotificationPermissions();
    try {
      _firebaseMessaging.configure(onMessage: (notification) {
        // print(notification);
      }, onLaunch: (notification) {
        // print(notification);
      }, onResume: (notification) {
        // print(notification);
      });
    } catch (e) {
      print("Catched");
    }
    if (isFirstLaunchChecked) {
      if (isFirstLaunch) {
        return LaunchHello(session);
      } else {
        if (sessionLoaded) {
          if (haveSession) {
            if (verified) {
              if (!isAvatarLoaded) {
                session.post("/account/getAvatar", {}).then((response) {
                  setState(() {
                    if (response["success"]) {
                      session.avatar = response["avatar"];
                    } else {
                      session.avatar =
                          "https://avatars.dicebear.com/v2/male/12312412165124.svg";
                    }
                    isAvatarLoaded = true;
                  });
                });
                return new Container(
                    child: Image.asset('assets/logo/logo_with_title.png'),
                    decoration:
                        BoxDecoration(color: Color.fromRGBO(48, 48, 48, 1)));
              } else {
                session.notRegistered = false;
                if (!isTokenSetted) {
                  var setTokenUrl = "/account/setFCMToken";
                  session
                      .post(setTokenUrl, {FCMToken: FCMToken}).then((response) {
                    setState(() {
                      isTokenSetted = true;
                    });
                  });
                  return new Container(
                      child: Image.asset('assets/logo/logo_with_title.png'),
                      decoration:
                          BoxDecoration(color: Color.fromRGBO(48, 48, 48, 1)));
                } else {
                  if (!gamesLoaded) {
                    var getGamesUrl = "/account/getGames";
                    session.get(getGamesUrl).then((response) {
                      getGames(response);
                    });
                    return new Container(
                        child: Image.asset('assets/logo/logo_with_title.png'),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(48, 48, 48, 1)));
                  } else {
                    if (games.length == 0) {
                      return new JoinCreateTeamScreen(session);
                    }
                    if (teams[0] == null) {
                      print("I am going to strategies");
                      return new StrategiesScreen(
                          games[0], "Solo", session, 1, games, teams, 0);
                    }
                    if (!leaderLoaded) {
                      var isLeaderUrl = "/team/isLeader";
                      session.post(isLeaderUrl, {
                        "gameName": games[0],
                        "teamName": teams[0],
                      }).then((response) {
                        loadLeader(response);
                      });
                      return new Container(
                          child: Image.asset('assets/logo/logo_with_title.png'),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(48, 48, 48, 1)));
                    }
                    return new TeamAvailabilityScreen(
                        games[0], teams[0], session, isLeader, games, teams, 0);
                  }
                }
              }
            } else {
              return new LoginScreen(session);
            }
          } else {
            return new LoginScreen(session);
          }
        } else {
          // print("here");
          loadSession(session).then((haveSess) {
            print("I have loaded sessions");
            print("haveSess is : " + haveSess.toString());
            sessionDoneReading(haveSess);
          });
          return new Container(
              child: Image.asset('assets/logo/logo_with_title.png'),
              decoration: BoxDecoration(color: Color.fromRGBO(48, 48, 48, 1)));
        }
      }
    } else {
      checkFirstLaunch();
      return new Container(
          child: Image.asset('assets/logo/logo_with_title.png'),
          decoration: BoxDecoration(color: Color.fromRGBO(48, 48, 48, 1)));
    }
  }
}

class InitiliazeApp extends StatefulWidget {
  // static final session = new Session("10.193.41.10:3000");
  static final session = new Session("scrimup.app");

  InitiliazeApp(
      FirebaseAnalytics analytics, FirebaseAnalyticsObserver observer) {
    session.analytics = analytics;
    session.observer = observer;
  }
  //"10.0.2.2:3000"

  @override
  _InitiliazeState createState() => _InitiliazeState(session);
}
