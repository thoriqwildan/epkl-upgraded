// lib/data/models/register_request.dart

import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String email;
  @JsonKey(name: 'm_jurusan_id')
  final int mJurusanId;
  @JsonKey(name: 'm_kelas_id')
  final int mKelasId;
  final String name;
  final String nisn;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  final String phone;
  final String semester;
  final String year;

  RegisterRequest({
    required this.email,
    required this.mJurusanId,
    required this.mKelasId,
    required this.name,
    required this.nisn,
    required this.password,
    required this.passwordConfirmation,
    required this.phone,
    required this.semester,
    required this.year,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
