// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      mJurusanId: (json['m_jurusan_id'] as num).toInt(),
      mKelasId: (json['m_kelas_id'] as num).toInt(),
      name: json['name'] as String,
      nisn: json['nisn'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      phone: json['phone'] as String,
      semester: json['semester'] as String,
      year: json['year'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'm_jurusan_id': instance.mJurusanId,
      'm_kelas_id': instance.mKelasId,
      'name': instance.name,
      'nisn': instance.nisn,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
      'phone': instance.phone,
      'semester': instance.semester,
      'year': instance.year,
    };
