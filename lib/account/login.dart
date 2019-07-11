import 'package:ScrimUp/Strategies.dart';
import 'package:ScrimUp/game/JoinCreateTeam.dart';
import 'package:ScrimUp/dbDemo.dart';
import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:flutter/material.dart';
import "../utils/session.dart";
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/SnackBars.dart';
import "./ForgotPassword.dart";
import "./verification.dart";
import './signup.dart';
import '../game/GameSelect.dart';
import '../availability/TeamAvailability.dart';
import './discordLogin.dart';
import '../utils/FirebaseAnalytics.dart';
import '../utils/googleLogin.dart';

class _LoginScreenState extends State<LoginScreen> {
  //414
  //896
  GoogleSignInAccount _currentUser;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  static LocalDB localDB = LocalDB();
  var FCMToken;
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  Session session;
  String logsign;
  String loginButtonText;
  String signupButtonText;
  bool logsignb;
  double borderCircleRadius = 5;
  double emailOkey = 0;
  bool isEmailEdited = false;
  double isError = 0.0;
  String _errorMessage = "";
  double _buttonPaddingTop;
  var games;
  var teams;
  double _formPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  double _fontSize;
  ButtonTextTheme loginTheme;
  Color loginColor;
  Color signupColor;
  ButtonTextTheme signupTheme;
  _LoginScreenState(this.session);

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
  void dispose() {
    mailController.dispose();
    passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void login(context) {
    var loginUrl = "/account/login";
    session.post(loginUrl, {
      "email": mailController.text,
      "password": passwordController.text,
      "FCMToken": session.FCMToken
    }).then((response) {
      if (response["success"]) {
        session.notRegistered = false;
        saveSession(session);
        sendAnalyticsEvent(session.analytics, "email_login", {});
        session.post("/account/getAvatar", {}).then((response) {
          if (response["success"]) {
            session.avatar = response["avatar"];
          } else {
            session.avatar =
                "https://avatars.dicebear.com/v2/male/12312412165124.svg";
          }
          if (_errorMessage == "Not verified") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationScreen(session),
              ),
            );
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
                    .showSnackBar(ErrorSnackBar(_errorMessage, _fontSize));
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
            if (teams[0] == "Solo" || teams[0] == null) {
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
        sendAnalyticsEvent(session.analytics, "incorrect_login", {});
        _errorMessage = response["msg"];
        Scaffold.of(context)
            .showSnackBar(ErrorSnackBar(_errorMessage, _fontSize));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.020;
    _formPaddingTop = size.height * 0.011;
    _containerPaddingSide = size.width * 0.10;
    _headerPaddingTop = size.height * 0.051;
    _headerFontSize = size.width * 0.096;
    _fontSize = size.width * 0.057;
    return new GestureDetector(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Scrim UP"),
          ),
          body: Center(
              child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: _containerPaddingSide),
                  child: Builder(builder: (BuildContext context) {
                    return new ListView(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: _headerPaddingTop),
                            child: Image(
                              image:
                                  AssetImage('assets/logo/logo_with_title.png'),
                              height: size.height * 0.20,
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: _formPaddingTop * 2),
                            child: Form(
                              child: Column(children: <Widget>[
                                TextFormField(
                                  focusNode: _emailFocus,
                                  cursorColor: Colors.orangeAccent,
                                  decoration: new InputDecoration(
                                    labelText: "Email",
                                    prefixIcon: Icon(Icons.email),
                                    border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(
                                          borderCircleRadius),
                                      borderSide: new BorderSide(),
                                    ),
                                    //fillColor: Colors.green
                                  ),
                                  controller: mailController,
                                  maxLines: 1,
                                  onFieldSubmitted: (term) {
                                    _emailFocus.unfocus();

                                    FocusScope.of(context)
                                        .requestFocus(_passwordFocus);
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(fontSize: _fontSize / 1.5),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: _buttonPaddingTop),
                                  child: TextFormField(
                                    focusNode: _passwordFocus,
                                    decoration: new InputDecoration(
                                      labelText: "Password",
                                      prefixIcon: Icon(Icons.lock),
                                      border: new OutlineInputBorder(
                                        borderRadius: new BorderRadius.circular(
                                            borderCircleRadius),
                                        borderSide: new BorderSide(),
                                      ),

                                      counter: FlatButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ForgotPasswordScreen(
                                                        session),
                                              ));
                                        },
                                        child: Text("Forgot Password"),
                                        textColor: Colors.orange,
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (text) {
                                      if (mailController.text.length > 0 &&
                                          passwordController.text.length > 0) {
                                        login(context);
                                      } else {
                                        Scaffold.of(context).showSnackBar(
                                            ErrorSnackBar(
                                                "Email can't be empty",
                                                _fontSize));
                                      }
                                    },
                                    controller: passwordController,
                                    maxLines: 1,
                                    obscureText: true,
                                    style: TextStyle(fontSize: _fontSize / 1.5),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    children: <Widget>[
                                      FittedBox(
                                        fit: BoxFit.cover,
                                        child: FlatButton(
                                          child: Text(
                                            "Login",
                                            style: TextStyle(
                                                fontSize: _fontSize,
                                                color: Colors.orangeAccent),
                                          ),
                                          onPressed: () {
                                            if (mailController.text.length >
                                                    0 &&
                                                passwordController.text.length >
                                                    0) {
                                              login(context);
                                            } else {
                                              Scaffold.of(context).showSnackBar(
                                                  ErrorSnackBar(
                                                      "Email can't be empty",
                                                      _fontSize));
                                            }
                                          },
                                        ),
                                      ),
                                      FlatButton(
                                          child: Text(
                                            "Create an Account",
                                            style: TextStyle(
                                                fontSize: _fontSize,
                                                color: Colors.white),
                                          ),
                                          onPressed: () {
                                            // print("I am here");
                                            // print(logsignb);
                                            // in login page
                                            // print("also here");
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignupScreen(session,
                                                          session.FCMToken),
                                                ), (_) {
                                              return false;
                                            });
                                          }),
                                      RaisedButton(
                                        padding: EdgeInsets.only(
                                          left: _containerPaddingSide / 2,
                                          right: _containerPaddingSide / 2,
                                        ),
                                        color: Color.fromRGBO(112, 145, 255, 1),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DiscordLogin(session),
                                              ));
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Image(
                                              height: size.height * 0.040,
                                              image: AssetImage(
                                                  'assets/logo/Discord-Logo-White.png'),
                                            ),
                                            Text("Continue with Discord",
                                                style: TextStyle(
                                                    fontSize: _fontSize))
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: _buttonPaddingTop),
                                        child: RaisedButton(
                                            padding: EdgeInsets.only(
                                              left: _containerPaddingSide / 2,
                                              right: _containerPaddingSide / 2,
                                            ),
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1),
                                            onPressed: () {
                                              session
                                                  .setFCMToken(session)
                                                  .then((onValue) async {
                                                try {
                                                  await _googleSignIn.signIn();
                                                  googleLogin(context, session,
                                                      _currentUser, _fontSize);
                                                } catch (error) {
                                                  print(error);
                                                }
                                              });
                                            },
                                            child: Text("Continue with Google",
                                                style: TextStyle(
                                                    fontSize: _fontSize))),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: _buttonPaddingTop),
                                        child: FlatButton(
                                            padding: EdgeInsets.only(
                                              left: _containerPaddingSide / 2,
                                              right: _containerPaddingSide / 2,
                                            ),
                                            onPressed: () async {
                                              widget.session.notRegistered =
                                                  true;
                                              await localDB.connectDB();
                                              var gameList =
                                                  await localDB.getGames();

                                              if (gameList.length == 0) {
                                                if (await localDB
                                                        .get("allowedGames") ==
                                                    null) {
                                                  var allowedGamesUrl =
                                                      "/account/getAllowedGames";
                                                  var response = await session
                                                      .get(allowedGamesUrl);

                                                  var allowedGames =
                                                      List<String>();
                                                  for (int i = 0;
                                                      i <
                                                          response["games"]
                                                              .length;
                                                      i++) {
                                                    allowedGames.add(
                                                        response["games"][i]
                                                            .toString());
                                                  }
                                                  await localDB.put(
                                                      "allowedGames",
                                                      allowedGames);
                                                }
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          JoinCreateTeamScreen
                                                              .local(localDB),
                                                    ),
                                                    (_) => false);
                                              } else {
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          StrategiesScreen
                                                              .local(
                                                                  gameList[0],
                                                                  localDB,
                                                                  gameList),
                                                    ),
                                                    (_) => false);
                                              }
                                            },
                                            child: Text(
                                                "Continue without Register",
                                                style: TextStyle(
                                                    fontSize: _fontSize))),
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                            ))
                      ],
                    );
                  })))),
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }
  /* if(index==2){
                  return
              Padding(
                child: Text(
                  "Email",
                  style: TextStyle(fontSize: _fontSize),
                ),
                padding: EdgeInsets.only(top: _headerPaddingTop),
              );
               }*/

}

class LoginScreen extends StatefulWidget {
  Session session;
  LoginScreen(this.session);
  _LoginScreenState createState() => _LoginScreenState(session);
}
