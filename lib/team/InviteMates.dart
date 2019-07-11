import 'package:ScrimUp/availability/TeamAvailability.dart';
import 'package:ScrimUp/game/TokenJoin.dart';
import 'package:ScrimUp/models/Team.dart';
import 'package:ScrimUp/team/invitation.dart';
import 'package:ScrimUp/utils/ErrorHandle.dart';
import 'package:flutter/material.dart';
import "../utils/session.dart";
import '../InitializeApp.dart';
import "../utils/SnackBars.dart";
import 'package:flutter/services.dart';
import '../utils/FirebaseAnalytics.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'InvitationState.dart';
import '../utils/Request.dart';

class InviteMates extends StatelessWidget {
  String _gameName;
  String _teamName;
  Session session;
  String _errorMessage;
  Request _request;
  LinkState _link;
  Team team;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;
  BuildContext widgetContext;
  InviteMates(String gameName, String teamName, Session session) {
    this._gameName = gameName;
    this._teamName = teamName;
    this.session = session;
    this._request = Request(session);
    this.team = Team(gameName, teamName);
    getLink();
  }

  void getLink() {
    _request
        .inviteLinkRequest(team)
        .then((link) => _link.link = link.link)
        .catchError((error) {
      //TODO: handle success messages
      handleError(error, widgetContext, _buttonFontSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Size size = MediaQuery.of(context).size;
    widgetContext = context;
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.030;
    return ChangeNotifierProvider(
      builder: (context) => LinkState(),
      child: new Scaffold(
        appBar: AppBar(
          title: Text("Scrim UP"),
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.orangeAccent,
            label: Text("Skip"),
            icon: Icon(Icons.skip_next),
            onPressed: () {
              var getGamesUrl = "/account/getGames";
              session.get(getGamesUrl).then((response) {
                var games = [];
                var teams = [];
                if (!response["success"]) {
                  if (response["msg"] == "Login first") {
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/", (_) => false);
                  } else {
                    _errorMessage = response["msg"];
                    Scaffold.of(context).showSnackBar(
                        ErrorSnackBar(_errorMessage, _buttonFontSize));
                  }
                }
                for (int i = 0; i < response["games"].length; i++) {
                  games.add(response["games"][i]["name"]);
                  teams.add(response["games"][i]["team"]);
                }

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => new TeamAvailabilityScreen(
                            _gameName,
                            _teamName,
                            session,
                            1.0,
                            games,
                            teams,
                            games.indexOf(_gameName))),
                    (_) => false);
              });
            }),
        body: Builder(builder: (BuildContext context) {
          _link = Provider.of<LinkState>(context);
          return new Center(
              child: Padding(
            padding: EdgeInsets.only(top: _headerPaddingTop),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: _containerPaddingSide / 4),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: _headerPaddingTop),
                    child: Text(
                      "Well Done! You have created a team.\nLets invite your team mates, so you can play together.",
                      style: TextStyle(fontSize: _buttonFontSize),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: _headerPaddingTop),
                    child: RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Invite Your Team Mates",
                              style: TextStyle(
                                  fontSize: _buttonFontSize,
                                  color: Colors.white),
                            ),
                            Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        onPressed: () {
                          // TODO: add share link event for firebase when sharing implemented
                          sendAnalyticsEvent(
                              session.analytics, "share_link", {});
                          Share.share("Join my team on ScrimUP\n" + _link.link);
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: _buttonPaddingTop * 2),
                    child: RaisedButton(
                      textTheme: ButtonTextTheme.primary,
                      child: Center(
                        child: Text(
                          "Link not working ? Use token instead",
                          style: TextStyle(fontSize: _buttonFontSize / 1.3),
                        ),
                      ),
                      onPressed: () {
                        // TODO: add share link event for firebase when sharing implemented
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => new InvitationScreen(
                                    _gameName,
                                    _teamName,
                                    session,
                                  )),
                        );
                        /*ClipboardManager.copyToClipBoard(token).then((result) {
                            final snackBar = SnackBar(
                              content: Text('Copied to Clipboard'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {},
                              ),
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                          });
                          */
                      },
                    ),
                  ),
                ],
              ),
            ),
          ));
        }),
      ),
    );
  }
}
