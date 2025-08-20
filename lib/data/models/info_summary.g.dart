// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoSummary _$InfoSummaryFromJson(Map<String, dynamic> json) => InfoSummary(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  image: json['image'] as String?,
);

Map<String, dynamic> _$InfoSummaryToJson(InfoSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image': instance.image,
    };
