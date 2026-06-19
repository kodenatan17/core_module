// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_success_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseSuccessResponse<T> _$BaseSuccessResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    BaseSuccessResponse<T>(
      fromJsonT(json['data']),
      Status.fromJson(json['status'] as Map<String, dynamic>),
      json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BaseSuccessResponseToJson<T>(
  BaseSuccessResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'status': instance.status,
      'data': toJsonT(instance.data),
      'meta': instance.meta,
    };

Status _$StatusFromJson(Map<String, dynamic> json) => Status(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
    );

Map<String, dynamic> _$StatusToJson(Status instance) => <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
      (json['page'] as num?)?.toInt(),
      (json['limit'] as num?)?.toInt(),
      (json['totalPage'] as num?)?.toInt(),
      (json['totalData'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'totalPage': instance.totalPage,
      'totalData': instance.totalData,
    };
