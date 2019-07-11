import 'package:ScrimUp/models/Strategy.dart';
import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/Game.dart';

class DbDemoStrategy extends StatefulWidget {
  Game game;
  LocalDB db;
  DbDemoStrategy(this.game, this.db);
  @override
  _DbDemoStrategyState createState() => _DbDemoStrategyState(game, db);
}

class _DbDemoStrategyState extends State<DbDemoStrategy> {
  Game game;
  LocalDB db;
  final titleController = TextEditingController();
  final detailController = TextEditingController();

  _DbDemoStrategyState(this.game, this.db);
  void _createStrategy(context) async {
    Strategy strategy = Strategy(titleController.text, detailController.text);
    game.strategies.add(strategy);
    await db.updateGame(game);
    Navigator.pop(context);
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
                child: Column(children: <Widget>[
                  TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: "Title")),
                  TextField(
                      controller: detailController,
                      decoration: InputDecoration(labelText: "Detail")),
                  RaisedButton(
                      onPressed: () {
                        _createStrategy(context);
                      },
                      child: Text("Create Strategy")),
                ]))));
  }
}
