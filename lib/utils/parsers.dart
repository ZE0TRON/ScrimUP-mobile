import 'package:json_annotation/json_annotation.dart';
part 'parsers.g.dart';

@JsonSerializable()
class UserAvailability {
  final String gameName;
  final String teamName;
  final String hourType;
  List<HourAvailability> hours;

  UserAvailability(
      this.gameName, this.teamName, this.hourType, List<HourAvailability> hours)
      : hours = hours ?? <HourAvailability>[];

  factory UserAvailability.fromJson(Map<String, dynamic> json) =>
      _$UserAvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$UserAvailabilityToJson(this);
}

@JsonSerializable()
class HourAvailability {
  final String key;
  final double value;

  HourAvailability(this.key, this.value);

  factory HourAvailability.fromJson(Map<String, dynamic> json) =>
      _$HourAvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$HourAvailabilityToJson(this);
}
