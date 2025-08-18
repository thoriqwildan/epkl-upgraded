// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kelas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Kelas _$KelasFromJson(Map<String, dynamic> json) => Kelas(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  mJurusanId: (json['m_jurusan_id'] as num).toInt(),
);

Map<String, dynamic> _$KelasToJson(Kelas instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'm_jurusan_id': instance.mJurusanId,
};
