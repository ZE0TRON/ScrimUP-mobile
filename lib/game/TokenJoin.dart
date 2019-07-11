import 'package:ScrimUp/availability/TeamAvailability.dart';
import 'package:ScrimUp/utils/FirebaseAnalytics.dart';
import 'package:flutter/material.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";

class _TokenScreenState extends State<TokenScreen> {
  Session session;
  double isError = 0.0;
  String _errorMessage = "";
  final tokenController = TextEditingController();
  final nickNameController = TextEditingController();
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  var games;
  var teams;
  double _notificationPadding;
  double _mediumFontSize;
  bool isLoaded = false;
  _TokenScreenState(Session session) {
    this.session = session;
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.030;
    var getTokenUrl = "/team/getToken";
    return new Scaffold(
      appBar: AppBar(
        title: Text("Scrim UP"),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: _headerPaddingTop),
              child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: _containerPaddingSide / 4),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: _headerPaddingTop),
                        child: Text(
                          "Token",
                          style: TextStyle(fontSize: _buttonFontSize),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: _buttonPaddingTop / 3),
                          child: TextField(
                            controller: tokenController,
                            maxLength: 100,
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: _headerPaddingTop),
                        child: Text(
                          "Nickname",
                          style: TextStyle(fontSize: _buttonFontSize),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: _buttonPaddingTop / 3),
                          child: TextField(
                            controller: nickNameController,
                            maxLength: 100,
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: _buttonPaddingTop),
                        child: OutlineButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                          textTheme: ButtonTextTheme.primary,
                          child: Center(
                            child: Text(
                              "Join The Team",
                              style: TextStyle(fontSize: _buttonFontSize),
                            ),
                          ),
                          onPressed: () {
                            if (nickNameController.text.length > 0) {
                              var enterTokenUrl = "/team/enterWithToken";
                              session.post(enterTokenUrl, {
                                "token": tokenController.text,
                                "nickName": nickNameController.text
                              }).then((response3) {
                                setState(() {
                                  if (response3["success"]) {
                                    //navigator
                                    var getGamesUrl = "/account/getGames";
                                    session.get(getGamesUrl).then((response) {
                                      games = [];
                                      teams = [];
                                      if (!response["success"]) {
                                        sendAnalyticsEvent(session.analytics,
                                            "join_with_token", {});

                                        if (response["msg"] == "Login first") {
                                          Navigator.pushNamedAndRemoveUntil(
                                              context, "/", (_) => false);
                                        } else {
                                          _errorMessage = response["msg"];
                                          Scaffold.of(context).showSnackBar(
                                              ErrorSnackBar(_errorMessage,
                                                  _buttonFontSize));
                                        }
                                      }
                                      for (int i = 0;
                                          i < response["games"].length;
                                          i++) {
                                        games.add(response["games"][i]["name"]);
                                        teams.add(response["games"][i]["team"]);
                                      }

                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  TeamAvailabilityScreen(
                                                      games[games.length - 1],
                                                      teams[teams.length - 1],
                                                      session,
                                                      0,
                                                      games,
                                                      teams,
                                                      games.length - 1)),
                                          (_) => false);
                                    });
                                  } else {
                                    _errorMessage = response3["msg"];
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar(
                                            _errorMessage, _buttonFontSize));
                                  }
                                });
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          );
        },
      ),
    );
  }
}

class TokenScreen extends StatefulWidget {
  Session session;
  TokenScreen(Session session) {
    this.session = session;
  }
  @override
  _TokenScreenState createState() => _TokenScreenState(session);
}
