// lib/data/models/attendance.dart

import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

int _dynamicToInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0; // Default value jika terjadi kesalahan
}

@JsonSerializable()
class Attendance {
  @JsonKey(fromJson: _dynamicToInt)
  final int id;
  final String date;

  @JsonKey(name: 'check_in')
  final String? checkIn;

  @JsonKey(name: 'check_out')
  final String? checkOut;

  final String? description;
  final String nisn;

  Attendance({
    required this.id,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.description,
    required this.nisn,
  });

  String get checkInTime {
    if (checkIn == null) return '-';
    try {
      final timestamp = int.parse(checkIn!);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  String get checkOutTime {
    if (checkOut == null) return '-';
    try {
      final timestamp = int.parse(checkOut!);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceToJson(this);
}
