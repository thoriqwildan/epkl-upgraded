// lib/data/models/info_summary.dart
import 'package:json_annotation/json_annotation.dart';
part 'info_summary.g.dart';

@JsonSerializable()
class InfoSummary {
  final int id;
  final String title;
  final String? image;

  InfoSummary({required this.id, required this.title, this.image});
  factory InfoSummary.fromJson(Map<String, dynamic> json) =>
      _$InfoSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$InfoSummaryToJson(this);
}
