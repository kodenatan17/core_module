import 'package:core_module/domain/entities/base_result_entities.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class BaseDioErrorHandler {
  final List<String> serverErrorWhiteList = [];

  BaseDioErrorHandler();

  String? _getErrorMessageFromResponse(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final status = data['status'];
    if (status is Map<String, dynamic>) {
      final statusMessage = status['message'];
      if (statusMessage is String && statusMessage.trim().isNotEmpty) {
        return statusMessage;
      }
      // Handle case where BE sends error message as a key in the status map
      for (final key in status.keys) {
        if (key != 'code' && key != 'message' && key.trim().isNotEmpty) {
          return key;
        }
      }
    }

    final error = data['error'];
    if (error is Map<String, dynamic>) {
      final errorMessage = error['message'];
      if (errorMessage is String && errorMessage.trim().isNotEmpty) {
        return errorMessage;
      }
    }

    return null;
  }

  ResultError<T> _errorFromResponse<T>(
    Response<dynamic>? response, {
    String fallbackMessage = "ERR_UNKNOWN_REMOTE_CALL_EXCEPTION",
  }) {
    final message = _getErrorMessageFromResponse(response?.data);
    return ResultEntity.error(message: message ?? fallbackMessage);
  }

  ResultError<T>? handleDioError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        try {
          return _errorFromResponse(
            error.response,
            fallbackMessage: "ERR_CONNECTION_TIMEOUT",
          );
        } catch (e) {
          return ResultEntity.error(message: "ERR_CONNECTION_TIMEOUT");
        }
      case DioExceptionType.badCertificate:
        return ResultEntity.error(message: "BAD_CERTIFICATE");
      case DioExceptionType.badResponse:
        try {
          if (error.response != null) {
            if (error.response!.statusCode! >= 500) {
              final beMessage = _getErrorMessageFromResponse(
                error.response!.data,
              );
              if (beMessage != null) {
                return ResultEntity.error(message: beMessage);
              }
              return ResultEntity.error(
                message: error.message ?? "ERR_UNKNOWN_REMOTE_CALL_EXCEPTION",
              );
            } else if (error.response!.statusCode == 404) {
              if (error.response!.data != null) {
                return _errorFromResponse(error.response);
              } else {
                return ResultEntity.error(message: "ERR_NOT_FOUND");
              }
            } else if (error.response!.statusCode == 403) {
              return _errorFromResponse(error.response);
            } else if (error.response!.statusCode == 400) {
              final errorMessage = _getErrorMessageFromResponse(
                error.response!.data,
              );
              if ((errorMessage ?? "").toLowerCase().contains(
                "failed to get user profile",
              )) {
                return ResultEntity.error(message: errorMessage ?? '');
              }
              return _errorFromResponse(error.response);
            } else if (error.response!.statusCode == 429) {
              return _errorFromResponse(error.response);
            } else {
              if (error.response!.data != null) {
                return _errorFromResponse(error.response);
              }
            }
          } else {
            return ResultEntity.error(
              message: "ERR_UNKNOWN_REMOTE_CALL_EXCEPTION",
            );
          }
        } catch (e) {
          return ResultEntity.error(
            message: "ERR_UNKNOWN_REMOTE_CALL_EXCEPTION",
          );
        }
      case DioExceptionType.cancel:
        return ResultEntity.error(message: "ERR_REQUEST_CANCELED");
      case DioExceptionType.unknown:
        return ResultEntity.error(message: "UNKNOWN_ERROR");
    }
    return null;
  }
}
