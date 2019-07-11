import 'package:ScrimUp/models/Event.dart';
import 'package:ScrimUp/models/ParsedEvent.dart';
import 'package:flutter/material.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";
import '../utils/AvailabilityParse.dart';
import '../utils/widgets.dart';
import './CreateEvent.dart';
import '../utils/Navigation.dart';
import '../utils/FirebaseAnalytics.dart';

class _EventsState extends State<EventsScreen> {
  String _gameName;
  String _teamName;
  Session session;
  DayTime dayTime;
  String _errorMessage;
  List<ParsedEvent> events = List<ParsedEvent>();
  BuildContext scaffoldContext;
  double isLeader;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _mediumFontSize;
  bool isLoaded = false;
  bool empty = true;
  int selectedGameIndex;
  var lastSize = 0;

  var games;
  var teams;

  String nickName;

  List<Widget> eventCardBottom = [];
  var isExpanded = [];
  List<Widget> actionsRows = [];
  var responseEvents = [];
  final double _cardBorderRadius = 17.0;
  void expandClicked(int index) {
    print("Clicked");
    setState(() {
      isExpanded[index] = !isExpanded[index];
    });
  }

  String capitalize(String string) {
    try {
      return string[0].toUpperCase() + string.substring(1);
    } catch (e) {
      return string;
    }
  }

