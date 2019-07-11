import 'package:flutter/material.dart';
import '../InitializeApp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";
import "../utils/widgets.dart";
import '../utils/AvailabilityParse.dart';
import '../team/CreateEvent.dart';
import '../utils/Navigation.dart';
import './availability.dart';
import '../utils/FirebaseAnalytics.dart';
import '../utils/DynamicLinks.dart';

class _TeamAvailabilityState extends State<TeamAvailabilityScreen>
    with WidgetsBindingObserver {
  // TODO: add dropdown button for who is absent and not backend supports it.
  // TODO: fix the double int bug.

  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _mediumFontSize;
  double _expansionPanelHeaderFontSize;
  String _errorMessage;
  bool isLoaded = false;
  int selectedGameIndex;
  bool areEnoughTimes = false;
  var days = [];
  var hours = [];
  var noUsers = [];
  String _gameName;
  BuildContext _tempContext;
  double isLeader;
  String _teamName;
  Session session;
  var games;
  var teams;
  List<NewItem> items;
  int lastMax = -1;
  void getTimes() {
    setState(() {
      var teamRequestsUrl = "/team/getBestTimes";
      session.post(teamRequestsUrl,
          {"gameName": _gameName, "teamName": _teamName}).then((response3) {
        sendAnalyticsEvent(session.analytics, "check_team_availability", {});
        requestsLoaded(response3);
      });
    });
  }

  initState() {
    retrieveDynamicLink().then((s) {
      if (s != null) {
        print("Token is " + s.queryParams["token"]);
        String token = s.queryParams["token"];
        if (token.length > 0) {
          joinTeamWithToken(
              token, _tempContext, session, _buttonFontSize, _buttonPaddingTop);
        }
      }
    });
    getTimes();
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
            joinTeamWithToken(token, _tempContext, session, _buttonFontSize,
                _buttonPaddingTop);
          }
        }
      });
    }
  }

  _TeamAvailabilityState(this._gameName, this._teamName, this.session,
      this.isLeader, this.games, this.teams, this.selectedGameIndex);
  void requestsLoaded(response3) {
    if (!response3["success"]) {
      if (response3["msg"] == "Login first") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  new InitiliazeApp(session.analytics, session.observer)),
        );
      } else {
        _errorMessage = response3["msg"];
        Scaffold.of(context)
            .showSnackBar(ErrorSnackBar(_errorMessage, _buttonFontSize));
      }
    }
    setState(() {
      items = new List<NewItem>();
      isLoaded = true;
      // print(DateTime.now().timeZoneOffset.toString());
      double localDiff = DateTime.now().timeZoneOffset.inHours.toDouble();

      DayTime dayTime;
      dayTime = new DayTime(localDiff);
      var times = response3["bests"];
      if (times.length > 0) {
        setState(() {
          areEnoughTimes = true;
          return;
        });
      }
      var current;
      days = [];
      hours = [];
      noUsers = [];
      String day;
      String hour;
      List<String> dayHour;
      int numberOfUsers;
      for (int i = 0; i < times.length; i++) {
        current = times[i]["time"].split(" ");
        day = current[0];
        hour = current[1];
        dayHour = dayTime.parseTime(day, hour);
        numberOfUsers = times[i]["precision"];
        days.add(dayHour[0]);
        hours.add(dayHour[1]);
        noUsers.add(numberOfUsers);
        print(numberOfUsers);
        // print(numberOfUsers);
        var currentColor = Colors.green;
        Widget header = GestureDetector(
          onTap: () {
            setState(() {
              items[i].isExpanded = !items[i].isExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people,
                color: Colors.orangeAccent,
              ),
              Padding(
                  padding: EdgeInsets.only(right: _containerPaddingSide / 10),
                  child: Text(
                    noUsers[i].toString(),
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: _expansionPanelHeaderFontSize),
                  )),
              Container(
                alignment: Alignment.centerLeft,
                width: _containerPaddingSide * 2.5,
                child: FlatButton(
                  child: Text(
                    days[i],
                    style: TextStyle(
                        fontSize: _expansionPanelHeaderFontSize * 1.5),
                  ),
                  onPressed: () {
                    setState(() {
                      items[i].isExpanded = !items[i].isExpanded;
                    });
                  },
                ),
              ),
              FlatButton(
                color: currentColor,
                child: Center(
                  child: Text(
                    hours[i],
                    style: TextStyle(
                        fontSize: _expansionPanelHeaderFontSize * 1.5),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    items[i].isExpanded = !items[i].isExpanded;
                  });
                },
              ),
            ],
          ),
        );
        var available = times[i]["available"];
        var absent = times[i]["absent"];
        var realAbsents = [];
        var notActive = times[i]["notActive"];
        for (int i = 0; i < absent.length; i++) {
          if (!(notActive.contains(absent[i]))) {
            realAbsents.add(absent[i]);
          }
        }
        Widget body = ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount:
              available.length + realAbsents.length + notActive.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index ==
                available.length + realAbsents.length + notActive.length) {
              return Opacity(
                opacity: isLeader,
                child: FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15.0)),
                    color: Colors.orange,
                    child: Center(
                      child: Text(
                        "Create Event",
                        style: TextStyle(
                            fontSize: _buttonFontSize, color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      if (isLeader == 1.0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateEventScreen(
                                session,
                                _teamName,
                                _gameName,
                                times[i]["time"],
                                hours[i].split("-")[0],
                                available.length),
                          ),
                        ).then((_) {
                          getTimes();
                        });
                      } //Add then refresh the content
                    }),
              );
            }
            if (index > available.length - 1 + realAbsents.length) {
              return ListTile(
                  leading: Icon(FontAwesomeIcons.question),
                  title: Text(notActive[
                      index - available.length - realAbsents.length]));
            } else if (index < available.length) {
              return ListTile(
                  leading: Icon(Icons.check, color: Colors.green),
                  title: Text(available[index]));
            } else {
              return ListTile(
                  leading: Icon(FontAwesomeIcons.times, color: Colors.red),
                  title: Text(realAbsents[index - available.length]));
            }
          },
        );
        items.add(NewItem(false, header, body, Icon(Icons.list)));
      }
      // print(days);
      // print(hours);
      // print(noUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    _tempContext = context;
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.006;
    _expansionPanelHeaderFontSize = size.width * 0.02;
    _containerPaddingSide = size.width * 0.12;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.030;
    var leftDrawer = drawer(teams, games, context, session, selectedGameIndex);

    var bottomNavigation = bottomNavigationBar(1, context, teams, games,
        _teamName, _gameName, session, isLeader, selectedGameIndex);
    if (!isLoaded) {
      return new Scaffold(
        bottomNavigationBar: bottomNavigation,
        drawer: leftDrawer,
        appBar: AppBar(
          title: Text("Scrim UP"),
        ),
        body: Container(
          padding:
              EdgeInsets.symmetric(horizontal: _containerPaddingSide / 3.5),
          child: ListView(children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: _headerPaddingTop),
              child: Text(
                "Best Times",
                style: TextStyle(fontSize: _headerFontSize),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: _buttonPaddingTop * 15),
                child: Text("Best Times Are Loading",
                    style: TextStyle(
                      fontSize: _buttonFontSize * 1.8,
                    )),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: _buttonPaddingTop * 4),
              child: Center(
                child: new Spinner(),
              ),
            ),
          ]),
        ),
      );
    }
    // No best times
    if (items.length == 0) {
      return new Scaffold(
        bottomNavigationBar: bottomNavigation,
        drawer: leftDrawer,
        appBar: AppBar(
          title: Text("Scrim UP"),
        ),
        body: Container(
          padding:
              EdgeInsets.symmetric(horizontal: _containerPaddingSide / 3.5),
          child: ListView(children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: _headerPaddingTop),
              child: Text(
                "Best Times",
                style: TextStyle(fontSize: _headerFontSize),
              ),
            ),
            Text(
              "Looks like your team have no available times.\nDon’t worry, let’s start with setting some availability.",
              style: TextStyle(fontSize: _buttonFontSize * 0.80),
            ),
            Padding(
              padding: EdgeInsets.only(top: _buttonPaddingTop * 2),
              child: FlatButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(15.0)),
                  color: Colors.orange,
                  child: Center(
                    child: Text(
                      "Set Availability",
                      style: TextStyle(
                          fontSize: _buttonFontSize, color: Colors.white),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        new MaterialPageRoute(
                            builder: (context) => AvailabilityScreen(
                                _gameName,
                                _teamName,
                                session,
                                isLeader,
                                games,
                                teams,
                                selectedGameIndex)),
                        (_) => false);
                  }),
            ),
          ]),
        ),
      );
    }
    return new Scaffold(
        bottomNavigationBar: bottomNavigation,
        drawer: leftDrawer,
        appBar: AppBar(
          title: Text("Scrim UP"),
        ),
        body: Container(
          padding:
              EdgeInsets.symmetric(horizontal: _containerPaddingSide / 3.5),
          child: ListView(children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: _headerPaddingTop),
              child: Text(
                "Best Times",
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
            Padding(
                padding: EdgeInsets.only(top: _buttonPaddingTop * 2),
                child: Text(
                  "* The times shown are automatically converted to your time zone.",
                  style: TextStyle(fontSize: _buttonFontSize / 1.5),
                )),
          ]),
        ));
  }
}

class TeamAvailabilityScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  Session session;
  int selectedGameIndex;
  var games;
  var teams;
  double isLeader;

  TeamAvailabilityScreen(this._gameName, this._teamName, this.session,
      this.isLeader, this.games, this.teams, this.selectedGameIndex);
  @override
  _TeamAvailabilityState createState() => _TeamAvailabilityState(
      _gameName, _teamName, session, isLeader, games, teams, selectedGameIndex);
}
