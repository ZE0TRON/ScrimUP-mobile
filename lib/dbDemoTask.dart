import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/Game.dart';
import 'models/Task.dart';

class DbDemoTask extends StatefulWidget {
  Game game;
  LocalDB db;
  DbDemoTask(this.game, this.db);
  @override
  _DbDemoTaskState createState() => _DbDemoTaskState(game, db);
}

class _DbDemoTaskState extends State<DbDemoTask> {
  Game game;
  String _errorText = null;
  LocalDB db;
  final titleController = TextEditingController();
  final detailController = TextEditingController();
  final goalController = TextEditingController();
  _DbDemoTaskState(this.game, this.db);

  void _createTask(context) async {
    Task task = Task(titleController.text, detailController.text, game.nick,
        int.parse(goalController.text));
    game.tasks.add(task);
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
                  TextField(
                    controller: goalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Goal(How many Times ?)",
                        errorText: _errorText),
                    onChanged: (text) {
                      try {
                        int.parse(text);
                        _errorText = null;
                      } catch (e) {
                        _errorText = "Please enter a number";
                      }
                    },
                  ),
                  RaisedButton(
                      onPressed: () {
                        _createTask(context);
                      },
                      child: Text("Create Task")),
                ]))));
  }
}
