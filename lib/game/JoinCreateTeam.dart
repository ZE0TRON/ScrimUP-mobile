import 'package:ScrimUp/Strategies.dart';
import 'package:ScrimUp/account/login.dart';
import 'package:ScrimUp/game/TokenJoin.dart';
import 'package:ScrimUp/models/Game.dart';
import 'package:ScrimUp/team/InviteMates.dart';
import 'package:ScrimUp/utils/DynamicLinks.dart';
import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:ScrimUp/utils/widgets.dart';
import "package:flutter/material.dart";
import '../utils/session.dart';
import '../utils/SnackBars.dart';
import '../availability/TeamAvailability.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/FirebaseAnalytics.dart';

class _JoinCreateTeamState extends State<JoinCreateTeamScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Session session;
  String game = "No game selected";
  String _errorMessage;
  BuildContext _tempContext;
  var teams;
  var games;
  var selectGames = [];
  bool isGamesLoaded = false;
  bool isGameSelected = false;
  final TextEditingController searchController = TextEditingController();
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;
  LocalDB db;
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController teamController = TextEditingController();
  final TextEditingController nickController = TextEditingController();
  var createTab;
  TabController _tabController;
  _JoinCreateTeamState(this.session);
  _JoinCreateTeamState.local(LocalDB db) {
    this.db = db;
  }
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Team'),
    Tab(text: 'Individual'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    retrieveDynamicLink().then((s) {
      if (s != null) {
        print("Token is " + s.queryParams["token"]);
        String token = s.queryParams["token"];
        if (token.length > 0) {
          joinTeamWithToken(
              token, _tempContext, session, _buttonFontSize, _buttonPaddingTop);
        }
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("I am resuming");
      retrieveDynamicLink().then((s) {
        if (s != null) {
          print("Token is " + s.queryParams["token"]);
          String token = s.queryParams["token"];
          if (token.length > 0) {
            joinTeamWithToken(token, _tempContext, session, _buttonFontSize,
                _buttonPaddingTop);
          }
        }
      });
    }
  }

  void loadGames(response) {
    setState(() {
      selectGames = [];
      for (int i = 0; i < response["games"].length; i++) {
        selectGames.add(response["games"][i].toString());
      }
      isGamesLoaded = true;
    });
  }

  void _getGames() async {
    if (session == null) {
      print("I am here");
      var gameList = await db.get("allowedGames");
      setState(() {
        selectGames = gameList;
        isGamesLoaded = true;
      });
    } else {
      var allowedGamesUrl = "/account/getAllowedGames";
      session.get(allowedGamesUrl).then((response) {
        loadGames(response);
      });
    }
  }

  @override
  void dispose() {
    nickController.dispose();
    tokenController.dispose();
    teamController.dispose();
    nickNameController.dispose();
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _chooseGameBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              border: BorderDirectional(
                  top: BorderSide(color: Colors.orangeAccent)),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: selectGames.length,
              itemBuilder: (BuildContext context, int index) {
                String gameName = selectGames[index]
                    .replaceAll(" ", "\ ")
                    .replaceAll(":", "_");
                var gameLogo;
                if (gameName == "Business") {
                  gameLogo = Padding(
                      padding:
                          EdgeInsets.only(right: _containerPaddingSide * 0.7),
                      child: Icon(FontAwesomeIcons.businessTime));
                } else if (gameName == "Other") {
                  gameLogo = Padding(
                      padding:
                          EdgeInsets.only(right: _containerPaddingSide * 0.7),
                      child: Icon(FontAwesomeIcons.question));
                } else {
                  gameLogo = Image.asset(
                    'assets/games/${gameName}_logo.png',
                    height: 60,
                    width: 60,
                  );
                }
                return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: _containerPaddingSide,
                    ),
                    enabled: true,
                    title: Text(
                      '${selectGames[index]}',
                      style: TextStyle(fontSize: _buttonFontSize * 1.5),
                    ),
                    onTap: () {
                      setState(() {
                        game = selectGames[index];
                        isGameSelected = true;
                      });
                      Navigator.pop(context);
                    });
              },
            ),
          );
        });
  }

  Widget teamCreate(gameLogo, context) {
    if (session != null) {
      return ListView(children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _containerPaddingSide / 2,
            vertical: _buttonPaddingTop * 2,
          ),
          child: RaisedButton(
            onPressed: () {
              _chooseGameBottomSheet(context);
            },
            child: Text(
              "Choose a game",
              style: TextStyle(
                  fontSize: _buttonFontSize * 1.25, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: _headerPaddingTop / 4),
          child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                  vertical: _buttonPaddingTop * 2.5,
                  horizontal: _containerPaddingSide / 2),
              enabled: true,
              leading: gameLogo,
              title: Text(
                game,
                style: TextStyle(fontSize: _buttonFontSize * 1.5),
              ),
              onTap: () {}),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: _containerPaddingSide / 2,
              right: _containerPaddingSide / 2,
              top: _buttonPaddingTop * 3),
          child: TextField(
            decoration: new InputDecoration(
              labelText: "Team Name",
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(5),
                borderSide: new BorderSide(),
              ),
            ),
            controller: teamController,
            maxLines: 1,
            maxLength: 20,
            style: TextStyle(fontSize: _buttonFontSize),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: _containerPaddingSide / 2,
              right: _containerPaddingSide / 2,
              top: _buttonPaddingTop * 3),
          child: TextField(
            decoration: new InputDecoration(
              labelText: "Nickname",
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(5),
                borderSide: new BorderSide(),
              ),
            ),
            controller: nickController,
            maxLines: 1,
            maxLength: 20,
            style: TextStyle(fontSize: _buttonFontSize),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: _buttonPaddingTop),
          child: FlatButton(
            child: Center(
              child: Text(
                "Create",
                style: TextStyle(
                    fontSize: _buttonFontSize * 1.3,
                    color: Colors.orangeAccent),
              ),
            ),
            onPressed: () {
              // Make a post request
              if (!isGameSelected) {
                Scaffold.of(context).showSnackBar(
                    ErrorSnackBar("You must select a game", _mediumFontSize));
              } else {
                var createTeamUrl = "/team/createTeam";
                session.post(createTeamUrl, {
                  "gameName": game,
                  "teamName": teamController.text,
                  "nickName": nickController.text,
                  // TODO: add server side of this locale
                }).then((response) {
                  if (response["success"]) {
                    //Navigator.popUntil(context, ModalRoute.withName("/teams"));
                    //navigator
                    sendAnalyticsEvent(session.analytics, "create_team",
                        {"team_name": teamController.text});

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new InviteMates(
                                game, teamController.text, session)),
                        (_) => false);
                  } else {
                    Scaffold.of(context).showSnackBar(
                        ErrorSnackBar(response["msg"], _buttonFontSize));
                  }
                });
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: _buttonPaddingTop * 3),
          child: FlatButton(
              child: Center(
                child: Text(
                  "Have token instead ?",
                  style: TextStyle(
                      fontSize: _buttonFontSize / 1.3, color: Colors.white),
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => new TokenScreen(session)));
              }),
        ),
      ]);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: _headerPaddingTop),
            child: Text(
              "You need to be logged in for creating team.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: _mediumFontSize),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: _containerPaddingSide / 2),
            child: RaisedButton(
              child: Text(
                "Login/Register",
                style: TextStyle(
                    fontSize: _mediumFontSize / 1.25, color: Colors.white),
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, "/", (_) {
                  return false;
                });
              },
            ),
          )
        ],
      );
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Game"),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        if (!isGamesLoaded) {
          _getGames();
          return Center(child: Spinner());
        }
        _tempContext = context;
        String gameName = game.replaceAll(" ", "\ ").replaceAll(":", "_");
        var gameLogo;
        if (gameName == "Business") {
          gameLogo = Icon(FontAwesomeIcons.businessTime);
        } else if (gameName == "Other" || gameName == "No game selected") {
          gameLogo = Icon(FontAwesomeIcons.question);
        } else {
          gameLogo = Image.asset(
            'assets/games/${gameName}_logo.png',
            height: 60,
            width: 60,
          );
        }
        return TabBarView(controller: _tabController, children: <Widget>[
          // CREATE TEAM
          teamCreate(gameLogo, context),
          ListView(children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _containerPaddingSide / 2,
                vertical: _buttonPaddingTop * 2,
              ),
              child: RaisedButton(
                onPressed: () {
                  _chooseGameBottomSheet(context);
                },
                child: Text(
                  "Choose a game",
                  style: TextStyle(
                      fontSize: _buttonFontSize * 1.25, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: _headerPaddingTop / 4),
              child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      vertical: _buttonPaddingTop * 2.5,
                      horizontal: _containerPaddingSide / 2),
                  enabled: true,
                  leading: gameLogo,
                  title: Text(
                    game,
                    style: TextStyle(fontSize: _buttonFontSize * 1.5),
                  ),
                  onTap: () {}),
            ),
            // Padding(
            //     padding: EdgeInsets.only(top: _buttonPaddingTop * 3),
            //     child: TextField(
            //       decoration: new InputDecoration(
            //         labelText: "Token",
            //         border: new OutlineInputBorder(
            //           borderRadius: new BorderRadius.circular(5),
            //           borderSide: new BorderSide(),
            //         ),
            //       ),
            //       controller: tokenController,
            //       maxLength: 100,
            //     )),
            Padding(
                padding: EdgeInsets.only(
                    top: _buttonPaddingTop * 3,
                    left: _containerPaddingSide / 2,
                    right: _containerPaddingSide / 2),
                child: TextField(
                  decoration: new InputDecoration(
                    labelText: "Nickname",
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(5),
                      borderSide: new BorderSide(),
                    ),
                  ),
                  controller: nickNameController,
                  maxLength: 100,
                )),
            Padding(
              padding: EdgeInsets.only(top: _buttonPaddingTop),
              child: FlatButton(
                child: Center(
                  child: Text(
                    "Create",
                    style: TextStyle(
                        fontSize: _buttonFontSize * 1.3,
                        color: Colors.orangeAccent),
                  ),
                ),
                onPressed: () {
                  if (nickNameController.text.length > 0) {
                    if (!isGameSelected) {
                      Scaffold.of(context).showSnackBar(ErrorSnackBar(
                          "You must select a game", _mediumFontSize));
                    } else {
                      if (session == null) {
                        db.connectDB().then((_) {
                          Game gameObj = Game(game, nickNameController.text);
                          db.addGame(gameObj).then((_) {
                            db.getGames().then((gameList) {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          StrategiesScreen.local(
                                              gameObj, db, gameList)));
                            });
                          });
                        });
                      } else {
                        var createIndividualUrl = "/account/addGame";
                        session.post(createIndividualUrl, {
                          "game": game,
                          "nick": nickController.text,
                        }).then((response) {
                          if (response["success"]) {
                            //Navigator.popUntil(context, ModalRoute.withName("/teams"));
                            //navigator
                            // sendAnalyticsEvent(session.analytics, "create_team",
                            //     {"team_name": teamController.text});
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
                                      ErrorSnackBar(
                                          _errorMessage, _buttonFontSize));
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
                                      builder: (context) => StrategiesScreen(
                                          game,
                                          "Solo",
                                          session,
                                          1.0,
                                          games,
                                          teams,
                                          games.indexOf(game))),
                                  (_) => false);
                            });
                            print("Succesfully created solo team");
                          } else {
                            Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                response["msg"], _buttonFontSize));
                          }
                        });
                      }
                    }
                  }
                },
              ),
            ),
          ]),
        ]);
      }),
    );
  }
}

class JoinCreateTeamScreen extends StatefulWidget {
  Session session;
  LocalDB db;
  bool isLocal = false;
  JoinCreateTeamScreen(this.session);
  JoinCreateTeamScreen.local(LocalDB db) {
    this.db = db;
    isLocal = true;
  }
  @override
  _JoinCreateTeamState createState() {
    if (isLocal) {
      return _JoinCreateTeamState.local(this.db);
    } else {
      return _JoinCreateTeamState(session);
    }
  }
}
