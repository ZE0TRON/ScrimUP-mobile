import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:ScrimUp/dbDemoGame.dart';
import 'package:flutter/material.dart';

import 'models/Game.dart';

class DBDemo extends StatefulWidget {
  @override
  _DBDemoState createState() => _DBDemoState();
}

class _DBDemoState extends State<DBDemo> {
  LocalDB db;
  final TextEditingController gameController = TextEditingController();
  final TextEditingController nickController = TextEditingController();
  int count;
  int dbCount;
  List<Game> games = List<Game>();
  void _refreshCount() async {
    var tempCount = await db.get("count");
    setState(() {
      dbCount = tempCount;
      count = tempCount;
    });
  }

  void _refreshGames() async {
    db.getGames().then((gameList) {
      setState(() {
        games = gameList;
      });
    });
  }

  void _increment() {
    count++;
    db.put("count", count).then((_) {
      _refreshCount();
    });
  }

  void _addGame(String game, String nick) {
    Game gameObj = Game(game, nick);
    db.addGame(gameObj).then((_) {
      print("calling refresh games");
      _refreshGames();
    });
  }

  @override
  void initState() {
    count = 0;
    db = LocalDB();
    db.connectDB().then((_) {
      _refreshCount();
      _refreshGames();
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ScrimUP"),
        ),
        body: Center(
            child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: <Widget>[
              Text("Hello " + dbCount.toString()),
              RaisedButton(
                child: Icon(Icons.add),
                onPressed: () {
                  _increment();
                },
              ),
              TextField(
                controller: gameController,
                decoration: InputDecoration(labelText: "Game"),
              ),
              TextField(
                controller: nickController,
                decoration: InputDecoration(labelText: "Nick"),
              ),
              RaisedButton(
                child: Text("Add Game"),
                onPressed: () {
                  print("sending" + gameController.text + nickController.text);
                  _addGame(gameController.text, nickController.text);
                },
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: games.length,
                itemBuilder: (BuildContext context, int index) {
                  return RaisedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  DbDemoGame(db, games[index]))).then((_) {
                        _refreshGames();
                      });
                    },
                    child: Text("Game: " +
                        games[index].game +
                        "Nick: " +
                        games[index].nick),
                  );
                },
              )
            ],
          ),
        )));
  }
}
