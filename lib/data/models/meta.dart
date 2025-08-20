// lib/data/models/meta.dart
import 'package:json_annotation/json_annotation.dart';
part 'meta.g.dart';

@JsonSerializable()
class Meta {
  @JsonKey(name: 'total_item')
  final int totalItem;
  @JsonKey(name: 'total_page')
  final int totalPage;
  @JsonKey(name: 'current_page')
  final int currentPage;

  Meta({
    required this.totalItem,
    required this.totalPage,
    required this.currentPage,
  });
  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
  Map<String, dynamic> toJson() => _$MetaToJson(this);
}
