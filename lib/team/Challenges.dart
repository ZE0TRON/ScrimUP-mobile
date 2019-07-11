import 'package:flutter/material.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";
import '../utils/AvailabilityParse.dart';
import '../utils/widgets.dart';
import './ChallengeTeams.dart';
import './ChallengeRequests.dart';
import '../utils/Navigation.dart';
import '../utils/FirebaseAnalytics.dart';

class _ChallengesState extends State<ChallengesScreen> {
  String _gameName;
  String _teamName;
  Session session;
  DayTime dayTime;
  String _errorMessage;
  double isLeader;
  int selectedGameIndex;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;
  var challenges = [];
  bool isLoaded = false;
  bool empty = true;
  var lastSize = 0;
  var days = [];
  var teams;
  var games;
  var hours = [];
  var players = [];
  var exactTimes = [];
  var notes = [];
  var hosts = [];
  var others = [];

  var times = [];
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
      items.clear();
      challenges = [];
      days = [];
      hours = [];
      players = [];
      exactTimes = [];
      notes = [];
      hosts = [];
      others = [];
      times = [];
      isLoaded = true;
      challenges = response3["challenges"];
      var current;
      var day, hour, dayHour;
      for (int i = 0; i < response3["challenges"].length; i++) {
        // print("Length : " + response3["challenges"].toString());
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
        others.add(current["otherTeam"]);
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

  void _getRequest() {
    var getChallengesUrl = "/team/getChallenges";
    session.post(getChallengesUrl, {
      "gameName": _gameName,
      "teamName": _teamName,
    }).then((response3) {
      if (response3["success"]) {
        sendAnalyticsEvent(session.analytics, "check_challenges", {});

        requestsLoaded(response3);
      }
    });
  }

  _ChallengesState(this._gameName, this._teamName, this.session, this.isLeader,
      this.games, this.teams, this.selectedGameIndex);

  @override
  Widget build(BuildContext context) {
    double localDiff = DateTime.now().timeZoneOffset.inHours.toDouble();

    dayTime = new DayTime(localDiff);
    Size size = MediaQuery.of(context).size;
    // print(size.width);
    // print(size.height);
    var bottomNavigation = bottomNavigationBar(3, context, teams, games,
        _teamName, _gameName, session, isLeader, selectedGameIndex);
    var leftDrawer = drawer(teams, games, context, session, selectedGameIndex);
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.030;
    lastSize = 0;

    var getChallengesUrl = "/team/getChallenges";
    if (!isLoaded) {
      session.post(getChallengesUrl, {
        "gameName": _gameName,
        "teamName": _teamName,
      }).then((response3) {
        if (response3["success"]) {
          requestsLoaded(response3);
        } else {
          setState(() {
            isLoaded = true;
          });
        }
      });
    }

    return new Scaffold(
        drawer: leftDrawer,
        bottomNavigationBar: bottomNavigation,
        appBar: AppBar(
          title: Text("Scrim UP"),
          actions: <Widget>[
            Opacity(
              opacity: isLeader,
              child: IconButton(
                icon: new Image.asset(
                  'assets/icon/challenge.png',
                  color: Colors.white,
                ),
                onPressed: () {
                  if (isLeader == 1) {
                    Navigator.of(context)
                        .push(new MaterialPageRoute(
                            builder: (context) => new ChallengeRequestsScreen(
                                _gameName, _teamName, session)))
                        .then((val) {
                      _getRequest();
                    });
                  }
                },
              ),
            )
          ],
        ),
        floatingActionButton: Opacity(
          opacity: isLeader,
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            child: Icon(Icons.add),
            onPressed: () {
              if (isLeader == 1) {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => new ChallengeOtherTeamsScreen(
                            _gameName, _teamName, session)))
                    .then((val) {
                  _getRequest();
                });
              }
            },
          ),
        ),
        body: Container(
            padding:
                EdgeInsets.symmetric(horizontal: _containerPaddingSide / 3.5),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: _headerPaddingTop / 4),
              itemCount: items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Card(
                    color: Color.fromRGBO(100, 100, 100, 100),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(17))),
                    child: Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Column(
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 16 / 7,
                            child: ClipRRect(
                              child: Image(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    'assets/images/challenge-promo-card.jpg'),
                              ),
                              borderRadius: new BorderRadius.only(
                                  topLeft: Radius.circular(17),
                                  topRight: Radius.circular(17)),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: _buttonPaddingTop * 3),
                              child: Text(
                                "Challenges",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: _headerFontSize / 1.2),
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  bottom: _headerPaddingTop,
                                  left: _containerPaddingSide,
                                  right: _containerPaddingSide),
                              child: Text(
                                "Challenge other teams and prove them you are the best.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: _buttonFontSize),
                              ))
                        ],
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: _headerPaddingTop / 4),
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 15 / 8.9,
                            child: Image(
                              image: AssetImage(
                                  'assets/images/challenge-promo-card.jpg'),
                              fit: BoxFit.cover,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                              colorBlendMode: BlendMode.multiply,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: _headerPaddingTop / 2),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: _headerPaddingTop / 4,
                                        horizontal: _containerPaddingSide / 4),
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        '${hosts[index - 1]} VS ${others[index - 1]}',
                                        style: TextStyle(
                                            fontSize: _mediumFontSize * 2),
                                      ),
                                    )),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: _headerPaddingTop / 4),
                                  child: Text(
                                    '${days[index - 1][0].toUpperCase()}${days[index - 1].substring(1)}' +
                                        " " +
                                        hours[index - 1].split('-')[0],
                                    style: TextStyle(fontSize: _mediumFontSize),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: _headerPaddingTop / 4),
                                  child: Text(
                                    notes[index - 1],
                                    style: TextStyle(
                                      fontSize: _mediumFontSize / 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: _headerPaddingTop / 4),
                                  child: Text(
                                    '${players[index - 1]} vs ${players[index - 1]}',
                                    style: TextStyle(
                                      fontSize: _mediumFontSize,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                    ),
                  );
                }
              },
            )));
  }
}

class ChallengesScreen extends StatefulWidget {
  String _gameName;
  String _teamName;
  var games;
  var teams;
  int selectedGameIndex;
  Session session;
  double isLeader;
  ChallengesScreen(
      this._gameName,
      this._teamName,
      this.session,
      this.isLeader,
      this.games,
      this.teams,
      this.selectedGameIndex); // TODO: change all constructors to look like this if possible

  @override
  _ChallengesState createState() => _ChallengesState(
      _gameName, _teamName, session, isLeader, games, teams, selectedGameIndex);
}
