import 'package:ScrimUp/dbDemoStrategy.dart';
import 'package:ScrimUp/dbDemoTask.dart';
import 'package:ScrimUp/models/Game.dart';
import 'package:ScrimUp/utils/LocalDB.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DbDemoGame extends StatefulWidget {
  LocalDB db;
  Game game;
  DbDemoGame(this.db, this.game);

  @override
  _DbDemoGameState createState() => _DbDemoGameState(db, game);
}

class _DbDemoGameState extends State<DbDemoGame> {
  LocalDB db;
  Game game;
  _DbDemoGameState(this.db, this.game);
  _refreshGame() async {
    Game tempGame = Game.fromJson((await db.get("games"))[game.game]);
    setState(() {
      game = tempGame;
    });
  }

  _winPressed(int index) {
    setState(() {
      game.strategies[index].win();
    });
    game.updateStrategy(game.strategies[index]);
    db.updateGame(game);
  }

  _losePressed(int index) {
    setState(() {
      game.strategies[index].lose();
    });

    game.updateStrategy(game.strategies[index]);
    db.updateGame(game);
  }

  _progressPressed(int index) {
    setState(() {
      game.tasks[index].progress();
    });
    game.updateTask(game.tasks[index]);
    db.updateGame(game);
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
                    Text("Game is " + game.game + "\n Nick is : " + game.nick),
                    Text("Strategies"),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: game.strategies.length,
                      itemBuilder: (BuildContext context, int index) {
                        int winCount = game.strategies[index].winCount;
                        int total = game.strategies[index].winCount +
                            game.strategies[index].loseCount;
                        int percentage;
                        if (total != 0) {
                          percentage = (winCount / total * 100).floor();
                        } else {
                          percentage = 0;
                        }
                        return Column(
                          children: <Widget>[
                            Text(game.strategies[index].title),
                            Text(game.strategies[index].detail),
                            Text("Win Rate " +
                                winCount.toString() +
                                "/" +
                                total.toString() +
                                "    %" +
                                percentage.toString()),
                            RaisedButton(
                              onPressed: () {
                                _winPressed(index);
                              },
                              child: Text("Win"),
                            ),
                            RaisedButton(
                              onPressed: () {
                                _losePressed(index);
                              },
                              child: Text("Lose"),
                            ),
                          ],
                        );
                      },
                    ),
                    RaisedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DbDemoStrategy(game, db))).then((_) {
                            _refreshGame();
                          });
                        },
                        child: Text("Create Strategy")),
                    Text("Tasks"),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: game.tasks.length,
                      itemBuilder: (BuildContext context, int index) {
                        int current = game.tasks[index].current;
                        int goal = game.tasks[index].goal;
                        int percentage = (current / goal * 100).floor();
                        return Column(
                          children: <Widget>[
                            Text(game.tasks[index].title),
                            Text(game.tasks[index].detail),
                            Text("Progress" +
                                current.toString() +
                                "/" +
                                goal.toString() +
                                "    %" +
                                percentage.toString()),
                            RaisedButton(
                              onPressed: () {
                                _progressPressed(index);
                              },
                              child: Text("Increment Progress"),
                            ),
                          ],
                        );
                      },
                    ),
                    RaisedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DbDemoTask(game, db))).then((_) {
                            _refreshGame();
                          });
                        },
                        child: Text("Create Task")),
                  ],
                ))));
  }
}
