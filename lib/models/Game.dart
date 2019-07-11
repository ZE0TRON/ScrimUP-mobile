import 'package:ScrimUp/models/Strategy.dart';

import 'Task.dart';

class Game {
  String game;
  String nick;
  List<Strategy> strategies;
  List<Task> tasks;
  Game(String game, String nick,
      [List<Strategy> strategies, List<Task> tasks]) {
    this.game = game;
    this.nick = nick;
    if (strategies == null) {
      this.strategies = List<Strategy>();
    } else {
      this.strategies = strategies;
    }
    if (tasks == null) {
      this.tasks = List<Task>();
    } else {
      this.tasks = tasks;
    }
  }
  factory Game.fromJson(dynamic json) {
    List<Strategy> tempSt = List<Strategy>();
    if (json["strategies"] != null) {
      for (Map<String, dynamic> jStrategy in json["strategies"]) {
        tempSt.add(Strategy.fromJson(jStrategy));
      }
    }
    List<Task> tempTasks = List<Task>();
    if (json["tasks"] != null) {
      for (Map<String, dynamic> jTask in json["tasks"]) {
        tempTasks.add(Task.fromJson(jTask));
      }
    }
    return Game(json["game"], json["nick"], tempSt, tempTasks);
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map<String, dynamic>();
    json["game"] = this.game;
    json["nick"] = this.nick;
    List<Map<String, dynamic>> jsonStrategies = List<Map<String, dynamic>>();
    for (Strategy strategy in strategies) {
      jsonStrategies.add(strategy.toJson());
    }
    List<Map<String, dynamic>> jsonTasks = List<Map<String, dynamic>>();
    for (Task task in tasks) {
      jsonTasks.add(task.toJson());
    }
    json["strategies"] = jsonStrategies;
    json["tasks"] = jsonTasks;
    return json;
  }

  void addStrategy(Strategy strategy) {
    strategies.add(strategy);
    // TODO: Db save in main page
  }

  void updateStrategy(Strategy strategy) {
    for (int i = 0; i < strategies.length; i++) {
      if (strategies[i].title == strategy.title) {
        strategies[i] = strategy;
      }
    }
    // TODO: Db save in main page
  }

  void deleteStrategy(Strategy strategy) {
    int removingIndex = -1;
    for (int i = 0; i < strategies.length; i++) {
      if (strategies[i].title == strategy.title) {
        removingIndex = i;
      }
    }
    if (removingIndex != -1) {
      strategies.removeAt(removingIndex);
    }
    // TODO: Db save in main page
  }

  List<Strategy> getStrategies() {
    return strategies;
  }

  List<Task> getTasks() {
    return tasks;
  }

  void addTask(Task task) {
    tasks.add(task);
    // TODO: Db save in main page
  }

  void updateTask(Task task) {
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].title == task.title) {
        tasks[i] = task;
      }
    }
    // TODO: Db save in main page
  }

  void deleteTask(Task task) {
    int removingIndex = -1;
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].title == task.title) {
        removingIndex = i;
      }
    }
    if (removingIndex != -1) {
      tasks.removeAt(removingIndex);
    }
    // TODO: Db save in main page
  }
}
