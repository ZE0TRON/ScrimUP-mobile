// import "package:flutter/material.dart";
// import '../utils/session.dart';
// import '../utils/widgets.dart';
// import './JoinCreateTeam.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../utils/DynamicLinks.dart';
// import '../utils/SnackBars.dart';
// import '../availability/TeamAvailability.dart';
// import 'dart:async';

// class _GameSelectState extends State<GameSelectScreen>
//     with WidgetsBindingObserver {
//   Session session;
//   double _buttonPaddingTop;
//   double _containerPaddingSide;
//   double _headerPaddingTop;
//   double _headerFontSize;
//   double _buttonFontSize;
//   double _notificationPadding;
//   double _mediumFontSize;
//   BuildContext _tempContext;
//   _GameSelectState(this.session);
//   var games = [];

//   var filteredGames = [];
//   bool isGamesLoaded = false;
//   final TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     retrieveDynamicLink().then((s) {
//       if (s != null) {
//         print("Token is " + s.queryParams["token"]);
//         String token = s.queryParams["token"];
//         if (token.length > 0) {
//           joinTeamWithToken(
//               token, _tempContext, session, _buttonFontSize, _buttonPaddingTop);
//         }
//       }
//     });
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       print("I am resuming");
//       retrieveDynamicLink().then((s) {
//         if (s != null) {
//           print("Token is " + s.queryParams["token"]);
//           String token = s.queryParams["token"];
//           if (token.length > 0) {
//             joinTeamWithToken(token, _tempContext, session, _buttonFontSize,
//                 _buttonPaddingTop);
//           }
//         }
//       });
//     }
//   }

//   void loadGames(response) {
//     setState(() {
//       games = [];
//       for (int i = 0; i < response["games"].length; i++) {
//         games.add(response["games"][i].toString());
//       }
//       isGamesLoaded = true;
//     });
//   }

//   void _getGames() {
//     var allowedGamesUrl = "/account/getAllowedGames";
//     session.get(allowedGamesUrl).then((response) {
//       loadGames(response);
//     });
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     _buttonPaddingTop = size.height * 0.006;
//     _containerPaddingSide = size.width * 0.12;
//     _notificationPadding = size.height * 0.10;
//     _headerPaddingTop = size.height * 0.038;
//     _headerFontSize = size.height * 0.044;
//     _buttonFontSize = size.height * 0.020;
//     _mediumFontSize = size.height * 0.030;
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Select Game"),
//         ),
//         body: Builder(builder: (BuildContext context) {
//           if (!isGamesLoaded) {
//             _getGames();
//             return Center(child: Spinner());
//           }
//           _tempContext = context;
//           return new Container(
//             padding: EdgeInsets.symmetric(horizontal: _containerPaddingSide),
//             child: ListView.builder(
//               itemCount: selectGames.length,
//               itemBuilder: (BuildContext context, int index) {
//                 String gameName = selectGames[index]
//                     .replaceAll(" ", "\ ")
//                     .replaceAll(":", "_");
//                 var gameLogo;
//                 if (gameName == "Business") {
//                   gameLogo = Padding(
//                       padding:
//                           EdgeInsets.only(right: _containerPaddingSide * 0.7),
//                       child: Icon(FontAwesomeIcons.businessTime));
//                 } else if (gameName == "Other") {
//                   gameLogo = Padding(
//                       padding:
//                           EdgeInsets.only(right: _containerPaddingSide * 0.7),
//                       child: Icon(FontAwesomeIcons.question));
//                 } else {
//                   gameLogo = Image.asset(
//                     'assets/games/${gameName}_logo.png',
//                     height: 60,
//                     width: 60,
//                   );
//                 }
//                 return ListTile(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: _buttonPaddingTop * 2.5),
//                     enabled: true,
//                     leading: gameLogo,
//                     title: Text(
//                       '${selectGames[index]}',
//                       style: TextStyle(fontSize: _buttonFontSize * 1.5),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   JoinCreateTeamScreen(session)));
//                     });
//               },
//             ),
//           );
//         }));
//   }
// }

// class GameSelectScreen extends StatefulWidget {
//   Session session;
//   GameSelectScreen(this.session);
//   _GameSelectState createState() => _GameSelectState(session);
// }
