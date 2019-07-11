import 'package:ScrimUp/models/Team.dart';
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

class InvitationScreen extends StatelessWidget {
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
  final double _borderRadius = 10.0;
  BuildContext widgetContext;
  InvitationScreen(String gameName, String teamName, Session session) {
    this._gameName = gameName;
    this._teamName = teamName;
    this.session = session;
    this._request = Request(session);
    this.team = Team(_gameName, teamName);
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

  void getToken() {
    _request.getTokenRequest(team).then((token) {
      print(token);
      _link.token = token;
      print(_link.token);
    }).catchError((err) => handleError(err, widgetContext, _buttonFontSize));
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
        body: Builder(
          builder: (BuildContext context) {
            _link = Provider.of<LinkState>(context);
            return new Center(
              child: Padding(
                padding: EdgeInsets.only(top: _headerPaddingTop),
                child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: _containerPaddingSide / 4),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: _buttonPaddingTop),
                          child: Text(
                            "Invite Link :",
                            style: TextStyle(fontSize: _mediumFontSize),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: _buttonPaddingTop),
                          child: Center(
                            child: Text(
                              _link.link,
                              style: TextStyle(fontSize: _buttonFontSize),
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: _headerPaddingTop),
                            child: RaisedButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(
                                        _borderRadius)),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Share Invite Link",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: _buttonFontSize),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: _containerPaddingSide / 10),
                                          child: Icon(
                                            Icons.share,
                                            color: Colors.white,
                                          )),
                                    ]),
                                onPressed: () {
                                  // TODO: add share link event for firebase when sharing implemented
                                  sendAnalyticsEvent(
                                      session.analytics, "share_link", {});
                                  Share.share(
                                      "Join my team on ScrimUP\n" + _link.link);
                                })),
                        Padding(
                            padding: EdgeInsets.only(top: _buttonPaddingTop),
                            child: RaisedButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(_borderRadius)),
                              textTheme: ButtonTextTheme.primary,
                              child: Center(
                                child: Text(
                                  "Regenerate Link",
                                  style: TextStyle(
                                      fontSize: _buttonFontSize,
                                      color: Colors.white),
                                ),
                              ),
                              onPressed: () {
                                var regenerateTokenUrl =
                                    "/team/regenerateInviteLink";
                                session.post(regenerateTokenUrl, {
                                  "gameName": _gameName,
                                  "teamName": _teamName
                                }).then((response3) {
                                  sendAnalyticsEvent(
                                      session.analytics, "regenerate_link", {});
                                  _link.link = response3["link"];
                                });
                              },
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: _buttonPaddingTop),
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius:
                                    new BorderRadius.circular(_borderRadius)),
                            textTheme: ButtonTextTheme.primary,
                            child: Center(
                              child: Text(
                                "Copy The Link",
                                style: TextStyle(
                                    fontSize: _buttonFontSize,
                                    color: Colors.white),
                              ),
                            ),
                            onPressed: () {
                              // TODO: add share link event for firebase when sharing implemented
                              sendAnalyticsEvent(
                                  session.analytics, "copy_link", {});
                              Clipboard.setData(
                                  new ClipboardData(text: _link.link));
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
                        Padding(
                          padding: EdgeInsets.only(top: _buttonPaddingTop),
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius:
                                    new BorderRadius.circular(_borderRadius)),
                            textTheme: ButtonTextTheme.primary,
                            child: Center(
                              child: Text(
                                "Link not working ? Use token instead",
                                style: TextStyle(
                                    fontSize: _buttonFontSize,
                                    color: Colors.white),
                              ),
                            ),
                            onPressed: () {
                              // TODO: add share link event for firebase when sharing implemented
                              sendAnalyticsEvent(
                                  session.analytics, "get_token", {});
                              getToken();
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
                        Padding(
                            padding:
                                EdgeInsets.only(top: _headerPaddingTop / 1.4),
                            child: Opacity(
                              opacity:
                                  (_link.token != "" && _link.token != null)
                                      ? 1.0
                                      : 0.0,
                              child: Text(
                                "Invite Token :",
                                style: TextStyle(fontSize: _mediumFontSize),
                              ),
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: _buttonPaddingTop),
                            child: Opacity(
                              opacity:
                                  (_link.token != "" && _link.token != null)
                                      ? 1.0
                                      : 0.0,
                              child: Text(_link.token),
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: _buttonPaddingTop),
                          child: Opacity(
                            opacity: _link.token != "" ? 1.0 : 0.0,
                            child: RaisedButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(_borderRadius)),
                              textTheme: ButtonTextTheme.primary,
                              child: Center(
                                child: Text(
                                  "Copy The Token",
                                  style: TextStyle(
                                      fontSize: _buttonFontSize,
                                      color: Colors.white),
                                ),
                              ),
                              onPressed: () {
                                if (_link.token == "") {
                                  return;
                                }
                                // TODO: add share link event for firebase when sharing implemented
                                sendAnalyticsEvent(
                                    session.analytics, "copy_token", {});
                                Clipboard.setData(
                                    new ClipboardData(text: _link.token));
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
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: _buttonPaddingTop),
                          child: Opacity(
                            opacity: _link.token != "" ? 1.0 : 0.0,
                            child: RaisedButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(
                                        _borderRadius)),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Share Invite Token",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: _buttonFontSize),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: _containerPaddingSide / 10),
                                          child: Icon(
                                            Icons.share,
                                            color: Colors.white,
                                          )),
                                    ]),
                                onPressed: () {
                                  if (_link.token == "") {
                                    return;
                                  }
                                  // TODO: add share link event for firebase when sharing implemented
                                  sendAnalyticsEvent(
                                      session.analytics, "share_token", {});
                                  Share.share(
                                      "Join my team on ScrimUP\n Here is the Token: \n" +
                                          _link.token);
                                }),
                          ),
                        ),
                      ],
                    )),
              ),
            );
          },
        ),
      ),
    );
  }
}
