import 'package:ScrimUp/utils/ErrorHandle.dart';
import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:ScrimUp/utils/Request.dart';
import 'package:ScrimUp/utils/SnackBars.dart';
import 'package:ScrimUp/utils/session.dart';
import 'package:ScrimUp/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'models/Game.dart';
import 'models/Task.dart';

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  LocalDB db;
  Game game;
  bool isLocal = false;
  Request _request;
  Session session;
  String _gameName;
  String _teamName;
  String dropdownValue = "-";
  bool isMembersLoaded = false;
  GlobalKey _scaffoldKey;
  String _errMsg;
  String me;
  BuildContext widgetContext;
  double isLeader;
  bool isSolo = false;
  int selectedGameIndex;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;
  List<String> members = ["Not Selected"];
  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController taskGoalController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  @override
  void initState() {
    _request = Request(session);
    _loadMembers();
    super.initState();
  }

  @override
  void dispose() {
    taskTitleController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }

  void _onMemberSelect(String member) {
    setState(() {
      dropdownValue = member;
      // print(member);
      // print("leader selected");
    });
  }

  void _createTask(String title, String detail, String assigned, int goal) {
    Task task = Task(title, detail, assigned, goal);
    if (isLocal) {
      setState(() {
        game.addTask(task);
        db.updateGame(game);
      });
    } else {
      _request
          .createTaskRequest(task, _gameName)
          .then((_) => Navigator.pop(context));
      //     .catchError((err) {

      //   handleError(err, widgetContext, _buttonFontSize);
      // });
    }
  }

  _loadMembers() {
    members = List<String>();
    if (isLocal || isLeader == 0 || isSolo) {
      setState(() {
        members.add("Me");
        isMembersLoaded = true;
      });
    } else {
      var teamRequestsUrl = "/team/getTeamMembers";
      session.post(teamRequestsUrl,
          {"gameName": _gameName, "teamName": _teamName}).then((response3) {
        setState(() {
          me = response3["you"];
          for (int i = 0; i < response3["members"].length; i++) {
            members.add(response3["members"][i]);
          }
          dropdownValue = members[0];
          isMembersLoaded = true;
        });
      });
    }
  }

  void _dropdownChanged(String value) {
    setState(() {
      dropdownValue = value;
    });
  }

  _CreateTaskScreenState(
      this._gameName, this._teamName, this.session, this.isLeader, this.isSolo);
  _CreateTaskScreenState.local(Game game, LocalDB db) {
    this.game = game;
    this.db = db;
    this.isLocal = true;
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.028;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.025;
    if (!isMembersLoaded) {
      return Spinner();
    }
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Scrim UP"),
        ),
        body: Builder(builder: (context) {
          widgetContext = context;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                      horizontal: _containerPaddingSide / 4,
                      vertical: _headerPaddingTop / 2),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: _headerPaddingTop / 2,
                      ),
                      child: Text(
                        "Create Task/Goal",
                        style: TextStyle(
                            fontSize: _headerFontSize,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: _headerPaddingTop / 2),
                      child: TextFormField(
                        decoration: new InputDecoration(
                          labelText: "Title",
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        controller: taskTitleController,
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
                        ),
                        controller: taskDescriptionController,
                        maxLines: 1,
                        style: TextStyle(fontSize: _buttonFontSize / 1.2),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: _headerPaddingTop / 4),
                      child: TextFormField(
                        decoration: new InputDecoration(
                            labelText: "Goal (How many Times ?)",
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: new BorderSide(),
                            ),
                            errorText: _errMsg),
                        controller: taskGoalController,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        style: TextStyle(fontSize: _buttonFontSize / 1.2),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _headerPaddingTop / 4,
                            horizontal: _containerPaddingSide / 4),
                        child: DropdownButton(
                          hint: Text("Select a teammate"),
                          value: dropdownValue,
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          items: members
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: _containerPaddingSide / 4,
                    vertical: _headerPaddingTop / 2),
                child: RaisedButton(
                  padding:
                      EdgeInsets.symmetric(vertical: _buttonPaddingTop * 1.5),
                  child: Text(
                    "Create Task/Goal",
                    style: TextStyle(
                        fontSize: _buttonFontSize * 1.5, color: Colors.white),
                  ),
                  onPressed: () {
                    if (taskTitleController.text.length == 0) {
                      Scaffold.of(widgetContext).showSnackBar(ErrorSnackBar(
                          "Title can't be empty.",
                          MediaQuery.of(context).size.height * 0.020 * 2));
                    } else if (int.tryParse(taskGoalController.text) == null) {
                      setState(() {
                        _errMsg = "Goal Must be a number";
                      });
                    } else {
                      setState(() {
                        _errMsg = null;
                      });
                      _createTask(
                          taskTitleController.text,
                          taskDescriptionController.text,
                          dropdownValue,
                          int.parse(taskGoalController.text));
                      taskTitleController.clear();
                      taskDescriptionController.clear();
                      dropdownValue = null;
                      taskGoalController.clear();
                      Navigator.pop(context);
                    }
                  },
                ),
              )
            ],
          );
        }));
  }
}

class CreateTaskScreen extends StatefulWidget {
  Session session;
  String _gameName;
  String _teamName;
  LocalDB db;
  Game game;
  bool isLocal = false;
  double isLeader;
  bool isSolo = false;
  CreateTaskScreen(
      this._gameName, this._teamName, this.session, this.isLeader, this.isSolo);
  CreateTaskScreen.local(Game game, LocalDB db) {
    this.game = game;
    this.db = db;
    this.isLocal = true;
  }
  createState() {
    if (this.isLocal) {
      return _CreateTaskScreenState.local(game, db);
    } else {
      return _CreateTaskScreenState(
          _gameName, _teamName, session, isLeader, isSolo);
    }
  }
}
