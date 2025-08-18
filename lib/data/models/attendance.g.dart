// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
  id: (json['id'] as num).toInt(),
  date: json['date'] as String,
  checkIn: json['check_in'] as String?,
  checkOut: json['check_out'] as String?,
  description: json['description'] as String?,
  nisn: json['nisn'] as String,
);

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'check_in': instance.checkIn,
      'check_out': instance.checkOut,
      'description': instance.description,
      'nisn': instance.nisn,
    };
