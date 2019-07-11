import 'package:ScrimUp/availability/TeamAvailability.dart';
import 'package:ScrimUp/utils/session.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'dart:core';
import 'dart:async';

import 'package:flutter/material.dart';

import 'FirebaseAnalytics.dart';
import 'SnackBars.dart';

class DynamicLinkData {
  static final _dynamicLinkData = DynamicLinkData._internal(null, null);

  factory DynamicLinkData(String path, Map<String, String> queryParams) {
    if (path != _dynamicLinkData.path) {
      _dynamicLinkData.path = path;
      _dynamicLinkData.queryParams = queryParams;
      return _dynamicLinkData;
    } else {
      return null;
    }
  }

  DynamicLinkData._internal(String path, Map<String, String> queryParams) {
    this.path = path;
    this.queryParams = queryParams;
  }
  String path;
  Map<String, String> queryParams;
}

void joinTeamWithToken(String token, BuildContext context, Session session,
    double _buttonFontSize, double _buttonPaddingTop) {
  final nickController = TextEditingController();
  showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text('Join team')),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(bottom: _buttonPaddingTop),
                  child: Center(child: Text("Nickname"))),
              TextField(
                decoration: new InputDecoration(
                  labelText: "Enter Nickname",
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                controller: nickController,
                maxLines: 1,
              )
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Done'),
              onPressed: () {
                if (nickController.text.length != 0) {
                  var enterTokenUrl = "/team/enterWithToken";
                  session.post(enterTokenUrl, {
                    "token": token,
                    "nickName": nickController.text
                  }).then((response3) {
                    if (response3["success"]) {
                      sendAnalyticsEvent(
                          session.analytics, "join_with_link", {});
                      //navigator
                      String game = response3["game"];
                      String team = response3["team"];
                      var getGamesUrl = "/account/getGames";
                      session.get(getGamesUrl).then((response) {
                        var games = [];
                        var teams = [];
                        if (!response["success"]) {
                          if (response["msg"] == "Login first") {
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/", (_) => false);
                          } else {
                            var _errorMessage = response["msg"];
                            Scaffold.of(context).showSnackBar(
                                ErrorSnackBar(_errorMessage, _buttonFontSize));
                          }
                        }
                        for (int i = 0; i < response["games"].length; i++) {
                          games.add(response["games"][i]["name"]);
                          teams.add(response["games"][i]["team"]);
                        }
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => new TeamAvailabilityScreen(
                                  game,
                                  team,
                                  session,
                                  0,
                                  games,
                                  teams,
                                  games.indexOf(game))),
                          (_) => false,
                        );
                      });
                    }
                  });
                } else {
                  Scaffold.of(context).showSnackBar(ErrorSnackBar(
                      "Nickname can't be empty", _buttonFontSize));
                }
              }),
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<DynamicLinkData> retrieveDynamicLink() async {
  try {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.retrieveDynamicLink();
    print(data);
    final Uri deepLink = data?.link;
    print("getting the link");
    if (deepLink != null) {
      print("link is not null yeahh");
      print(deepLink);
      DynamicLinkData dynamicLinkData =
          new DynamicLinkData(deepLink.path, deepLink.queryParameters);
      return dynamicLinkData; // deeplink.path == '/helloworld'
    }
    return null;
  } catch (e) {
    print(e.toString());
    return null;
  }
}
