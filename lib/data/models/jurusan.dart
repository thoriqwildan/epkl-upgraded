// lib/data/models/jurusan.dart

import 'package:json_annotation/json_annotation.dart';

part 'jurusan.g.dart';

@JsonSerializable()
class Jurusan {
  final int id;
  final String name;

  Jurusan({required this.id, required this.name});

  factory Jurusan.fromJson(Map<String, dynamic> json) =>
      _$JurusanFromJson(json);
  Map<String, dynamic> toJson() => _$JurusanToJson(this);
}
