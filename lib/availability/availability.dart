import 'package:flutter/material.dart';
import "../utils/session.dart";
import './DetailedAvailability.dart';
import './GeneralAvailability.dart';
import '../utils/AvailabilityParse.dart';
import '../utils/Navigation.dart';

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  var days = [];
  var games;
  var teams;
  double isLeader;
  int selectedGameIndex;
  var dayColors = [
    Colors.black45,
    Colors.black45,
    Colors.black45,
    Colors.black45,
    Colors.black45,
    Colors.black45,
    Colors.black45,
  ];

  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  String _gameName;
  String _teamName;
  Session session;
  DayTime dayTime;
  var apiWeekdays = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];
  var weekdays = [
    "",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  void getAvailability() {
    var getDayAvailabilityUrl = "/account/getDayAvailability";
    session.post(getDayAvailabilityUrl, {"game": _gameName}).then((response) {
      setState(() {
        dayColors = [
          Colors.black45,
          Colors.black45,
          Colors.black45,
          Colors.black45,
          Colors.black45,
          Colors.black45,
          Colors.black45,
        ];
        if (response["success"]) {
          var resAvailability = response["availability"];
          for (int i = 0; i < 7; i++) {
            currentAvailability[apiWeekdays[i]] = 0;
          }
          for (int i = 0; i < 7; i++) {
            for (int j = 0; j < 24; j++) {
              var ress =
                  dayTime.singleHourParse(apiWeekdays[i], "t" + j.toString());
              var day = ress[0];
              currentAvailability[day] +=
                  resAvailability[apiWeekdays[i]]["t" + j.toString()];
            }
          }
          for (int i = 0; i < 7; i++) {
            if (currentAvailability[apiWeekdays[days[i].weekday - 1]] > 0) {
              dayColors[i] = Colors.green;
              print("I am chaning " + i.toString() + "to  green");
            }
          }
          print(currentAvailability);
        }
      });
    });
  }

  _AvailabilityScreenState(String gameName, String teamName, Session session,
      double isLeader, var games, var teams, var selectedGameIndex) {
    this.selectedGameIndex = selectedGameIndex;
    this._gameName = gameName;
    this._teamName = teamName;
    this.session = session;
    this.isLeader = isLeader;
    this.games = games;
    this.teams = teams;
    DateTime today = DateTime.now();
    days.add(today);
    days.add(today.add(new Duration(days: 1)));
    days.add(today.add(new Duration(days: 2)));
    days.add(today.add(new Duration(days: 3)));
    days.add(today.add(new Duration(days: 4)));
    days.add(today.add(new Duration(days: 5)));
    days.add(today.add(new Duration(days: 6)));
    double localDiff = DateTime.now().timeZoneOffset.inHours.toDouble();
    this.dayTime = new DayTime(localDiff);
  }
  Map<String, int> currentAvailability = new Map();
  @override
  void initState() {
    getAvailability();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var bottomNavigation = bottomNavigationBar(0, context, teams, games,
        _teamName, _gameName, session, isLeader, selectedGameIndex);
    var leftDrawer = drawer(teams, games, context, session, selectedGameIndex);
    print(dayColors);
    _buttonPaddingTop = size.height * 0.005;
    _containerPaddingSide = size.width * 0.12;
    _headerPaddingTop = size.height * 0.025;
    _headerFontSize = size.width * 0.096;
    _buttonFontSize = size.width * 0.05;
    return new Scaffold(
      bottomNavigationBar: bottomNavigation,
      drawer: leftDrawer,
      appBar: AppBar(
        title: Text("Scrim UP"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.access_time),
        label: Text("Quick Set"),
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new LongTermAvailabilityScreen(
                    _gameName, _teamName, session)),
          ).then((_) {
            getAvailability();
          });
        },
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: _headerPaddingTop),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: _containerPaddingSide / 3.5),
            child: ListView.builder(
              itemCount: days.length + 2,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return new Padding(
                    padding: EdgeInsets.only(
                        top: _buttonPaddingTop, bottom: _headerPaddingTop),
                    child: Text(
                      "My Availability",
                      style: TextStyle(fontSize: _headerFontSize),
                    ),
                  );
                } else if (index < days.length + 1) {
                  return new Padding(
                    padding: EdgeInsets.only(top: _buttonPaddingTop),
                    child: new FlatButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                      color: dayColors[index - 1],
                      //dayColors[index-1],
                      child: Center(
                        child: Text(
                          weekdays[days[index - 1].weekday] +
                              "(" +
                              days[index - 1].day.toString() +
                              "th)",
                          style: TextStyle(fontSize: _buttonFontSize),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  new DetailedAvailabilityScreen(
                                      days[index - 1],
                                      _gameName,
                                      _teamName,
                                      session)),
                        ).then((_) {
                          getAvailability();
                        });
                        // print("${index - 1} clicked");
                      },
                    ),
                  );
                } else {
                  return Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop),
                      child: Text(
                        "* The times shown are automatically converted to your time zone.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: _buttonFontSize / 1.5),
                      ));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AvailabilityScreen extends StatefulWidget {
  //7 gun gostercez saturday sunday her zaman mavi
  String _gameName;
  String _teamName;
  DateTime _today;
  double isLeader;
  var games;
  var teams;
  Session session;
  int selectedGameIndex;
  AvailabilityScreen(this._gameName, this._teamName, this.session,
      this.isLeader, this.games, this.teams, this.selectedGameIndex);
  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState(
      _gameName, _teamName, session, isLeader, games, teams, selectedGameIndex);
}
