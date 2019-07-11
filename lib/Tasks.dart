import 'package:ScrimUp/CreateTask.dart';
import 'package:ScrimUp/utils/AvailabilityParse.dart';
import 'package:ScrimUp/utils/ErrorHandle.dart';
import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:ScrimUp/utils/Navigation.dart';
import 'package:ScrimUp/utils/Request.dart';
import 'package:ScrimUp/utils/SnackBars.dart';
import 'package:ScrimUp/utils/session.dart';
import 'package:ScrimUp/utils/widgets.dart';
import 'package:flutter/material.dart';

import 'models/Game.dart';
import 'models/Task.dart';

class _TasksState extends State<TasksScreen> {
  String _gameName;
  String _teamName;
  Session session;
  DayTime dayTime;
  String _errorMessage;
  List<String> members;
  String _errMsg;
  Request _request;

  String dropdownValue;
  BuildContext widgetContext;
  bool isMembersLoaded = false;
  double isLeader;
  String avatar;
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
  var teams;
  var games;
  String leader;
  String me;
  Game game;
  LocalDB db;
  bool isLocal = false;
  bool isSolo = false;
  List<Game> gameList;
  //Lists for items from server/local
  var titles = [];
  var descriptions = [];
  var progressCounter;
  List<Task> tasks;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dropDownKey = GlobalKey();

  _TasksState(this._gameName, this._teamName, this.session, this.isLeader,
      this.games, this.teams, this.selectedGameIndex);
  _TasksState.local(Game game, LocalDB db, List<Game> gameList) {
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
  _getAvatar() {
    return Future(() async {
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
    });
  }

  _getTasks() {
    tasks = List<Task>();
    if (isLocal) {
      setState(() {
        tasks = game.tasks;
      });
    } else {
      _request.getTasksRequest(_gameName).then((taskList) {
        setState(() {
          tasks = taskList;
        });
      }).catchError((err) {
        handleError(err, context, _buttonFontSize);
      });
    }
  }

  _loadMembers() {
    var teamRequestsUrl = "/team/getTeamMembers";
    session.post(teamRequestsUrl,
        {"gameName": _gameName, "teamName": _teamName}).then((response3) {
      setState(() {
        me = response3["you"];
        // dropdownValue = members[0];
      });
    });
  }

  _deleteTask(int index) {
    if (isLocal) {
      setState(() {
        game.deleteTask(tasks[index]);
        db.updateGame(game);
      });
    } else {
      if (tasks[index].assigned == me || isLeader == 1) {
        _request.deleteTaskRequest(tasks[index], _gameName).then((_) {
          _getTasks();
        }).catchError((err) {
          handleError(err, context, _buttonFontSize);
        });
      }
    }
  }

  _incrementProgress(int index) {
    if (isLocal) {
      setState(() {
        tasks[index].progress();
        game.updateTask(tasks[index]);
        db.updateGame(game);
      });
    } else {
      _request.progressTaskRequest(tasks[index], _gameName).then((_) {
        _getTasks();
      }).catchError((err) {
        handleError(err, context, _buttonFontSize);
      });
    }
  }

  @override
  void initState() {
    if (!isLocal) {
      if (_teamName == "Solo") {
        isSolo = true;
      }
    }

    _request = Request(session);
    _getAvatar();
    _loadMembers();
    _getTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("lel");
    Size size = MediaQuery.of(context).size;
    BottomNavigationBar bottomNavigation;
    if (isLocal) {
      bottomNavigation =
          localBottomNavigationBar(1, context, gameList, selectedGameIndex, db);
    } else if (isSolo) {
      bottomNavigation = soloNavigationBar(1, context, teams, games, _teamName,
          _gameName, session, isLeader, selectedGameIndex);
    } else {
      bottomNavigation = bottomNavigationBar(4, context, teams, games,
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
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.028;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.025;
    final double _cardBorderRadius = 17.0;
    widgetContext = context;
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
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) {
                if (isLocal) {
                  return CreateTaskScreen.local(game, db);
                } else {
                  return CreateTaskScreen(
                      _gameName, _teamName, session, isLeader, isSolo);
                }
              },
            )).then((_) => _getTasks());
          },
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: _headerPaddingTop, bottom: _headerPaddingTop / 2),
              child: Text(
                "Tasks/Goals",
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
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  int current = tasks[index].current;
                  int goal = tasks[index].goal;
                  int percentage = (current / goal * 100).floor();
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
                                tasks[index].title,
                                style: TextStyle(
                                    fontSize: _mediumFontSize * 1.2,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(tasks[index].detail,
                                style: TextStyle(
                                    fontSize: _mediumFontSize / 1.25)),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: _buttonPaddingTop * 3),
                              child: Visibility(
                                visible: isLocal ||
                                    tasks[index].assigned == me ||
                                    isLeader == 1,
                                child: Text(
                                  "Assigned to " + tasks[index].assigned,
                                  style: TextStyle(
                                      fontSize: _mediumFontSize / 1.3,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    bottom: _headerPaddingTop,
                                    top: _headerPaddingTop / 2),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "Progress  " +
                                            current.toString() +
                                            "/" +
                                            goal.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: _mediumFontSize / 1.4),
                                      ),
                                    ),
                                    Text(
                                      "    %" + percentage.toString(),
                                      style: TextStyle(
                                          fontSize: _mediumFontSize / 1.4,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                )),
                            RaisedButton(
                              padding: EdgeInsets.symmetric(
                                  vertical: _buttonPaddingTop * 1.5,
                                  horizontal: _containerPaddingSide / 2),
                              child: Text(
                                "Increment Progress",
                                style:
                                    TextStyle(fontSize: _mediumFontSize / 1.25),
                              ),
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(_cardBorderRadius * 2))),
                              onPressed: () {
                                _incrementProgress(index);
                              },
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: _headerPaddingTop / 4),
                              child: Visibility(
                                visible: tasks[index].assigned == me ||
                                    isLocal ||
                                    isLeader == 1 ||
                                    isSolo,
                                child: RaisedButton(
                                  padding: EdgeInsets.symmetric(
                                      vertical: _buttonPaddingTop * 1.5,
                                      horizontal: _containerPaddingSide / 2),
                                  child: Text(
                                    "Delete Task",
                                    style: TextStyle(
                                        fontSize: _mediumFontSize / 1.25),
                                  ),
                                  color: Colors.red[700],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              _cardBorderRadius * 2))),
                                  onPressed: () {
                                    _deleteTask(index);
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

class TasksScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  var games;
  var teams;
  int selectedGameIndex;
  Session session;
  Game _game;
  LocalDB _db;
  List<Game> _gameList;
  bool isLocal = false;
  double isLeader;
  TasksScreen(
      this._gameName,
      this._teamName,
      this.session,
      this.isLeader,
      this.games,
      this.teams,
      this.selectedGameIndex); // TODO: change all constructors to look like this if possible
  TasksScreen.local(Game game, LocalDB db, List<Game> gameList) {
    this._game = game;
    this._db = db;
    this._gameList = gameList;
    this.isLocal = true;
  }
  @override
  _TasksState createState() {
    if (isLocal) {
      return _TasksState.local(_game, _db, _gameList);
    } else {
      return _TasksState(_gameName, _teamName, session, isLeader, games, teams,
          selectedGameIndex);
    }
  }
}
