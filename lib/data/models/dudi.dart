// lib/data/models/dudi.dart

import 'package:json_annotation/json_annotation.dart';

part 'dudi.g.dart';

@JsonSerializable()
class Dudi {
  final int id;
  final String name;
  final String address;
  final String? logo;

  Dudi({
    required this.id,
    required this.name,
    required this.address,
    this.logo,
  });

  factory Dudi.fromJson(Map<String, dynamic> json) => _$DudiFromJson(json);
  Map<String, dynamic> toJson() => _$DudiToJson(this);
}
