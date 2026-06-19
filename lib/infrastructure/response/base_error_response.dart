import 'package:json_annotation/json_annotation.dart';

part 'base_error_response.g.dart';

@JsonSerializable()
class BaseErrorResponse {
  final int? code;
  final String? message;

  BaseErrorResponse(this.code, this.message);

  factory BaseErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseErrorResponseToJson(this);
}