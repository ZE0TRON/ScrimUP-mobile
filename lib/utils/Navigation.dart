import 'package:ScrimUp/game/JoinCreateTeam.dart';
import 'package:ScrimUp/main.dart';
import 'package:ScrimUp/models/Game.dart';
import 'package:ScrimUp/rss/RSS.dart';
import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:ScrimUp/utils/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/parser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Tasks.dart';
import '../team/Challenges.dart';
import '../availability/availability.dart';
import '../availability/TeamAvailability.dart';
import '../team/Events.dart';
import '../team/TeamScreen.dart';
import '../game/GameSelect.dart';
import './widgets.dart';
import 'package:ScrimUp/Strategies.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/avd.dart';

import 'FirebaseAnalytics.dart';

BottomNavigationBar bottomNavigationBar(int selectedIndex, context, teams,
    games, team, game, session, isLeader, selectedGameIndex) {
  var screens = [];
  screens.add(AvailabilityScreen(
      game, team, session, isLeader, games, teams, selectedGameIndex));
  screens.add(TeamAvailabilityScreen(
      game, team, session, isLeader, games, teams, selectedGameIndex));
  screens.add(EventsScreen(
      game, team, session, isLeader, games, teams, selectedGameIndex));
  screens.add(StrategiesScreen(
      game, team, session, isLeader, games, teams, selectedGameIndex));
  screens.add(TasksScreen(
      game, team, session, isLeader, games, teams, selectedGameIndex));
  screens.add(TeamScreen(
      game, team, session, isLeader, games, teams, selectedGameIndex));
  var challengeColor;
  if (selectedIndex == 3) {
    challengeColor = Colors.orangeAccent;
  } else {
    challengeColor = Colors.grey;
  }
  return BottomNavigationBar(
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.timer)),
      BottomNavigationBarItem(
        icon: Icon(FontAwesomeIcons.calendar),
      ),
      BottomNavigationBarItem(icon: Icon(Icons.event)),
      BottomNavigationBarItem(
        icon: new Image.asset(
          'assets/icon/challenge.png',
          color: challengeColor,
          width: 25,
          height: 25,
        ),
      ),
      BottomNavigationBarItem(icon: Icon(Icons.track_changes)),
      BottomNavigationBarItem(icon: Icon(Icons.people)),
    ],
    type: BottomNavigationBarType.fixed,
    currentIndex: selectedIndex,
    selectedItemColor: Colors.orangeAccent,
    onTap: (index) {
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => screens[index]),
          (_) => false);
      print(index.toString() + " tapped.");
    },
  );
}

BottomNavigationBar localBottomNavigationBar(int selectedIndex, context,
    List<Game> games, int selectedGameIndex, LocalDB db) {
  var screens = [];

  screens.add(StrategiesScreen.local(games[selectedGameIndex], db, games));
  screens.add(TasksScreen.local(games[selectedGameIndex], db, games));
  var challengeColor;
  if (selectedIndex == 0) {
    challengeColor = Colors.orangeAccent;
  } else {
    challengeColor = Colors.grey;
  }
  return BottomNavigationBar(
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: new Image.asset(
            'assets/icon/challenge.png',
            color: challengeColor,
            width: 25,
            height: 25,
          ),
          title: Text('Strategies')),
      BottomNavigationBarItem(
          icon: Icon(Icons.track_changes), title: Text('Tasks')),
    ],
    type: BottomNavigationBarType.fixed,
    currentIndex: selectedIndex,
    selectedItemColor: Colors.orangeAccent,
    onTap: (index) {
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => screens[index]),
          (_) => false);
      print(index.toString() + " tapped.");
    },
  );
}

BottomNavigationBar soloNavigationBar(int selectedIndex, context, teams, games,
    team, game, session, isLeader, selectedGameIndex) {
  var screens = [];
  screens.add(StrategiesScreen(
      game, team, session, isLeader, games, teams, selectedGameIndex));
  screens.add(TasksScreen(
      game, team, session, isLeader, games, teams, selectedGameIndex));
  var challengeColor;
  if (selectedIndex == 0) {
    challengeColor = Colors.orangeAccent;
  } else {
    challengeColor = Colors.grey;
  }
  return BottomNavigationBar(
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: new Image.asset(
            'assets/icon/challenge.png',
            color: challengeColor,
            width: 25,
            height: 25,
          ),
          title: Text('Strategies')),
      BottomNavigationBarItem(
          icon: Icon(Icons.track_changes), title: Text('Tasks')),
    ],
    type: BottomNavigationBarType.fixed,
    currentIndex: selectedIndex,
    selectedItemColor: Colors.orangeAccent,
    onTap: (index) {
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => screens[index]),
          (_) => false);
      print(index.toString() + " tapped.");
    },
  );
}

