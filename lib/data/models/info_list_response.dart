// lib/data/models/info_list_response.dart
import 'package:epkl/data/models/meta.dart';
import 'package:epkl/data/models/info_summary.dart';
import 'package:json_annotation/json_annotation.dart';
part 'info_list_response.g.dart';

@JsonSerializable()
class InfoListResponse {
  final Meta meta;
  @JsonKey(name: 'info')
  final List<InfoSummary> infoList;

  InfoListResponse({required this.meta, required this.infoList});
  factory InfoListResponse.fromJson(Map<String, dynamic> json) =>
      _$InfoListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$InfoListResponseToJson(this);
}
