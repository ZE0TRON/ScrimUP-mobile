import 'package:ScrimUp/models/Event.dart';
import 'package:ScrimUp/utils/AvailabilityParse.dart';

class ParsedEvent extends Event {
  String day;
  String hour;
  bool joinable;
  String nickName;
  String accurateTime;
  ParsedEvent(Event event)
      : super(event.name, event.numberOfPlayers, event.note, event.time,
            event.exactTime, event.players);
  factory ParsedEvent.fromJson(
      Map<String, dynamic> json, DayTime dayTime, String nickName) {
    Event nEvent = Event.fromJson(json);
    ParsedEvent event = ParsedEvent(nEvent);
    event.nickName = nickName;
    var dayHour = event.time.split(" ");
    String day = dayHour[0];
    String hour = dayHour[1];
    dayHour = dayTime.parseTime(day, hour);
    event.day = dayHour[0];
    event.hour = dayHour[1];
    print(event.players);
    print(event.players.contains(event.nickName));
    print(event.nickName);
    event.joinable = !event.players.contains(event.nickName);
    var amPm = event.hour.split("00")[1].substring(0, 2);
    var parsedExactTime =
        event.exactTime.length < 2 ? "0" + event.exactTime : event.exactTime;
    event.accurateTime =
        event.hour.split(":")[0] + ":" + parsedExactTime + amPm;
    return event;
  }
}