// TODO: add scroll to refresh
Drawer drawer(teams, games, context, Session session, selectedGameIndex) {
  Size size = MediaQuery.of(context).size;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;
  bool isRSSSelected = false;
  _buttonPaddingTop = size.height * 0.006;
  _containerPaddingSide = size.width * 0.12;
  _notificationPadding = size.height * 0.10;
  _headerPaddingTop = size.height * 0.038;
  _headerFontSize = size.height * 0.044;
  _buttonFontSize = size.height * 0.020;
  _mediumFontSize = size.height * 0.030;
  var selecteds = [];
  for (int i = 0; i < games.length + 1; i++) {
    selecteds.add(false);
  }
  selecteds[selectedGameIndex] = true;
  var avatar;
  if (session.avatar.endsWith(".svg")) {
    avatar = CircleAvatar(
        radius: size.height / 15,
        child: SvgPicture.network(session.avatar,
            width: size.height / 12,
            height: size.height / 12,
            fit: BoxFit.fill));
  } else {
    avatar = CircleAvatar(
        radius: size.height / 15,
        backgroundImage: NetworkImage(
          session.avatar,
        ));
  }

  return Drawer(
      child: Column(
    children: <Widget>[
      SafeArea(
        top: true,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(
                FontAwesomeIcons.signOutAlt,
                color: Colors.white,
              ),
              onPressed: () {
                areYouSureDialog("Are you sure you want to logout ?", context)
                    .then((sure) {
                  if (sure) {
                    var logoutUrl = "/account/logout";
                    session.post(logoutUrl, {}).then((response) {
                      if (response["success"]) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (_) => false,
                            arguments: session);
                      }
                    }); // _askedToLead();
                  }
                });
              },
            )
          ],
        ),
      ),
      Padding(
          padding: EdgeInsets.only(
              bottom: _headerPaddingTop / 2, top: _headerPaddingTop / 4),
          child: avatar),
      Padding(
        padding: EdgeInsets.only(
            left: _containerPaddingSide / 2.5, top: _headerPaddingTop / 2),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Games",
                style: TextStyle(
                    fontSize: _headerFontSize / 1.25,
                    fontWeight: FontWeight.w500),
              ),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.plus),
              color: Colors.orangeAccent,
              highlightColor: Colors.grey[800],
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinCreateTeamScreen(session),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[800],
              border: BorderDirectional(
                  top: BorderSide(color: Colors.orangeAccent, width: 0.5),
                  bottom: BorderSide(color: Colors.orangeAccent, width: 0.5))),
          child: ListView.builder(
            padding: EdgeInsets.only(left: _containerPaddingSide / 4),
            shrinkWrap: true,
            itemCount: games.length,
            itemBuilder: (BuildContext context, int index) {
              String gameName =
                  games[index].replaceAll(" ", "\ ").replaceAll(":", "_");
              var gameLogo;
              if (gameName == "Business") {
                gameLogo = Padding(
                    padding:
                        EdgeInsets.only(right: _containerPaddingSide * 0.7),
                    child: Icon(FontAwesomeIcons.businessTime));
              } else if (gameName == "Other") {
                gameLogo = Padding(
                    padding:
                        EdgeInsets.only(right: _containerPaddingSide * 0.7),
                    child: Icon(FontAwesomeIcons.question));
              } else {
                gameLogo = Image.asset(
                  'assets/games/${gameName}_logo.png',
                  height: 60,
                  width: 60,
                );
              }
              String teamName = teams[index];
              if (teamName == null || teamName == "null") {
                teamName = "Solo";
              }
              print("team name is :" + teamName);
              return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: _buttonPaddingTop * 2),
                  enabled: true,
                  leading: gameLogo,
                  title: Text(
                    teamName,
                    style: TextStyle(fontSize: _buttonFontSize * 1.50),
                  ),
                  selected: selecteds[index],
                  onTap: () {
                    if (teamName == "Solo") {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: (context) => StrategiesScreen(games[index],
                                "Solo", session, 1, games, teams, index)),
                      );
                    }
                    // print("You pressed me");
                    else {
                      var isLeaderUrl = "/team/isLeader";
                      session.post(isLeaderUrl, {
                        "gameName": games[index],
                        "teamName": teams[index],
                      }).then((response) {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          new MaterialPageRoute(
                            builder: (context) => TeamAvailabilityScreen(
                                games[index],
                                teams[index],
                                session,
                                response["success"] == true ? 1.0 : 0.0,
                                games,
                                teams,
                                index),
                          ),
                        );
                      });
                    }
                  });
            },
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: _containerPaddingSide / 1.5),
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
            child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: _buttonPaddingTop * 2.5),
                enabled: true,
                leading: Image(
                  height: size.height / 18,
                  image: AssetImage("assets/icon/news.png"),
                  color: Colors.orangeAccent,
                ),
                title: Text(
                  "Esport News",
                  style: TextStyle(
                      fontSize: _buttonFontSize * 1.5,
                      color: Colors.orangeAccent),
                ),
                onTap: () {
                  sendAnalyticsEvent(session.analytics, "get_esport_news", {});
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RSSPage()));
                }),
          ),
        ),
      )
    ],
  ));
}

