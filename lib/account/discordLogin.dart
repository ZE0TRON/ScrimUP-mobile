import 'package:ScrimUp/account/login.dart';
import 'package:ScrimUp/game/GameSelect.dart';
import 'package:ScrimUp/game/JoinCreateTeam.dart';
import 'package:flutter/material.dart';
import '../Strategies.dart';
import "../utils/session.dart";
import "package:flutter_webview_plugin/flutter_webview_plugin.dart";
import "../utils/widgets.dart";
import "../availability/TeamAvailability.dart";
import '../utils/FirebaseAnalytics.dart';

class DiscordLoginState extends State<DiscordLogin> {
  Session session;
  var games;
  var teams;
  var isloading = false;
  //var discordAuthUrl = "https://discordapp.com/api/oauth2/authorize?client_id=573777589513224202&redirect_uri=http%3A%2F%2F10.193.41.17%3A3000%2Fauth%2FdiscordCallback&response_type=code&scope=identify%20email%20guilds";
  var discordAuthUrl =
      "https://discordapp.com/api/oauth2/authorize?client_id=573777589513224202&redirect_uri=https%3A%2F%2Fscrimup.app%2Fauth%2FdiscordCallback&response_type=code&scope=identify%20email%20guilds%20connections";
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  DiscordLoginState(this.session);
  @override
  Widget build(BuildContext context) {
    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (!url.contains("discordapp")) {
        if (!isloading) {
          isloading = true;
          flutterWebviewPlugin.hide();
          await Future.delayed(Duration(seconds: 2));
          var accessToken = await flutterWebviewPlugin.evalJavascript(
              "document.getElementById('accessToken').innerHTML");
          print(accessToken);
          if (accessToken[0] == '"') {
            accessToken = accessToken.substring(1, accessToken.length - 1);
          }
          flutterWebviewPlugin.close();
          flutterWebviewPlugin.dispose();
          session.post("/auth/discord", {
            "accessToken": accessToken,
            "FCMToken": session.FCMToken
          }).then((response) {
            if (response["success"]) {
              saveSession(session).then((a) {
                sendAnalyticsEvent(session.analytics, "discord_login", {});
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
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/", (_) => false);
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
                              builder: (context) =>
                                  JoinCreateTeamScreen(session)),
                          (_) => false);
                    }
                    if (teams[0] == "Solo") {
                      Navigator.pushAndRemoveUntil(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => StrategiesScreen(games[0],
                                  teams[0], session, 1, games, teams, 0)),
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
              });
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => LoginScreen(session)),
                  (_) => false);
            }
          });
        }
      }
    });

    // TODO: implement build
    return new WebviewScaffold(
      url: discordAuthUrl,
      appBar: new AppBar(
        title: const Text('Discord Authentication'),
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
        child: Center(
          child: Spinner(),
        ),
      ),
    );
  }
}

class DiscordLogin extends StatefulWidget {
  Session session;
  DiscordLogin(this.session);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DiscordLoginState(session);
  }
}
