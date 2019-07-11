import 'dart:core';

class Task {
  String title;
  String detail;
  String assigned;
  int goal;
  int current;
  Task(String title, String detail, String assigned, int goal) {
    this.title = title;
    this.detail = detail;
    this.assigned = assigned;
    this.goal = goal;
    this.current = 0;
  }

  Task.withCount(
      this.title, this.detail, this.assigned, this.goal, this.current);
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task.withCount(json["title"], json["detail"], json["assigned"],
        json["goal"], json["current"]);
  }

  Map<String, dynamic> toJson() {
    Map json = Map<String, dynamic>();
    json["title"] = this.title;
    json["detail"] = this.detail;
    json["assigned"] = this.assigned;
    json["goal"] = this.goal;
    json["current"] = this.current;
    return json;
  }

  void progress() {
    if (current != goal) {
      this.current++;
    }
    // TODO: update task in main page
  }
}
