import 'package:ScrimUp/game/JoinCreateTeam.dart';
import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:flutter/material.dart';
import 'package:ScrimUp/utils/session.dart';
import 'package:ScrimUp/account/signup.dart';
import 'package:ScrimUp/account/discordLogin.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Strategies.dart';
import '../utils/googleLogin.dart';

class Launch extends StatefulWidget {
  Session session;

  Launch(Session session) {
    this.session = session;
  }
  @override
  _LaunchState createState() => _LaunchState();
}

class _LaunchState extends State<Launch> {
  GoogleSignInAccount _currentUser;
  static LocalDB localDB = LocalDB();
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  double borderCircleRadius = 5;

  double _buttonPaddingTop;

  double _formPaddingTop;

  double _containerPaddingSide;

  double _headerPaddingTop;

  double _headerFontSize;

  double _fontSize;
  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        print(_currentUser.email);
        print(_currentUser.id);
        _currentUser.authHeaders.then((header) {
          print(header);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.020;
    _formPaddingTop = size.height * 0.011;
    _containerPaddingSide = size.width * 0.10;
    _headerPaddingTop = size.height * 0.071;
    _headerFontSize = size.width * 0.096;
    _fontSize = size.width * 0.057;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("Scrim UP"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: _headerPaddingTop / 1.5,
            horizontal: _containerPaddingSide),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
              0.01,
              0.3,
              1.0
            ],
                colors: <Color>[
              Color.fromRGBO(255, 200, 70, 0.01),
              Color.fromRGBO(255, 200, 70, 0.2),
              Color.fromRGBO(255, 200, 70, 0.8)
            ])),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    top: _headerPaddingTop * 1.5,
                    bottom: _headerPaddingTop * 1.5),
                child: Opacity(
                  opacity: 0.3,
                  child: Image(
                    image: AssetImage('assets/logo/logo_with_title.png'),
                    height: size.height * 0.35,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: _buttonPaddingTop),
              child: FlatButton(
                splashColor: Colors.transparent,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Create an Account",
                    style: TextStyle(
                        fontSize: _fontSize * 1.2, fontWeight: FontWeight.w400),
                  ),
                ),
                onPressed: () {
                  widget.session.setFCMToken(widget.session).then((onValue) => {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(
                                  widget.session, widget.session.FCMToken),
                            ), (_) {
                          return false;
                        })
                      });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: _buttonPaddingTop),
              child: RaisedButton(
                padding: EdgeInsets.only(
                  left: _containerPaddingSide / 2,
                  right: _containerPaddingSide / 2,
                ),
                color: Color.fromRGBO(112, 145, 255, 1),
                onPressed: () {
                  widget.session.setFCMToken(widget.session).then((onValue) =>
                      Navigator.pushAndRemoveUntil(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  DiscordLogin(widget.session)),
                          (_) => false));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Image(
                      height: MediaQuery.of(context).size.height * 0.040,
                      image: AssetImage('assets/logo/Discord-Logo-White.png'),
                    ),
                    Text("Continue with Discord",
                        style: TextStyle(fontSize: _fontSize))
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: _buttonPaddingTop),
              child: RaisedButton(
                  padding: EdgeInsets.only(
                    left: _containerPaddingSide / 2,
                    right: _containerPaddingSide / 2,
                  ),
                  color: Color.fromRGBO(255, 255, 255, 1),
                  onPressed: () {
                    widget.session
                        .setFCMToken(widget.session)
                        .then((onValue) async {
                      try {
                        await _googleSignIn.signIn();
                        googleLogin(
                            context, widget.session, _currentUser, _fontSize);
                      } catch (error) {
                        print(error);
                      }
                    });
                  },
                  child: Text("Continue with Google",
                      style: TextStyle(fontSize: _fontSize))),
            ),
            Padding(
              padding: EdgeInsets.only(top: _buttonPaddingTop),
              child: FlatButton(
                  padding: EdgeInsets.only(
                    left: _containerPaddingSide / 2,
                    right: _containerPaddingSide / 2,
                  ),
                  onPressed: () async {
                    widget.session.notRegistered = true;
                    await localDB.connectDB();
                    var gameList = await localDB.getGames();

                    if (gameList.length == 0) {
                      if (await localDB.get("allowedGames") == null) {
                        var allowedGamesUrl = "/account/getAllowedGames";
                        var response =
                            await widget.session.get(allowedGamesUrl);

                        var allowedGames = List<String>();
                        for (int i = 0; i < response["games"].length; i++) {
                          allowedGames.add(response["games"][i].toString());
                        }
                        await localDB.put("allowedGames", allowedGames);
                      }
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                JoinCreateTeamScreen.local(localDB),
                          ),
                          (_) => false);
                    } else {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StrategiesScreen.local(
                                gameList[0], localDB, gameList),
                          ),
                          (_) => false);
                    }
                  },
                  child: Text("Continue without Register",
                      style: TextStyle(fontSize: _fontSize))),
            )
          ],
        ),
      ),
    );
  }
}
