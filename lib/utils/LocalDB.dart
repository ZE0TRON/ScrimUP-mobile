import 'dart:io';

import 'package:ScrimUp/models/Game.dart';
import 'package:path_provider/path_provider.dart';
import "package:sembast/sembast.dart";
import "package:sembast/sembast_io.dart";

class LocalDB {
  Database _db;
  Future<void> connectDB() {
    return Future(() async {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String dbPath = appDocPath + '/solo.db';
      DatabaseFactory dbFactory = databaseFactoryIo;

      // We use the database factory to open the database
      this._db = await dbFactory.openDatabase(dbPath);
    });
  }

  Future<List<Game>> getGames() {
    return Future(() async {
      Map dbGames = await _db.get("games");
      List<Game> games = List<Game>();
      if (dbGames == null) {
        print("games null");
        return games;
      }
      for (String key in dbGames.keys) {
        Game game = Game.fromJson(dbGames[key]);
        print("getting game " + game.game);
        games.add(game);
      }
      return games;
    });
  }

  Future<void> put(dynamic key, dynamic value) {
    return Future(() async {
      await _db.put(value, key);
    });
  }

  Future<dynamic> get(dynamic key) {
    return Future(() async {
      dynamic value = await _db.get(key);
      return value;
    });
  }

  Future<void> addGame(Game game) {
    return Future(() async {
      Map<String, dynamic> games = await _db.get('games');
      if (games != null) {
        if (games.containsKey(game.game)) {
          return null;
        }
        games[game.game] = game.toJson();
        await _db.put(games, "games");
        print("game added 1");
      } else {
        games = Map<String, dynamic>();
        print("putting ");
        print(game.toJson());
        games[game.game] = game.toJson();
        print("games are ");
        print(games);
        await _db.put(games, "games");
        print("game added 2");
      }
    });
  }

  Future<void> updateGame(Game game) {
    return Future(() async {
      Map<String, dynamic> games = await _db.get('games');
      if (games == null) {
        return null;
      } else if (!games.containsKey(game.game)) {
        return null;
      } else {
        games[game.game] = game.toJson();
        await _db.put(games, "games");
        print("game added 2");
      }
    });
  }
}
// Example flow :
// strategy.win() => game.updateStrategy() => db.updateGame()
