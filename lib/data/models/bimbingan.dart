import 'package:json_annotation/json_annotation.dart';

part 'bimbingan.g.dart';

@JsonSerializable()
class Bimbingan {
  final String nip;
  final String name;
  final String email;
  final String? avatar;
  final String? phone;

  Bimbingan({
    required this.nip,
    required this.name,
    required this.email,
    this.avatar,
    this.phone,
  });

  factory Bimbingan.fromJson(Map<String, dynamic> json) =>
      _$BimbinganFromJson(json);
  Map<String, dynamic> toJson() => _$BimbinganToJson(this);
}
