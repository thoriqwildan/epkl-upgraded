// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoDetail _$InfoDetailFromJson(Map<String, dynamic> json) => InfoDetail(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  info: json['info'] as String,
  image: json['image'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$InfoDetailToJson(InfoDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'info': instance.info,
      'image': instance.image,
      'created_at': instance.createdAt.toIso8601String(),
    };
