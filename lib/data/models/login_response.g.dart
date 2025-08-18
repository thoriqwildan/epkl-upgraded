// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: UserData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
  token: json['token'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
  'token': instance.token,
  'user': instance.user,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  nisn: json['nisn'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  avatar: json['avatar'] as String?,
  mJurusanId: _stringToInt(json['m_jurusan_id']),
  mKelasId: _stringToInt(json['m_kelas_id']),
  mDudiId: (json['m_dudi_id'] as num?)?.toInt(),
  lat: json['lat'] as String?,
  longitude: json['long'] as String?,
  year: json['year'] as String?,
  jurusan: json['jurusan'] == null
      ? null
      : Jurusan.fromJson(json['jurusan'] as Map<String, dynamic>),
  kelas: json['kelas'] == null
      ? null
      : Kelas.fromJson(json['kelas'] as Map<String, dynamic>),
  dudi: json['dudi'] == null
      ? null
      : Dudi.fromJson(json['dudi'] as Map<String, dynamic>),
  bimbingan: json['bimbingan'] == null
      ? null
      : Bimbingan.fromJson(json['bimbingan'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'nisn': instance.nisn,
  'email': instance.email,
  'name': instance.name,
  'phone': instance.phone,
  'avatar': instance.avatar,
  'm_jurusan_id': _intToString(instance.mJurusanId),
  'm_kelas_id': _intToString(instance.mKelasId),
  'm_dudi_id': instance.mDudiId,
  'lat': instance.lat,
  'long': instance.longitude,
  'year': instance.year,
  'jurusan': instance.jurusan?.toJson(),
  'kelas': instance.kelas?.toJson(),
  'dudi': instance.dudi?.toJson(),
  'bimbingan': instance.bimbingan?.toJson(),
};
