import 'package:epkl/data/models/attendance.dart';

class AttendanceStatus {
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final Attendance? attendanceData;

  AttendanceStatus({
    required this.hasCheckedIn,
    required this.hasCheckedOut,
    this.attendanceData,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    if (json['success'] == true && json['data'] != null) {
      final attendance = Attendance.fromJson(json['data']);
      return AttendanceStatus(
        hasCheckedIn: true,
        hasCheckedOut: attendance.checkOut != null,
        attendanceData: attendance,
      );
    } else {
      return AttendanceStatus(
        hasCheckedIn: false,
        hasCheckedOut: false,
        attendanceData: null,
      );
    }
  }
}
