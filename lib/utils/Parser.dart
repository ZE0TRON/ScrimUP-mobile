import 'package:ScrimUp/models/Strategy.dart';
import 'package:ScrimUp/models/Task.dart';
import 'package:ScrimUp/utils/UtilClasses.dart';

import '../models/Link.dart';

class Parser {
  static final _parser = Parser._internal();

  factory Parser() {
    return _parser;
  }

  Parser._internal();
  ResponsePack _generalResponseParser(var response, var key) {
    return ResponsePack(response["msg"], !response["success"], response[key]);
  }

  String _noMessageParser(var response) {
    ResponsePack responsePack = _generalResponseParser(response, "success");
    if (responsePack.isError()) {
      throw new Exception(responsePack.getMessage());
    }
    return responsePack.getMessage();
  }

  Link getInviteLinkParse(var response) {
    ResponsePack responsePack = _generalResponseParser(response, "link");
    if (responsePack.isError()) {
      throw new Exception(responsePack.getMessage());
    }
    return Link(responsePack.getData());
  }

  String createEventParse(var response) {
    return _noMessageParser(response);
  }

  String createStrategyParse(var response) {
    return _noMessageParser(response);
  }

  List<Strategy> getStrategiesParse(var response) {
    ResponsePack responsePack = _generalResponseParser(response, "strategies");
    if (responsePack.isError()) {
      throw new Exception(responsePack.getMessage());
    }
    var jsonStrategies = responsePack.getData();
    List<Strategy> strategies = List<Strategy>();
    for (int i = 0; i < jsonStrategies.length; i++) {
      strategies.add(Strategy.fromJson(jsonStrategies[i]));
    }
    return strategies;
  }

  String deleteStrategyParse(var response) {
    return _noMessageParser(response);
  }

  String createTaskParse(var response) {
    return _noMessageParser(response);
  }

  List<Task> getTasksParse(var response) {
    ResponsePack responsePack = _generalResponseParser(response, "tasks");
    if (responsePack.isError()) {
      throw new Exception(responsePack.getMessage());
    }
    var jsonTasks = responsePack.getData();
    List<Task> tasks = List<Task>();
    for (int i = 0; i < jsonTasks.length; i++) {
      tasks.add(Task.fromJson(jsonTasks[i]));
    }
    return tasks;
  }

  String deleteTaskParse(var response) {
    return _noMessageParser(response);
  }

  String progressTaskParse(var response) {
    return _noMessageParser(response);
  }

  String strategyStatusChangeParse(var response) {
    return _noMessageParser(response);
  }

  String getTokenParse(var response) {
    ResponsePack responsePack = _generalResponseParser(response, "token");
    print(responsePack.getData());
    if (responsePack.isError()) {
      throw new Exception(responsePack.getMessage());
    }
    return responsePack.getData();
  }

  List<List<String>> getGamesParse(var response) {
    List<String> games = List<String>();
    List<String> teams = List<String>();
    List<String> nicks = List<String>();
    if (!response["success"]) {
      throw new Exception(response["msg"]);
    }
    var gameList = response["games"];
    for (int i = 0; i < gameList.length; i++) {
      var game = gameList[i]["name"];
      var team;
      if (gameList[i]["isSolo"]) {
        team = "Solo";
      } else {
        team = gameList[i]["team"];
      }
      var nick = gameList[i]["nickName"];
      games.add(game);
      teams.add(team);
      nicks.add(nick);
    }
    List<List<String>> data;
    data.add(games);
    data.add(teams);
    data.add(nicks);
    return data;
  }
}
