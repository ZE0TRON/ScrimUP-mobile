import 'package:flutter/material.dart';
import '../utils/parsers.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";
import '../utils/AvailabilityParse.dart';
import '../utils/TimeButton.dart';
import '../utils/widgets.dart';
import '../utils/FirebaseAnalytics.dart';

class _DetailedAvailabilityState extends State<DetailedAvailabilityScreen> {
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  Availability availability;
  Availability previousAvailability;
  String header;
  String _gameName;
  String _teamName;
  Session session;
  double isError = 0.0;
  String _errorMessage = "";
  String currentDay;
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
  var apiWeekDays = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];
  var times = [
    "0AM-2AM",
    "2AM-6AM",
    "6AM-11AM",
    "11AM-1PM",
    "1PM-3PM",
    "3PM-5PM",
    "5PM-7PM",
    "7PM-9PM",
    "9PM-12AM",
  ];
  var apiTimes = [
    [0, 2],
    [2, 6],
    [6, 11],
    [11, 13],
    [13, 15],
    [15, 17],
    [17, 19],
    [19, 21],
    [21, 0]
  ];
  DateTime thisDay;
  bool isLoaded = false;
  DayTime dayTime;
  Map<String, Map<int, int>> currentAvailability = new Map();
  Map<String, Map<int, int>> prevAvailability = new Map();
  _DetailedAvailabilityState(
      DateTime thisDay, String gameName, String teamName, Session session) {
    this.thisDay = thisDay;
    this.currentDay = apiWeekDays[(thisDay.weekday - 1) % 7];
    header = weekdays[thisDay.weekday] + "(" + thisDay.day.toString() + "th)";
    this._gameName = gameName;
    this._teamName = teamName;
    this.session = session;
    String localLocale = DateTime.now().timeZoneName;
    double localDiff = DateTime.now().timeZoneOffset.inHours.toDouble();

    this.dayTime = new DayTime(localDiff);
  }
  void onRequestLoad(response) {
    setState(() {
      isLoaded = true;
      availability = new Availability();
      previousAvailability = new Availability();
      if (response["success"]) {
        var resAvailability = response["availability"];
        var resPrevAvailability = response["prevAvailability"];
        for (int i = 0; i < 7; i++) {
          currentAvailability[apiWeekDays[i]] = new Map<int, int>();
          prevAvailability[apiWeekDays[i]] = new Map<int, int>();
        }
        for (int i = 0; i < 7; i++) {
          for (int j = 0; j < 24; j++) {
            var ress =
                dayTime.singleHourParse(apiWeekDays[i], "t" + j.toString());
            var day = ress[0];
            var hour = ress[1];
            currentAvailability[day][int.parse(hour)] =
                resAvailability[apiWeekDays[i]]["t" + j.toString()];
            prevAvailability[day][int.parse(hour)] =
                resPrevAvailability[apiWeekDays[i]]["t" + j.toString()];
          }
        }
        // print(currentAvailability[currentDay]);
        // print("Res Availability");
        // print(resAvailability[currentDay]);
        availability.parseAvailability(currentAvailability[currentDay]);
        previousAvailability.parseAvailability(prevAvailability[currentDay]);
        // print(availability.getAvailabilities());
      } else {
        // No scaffold here so no error message
      }
    });
  }

  // TODO: add clear availability button.
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    _buttonPaddingTop = size.height * 0.008;
    _containerPaddingSide = size.width * 0.12;
    _headerPaddingTop = size.height * 0.025;
    _headerFontSize = size.height * 0.034;
    _buttonFontSize = size.height * 0.02;
    if (!isLoaded) {
      var getDayAvailabilityUrl = "/account/getDayAvailability";
      session.post(getDayAvailabilityUrl, {"game": _gameName}).then((response) {
        onRequestLoad(response);
      });
      return new Center(child: Spinner());
    }
    return new Scaffold(
      appBar: AppBar(
        title: Text("Scrim UP"),
      ),
      //floatingActionButton: FloatingActionButton.extended(icon: Icon(Icons.date_range),label: Text("Previous Availability"),backgroundColor: Colors.orange,),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: _headerPaddingTop),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: _containerPaddingSide / 3.5),
            child: ListView.builder(
              itemCount: times.length + 3,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return new Padding(
                    padding: EdgeInsets.symmetric(vertical: _headerPaddingTop),
                    child: Text(
                      "Pick Best Times\n" + header,
                      style: TextStyle(fontSize: _headerFontSize),
                    ),
                  );
                } else if (index == times.length + 1) {
                  return new Padding(
                    padding: EdgeInsets.only(top: _headerPaddingTop),
                    child: FlatButton(
                      child: Center(
                        child: Text(
                          "Set Availability",
                          style: TextStyle(
                              fontSize: _buttonFontSize * 1.3,
                              color: Colors.orangeAccent),
                        ),
                      ),
                      onPressed: () {
                        // print(weekdays[thisDay.weekday]);
                        var setHoursUrl = "/account/setHours";
                        List<HourAvailability> hours = [];
                        for (int i = 0; i < times.length; i++) {
                          var ress = dayTime.getTimes(currentDay, apiTimes[i]);
                          ress.forEach((dayHour) {
                            // print("I am here");
                            // print(dayHour);
                            // print(i);
                            var day = dayHour[0];
                            var intHour = dayHour[1];
                            // print(day);
                            hours.add(new HourAvailability(
                                day + "-t" + intHour.toInt().toString(),
                                availability.getAvailability(i)));
                          });
                        }
                        // print("Team name is :");
                        // print(_teamName);
                        UserAvailability postBody = UserAvailability(
                            _gameName, _teamName, "single", hours);
                        // print("Json body");
                        // print(json.encode(postBody));
                        session
                            .apiRequest(setHoursUrl, postBody.toJson())
                            .then((response) {
                          var success = response["success"];

                          if (success) {
                            sendAnalyticsEvent(
                                session.analytics, "set_availability", {});
                            Navigator.pop(context);
                          } else {
                            _errorMessage = response["msg"];
                            Scaffold.of(context).showSnackBar(
                                ErrorSnackBar(_errorMessage, _buttonFontSize));
                            if (_errorMessage == "Login first") {
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, "/", (_) => false);
                              });
                            }
                          }
                        });
                      },
                    ),
                  );
                } else if (index == times.length + 2) {
                  return Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop),
                      child: Text(
                        "* The times shown are automatically converted to your time zone.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: _buttonFontSize / 1.25),
                      ));
                } else {
                  return new Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop),
                      child: TimeButton(
                          times[index - 1], availability, index - 1, 10, 0.05));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DetailedAvailabilityScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  DateTime thisDay;
  Session session;
  String teamLocale;
  DetailedAvailabilityScreen(
      this.thisDay, this._gameName, this._teamName, this.session);
  @override
  _DetailedAvailabilityState createState() =>
      _DetailedAvailabilityState(thisDay, _gameName, _teamName, session);
}
