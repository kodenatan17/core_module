import 'package:core_module/domain/entities/base_result_entities.dart';
import 'package:test/test.dart';

void main() {
  group('ResultEntity', () {
    test('ResultSuccess should store and retrieve data', () {
      final success = ResultEntity.success(data: 'test_data');
      expect(success.successOrNull, 'test_data');
      
      success.when(
        success: (s) => expect(s.data, 'test_data'),
        error: (e) => fail('Should not be error'),
      );
    });

    test('ResultError should store and retrieve message', () {
      final error = ResultEntity.error(message: 'error_msg');
      expect(error.successOrNull, isNull);
      
      error.when(
        success: (s) => fail('Should not be success'),
        error: (e) => expect(e.message, 'error_msg'),
      );
    });
  });
}
