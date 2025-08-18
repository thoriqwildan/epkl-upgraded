// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Journal _$JournalFromJson(Map<String, dynamic> json) => Journal(
  id: json['id'] as String,
  siswaNisn: json['siswa_nisn'] as String,
  tanggal: json['tanggal'] as String,
  kegiatan: json['kegiatan'] as String,
  target: json['target'] as String?,
);

Map<String, dynamic> _$JournalToJson(Journal instance) => <String, dynamic>{
  'id': instance.id,
  'siswa_nisn': instance.siswaNisn,
  'tanggal': instance.tanggal,
  'kegiatan': instance.kegiatan,
  'target': instance.target,
};
