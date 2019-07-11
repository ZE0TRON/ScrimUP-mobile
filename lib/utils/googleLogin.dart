import 'package:ScrimUp/game/JoinCreateTeam.dart';
import 'package:flutter/material.dart';
import '../Strategies.dart';
import "./session.dart";
import './SnackBars.dart';
import '../availability/TeamAvailability.dart';
import './FirebaseAnalytics.dart';

void googleLogin(
    BuildContext context, Session session, currentUser, double fontSize) async {
  var games = [];
  var teams = [];
  var _errorMessage;

  var authHeader = await currentUser.authHeaders;
  var accessToken = await authHeader["Authorization"].split(" ")[1];
  var googleLoginUrl = "/auth/google";
  session.post(googleLoginUrl,
      {"accessToken": accessToken, "FCMToken": session.FCMToken}).then((msg) {
    if (msg["success"]) {
      saveSession(session);
      sendAnalyticsEvent(session.analytics, "google_login", {});
      session.post("/account/getAvatar", {}).then((response) {
        if (response["success"]) {
          session.avatar = response["avatar"];
        } else {
          session.avatar =
              "https://avatars.dicebear.com/v2/male/12312412165124.svg";
        }
        var getGamesUrl = "/account/getGames";
        session.get(getGamesUrl).then((response) {
          games = [];
          teams = [];
          if (!response["success"]) {
            if (response["msg"] == "Login first") {
              Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
            } else {
              _errorMessage = response["msg"];
              Scaffold.of(context)
                  .showSnackBar(ErrorSnackBar(_errorMessage, fontSize));
            }
          }
          for (int i = 0; i < response["games"].length; i++) {
            games.add(response["games"][i]["name"]);
            teams.add(response["games"][i]["team"]);
          }
          if (games.length == 0) {
            Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                    builder: (context) => JoinCreateTeamScreen(session)),
                (_) => false);
          }
          if (teams[0] == "Solo") {
            Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                    builder: (context) => StrategiesScreen(
                        games[0], teams[0], session, 1, games, teams, 0)),
                (_) => false);
          }
          var isLeaderUrl = "/team/isLeader";
          session.post(isLeaderUrl, {
            "gameName": games[0],
            "teamName": teams[0],
          }).then((response) {
            Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                    builder: (context) => TeamAvailabilityScreen(
                        games[0],
                        teams[0],
                        session,
                        response["success"] == true ? 1.0 : 0.0,
                        games,
                        teams,
                        0)),
                (_) => false);
          });
        });
      });
    } else {
      Scaffold.of(context).showSnackBar(ErrorSnackBar(msg["msg"], fontSize));
    }
  });
}
