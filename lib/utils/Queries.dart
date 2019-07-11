// Singleton Query Class
import 'package:ScrimUp/models/Event.dart';
import 'package:ScrimUp/models/Strategy.dart';
import 'package:ScrimUp/models/Task.dart';
import 'package:ScrimUp/models/Team.dart';

class Query {
  static final _query = new Query._internal();

  factory Query() {
    return _query;
  }
  Query._internal();

  dynamic getInviteLinkQuery(game, team) {
    return {"gameName": game, "teamName": team};
  }

  dynamic createEventQuery(Event event, Team team) {
    var json = event.toJson();
    json["team"] = team.team;
    json["game"] = team.game;
    return json;
  }

  dynamic createStrategyQuery(String game, Strategy strategy) {
    var json = strategy.toJson();
    var payload = Map<String, dynamic>();
    payload["strategy"] = json;
    payload["game"] = game;
    return payload;
  }

  dynamic getStrategiesQuery(String game) {
    return {"game": game};
  }

  dynamic deleteStrategyQuery(String game, Strategy strategy) {
    return {"game": game, "strategy": strategy.toJson()};
  }

  dynamic createTaskQuery(String game, Task task) {
    var json = task.toJson();
    var payload = Map<String, dynamic>();
    payload["task"] = json;
    payload["game"] = game;
    return payload;
  }

  dynamic getTasksQuery(String game) {
    return {"game": game};
  }

  dynamic deleteTaskQuery(String game, Task task) {
    return {"game": game, "task": task.toJson()};
  }

  dynamic progressTaskQuery(String game, Task task) {
    return {"game": game, "task": task.toJson()};
  }

  dynamic strategyStatusChangeQuery(
      String game, Strategy strategy, bool isWin) {
    return {"game": game, "strategy": strategy.toJson(), "isWin": isWin};
  }

  dynamic getTokenQuery(Team team) {
    return {"game": team.game, "team": team.team};
  }
}
