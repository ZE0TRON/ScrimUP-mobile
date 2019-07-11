import 'package:flutter/material.dart';
import "../utils/session.dart";
import '../InitializeApp.dart';
import "../utils/SnackBars.dart";
import '../utils/AvailabilityParse.dart';
import '../utils/widgets.dart';
import '../utils/FirebaseAnalytics.dart';

class _TimeSelectWindowState extends State<TimeSelectWindow> {
  String sMinute;
  @override
  void initState() {
    super.initState();
    sMinute = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    var minute = new List<String>.generate(61, (i) => i.toString());
    return DropdownButton(
      value: sMinute,
      items: minute.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          sMinute = value;
        });
        widget.onValueChange(value);
      },
    );
  }
}

class TimeSelectWindow extends StatefulWidget {
  final String initialValue;
  final void Function(String) onValueChange;
  TimeSelectWindow({this.onValueChange, this.initialValue});

  @override
  _TimeSelectWindowState createState() => _TimeSelectWindowState();
}

class _ChallengeOtherTeamsState extends State<ChallengeOtherTeamsScreen> {
  String _gameName;
  String _teamName;
  Session session;
  String challengeNote = "";
  String exactTime = "";
  DayTime dayTime;
  final noteController = new TextEditingController();
  bool okChallenge = false;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  String _errorMessage;
  double _notificationPadding;
  double _mediumFontSize;
  var sHour;
  var sMinute = "0";
  String v1 = "5"; // Add editing controller to change them
  String v2 = "5";
  var teams = [];
  bool isLoaded = false;
  bool empty = true;
  var times = [];
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
      empty = false;
      teams = [];
      times = [];
      for (int i = 0; i < response3["teams"].length; i++) {
        teams.add(response3["teams"][i]);
        // print(teams);
        var currentTime = teams[i]["time"];
        var day = currentTime.split(" ")[0];
        var hour = currentTime.split(" ")[1];
        var ress = dayTime.parseTime(day, hour);
        times.add([ress[0], ress[1]]);
      }
    });
  }

  void _onMinuteChange(String value) {
    sMinute = value;
    exactTime = value;
  }

  _ChallengeOtherTeamsState(this._gameName, this._teamName, this.session);

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<bool> _challengeTeam(String dateRange) async {
    var hour = [dateRange.split(":")[0]];
    sHour = hour[0];
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(' Challenge ? ')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(bottom: _buttonPaddingTop),
                    child: Center(child: Text("Select exact time"))),
                Padding(
                  padding: EdgeInsets.only(bottom: _buttonPaddingTop),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(right: _buttonPaddingTop * 3),
                          child: DropdownButton(
                            value: sHour,
                            items: hour.map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                sHour = value;
                                isLoaded = false;
                              });
                              // print("I have changed");
                            },
                          ),
                        ),
                        TimeSelectWindow(
                            onValueChange: _onMinuteChange, initialValue: "0"),
                      ]),
                ),
                TextField(
                  decoration: new InputDecoration(
                    labelText: "Enter Note(Optional)",
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  controller: noteController,
                  maxLines: 1,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Done'),
              onPressed: () {
                challengeNote = noteController.text;
                okChallenge = true;
                Navigator.of(context).pop();
                return true;
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double localDiff = DateTime.now().timeZoneOffset.inHours.toDouble();

    dayTime = new DayTime(localDiff);
    Size size = MediaQuery.of(context).size;
    // print(size.width);
    // print(size.height);
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.030;
    var teamSizes = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
    var challengableTeamsUrl = "/team/getChallengableTeams";
    if (!isLoaded) {
      session.post(challengableTeamsUrl, {
        "gameName": _gameName,
        "teamName": _teamName,
        "v1": v1,
        "v2": v2
      }).then((response3) {
        if (response3["success"]) {
          requestsLoaded(response3);
        } else {
          setState(() {
            isLoaded = true;
            empty = true;
          });
        }
      });
      return new Center(
        child: new Spinner(),
      );
    }
    if (empty) {
      return new Scaffold(
        appBar: AppBar(
          title: Text("Scrim UP"),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: _containerPaddingSide / 4),
          child: Center(
              child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(_headerPaddingTop),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton(
                        value: v1,
                        items: teamSizes.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            v1 = value;
                            isLoaded = false;
                          });
                          // print("I have changed");
                        },
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: _buttonPaddingTop),
                        child: Text(
                          "vs",
                          style: TextStyle(fontSize: _buttonFontSize),
                        ),
                      ),
                      DropdownButton(
                        value: v2,
                        items: teamSizes.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            isLoaded = false;
                            v2 = value;
                          });
                        },
                      ),
                    ]),
              ),
              Text(
                "No teams found to challenge right now.\nYou can invite your friends so, you can find more teams to play with.",
                style: TextStyle(fontSize: _buttonFontSize * 0.8),
              ),
            ],
          )),
        ),
      );
    }
    return new Scaffold(
      appBar: AppBar(
        title: Text("Scrim UP"),
      ),
      body: ListView.builder(
        itemCount: teams.length + 3,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return new Padding(
                padding: EdgeInsets.only(top: _headerPaddingTop),
                child: Center(
                  child: Text(
                    "Challenge",
                    style: TextStyle(fontSize: _headerFontSize),
                  ),
                ));
          }
          if (index == 1) {
            return new Padding(
              padding: EdgeInsets.only(top: _headerPaddingTop),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButton(
                      value: v1,
                      items: teamSizes.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          v1 = value;
                        });
                        // print("I have changed");
                      },
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: _buttonPaddingTop),
                      child: Text(
                        "vs",
                        style: TextStyle(fontSize: _buttonFontSize),
                      ),
                    ),
                    DropdownButton(
                      value: v2,
                      items: teamSizes.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          isLoaded = false;
                          v2 = value;
                        });
                      },
                    ),
                  ]),
            );
          }
          if (index == 2) {
            return new Padding(
              padding: EdgeInsets.only(top: _buttonPaddingTop),
              child: FlatButton(
                child: Center(
                  child: Text(
                    v1.toString() + " vs  " + v2.toString(),
                    style: TextStyle(fontSize: _headerFontSize),
                  ),
                ),
                onPressed: () {
                  // print("weekdays clicked");
                },
              ),
            );
          } else {
            return new Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: _buttonPaddingTop),
                  child: FlatButton(
                    child: Center(
                      child: Text(
                        teams[index - 3]["teamName"],
                        style: TextStyle(fontSize: _mediumFontSize),
                      ),
                    ),
                    onPressed: () {
                      // print("weekdays clicked");
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: _buttonPaddingTop),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlineButton(
                          child: Center(
                            child: Text(
                              times[index - 3][0],
                              style: TextStyle(fontSize: _buttonFontSize),
                            ),
                          ),
                          onPressed: () {
                            // print("team availability clicked");
                          },
                        ),
                        FlatButton(
                          color: Colors.green,
                          child: Center(
                            child: Text(
                              times[index - 3][1],
                              style: TextStyle(fontSize: _buttonFontSize),
                            ),
                          ),
                          onPressed: () {
                            // print("team availability clicked");
                          },
                        ),
                        IconButton(
                          icon: Icon(
                              Icons.play_arrow // TODO: put swords icon here
                              ),
                          onPressed: () {
                            _challengeTeam(times[index - 3][1]).then((void a) {
                              if (okChallenge) {
                                var challengeTeamUrl =
                                    "/team/challengeOtherTeams";
                                session.post(challengeTeamUrl, {
                                  "gameName": _gameName,
                                  "teamName": _teamName,
                                  "v1": v1,
                                  "v2": v2,
                                  "otherTeam": teams[index - 3]["teamName"],
                                  "time": teams[index - 3]["time"],
                                  "exactTime": exactTime,
                                  "note": challengeNote
                                }).then((response3) {
                                  if (response3["success"]) {
                                    sendAnalyticsEvent(session.analytics,
                                        "challenge_request_sent", {});
                                    setState(() {
                                      // print(response3);
                                      isLoaded = false;
                                    });
                                  } else {
                                    _errorMessage = response3["msg"];
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar(
                                            _errorMessage, _buttonFontSize));
                                  }
                                });
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class ChallengeOtherTeamsScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  Session session;
  ChallengeOtherTeamsScreen(this._gameName, this._teamName,
      this.session); // TODO: change all constructors to look like this if possible

  @override
  _ChallengeOtherTeamsState createState() =>
      _ChallengeOtherTeamsState(_gameName, _teamName, session);
}
