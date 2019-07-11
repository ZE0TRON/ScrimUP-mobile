import 'package:ScrimUp/models/Event.dart';
import 'package:ScrimUp/models/Team.dart';
import 'package:ScrimUp/utils/Request.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/session.dart';
import '../utils/SnackBars.dart';
import '../utils/AvailabilityParse.dart';
import '../utils/FirebaseAnalytics.dart';
import '../utils/ErrorHandle.dart';

class _CreateEventState extends State<CreateEventScreen> {
  Session session;
  String _teamName;
  String _gameName;
  String time;
  String sHour;
  String sDay;
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventNoteController = TextEditingController();
  String sMinute = "0";
  List<String> hours;
  List<String> mins;

  var apiWeekDays = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];
  DayTime dayTime;
  Team _team;
  Request _request;
  int numberOfPlayers;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _mediumFontSize;
  bool buttonBlocked = false;
  String _errorMessage;

  _CreateEventState(this.session, this._teamName, this._gameName, this.hours,
      this.sHour, this.mins, this.time, this.sDay, this.numberOfPlayers);
  @override
  void initState() {
    double localDiff = DateTime.now().timeZoneOffset.inHours.toDouble();
    dayTime = new DayTime(localDiff);
    // TODO: move this to constructor
    _team = Team(_gameName, _teamName);
    _request = Request(session);
    super.initState();
  }

  @override
  void dispose() {
    eventNameController.dispose();
    eventNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(sHour);

    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.030;
    return new Scaffold(
        appBar: AppBar(
          title: Text("Scrim UP"),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return ListView(children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: _headerPaddingTop),
                child: Text(
                  "Create Event",
                  style: TextStyle(fontSize: _headerFontSize),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: _buttonPaddingTop),
                child: Row(children: <Widget>[
                  Padding(
                      padding:
                          EdgeInsets.only(right: _containerPaddingSide / 4),
                      child: Text(
                        "Day : ",
                        style: TextStyle(fontSize: _mediumFontSize),
                      )),
                  DropdownButton(
                    value: sDay,
                    items: apiWeekDays.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        sDay = value;
                      });
                      // print("I have changed");
                    },
                  )
                ]),
              ),
              Padding(
                padding: EdgeInsets.only(top: _buttonPaddingTop),
                child: Row(children: <Widget>[
                  Padding(
                      padding:
                          EdgeInsets.only(right: _containerPaddingSide / 4),
                      child: Text(
                        "Hour : ",
                        style: TextStyle(fontSize: _mediumFontSize),
                      )),
                  DropdownButton(
                    value: sHour,
                    items: hours.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        sHour = value;
                      });
                      // print("I have changed");
                    },
                  )
                ]),
              ),
              Padding(
                  padding: EdgeInsets.only(top: _buttonPaddingTop),
                  child: Row(children: <Widget>[
                    Padding(
                        padding:
                            EdgeInsets.only(right: _containerPaddingSide / 4),
                        child: Text(
                          "Starting Minute : ",
                          style: TextStyle(fontSize: _mediumFontSize),
                        )),
                    DropdownButton(
                      value: sMinute,
                      items: mins.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          sMinute = value;
                        });
                        // print("I have changed");
                      },
                    ),
                  ])),
              Padding(
                  padding: EdgeInsets.only(top: _buttonPaddingTop * 2),
                  child: TextField(
                    decoration: new InputDecoration(
                      labelText: "Event Name",
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      //fillColor: Colors.green
                    ),
                    controller: eventNameController,
                    maxLines: 1,
                    style: TextStyle(fontSize: _buttonFontSize / 1.3),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: _buttonPaddingTop * 2),
                  child: TextField(
                    decoration: new InputDecoration(
                      labelText: "Event Note(optional)",
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      //fillColor: Colors.green
                    ),
                    controller: eventNoteController,
                    maxLines: 1,
                    style: TextStyle(fontSize: _buttonFontSize / 1.3),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: _buttonPaddingTop * 2),
                  child: FlatButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15.0)),
                      child: Center(
                        child: Text(
                          "Create Event",
                          style: TextStyle(
                              fontSize: _buttonFontSize, color: Colors.white),
                        ),
                      ),
                      color: Colors.orangeAccent,
                      onPressed: () {
                        if (eventNameController.text.length == 0) {
                          Scaffold.of(context).showSnackBar(ErrorSnackBar(
                              "Event name can't be empty", _buttonFontSize));
                          return;
                        }
                        int cHour = int.parse(sHour.split(":")[0]);
                        String amPm = sHour.substring(sHour.length - 2);
                        print(amPm);
                        if (amPm == "PM") {
                          cHour += 12;
                        }
                        var timeRange = [cHour, (cHour + 1) % 24];
                        var ress = dayTime.getTimes(sDay, timeRange);
                        ress.forEach((dayHour) {
                          // print("I am here");
                          // print(dayHour);
                          // print(i);
                          var day = dayHour[0];
                          var intHour = dayHour[1];
                          // print(day);
                          time = day + " t" + intHour.toInt().toString();
                        });
                        String note = eventNoteController.text.length > 0
                            ? eventNoteController.text
                            : " ";
                        var eventName = eventNameController.text;
                        Event event =
                            Event(eventName, 1, note, time, sMinute, []);
                        if (!buttonBlocked) {
                          buttonBlocked = true;
                          _request
                              .createEventRequest(event, _team)
                              .then((msg) async {
                            sendAnalyticsEvent(
                                session.analytics, "create_event", {});
                            Scaffold.of(context).showSnackBar(
                                SucessSnackBar(msg, _buttonFontSize));
                            await Future.delayed(Duration(seconds: 2));
                            Navigator.pop(context);
                          }).catchError((err) {
                            print(err);
                            handleError(err, context, _buttonFontSize);
                          });
                        }
                      }))
            ]);
          },
        ));
  }
}

class CreateEventScreen extends StatefulWidget {
  Session session;
  String _teamName;
  String _gameName;
  String time;
  List<String> hour;
  String sHour;
  String sDay;
  List<String> mins = List();
  int numberOfPlayers;
  CreateEventScreen(
      session, teamName, gameName, time, parsedHour, numberOfPlayers) {
    this.session = session;
    _teamName = teamName;
    _gameName = gameName;
    this.time = time;
    this.numberOfPlayers = numberOfPlayers;
    sHour = parsedHour;
    hour = new List<String>();
    for (int i = 0; i < 24; i++) {
      if (i < 12) {
        hour.add(i.toString() + ":00AM");
      } else {
        hour.add((i % 12).toString() + ":00PM");
      }
    }
    print(hour);
    for (int i = 0; i < 60; i++) {
      mins.add(i.toString());
    }
    sDay = time.split(" ")[0];
  }
  _CreateEventState createState() => _CreateEventState(session, _teamName,
      _gameName, hour, sHour, mins, time, sDay, numberOfPlayers);
}
