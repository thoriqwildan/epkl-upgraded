// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bimbingan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bimbingan _$BimbinganFromJson(Map<String, dynamic> json) => Bimbingan(
  nip: json['nip'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  avatar: json['avatar'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$BimbinganToJson(Bimbingan instance) => <String, dynamic>{
  'nip': instance.nip,
  'name': instance.name,
  'email': instance.email,
  'avatar': instance.avatar,
  'phone': instance.phone,
};
