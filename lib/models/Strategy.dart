import 'dart:core';

class Strategy {
  String title;
  String detail;
  int winCount;
  int loseCount;
  Strategy(String title, String detail) {
    this.title = title;
    this.detail = detail;
    this.winCount = 0;
    this.loseCount = 0;
  }
  Strategy.withCount(this.title, this.detail, this.loseCount, this.winCount);
  factory Strategy.fromJson(Map<String, dynamic> json) {
    return Strategy.withCount(
      json["title"],
      json["detail"],
      json["loseCount"],
      json["winCount"],
    );
  }

  Map<String, dynamic> toJson() {
    Map json = Map<String, dynamic>();
    json["title"] = this.title;
    json["detail"] = this.detail;
    json["winCount"] = this.winCount;
    json["loseCount"] = this.loseCount;
    return json;
  }

  void win() {
    this.winCount++;
    //TODO: update Strategy in main page
  }

  void lose() {
    this.loseCount++;
    // TODO: update Strategy in main page
  }
}
