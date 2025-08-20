// lib/data/models/info_detail.dart
import 'package:json_annotation/json_annotation.dart';
part 'info_detail.g.dart';

@JsonSerializable()
class InfoDetail {
  final int id;
  final String title;
  final String info; // Konten utama
  final String? image;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  InfoDetail({
    required this.id,
    required this.title,
    required this.info,
    this.image,
    required this.createdAt,
  });
  factory InfoDetail.fromJson(Map<String, dynamic> json) =>
      _$InfoDetailFromJson(json);
  Map<String, dynamic> toJson() => _$InfoDetailToJson(this);
}