  List<NewItem> items = new List<NewItem>();
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
      events = List<ParsedEvent>();
      responseEvents = response3["events"];
      isExpanded = [];
      for (int i = 0; i < responseEvents.length; i++) {
        isExpanded.add(false);
        events.add(ParsedEvent.fromJson(
            responseEvents[i], dayTime, response3["nickName"]));
        List<Widget> widgetList = [];
        if (events[i].joinable) {
          widgetList.add(FlatButton(
            child: Text("Join"),
            color: Colors.green,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(_cardBorderRadius)),
            onPressed: () {
              if (events[i].joinable) {
                var joinEventUrl = "/team/joinEvent";
                session.post(joinEventUrl, {
                  "team": _teamName,
                  "game": _gameName,
                  "eventTime": events[i].time,
                  "eventName": events[i].name,
                }).then((response) {
                  if (response["success"]) {
                    sendAnalyticsEvent(session.analytics, "join_event", {});

                    Scaffold.of(scaffoldContext).showSnackBar(
                        SucessSnackBar(response["msg"], _buttonFontSize));
                    _getRequest();
                  } else {
                    Scaffold.of(scaffoldContext).showSnackBar(
                        ErrorSnackBar(response["msg"], _buttonFontSize));
                  }
                });
              }
            },
          ));
        } else {
          widgetList.add(FlatButton(
            child: Text("Leave Event"),
            color: Colors.red,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(_cardBorderRadius)),
            onPressed: () {
              if (!events[i].joinable) {
                areYouSureDialog(
                        "Are you sure you want to leave the event ?", context)
                    .then((sure) {
                  if (sure) {
                    var joinEventUrl = "/team/leaveEvent";
                    session.post(joinEventUrl, {
                      "team": _teamName,
                      "game": _gameName,
                      "eventName": events[i].name,
                    }).then((response) {
                      if (response["success"]) {
                        sendAnalyticsEvent(
                            session.analytics, "leave_event", {});
                        Scaffold.of(scaffoldContext).showSnackBar(
                            SucessSnackBar(response["msg"], _buttonFontSize));
                        _getRequest();
                      } else {
                        Scaffold.of(scaffoldContext).showSnackBar(
                            ErrorSnackBar(response["msg"], _buttonFontSize));
                      }
                    });
                  }
                });
              }
            },
          ));
        }
        if (isLeader == 1.0) {
          widgetList.add(Padding(
              padding: EdgeInsets.only(left: _containerPaddingSide / 4),
              child: FlatButton(
                child: Text("Delete Event"),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(_cardBorderRadius)),
                color: Colors.red,
                onPressed: () {
                  if (isLeader == 1.0) {
                    areYouSureDialog(
                            "Are you sure you want to delete the event ?",
                            context)
                        .then((sure) {
                      if (sure) {
                        var deleteEventUrl = "/team/deleteEvent";
                        session.post(deleteEventUrl, {
                          "team": _teamName,
                          "game": _gameName,
                          "eventName": events[i].name,
                        }).then((response) {
                          if (response["success"]) {
                            sendAnalyticsEvent(
                                session.analytics, "delete_event", {});
                            Scaffold.of(scaffoldContext).showSnackBar(
                                SucessSnackBar(
                                    response["msg"], _buttonFontSize));
                            _getRequest();
                          } else {
                            Scaffold.of(scaffoldContext).showSnackBar(
                                ErrorSnackBar(
                                    response["msg"], _buttonFontSize));
                          }
                        });
                      }
                    });
                  }
                },
              )));
        }

        actionsRows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgetList,
        ));
        Widget body = ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: _buttonPaddingTop),
              child: Text(
                "Players: ",
                style: TextStyle(fontSize: _buttonFontSize * 1.5),
              ),
            ),
            ListView.builder(
              itemCount: events[i].players.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return Row(children: <Widget>[
                  Padding(
                      child: MyBullet(),
                      padding: EdgeInsets.only(
                          left: _containerPaddingSide / 8,
                          right: _containerPaddingSide / 4)),
                  Text(events[i].players[index],
                      style: TextStyle(fontSize: _buttonFontSize * 1.2)),
                ]);
              },
            ),
          ],
        );
        items.add(NewItem(false, null, body, Icon(Icons.list)));
      }
      print(actionsRows.length);
    });
  }

  void _getRequest() {
    var getChallengesUrl = "/team/getEvents";
    session.post(getChallengesUrl, {
      "gameName": _gameName,
      "teamName": _teamName,
    }).then((response3) {
      if (response3["success"]) {
        sendAnalyticsEvent(session.analytics, "check_events", {});
        requestsLoaded(response3);
      }
    });
  }

  _EventsState(this._gameName, this._teamName, this.session, this.isLeader,
      this.games, this.teams, this.selectedGameIndex);

  @override
  Widget build(BuildContext context) {
    double localDiff = DateTime.now().timeZoneOffset.inHours.toDouble();

    dayTime = new DayTime(localDiff);
    Size size = MediaQuery.of(context).size;
    // print(size.width);
    // print(size.height);
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.030;
    lastSize = 0;
    var bottomNavigation = bottomNavigationBar(2, context, teams, games,
        _teamName, _gameName, session, isLeader, selectedGameIndex);
    var leftDrawer = drawer(teams, games, context, session, selectedGameIndex);

    var getChallengesUrl = "/team/getEvents";
    if (!isLoaded) {
      session.post(getChallengesUrl, {
        "gameName": _gameName,
        "teamName": _teamName,
      }).then((response3) {
        if (response3["success"]) {
          isLoaded = true;
          requestsLoaded(response3);
        } else {
          setState(() {
            isLoaded = true;
          });
        }
      });
      // No events
    }

    return new Scaffold(
      bottomNavigationBar: bottomNavigation,
      drawer: leftDrawer,
      appBar: AppBar(
        title: Text("Scrim UP"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventScreen(
                  session, _teamName, _gameName, "monday 5", "0:00AM", 0),
            ),
          ).then((_) {
            _getRequest();
          }); //Ad
        },
      ),
      body: Builder(builder: (BuildContext context) {
        scaffoldContext = context;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: _containerPaddingSide / 3),
          child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: _buttonPaddingTop),
              itemCount: events.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return new Card(
                      color: Color.fromRGBO(100, 100, 100, 100),
                      // TODO: add card shadow
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(_cardBorderRadius))),
                      child: Column(
                        children: <Widget>[
                          ClipRRect(
                            child: Image(
                              image: AssetImage(
                                  'assets/images/event-promo-card.jpg'),
                            ),
                            borderRadius:
                                new BorderRadius.circular(_cardBorderRadius),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: _buttonPaddingTop * 2),
                              child: Text(
                                "Events",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: _headerFontSize / 1.2),
                              )),
                          Padding(
                              padding:
                                  EdgeInsets.only(bottom: _headerPaddingTop),
                              child: Text(
                                "Events are fun. Create events and enjoy playing games with your team.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: _buttonFontSize),
                              ))
                        ],
                      ));
                } else {
                  ParsedEvent event = events[index - 1];
                  var eventDetailButton = FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius:
                            new BorderRadius.circular(_cardBorderRadius)),
                    color: Colors.orange,
                    child: Text(
                      "Event Details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: _buttonFontSize, color: Colors.white),
                    ),
                    onPressed: () {
                      expandClicked(index - 1);
                    },
                  );
                  var cardBottom;
                  if (!isExpanded[index - 1]) {
                    cardBottom = eventDetailButton;
                  } else {
                    cardBottom = ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        eventDetailButton,
                        items[index - 1].body
                      ],
                    );
                  }
                  return new Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop * 2),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(_cardBorderRadius)),
                              image: DecorationImage(
                                image:
                                    AssetImage("assets/images/event-card.jpg"),
                                fit: BoxFit.cover,
                                colorFilter: new ColorFilter.mode(
                                    Colors.black.withOpacity(0.8),
                                    BlendMode.multiply),
                              )),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: _buttonPaddingTop),
                                  child: Text(
                                    capitalize(event.name),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: _headerFontSize / 1.2),
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: _buttonPaddingTop * 2),
                                  child: Text(
                                    capitalize(event.day) +
                                        " " +
                                        event.accurateTime,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: _headerFontSize / 1.4),
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: _buttonPaddingTop),
                                  child: Text(
                                    capitalize(event.note),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: _buttonFontSize),
                                  )),
                              Padding(
                                padding:
                                    EdgeInsets.only(top: _buttonPaddingTop),
                                child: actionsRows[index - 1],
                              ),
                              GestureDetector(
                                  onTap: () {
                                    expandClicked(index - 1);
                                  },
                                  child: cardBottom)
                            ],
                          )));
                }
              }),
        );
      }),
    );
  }
}

class EventsScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  Session session;
  double isLeader;
  var games;
  int selectedGameIndex;
  var teams;
  EventsScreen(
      this._gameName,
      this._teamName,
      this.session,
      this.isLeader,
      this.games,
      this.teams,
      this.selectedGameIndex); // TODO: change all constructors to look like this if possible

  @override
  _EventsState createState() => _EventsState(
      _gameName, _teamName, session, isLeader, games, teams, selectedGameIndex);
}
