import 'package:epkl/data/models/login_response.dart';

class ProfileResponse {
  final bool success;
  final User data;

  ProfileResponse({required this.success, required this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'],
      data: User.fromJson(json['data']),
    );
  }
}
