import 'package:flutter/material.dart';
import '../utils/parsers.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";
import '../utils/AvailabilityParse.dart';
import '../utils/TimeButton.dart';
import '../utils/widgets.dart';
import '../utils/FirebaseAnalytics.dart';

class _LongTermState extends State<LongTermAvailabilityScreen> {
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  String _gameName;
  String _teamName;
  String _errorMessage = "";
  double isError = 0.0;
  Session session;
  String teamLocale;
  var weekdays = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];
  GeneralAvailability weekDaysAvailability;
  GeneralAvailability saturdayAvailability;
  GeneralAvailability sundayAvailability;
  bool isLoaded = false;

  var times = [
    "0AM\n2AM",
    "2AM\n8AM",
    "8AM\n12PM",
    "12PM\n6PM",
    "6PM\n8PM",
    "8PM\n12AM",
  ];
  var apiTimes = [
    [0, 2],
    [2, 8],
    [8, 12],
    [12, 18],
    [18, 20],
    [20, 0],
  ];
  DayTime dayTime;
  _LongTermState(String gameName, String teamName, Session session) {
    this._gameName = gameName;
    this._teamName = teamName;
    this.session = session;
    double localDiff = DateTime.now().timeZoneOffset.inHours.toDouble();
    // print("local diff");
    // print(localDiff);
    this.dayTime = new DayTime(localDiff);
  }
  Map<String, Map<int, int>> currentAvailability = new Map();
  void onRequestLoad(response) {
    setState(() {
      isLoaded = true;
      weekDaysAvailability = GeneralAvailability();
      saturdayAvailability = GeneralAvailability();
      sundayAvailability = GeneralAvailability();
      if (response["success"]) {
        var resAvailability = response["availability"];
        for (int i = 0; i < 7; i++) {
          currentAvailability[weekdays[i]] = new Map<int, int>();
        }
        for (int i = 0; i < 7; i++) {
          for (int j = 0; j < 24; j++) {
            var ress = dayTime.singleHourParse(weekdays[i], "t" + j.toString());
            var day = ress[0];
            var hour = ress[1];
            currentAvailability[day][int.parse(hour)] =
                resAvailability[weekdays[i]]["t" + j.toString()];
          }
        }
        var weekDayAverage = [];
        // print(currentAvailability);
        for (int j = 0; j < 24; j++) {
          var currentAverage = 0.0;

          for (int i = 0; i < 5; i++) {
            currentAverage += currentAvailability[weekdays[i]][j] + 0.0;
          }
          currentAverage = currentAverage / 5;
          weekDayAverage.add(currentAverage);
        }
        weekDaysAvailability.parseAvailability(weekDayAverage);
        // print(weekDaysAvailability.getAvailabilities());
        saturdayAvailability.singleDayParse(currentAvailability["saturday"]);
        sundayAvailability.singleDayParse(currentAvailability["sunday"]);
      } else {
        // No scaffold here so no error message
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double radius = 0;
    double multiplier = 0.09;
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
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
      body: Builder(
        builder: (BuildContext context) {
          return new Center(
            child: Padding(
              padding: EdgeInsets.only(top: _headerPaddingTop),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: _containerPaddingSide / 3.5),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop),
                      child: Text(
                        "Pick General Availability",
                        style: TextStyle(fontSize: _headerFontSize),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: _headerPaddingTop, bottom: _buttonPaddingTop),
                      child: Text(
                        "Weekdays",
                        style: TextStyle(fontSize: _buttonFontSize),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TimeButton(times[0], weekDaysAvailability, 0,
                                  radius, multiplier),
                              TimeButton(times[1], weekDaysAvailability, 1,
                                  radius, multiplier),
                              TimeButton(times[2], weekDaysAvailability, 2,
                                  radius, multiplier),
                              TimeButton(times[3], weekDaysAvailability, 3,
                                  radius, multiplier),
                              TimeButton(times[4], weekDaysAvailability, 4,
                                  radius, multiplier),
                              TimeButton(times[5], weekDaysAvailability, 5,
                                  radius, multiplier),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: _headerPaddingTop, bottom: _buttonPaddingTop),
                      child: Text(
                        "Saturday",
                        style: TextStyle(fontSize: _buttonFontSize),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop),
                      child: Center(
                        //TODO: handle day changes in a proper way
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TimeButton(times[0], saturdayAvailability, 0,
                                  radius, multiplier),
                              TimeButton(times[1], saturdayAvailability, 1,
                                  radius, multiplier),
                              TimeButton(times[2], saturdayAvailability, 2,
                                  radius, multiplier),
                              TimeButton(times[3], saturdayAvailability, 3,
                                  radius, multiplier),
                              TimeButton(times[4], saturdayAvailability, 4,
                                  radius, multiplier),
                              TimeButton(times[5], saturdayAvailability, 5,
                                  radius, multiplier),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: _headerPaddingTop, bottom: _buttonPaddingTop),
                      child: Text(
                        "Sunday",
                        style: TextStyle(fontSize: _buttonFontSize),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TimeButton(times[0], sundayAvailability, 0,
                                  radius, multiplier),
                              TimeButton(times[1], sundayAvailability, 1,
                                  radius, multiplier),
                              TimeButton(times[2], sundayAvailability, 2,
                                  radius, multiplier),
                              TimeButton(times[3], sundayAvailability, 3,
                                  radius, multiplier),
                              TimeButton(times[4], sundayAvailability, 4,
                                  radius, multiplier),
                              TimeButton(times[5], sundayAvailability, 5,
                                  radius, multiplier),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
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
                          // print("weekdays");
                          weekDaysAvailability
                              .getAvailabilities()
                              .forEach((value) {
                            // print(value);
                          });
                          // print("saturday");
                          saturdayAvailability
                              .getAvailabilities()
                              .forEach((value) {
                            // print(value);
                          });
                          // print("sunday");
                          sundayAvailability
                              .getAvailabilities()
                              .forEach((value) {
                            // print(value);
                          });
                          var setGeneralHoursUrl = "/account/setHours";
                          List<HourAvailability> hours = [];
                          for (int i = 0; i < apiTimes.length; i++) {
                            [
                              "monday",
                              "tuesday",
                              "wednesday",
                              "thursday",
                              "friday",
                            ].forEach((day) {
                              var ress = dayTime.getTimes(day, apiTimes[i]);
                              ress.forEach((intHours) {
                                var currentDay = intHours[0];
                                var intHour = intHours[1];
                                hours.add(new HourAvailability(
                                    currentDay +
                                        "-t" +
                                        intHour.toInt().toString(),
                                    weekDaysAvailability.getAvailability(i)));
                              });
                            });
                          }
                          for (int i = 0; i < apiTimes.length; i++) {
                            String day = "saturday";
                            var ress = dayTime.getTimes(day, apiTimes[i]);
                            ress.forEach((intHours) {
                              var currentDay = intHours[0];
                              var intHour = intHours[1];
                              hours.add(new HourAvailability(
                                  currentDay +
                                      "-t" +
                                      intHour.toInt().toString(),
                                  saturdayAvailability.getAvailability(i)));
                            });
                          }
                          for (int i = 0; i < apiTimes.length; i++) {
                            String day = "sunday";
                            var ress = dayTime.getTimes(day, apiTimes[i]);
                            ress.forEach((intHours) {
                              var currentDay = intHours[0];
                              var intHour = intHours[1];
                              hours.add(new HourAvailability(
                                  currentDay +
                                      "-t" +
                                      intHour.toInt().toString(),
                                  sundayAvailability.getAvailability(i)));
                            });
                          }
                          hours.forEach((f) {
                            print(f.key);
                            print(f.value);
                          });
                          UserAvailability postBody = UserAvailability(
                              _gameName, _teamName, "general", hours);
                          // print("Json body");
                          // print(json.encode(postBody));
                          session
                              .apiRequest(setGeneralHoursUrl, postBody.toJson())
                              .then((response) {
                            // print(response);
                            var tempString = response.split(":")[2];
                            var success =
                                tempString.substring(0, tempString.length - 1);
                            if (success == "true") {
                              sendAnalyticsEvent(session.analytics,
                                  "set_general_availability", {});
                              Navigator.pop(context);
                            } else {
                              var tempString2 =
                                  response.split(":")[1].split(",")[0];
                              _errorMessage = tempString2.substring(
                                  1, tempString2.length - 1);
                              if (_errorMessage == "")
                                Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                    _errorMessage, _buttonFontSize));
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(top: _buttonPaddingTop),
                          child: Text(
                            "* The times shown are automatically converted to your time zone.",
                            style: TextStyle(fontSize: _buttonFontSize / 1.25),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LongTermAvailabilityScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  Session session;
  LongTermAvailabilityScreen(this._gameName, this._teamName, this.session);

  @override
  _LongTermState createState() => _LongTermState(_gameName, _teamName, session);
}
