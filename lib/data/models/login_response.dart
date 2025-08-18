import 'package:epkl/data/models/bimbingan.dart';
import 'package:epkl/data/models/dudi.dart';
import 'package:epkl/data/models/jurusan.dart';
import 'package:epkl/data/models/kelas.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

int? _stringToInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

String? _intToString(int? value) {
  return value?.toString();
}

@JsonSerializable()
class LoginResponse {
  final bool success;
  final String message;
  final UserData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class UserData {
  final String token;
  final User user;

  UserData({required this.token, required this.user});

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable(explicitToJson: true) // Tambahkan explicitToJson: true
class User {
  final String nisn;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;

  // Field baru dari response profile
  @JsonKey(name: 'm_jurusan_id', fromJson: _stringToInt, toJson: _intToString)
  final int? mJurusanId;
  @JsonKey(name: 'm_kelas_id', fromJson: _stringToInt, toJson: _intToString)
  final int? mKelasId;
  @JsonKey(name: 'm_dudi_id')
  final int? mDudiId;
  final String? lat;
  @JsonKey(name: 'long')
  final String? longitude;
  final String? year;

  // Objek bersarang baru
  final Jurusan? jurusan;
  final Kelas? kelas;
  final Dudi? dudi;
  final Bimbingan? bimbingan;

  User({
    required this.nisn,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    // Tambahkan field baru di constructor
    this.mJurusanId,
    this.mKelasId,
    this.mDudiId,
    this.lat,
    this.longitude,
    this.year,
    this.jurusan,
    this.kelas,
    this.dudi,
    this.bimbingan,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
