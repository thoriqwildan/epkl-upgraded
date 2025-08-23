// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dudi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dudi _$DudiFromJson(Map<String, dynamic> json) => Dudi(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  logo: json['logo'] as String?,
  contact: json['contact'] as String?,
  pic: json['pic'] as String?,
);

Map<String, dynamic> _$DudiToJson(Dudi instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'logo': instance.logo,
  'contact': instance.contact,
  'pic': instance.pic,
};
