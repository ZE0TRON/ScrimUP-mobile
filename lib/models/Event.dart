import 'dart:core';

class Event {
  String name;
  int numberOfPlayers;
  String note;
  String time;
  String exactTime;
  List<String> players;
  Event(this.name, this.numberOfPlayers, this.note, this.time, this.exactTime,
      this.players);

  factory Event.fromJson(Map<String, dynamic> json) {
    List players = new List<String>();
    for (var player in json["players"]) {
      players.add(player["nickName"]);
    }
    return Event(json["name"], json["numberOfPlayers"], json["note"],
        json["time"], json["exactTime"], players);
  }

  Map<String, dynamic> toJson() {
    Map json = Map<String, dynamic>();
    json["name"] = this.name;
    json["numberOfPlayers"] = this.numberOfPlayers;
    json["note"] = this.note;
    json["time"] = this.time;
    json["exactTime"] = this.exactTime;
    return json;
  }
}
