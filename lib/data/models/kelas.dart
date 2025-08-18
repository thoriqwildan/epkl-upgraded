// lib/data/models/kelas.dart

import 'package:json_annotation/json_annotation.dart';

part 'kelas.g.dart';

@JsonSerializable()
class Kelas {
  final int id;
  final String name;
  @JsonKey(name: 'm_jurusan_id')
  final int mJurusanId;

  Kelas({required this.id, required this.name, required this.mJurusanId});

  factory Kelas.fromJson(Map<String, dynamic> json) => _$KelasFromJson(json);
  Map<String, dynamic> toJson() => _$KelasToJson(this);
}
