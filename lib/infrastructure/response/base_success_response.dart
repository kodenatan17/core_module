import 'package:json_annotation/json_annotation.dart';

part 'base_success_response.g.dart';

@JsonSerializable(genericArgumentFactories: true, includeIfNull: true)
class BaseSuccessResponse<T> {
  final Status status;
  final T data;
  final Meta? meta;

  BaseSuccessResponse(this.data, this.status, this.meta);

  factory BaseSuccessResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseSuccessResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseSuccessResponseToJson(this, toJsonT);
}

@JsonSerializable()
class Status {
  final int code;
  final String message;

  Status({required this.code, required this.message});

  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);

  Map<String, dynamic> toJson() => _$StatusToJson(this);
}

@JsonSerializable()
class Meta {
  final int? page;
  final int? limit;
  final int? totalPage;
  final int? totalData;

  Meta(this.page, this.limit, this.totalPage, this.totalData);

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}
