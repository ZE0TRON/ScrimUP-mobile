// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAvailability _$UserAvailabilityFromJson(Map<String, dynamic> json) {
  return UserAvailability(
      json['gameName'] as String,
      json['teamName'] as String,
      json['hourType'] as String,
      (json['hours'] as List)
          ?.map((e) => e == null
              ? null
              : HourAvailability.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$UserAvailabilityToJson(UserAvailability instance) =>
    <String, dynamic>{
      'gameName': instance.gameName,
      'teamName': instance.teamName,
      'hourType': instance.hourType,
      'hours': instance.hours
    };

HourAvailability _$HourAvailabilityFromJson(Map<String, dynamic> json) {
  return HourAvailability(
      json['key'] as String, (json['value'] as num)?.toDouble());
}

Map<String, dynamic> _$HourAvailabilityToJson(HourAvailability instance) =>
    <String, dynamic>{'key': instance.key, 'value': instance.value};