Drawer soloDrawer(gameList, context, selectedGameIndex, db, String avatar) {
  Size size = MediaQuery.of(context).size;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;
  bool isRSSSelected = false;
  _buttonPaddingTop = size.height * 0.006;
  _containerPaddingSide = size.width * 0.12;
  _notificationPadding = size.height * 0.10;
  _headerPaddingTop = size.height * 0.038;
  _headerFontSize = size.height * 0.044;
  _buttonFontSize = size.height * 0.020;
  _mediumFontSize = size.height * 0.030;
  var selecteds = [];
  for (int i = 0; i < gameList.length + 1; i++) {
    selecteds.add(false);
  }
  selecteds[selectedGameIndex] = true;
  print(avatar);
  return Drawer(
      child: Column(
    children: <Widget>[
      SafeArea(
        top: true,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(
                FontAwesomeIcons.signOutAlt,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/",
                  (_) => false,
                );
              },
            )
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.only(
            bottom: _headerPaddingTop / 2, top: _headerPaddingTop / 4),
        child: CircleAvatar(
          radius: size.height / 15,
          child: SvgPicture.network(
              "https://avatars.dicebear.com/v2/male/" + avatar + ".svg",
              width: size.height / 12,
              height: size.height / 12,
              fit: BoxFit.fill),
          backgroundColor: Colors.white70,
        ),
      ),
      // Text(
      //   gameList[selectedGameIndex].nick,
      //   textAlign: TextAlign.center,
      //   style: TextStyle(fontSize: _mediumFontSize),
      // ),
      Padding(
        padding: EdgeInsets.only(
            left: _containerPaddingSide / 2.5, top: _headerPaddingTop / 2),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Games",
                style: TextStyle(
                    fontSize: _headerFontSize / 1.25,
                    fontWeight: FontWeight.w500),
              ),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.plus),
              color: Colors.orangeAccent,
              highlightColor: Colors.grey[800],
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinCreateTeamScreen.local(
                          db,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[800],
              border: BorderDirectional(
                  top: BorderSide(color: Colors.orangeAccent, width: 0.5),
                  bottom: BorderSide(color: Colors.orangeAccent, width: 0.5))),
          child: ListView.builder(
              padding: EdgeInsets.only(left: _containerPaddingSide / 4),
              shrinkWrap: true,
              itemCount: gameList.length,
              itemBuilder: (BuildContext context, int index) {
                String gameName = gameList[index]
                    .game
                    .replaceAll(" ", "\ ")
                    .replaceAll(":", "_");
                var gameLogo;
                if (gameName == "Business") {
                  gameLogo = Padding(
                      padding:
                          EdgeInsets.only(right: _containerPaddingSide * 0.7),
                      child: Icon(FontAwesomeIcons.businessTime));
                } else if (gameName == "Other") {
                  gameLogo = Padding(
                      padding:
                          EdgeInsets.only(right: _containerPaddingSide * 0.7),
                      child: Icon(FontAwesomeIcons.question));
                } else {
                  gameLogo = Image.asset(
                    'assets/games/${gameName}_logo.png',
                    height: 60,
                    width: 60,
                  );
                }
                return ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: _buttonPaddingTop * 2),
                    enabled: true,
                    leading: gameLogo,
                    title: Text(
                      'Solo',
                      style: TextStyle(fontSize: _buttonFontSize * 1.50),
                    ),
                    selected: selecteds[index],
                    onTap: () {
                      // print("You pressed me");

                      Navigator.pop(context);
                      Navigator.of(context).push(
                        new MaterialPageRoute(
                          builder: (context) => StrategiesScreen.local(
                              gameList[index], db, gameList),
                        ),
                      );
                    });
              }),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: _containerPaddingSide / 1.5),
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
            child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: _buttonPaddingTop * 2.5),
                enabled: true,
                leading: Image(
                  height: size.height / 18,
                  image: AssetImage("assets/icon/news.png"),
                  color: Colors.orangeAccent,
                ),
                title: Text(
                  "Esport News",
                  style: TextStyle(
                      fontSize: _buttonFontSize * 1.5,
                      color: Colors.orangeAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RSSPage()));
                }),
          ),
        ),
      )
    ],
  ));
}
