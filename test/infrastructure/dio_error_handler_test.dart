import 'package:core_module/infrastructure/services/base_dio_error_handler.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  late BaseDioErrorHandler handler;

  setUp(() {
    handler = BaseDioErrorHandler();
  });

  group('BaseDioErrorHandler', () {
    test('should return error message from data map', () {
      final response = Response(
        requestOptions: RequestOptions(),
        data: {'message': 'Custom Error'},
        statusCode: 400,
      );
      final error = DioException(
        requestOptions: RequestOptions(),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final result = handler.handleDioError(error);
      expect(result?.message, 'Custom Error');
    });

    test('should return fallback message for unknown error', () {
      final error = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.unknown,
      );

      final result = handler.handleDioError(error);
      expect(result?.message, 'UNKNOWN_ERROR');
    });
  });
}
