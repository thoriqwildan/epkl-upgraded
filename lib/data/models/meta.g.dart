// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
  totalItem: (json['total_item'] as num).toInt(),
  totalPage: (json['total_page'] as num).toInt(),
  currentPage: (json['current_page'] as num).toInt(),
);

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'total_item': instance.totalItem,
  'total_page': instance.totalPage,
  'current_page': instance.currentPage,
};
