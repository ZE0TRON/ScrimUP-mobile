import 'package:ScrimUp/Strategies.dart';
import 'package:ScrimUp/game/JoinCreateTeam.dart';
import 'package:flutter/material.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";
import '../utils/widgets.dart';
import '../utils/Navigation.dart';
import '../utils/UtilClasses.dart';
import '../account/ChangePassword.dart';
import '../availability/TeamAvailability.dart';
import '../game/GameSelect.dart';
import './invitation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/FirebaseAnalytics.dart';

class _TeamScreenState extends State<TeamScreen> {
  String _gameName;
  String _teamName;
  Session session;
  String _errorMessage;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;
  double isLeader;
  var leader;
  int selectedGameIndex;
  var games;
  var teams;
  var applications = [];
  List<String> members = [];
  List<String> notMeMembers = [];
  String me = "";
  bool isLoaded = false;
  String newTeamName = "";
  String newLeaderNick = "";
  DataPack returnObject;
  void _onMemberSelect(String member) {
    setState(() {
      newLeaderNick = member;
      // print(member);
      // print("leader selected");
    });
  }

  Future<void> _leaderNickSet(List<String> members) async {
    notMeMembers = members.toList();
    notMeMembers.remove(me);
    newLeaderNick = notMeMembers[0];
    print(newLeaderNick);
    print(notMeMembers);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Please select the new leader of the team'),
          content: MemberSelectWindow(
            onValueChange: _onMemberSelect,
            values: notMeMembers,
            initialValue: notMeMembers[0],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Leave Team',
                style: TextStyle(color: Colors.orangeAccent),
              ),
              onPressed: () {
                var leaveTeamUrl = "/team/leaveTeam";
                session.post(leaveTeamUrl, {
                  "gameName": _gameName,
                  "teamName": _teamName,
                  "leaderNick": newLeaderNick
                }).then((response) {
                  if (response["success"]) {
                    sendAnalyticsEvent(session.analytics, "leave_team", {});
                    setState(() {
                      games.remove(_gameName);
                      teams.remove(_teamName);
                      if (games.length == 0) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    JoinCreateTeamScreen(session)),
                            (_) => false);
                      } else {
                        _gameName = games[0];
                        _teamName = teams[0];
                        if (_teamName == "Solo" || _teamName == null) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => StrategiesScreen(
                                      _gameName,
                                      _teamName,
                                      session,
                                      1,
                                      games,
                                      teams,
                                      0)),
                              (_) => false);
                        }
                        print(games);
                        print(teams);
                        print(_gameName);
                        print(_teamName);
                        var isLeaderUrl = "/team/isLeader";
                        session.post(isLeaderUrl, {
                          "gameName": games[0],
                          "teamName": teams[0],
                        }).then((response) {
                          isLeader = response["success"] ? 1.0 : 0.0;
                          Navigator.pushAndRemoveUntil(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => TeamAvailabilityScreen(
                                      _gameName,
                                      _teamName,
                                      session,
                                      isLeader,
                                      games,
                                      teams,
                                      0)),
                              (_) => false);
                        });
                      }
                    });
                  } else {
                    _errorMessage = response["msg"];
                    Scaffold.of(context).showSnackBar(
                        ErrorSnackBar(_errorMessage, _buttonFontSize));
                    Navigator.of(context).pop();
                  }
                });
              },
            ),
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.orangeAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<bool> _changeTeamName() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextEditingController teamNameController = new TextEditingController();
        return AlertDialog(
          title: Text("Please enter the new team name"),
          content: TextField(
            decoration: new InputDecoration(
              labelText: "New Team Name",
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(5.0),
                borderSide: new BorderSide(),
              ),

              //fillColor: Colors.green
            ),
            style: TextStyle(fontSize: _buttonFontSize / 1.2),
            controller: teamNameController,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Change Team Name",
                style: TextStyle(color: Colors.orangeAccent),
              ),
              onPressed: () {
                if (teamNameController.text != "") {
                  newTeamName = teamNameController.text;
                  // print("Return from changeTeamName");
                  Navigator.pop(context, true);
                }
              },
            ),
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.orangeAccent),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<DataPack> _Settings() async {
    switch (await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0)),
            title: const Center(
              child: Text('Settings'),
            ),
            children: <Widget>[
              OutlineButton(
                color: Colors.blueAccent,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
                textTheme: ButtonTextTheme.normal,
                onPressed: () {
                  Navigator.pop(context, 3);
                },
                child: const Text('Change Password'),
              ),
              OutlineButton(
                color: Colors.redAccent,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
                textTheme: ButtonTextTheme.primary,
                onPressed: () {
                  Navigator.pop(context, 4);
                },
                child: const Text(
                  'Leave Team',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Opacity(
                opacity: isLeader,
                child: OutlineButton(
                  color: Colors.red,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0)),
                  textTheme: ButtonTextTheme.primary,
                  onPressed: () {
                    if (isLeader == 1) {
                      Navigator.pop(context, 6);
                    }
                  },
                  child: const Text('Change Team Name',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              Opacity(
                opacity: isLeader,
                child: OutlineButton(
                  color: Colors.red,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0)),
                  textTheme: ButtonTextTheme.primary,
                  onPressed: () {
                    if (isLeader == 1) {
                      Navigator.pop(context, 5);
                    }
                  },
                  child: const Text('Delete Team',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          );
        })) {
      case 1:
        //TODO: implement change nickname
        // print("1 clicked");
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => new PasswordChangeScreen(session)),
        );
        return DataPack("", false, false, false, "");
        break;
      case 4:
        // print("2 clicked");
        var c = await areYouSureDialog(
                'Do you really want to leave the team', context)
            .then((sure) async {
          // print("return after sure Sure is ");
          // print(sure);
          if (sure) {
            var leaveTeamUrl = "/team/leaveTeam";
            if (isLeader != 1.0) {
              await session.post(leaveTeamUrl, {
                "gameName": _gameName,
                "teamName": _teamName
              }).then((response) {
                if (response["success"]) {
                  sendAnalyticsEvent(session.analytics, "leave_team", {});

                  setState(() {
                    games.remove(_gameName);
                    teams.remove(_teamName);
                    if (games.length == 0) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  JoinCreateTeamScreen(session)),
                          (_) => false);
                    } else {
                      games.remove(_gameName);
                      teams.remove(_teamName);
                      _gameName = games[0];
                      _teamName = teams[0];
                      if (_teamName == null) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => StrategiesScreen(
                                    _gameName,
                                    "Solo",
                                    session,
                                    1,
                                    games,
                                    teams,
                                    0)),
                            (_) => false);
                      }
                      var isLeaderUrl = "/team/isLeader";
                      session.post(isLeaderUrl, {
                        "gameName": games[0],
                        "teamName": teams[0],
                      }).then((response) {
                        isLeader = response["success"] ? 1.0 : 0.0;
                        Navigator.pushAndRemoveUntil(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => TeamAvailabilityScreen(
                                    _gameName,
                                    _teamName,
                                    session,
                                    isLeader,
                                    games,
                                    teams,
                                    0)),
                            (_) => false);
                      });
                    }
                  });
                } else {
                  return DataPack(response["msg"], true, false, true, "");
                }
              });
            } else {
              // print(" I am in the leader section");
              if (members.length > 1) {
                await _leaderNickSet(members);
              } else {
                // print("I am hereeeaaa");
                returnObject =
                    DataPack("Use delete team instead", true, false, false, "");
              }
              // Leader leave team

            }
          }
        });
        return returnObject;
        break;
      case 5:
        // print("2 clicked");
        areYouSureDialog('Do you really want to delete the team', context)
            .then((sure) {
          if (sure) {
            var deleteTeamUrl = "/team/deleteTeam";
            session.post(deleteTeamUrl, {
              "gameName": _gameName,
              "teamName": _teamName
            }).then((response) {
              if (response["success"]) {
                sendAnalyticsEvent(session.analytics, "delete_team", {});

                setState(() {
                  games.remove(_gameName);
                  teams.remove(_teamName);
                  if (games.length == 0) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        new MaterialPageRoute(
                            builder: (context) =>
                                JoinCreateTeamScreen(session)),
                        (_) => false);
                  } else {
                    _gameName = games[0];
                    _teamName = teams[0];
                    if (_teamName == "Solo" || _teamName == null) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => StrategiesScreen(_gameName,
                                  _teamName, session, 1, games, teams, 0)),
                          (_) => false);
                    }
                    var isLeaderUrl = "/team/isLeader";
                    session.post(isLeaderUrl, {
                      "gameName": games[0],
                      "teamName": teams[0],
                    }).then((response) {
                      isLeader = response["success"] ? 1.0 : 0.0;
                      Navigator.pushAndRemoveUntil(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => TeamAvailabilityScreen(
                                  _gameName,
                                  _teamName,
                                  session,
                                  isLeader,
                                  games,
                                  teams,
                                  0)),
                          (_) => false);
                    });
                  }
                });
                return DataPack("", false, false, true, "");
              } else {
                return DataPack(response["msg"], true, false, true, "");
              }
            });
          }
        });
        break;
      case 6:
        var changeTeamNameUrl = "/team/changeTeamName";
        _changeTeamName().then((ok) {
          // print("OK is ");
          // print(ok);
          if (ok) {
            session.post(changeTeamNameUrl, {
              "game": _gameName,
              "team": _teamName,
              "newTeamName": newTeamName
            }).then((response) {
              if (response["success"]) {
                sendAnalyticsEvent(session.analytics, "change_team_name", {});

                setState(() {
                  teams[teams.indexOf(_teamName)] = newTeamName;
                  _teamName = newTeamName;
                });
                return DataPack("", false, false, true, "");
              } else {
                return DataPack(response["msg"], true, false, true, "");
              }
            });
          }
        });
    }
  }

  _TeamScreenState(this._gameName, this._teamName, this.session, this.isLeader,
      this.games, this.teams, this.selectedGameIndex);
  void requestsLoaded(response3) {
    if (!response3["success"]) {
      if (response3["msg"] == "Login first") {
        Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
      } else {
        _errorMessage = response3["msg"];
        Scaffold.of(context)
            .showSnackBar(ErrorSnackBar(_errorMessage, _buttonFontSize));
      }
    }
    setState(() {
      isLoaded = true;
      members = [];
      leader = response3["leader"];
      me = response3["you"];
      for (int i = 0; i < response3["members"].length; i++) {
        members.add(response3["members"][i]);
      }
    });
  }

  void _getRequest() {
    var teamRequestsUrl = "/team/getTeamMembers";
    session.post(teamRequestsUrl,
        {"gameName": _gameName, "teamName": _teamName}).then((response3) {
      requestsLoaded(response3);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var bottomNavigation = bottomNavigationBar(5, context, teams, games,
        _teamName, _gameName, session, isLeader, selectedGameIndex);
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.030;
    var leftDrawer = drawer(teams, games, context, session, selectedGameIndex);

    var teamRequestsUrl = "/team/getTeamMembers";
    if (!isLoaded) {
      session.post(teamRequestsUrl,
          {"gameName": _gameName, "teamName": _teamName}).then((response3) {
        requestsLoaded(response3);
      });
      return new Scaffold(
        floatingActionButton: Opacity(
          opacity: isLeader,
          child: FloatingActionButton.extended(
            heroTag: "invite",
            backgroundColor: Colors.orange,
            icon: Icon(Icons.person_add),
            label: Text("Invite People"),
            onPressed: () {
              if (isLeader == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          new InvitationScreen(_gameName, _teamName, session)),
                );
              }
            },
          ),
        ),
        bottomNavigationBar: bottomNavigation,
        drawer: leftDrawer,
        appBar: AppBar(
          title: Text("Scrim UP"),
          actions: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    _Settings().then((dataPack) {
                      if (dataPack != null) {
                        // print(dataPack);
                        if (dataPack.shouldPop) {
                          Navigator.pop(context);
                        }
                        if (dataPack.isError()) {
                          Scaffold.of(context).showSnackBar(ErrorSnackBar(
                              dataPack.getMessage(), _buttonFontSize));
                        }
                        if (dataPack.isSuccess) {
                          Scaffold.of(context).showSnackBar(SucessSnackBar(
                              dataPack.getMessage(), _buttonFontSize));
                        }
                      }
                    });
                    // _askedToLead();
                  },
                );
              },
            )
          ],
        ),
        body: Container(
          padding:
              EdgeInsets.symmetric(horizontal: _containerPaddingSide / 3.5),
          child: Padding(
            padding: EdgeInsets.only(top: _headerPaddingTop),
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  String gameName =
                      _gameName.replaceAll(" ", "\ ").replaceAll(":", "_");
                  var gameLogo;
                  if (gameName == "Business") {
                    gameLogo = Icon(FontAwesomeIcons.businessTime);
                  } else if (gameName == "Other") {
                    gameLogo = Icon(FontAwesomeIcons.question);
                  } else {
                    gameLogo = Image.asset(
                      'assets/games/${gameName}_logo.png',
                      height: 60,
                      width: 60,
                    );
                  }
                  return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: _buttonPaddingTop * 2.5),
                      enabled: true,
                      leading: gameLogo,
                      title: Text(
                        '${_teamName}',
                        style: TextStyle(fontSize: _buttonFontSize * 1.5),
                      ));
                } else if (index == 1) {
                  return new Text(
                    "Members",
                    style: TextStyle(fontSize: _headerFontSize / 1.5),
                  );
                } else if (index == 2) {
                  return new Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop * 15),
                      child: Text("Members Are Loading",
                          style: TextStyle(
                            fontSize: _buttonFontSize * 1.8,
                          )),
                    ),
                  );
                } else {
                  return new Padding(
                    padding: EdgeInsets.only(top: _buttonPaddingTop * 4),
                    child: Center(
                      child: new Spinner(),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    }

    return new Scaffold(
      floatingActionButton: Opacity(
        opacity: isLeader,
        child: FloatingActionButton.extended(
          heroTag: "invite",
          backgroundColor: Colors.orange,
          icon: Icon(Icons.person_add),
          label: Text("Invite People"),
          onPressed: () {
            if (isLeader == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        new InvitationScreen(_gameName, _teamName, session)),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: bottomNavigation,
      drawer: leftDrawer,
      appBar: AppBar(
        title: Text("Scrim UP"),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  _Settings().then((dataPack) {
                    if (dataPack != null) {
                      // print(dataPack);
                      if (dataPack.shouldPop) {
                        Navigator.pop(context);
                      }
                      if (dataPack.isError()) {
                        Scaffold.of(context).showSnackBar(ErrorSnackBar(
                            dataPack.getMessage(), _buttonFontSize));
                      }
                      if (dataPack.isSuccess) {
                        Scaffold.of(context).showSnackBar(SucessSnackBar(
                            dataPack.getMessage(), _buttonFontSize));
                      }
                    }
                  });
                  // _askedToLead();
                },
              );
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: _containerPaddingSide / 3.5),
        child: Padding(
          padding: EdgeInsets.only(top: _headerPaddingTop),
          child: ListView.builder(
            itemCount: 2 + members.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                String gameName =
                    _gameName.replaceAll(" ", "\ ").replaceAll(":", "_");
                var gameLogo;
                if (gameName == "Business") {
                  gameLogo = Icon(FontAwesomeIcons.businessTime);
                } else if (gameName == "Other") {
                  gameLogo = Icon(FontAwesomeIcons.question);
                } else {
                  gameLogo = Image.asset(
                    'assets/games/${gameName}_logo.png',
                    height: 60,
                    width: 60,
                  );
                }
                return ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: _buttonPaddingTop * 2.5),
                    enabled: true,
                    leading: gameLogo,
                    title: Text(
                      '${_teamName}',
                      style: TextStyle(fontSize: _buttonFontSize * 1.5),
                    ));
              } else if (index == 1) {
                return new Text(
                  "Members",
                  style: TextStyle(fontSize: _headerFontSize / 1.5),
                );
              } else {
                if (members[index - 2] == leader) {
                  return new ListTile(
                    leading: Icon(Icons.star),
                    title: Text(members[index - 2],
                        style: TextStyle(fontSize: _buttonFontSize * 1.3)),
                  );
                }
                return new ListTile(
                  leading: MyBullet(),
                  title: Text(members[index - 2],
                      style: TextStyle(fontSize: _buttonFontSize * 1.3)),
                  trailing: Padding(
                      padding: EdgeInsets.only(left: _containerPaddingSide),
                      child: Opacity(
                          opacity: isLeader,
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.times,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              areYouSureDialog(
                                      "Are you sure you want to kick " +
                                          members[index - 2] +
                                          " from team",
                                      context)
                                  .then((sure) {
                                if (sure) {
                                  var joinEventUrl = "/team/kickFromTeam";
                                  session.post(joinEventUrl, {
                                    "team": _teamName,
                                    "game": _gameName,
                                    "kickedUser": members[index - 2],
                                  }).then((response) {
                                    if (response["success"]) {
                                      sendAnalyticsEvent(session.analytics,
                                          "kick_from_team", {});
                                      Scaffold.of(context).showSnackBar(
                                          SucessSnackBar(response["msg"],
                                              _buttonFontSize));
                                      _getRequest();
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                          ErrorSnackBar(response["msg"],
                                              _buttonFontSize));
                                    }
                                  });
                                }
                              });
                            },
                          ))),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class TeamScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  Session session;
  var games;
  var teams;
  double isLeader;
  int selectedGameIndex;
  TeamScreen(this._gameName, this._teamName, this.session, this.isLeader,
      this.games, this.teams, this.selectedGameIndex);
  @override
  _TeamScreenState createState() => _TeamScreenState(
      _gameName, _teamName, session, isLeader, games, teams, selectedGameIndex);
}
