import 'package:flutter/material.dart';
import "../utils/session.dart";
import '../InitializeApp.dart';
import "../utils/SnackBars.dart";
import '../utils/AvailabilityParse.dart';
import '../utils/widgets.dart';
import '../utils/FirebaseAnalytics.dart';

class _ChallengeRequestsState extends State<ChallengeRequestsScreen> {
  String _gameName;
  String _teamName;
  Session session;
  DayTime dayTime;
  String _errorMessage;
  List<NewItem> items = new List<NewItem>();
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;
  var challenges = [];
  var days = [];
  var hours = [];
  var players = [];
  var exactTimes = [];
  var notes = [];
  var hosts = [];
  var times = [];
  bool isLoaded = false;
  _ChallengeRequestsState(String gameName, String teamName, Session session) {
    this._gameName = gameName;
    this._teamName = teamName;
    this.session = session;
    double localDiff = DateTime.now().timeZoneOffset.inHours.toDouble();

    dayTime = new DayTime(localDiff);
  }
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
      items.clear();
      challenges = [];
      days = [];
      hours = [];
      players = [];
      exactTimes = [];
      notes = [];
      hosts = [];
      times = [];
      isLoaded = true;
      challenges = response3["challenges"];
      var current;
      var day, hour, dayHour;
      for (int i = 0; i < response3["challenges"].length; i++) {
        // print("Length : " + response3["challenges"].length.toString());
        if (i > 10) {
          break;
        }
        current = challenges[i];
        times.add(current["time"]);
        day = current["time"].split(" ")[0];
        hour = current["time"].split(" ")[1];
        dayHour = dayTime.parseTime(day, hour);
        days.add(dayHour[0]);
        hours.add((dayHour[1]));
        hosts.add(current["hostTeam"]);
        players.add(current["numberOfPlayers"]);
        exactTimes.add(current["exactTime"]);
        notes.add(current["note"]);
        var amPm = hours[i].split("00")[1].substring(0, 2);
        var currentExactTime =
            exactTimes[i].length < 2 ? "0" + exactTimes[i] : exactTimes[i];
        var accurateTime =
            hours[i].split(":")[0] + ":" + currentExactTime + amPm;
        Widget header = FittedBox(
            child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _buttonPaddingTop * 2),
              child: Text(
                hosts[i],
                style: TextStyle(fontSize: _headerFontSize / 1.5),
              ),
            ),
            OutlineButton(onPressed: () {}, child: Text(days[i])),
            FlatButton(
                color: Colors.green,
                onPressed: () {},
                child: Text(accurateTime)),
            Padding(
              padding: EdgeInsets.only(left: _containerPaddingSide / 12),
              child: IconButton(
                icon: Icon(
                  Icons.check,
                  size: _buttonFontSize,
                  color: Colors.green,
                ),
                onPressed: () {
                  // print("I am pressed");
                  var acceptChallengesUrl = "/team/acceptChallenges";
                  session.post(acceptChallengesUrl, {
                    "gameName": _gameName,
                    "teamName": _teamName,
                    "otherTeam": hosts[i],
                    "v2": players[i].toString(),
                    "time": times[i],
                    "accept": "Accept"
                  }).then((response3) {
                    if (response3["success"]) {
                      sendAnalyticsEvent(
                          session.analytics, "accept_challenge", {});
                      setState(() {
                        isLoaded = false;
                      });
                    } else {
                      _errorMessage = response3["msg"];
                      Scaffold.of(context).showSnackBar(
                          ErrorSnackBar(_errorMessage, _buttonFontSize));
                    }
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: _containerPaddingSide / 12),
              child: IconButton(
                icon: Icon(
                  Icons.not_interested,
                  size: _buttonFontSize,
                  color: Colors.red,
                ),
                onPressed: () {
                  // print("I am pressed");
                  var acceptChallengesUrl = "/team/acceptChallenges";
                  session.post(acceptChallengesUrl, {
                    "gameName": _gameName,
                    "teamName": _teamName,
                    "otherTeam": hosts[i],
                    "v2": players[i].toString(),
                    "time": times[i],
                    "accept": "Reject"
                  }).then((response3) {
                    if (response3["success"]) {
                      sendAnalyticsEvent(
                          session.analytics, "reject_challenge", {});
                      setState(() {
                        isLoaded = false;
                      });
                    } else {
                      _errorMessage = response3["msg"];
                      Scaffold.of(context).showSnackBar(
                          ErrorSnackBar(_errorMessage, _buttonFontSize));
                    }
                  });
                },
              ),
            ),
          ],
        ));
        Widget body = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Note : " + notes[i],
              style: TextStyle(fontSize: _buttonFontSize),
            ),
            Text(
              (players[i]).toString() + " vs " + (players[i]).toString(),
              style: TextStyle(fontSize: _buttonFontSize),
            )
          ],
        );
        items.add(NewItem(false, header, body, Icon(Icons.list)));
      }
    });
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
    var teamRequestsUrl = "/team/getPendingChallenges";
    if (!isLoaded) {
      session.post(teamRequestsUrl,
          {"gameName": _gameName, "teamName": _teamName}).then((response3) {
        sendAnalyticsEvent(session.analytics, "check_pending_challenges", {});
        requestsLoaded(response3);
      });
      return new Center(
        child: new Spinner(),
      );
    }
    return new Scaffold(
      appBar: AppBar(
        title: Text("Scrim UP"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: _containerPaddingSide / 4),
        child: ListView(children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: _headerPaddingTop),
            child: Text(
              "Pending Challenges",
              style: TextStyle(fontSize: _headerFontSize),
            ),
          ),
          ExpansionPanelList(
            expansionCallback: (index, expanded) {
              setState(() {
                items[index].isExpanded = !items[index].isExpanded;
              });
            },
            children: items.map((NewItem item) {
              return new ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return item.header;
                },
                body: item.body,
                isExpanded: item.isExpanded,
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}

class ChallengeRequestsScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  Session session;
  ChallengeRequestsScreen(String gameName, String teamName, Session session) {
    this._gameName = gameName;
    this._teamName = teamName;
    this.session = session;
  }
  @override
  _ChallengeRequestsState createState() =>
      _ChallengeRequestsState(_gameName, _teamName, session);
}
