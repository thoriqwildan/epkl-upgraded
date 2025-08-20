// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoListResponse _$InfoListResponseFromJson(Map<String, dynamic> json) =>
    InfoListResponse(
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
      infoList: (json['info'] as List<dynamic>)
          .map((e) => InfoSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InfoListResponseToJson(InfoListResponse instance) =>
    <String, dynamic>{'meta': instance.meta, 'info': instance.infoList};
