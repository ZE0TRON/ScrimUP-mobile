import 'package:ScrimUp/utils/AvailabilityParse.dart';
import 'package:ScrimUp/utils/DynamicLinks.dart';
import 'package:ScrimUp/utils/ErrorHandle.dart';
import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:ScrimUp/utils/Navigation.dart';
import 'package:ScrimUp/utils/Request.dart';
import 'package:ScrimUp/utils/SnackBars.dart';
import 'package:ScrimUp/utils/session.dart';
import 'package:ScrimUp/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'models/Game.dart';
import 'models/Strategy.dart';

class _StrategiesState extends State<StrategiesScreen>
    with WidgetsBindingObserver {
  String _gameName;
  String _teamName;
  Session session;
  List<Game> gameList;
  Request _request;
  DayTime dayTime;
  String _errorMessage;
  LocalDB db;
  BuildContext widgetContext;
  bool isLocal = false;
  Game game;
  final FocusNode _titleFocus = FocusNode();
  double isLeader;
  int selectedGameIndex;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;
  bool isLoaded = false;
  bool empty = true;
  var lastSize = 0;
  bool isSolo = false;
  var teams;
  var games;

  String avatar;
  List<Strategy> strategies;
  //Lists for items from server/local
  var winCounter;
  var gameCounter;

  final TextEditingController strategyTitleController = TextEditingController();
  final TextEditingController strategyDescriptionController =
      TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _StrategiesState(this._gameName, this._teamName, this.session, this.isLeader,
      this.games, this.teams, this.selectedGameIndex);
  _StrategiesState.local(Game game, LocalDB db, List<Game> gameList) {
    for (int i = 0; i < gameList.length; i++) {
      if (gameList[i].game == game.game) {
        this.selectedGameIndex = i;
      }
    }

    this.game = game;
    this.db = db;
    this.isLocal = true;
    this.gameList = gameList;
  }
  _getAvatar() async {
    if (isLocal) {
      var avatarString = await db.get("avatar");
      setState(() {
        if (avatarString == null) {
          avatar = randomInt().toString();
          db.put("avatar", avatar);
        } else {
          avatar = avatarString;
        }
      });
    }
  }

  @override
  void initState() {
    print("Initiating state");
    if (!isLocal) {
      if (_teamName == "Solo" || _teamName == null) {
        isSolo = true;
      }
    }
    _getAvatar();
    strategies = List<Strategy>();
    _request = Request(session);
    _getStrategies();
    super.initState();
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
            joinTeamWithToken(token, widgetContext, session, _buttonFontSize,
                _buttonPaddingTop);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    strategyTitleController.dispose();
    strategyDescriptionController.dispose();
    super.dispose();
  }

  void _createLocalStrategy(BuildContext context) async {
    Strategy strategy = Strategy(
        strategyTitleController.text, strategyDescriptionController.text);
    game.strategies.add(strategy);
    await db.updateGame(game);
    Navigator.pop(context);
  }

  void _createStrategy(BuildContext context) {
    Strategy strategy = Strategy(
        strategyTitleController.text, strategyDescriptionController.text);
    _request.createStrategyRequest(strategy, _gameName).then((onValue) {
      Navigator.pop(context);
      // }).catchError((onError) {
      //   print(onError);
      //   handleError(onError, context, _buttonFontSize);
      // })
    });
  }

  void _getStrategies() {
    if (isLocal) {
      setState(() {
        strategies = game.strategies;
      });
    } else {
      _request.getStrategiesRequest(_gameName).then((strategyList) {
        setState(() {
          strategies = strategyList;
        });
      }).catchError((err) {
        handleError(err, context, _buttonFontSize);
      });
    }
  }

  void _strategyStatusChange(BuildContext context, bool isWin, index) {
    _request
        .strategyStatusChangeRequest(strategies[index], _gameName, isWin)
        .then((_) {
      _getStrategies();
    }).catchError((err) {
      handleError(err, context, _buttonFontSize);
    });
  }

  _winLocalPressed(int index) {
    setState(() {
      game.strategies[index].win();
    });
    game.updateStrategy(game.strategies[index]);
    db.updateGame(game);
  }

  _loseLocalPressed(int index) {
    setState(() {
      game.strategies[index].lose();
    });

    game.updateStrategy(game.strategies[index]);
    db.updateGame(game);
  }

  _localDeleteStrategy(int index) {
    setState(() {
      game.deleteStrategy(game.strategies[index]);
    });
    db.updateGame(game);
  }

  Widget _addStrategyScreen() {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Scrim UP"),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: ListView(children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: _headerPaddingTop / 2,
                  ),
                  child: Text(
                    "Create Strategy",
                    style: TextStyle(
                        fontSize: _headerFontSize, fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: _headerPaddingTop / 2),
                  child: TextFormField(
                    onFieldSubmitted: (text) {
                      if (text.length == 0) {
                        return "Title can't be empty!";
                      }
                    },
                    decoration: new InputDecoration(
                      labelText: "Title",
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),

                      //fillColor: Colors.green
                    ),
                    focusNode: _titleFocus,
                    controller: strategyTitleController,
                    maxLines: 1,
                    style: TextStyle(fontSize: _buttonFontSize / 1.2),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: _headerPaddingTop / 4),
                  child: TextFormField(
                    decoration: new InputDecoration(
                      labelText: "Description",
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      //fillColor: Colors.green
                    ),
                    controller: strategyDescriptionController,
                    maxLines: 1,
                    style: TextStyle(fontSize: _buttonFontSize / 1.2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: _containerPaddingSide / 4,
                      right: _containerPaddingSide / 4,
                      top: _headerPaddingTop / 2,
                      bottom: _headerPaddingTop / 2),
                  child: RaisedButton(
                    padding:
                        EdgeInsets.symmetric(vertical: _buttonPaddingTop * 1.5),
                    child: Text(
                      "Create Strategy",
                      style: TextStyle(
                          fontSize: _buttonFontSize * 1.5, color: Colors.white),
                    ),
                    onPressed: () {
                      if (strategyTitleController.text.length == 0) {
                        _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(
                            "Title can't be empty.",
                            MediaQuery.of(context).size.height * 0.020 * 2));
                      } else {
                        if (isLocal) {
                          _createLocalStrategy(context);
                        } else {
                          _createStrategy(context);
                        }
                        strategyDescriptionController.clear();
                        strategyTitleController.clear();
                      }
                    },
                  ),
                ),
              ]))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    BottomNavigationBar bottomNavigation;
    if (isLocal) {
      bottomNavigation =
          localBottomNavigationBar(0, context, gameList, selectedGameIndex, db);
    } else if (isSolo) {
      bottomNavigation = soloNavigationBar(0, context, teams, games, _teamName,
          _gameName, session, isLeader, selectedGameIndex);
    } else {
      bottomNavigation = bottomNavigationBar(3, context, teams, games,
          _teamName, _gameName, session, isLeader, selectedGameIndex);
    }
    var leftDrawer;
    if (isLocal) {
      if (avatar == null) {
        avatar = 123123.toString();
      }
      leftDrawer = soloDrawer(gameList, context, selectedGameIndex, db, avatar);
    } else {
      leftDrawer = drawer(teams, games, context, session, selectedGameIndex);
    }
    widgetContext = context;
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.028;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.025;
    final double _cardBorderRadius = 17.0;
    return new Scaffold(
        drawer: leftDrawer,
        bottomNavigationBar: bottomNavigation,
        appBar: AppBar(
          title: Text("Scrim UP"),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return _addStrategyScreen();
                    },
                    fullscreenDialog: true))
                .then((_) {
              _getStrategies();
            });
          },
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: _headerPaddingTop, bottom: _headerPaddingTop / 2),
              child: Text(
                "Strategies",
                style: TextStyle(
                    fontSize: _headerFontSize, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: _containerPaddingSide / 3.5,
                ),
                itemCount: strategies.length,
                itemBuilder: (BuildContext context, int index) {
                  int winCount = strategies[index].winCount;
                  int total =
                      strategies[index].winCount + strategies[index].loseCount;
                  int percentage;
                  if (total != 0) {
                    percentage = (winCount / total * 100).floor();
                  } else {
                    percentage = 0;
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: _headerPaddingTop / 4),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(_cardBorderRadius))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _headerPaddingTop / 2,
                            horizontal: _containerPaddingSide / 2),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: _headerPaddingTop / 1.5),
                              child: Text(
                                strategies[index].title,
                                style: TextStyle(
                                    fontSize: _mediumFontSize * 1.5,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(strategies[index].detail,
                                style: TextStyle(
                                    fontSize: _mediumFontSize / 1.25)),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: _headerPaddingTop),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "Win Rate " +
                                            winCount.toString() +
                                            "/" +
                                            total.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: _mediumFontSize / 1.4),
                                      ),
                                    ),
                                    Text(
                                      "%" + percentage.toString(),
                                      style: TextStyle(
                                          fontSize: _mediumFontSize / 1.4,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                RaisedButton(
                                  padding: EdgeInsets.symmetric(
                                      vertical: _buttonPaddingTop * 2,
                                      horizontal: _containerPaddingSide / 1.5),
                                  child: Text(
                                    "Win",
                                    style: TextStyle(
                                        fontSize: _mediumFontSize / 1.25),
                                  ),
                                  color: Colors.green[500],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              _cardBorderRadius * 2))),
                                  onPressed: () {
                                    if (isLocal) {
                                      _winLocalPressed(index);
                                    } else {
                                      _strategyStatusChange(
                                          context, true, index);
                                    }
                                  },
                                ),
                                RaisedButton(
                                  padding: EdgeInsets.symmetric(
                                      vertical: _buttonPaddingTop * 2,
                                      horizontal: _containerPaddingSide / 1.5),
                                  child: Text(
                                    "Lose",
                                    style: TextStyle(
                                        fontSize: _mediumFontSize / 1.25),
                                  ),
                                  color: Colors.red[700],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              _cardBorderRadius * 2))),
                                  onPressed: () {
                                    if (isLocal) {
                                      _loseLocalPressed(index);
                                    } else {
                                      _strategyStatusChange(
                                          context, false, index);
                                    }
                                  },
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: _headerPaddingTop / 4),
                              child: Visibility(
                                visible: isLocal || isLeader == 1 || isSolo,
                                child: RaisedButton(
                                  padding: EdgeInsets.symmetric(
                                      vertical: _buttonPaddingTop * 2,
                                      horizontal: _containerPaddingSide),
                                  child: Text(
                                    "Delete Strategy",
                                    style: TextStyle(
                                        fontSize: _mediumFontSize / 1.25),
                                  ),
                                  color: Colors.red[900],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              _cardBorderRadius * 2))),
                                  onPressed: () {
                                    //TODO: add are you sure dialog
                                    if (isLocal) {
                                      _localDeleteStrategy(index);
                                    } else {
                                      _request
                                          .deleteStrategyRequest(
                                              strategies[index], _gameName)
                                          .then((_) {
                                        _getStrategies();
                                      }).catchError((err) {
                                        handleError(
                                            err, context, _buttonFontSize);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}

class StrategiesScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  var games;
  var teams;
  int selectedGameIndex;
  Game _game;
  List<Game> _gameList;
  LocalDB _db;
  Session session;
  double isLeader;
  bool isLocal = false;
  StrategiesScreen(
      this._gameName,
      this._teamName,
      this.session,
      this.isLeader,
      this.games,
      this.teams,
      this.selectedGameIndex); // TODO: change all constructors to look like this if possible
  StrategiesScreen.local(Game game, LocalDB db, List<Game> gameList) {
    this._game = game;
    this._db = db;
    this._gameList = gameList;
    this.isLocal = true;
  }
  @override
  _StrategiesState createState() {
    if (isLocal) {
      return _StrategiesState.local(_game, _db, _gameList);
    } else {
      return _StrategiesState(_gameName, _teamName, session, isLeader, games,
          teams, selectedGameIndex);
    }
  }
}
