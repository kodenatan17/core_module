import 'package:core_module/application/usecases/base_use_case.dart';
import 'package:core_module/domain/entities/base_result_entities.dart';
import 'package:test/test.dart';

/// Stub use cases to verify abstract contracts compile and work.
class _ConcreteUseCase extends UseCase<String> {
  @override
  Future<ResultEntity<String>> call() async {
    return ResultEntity.success(data: 'done');
  }
}

class _ConcreteUseCaseWithParams extends UseCaseWithParams<int, String> {
  @override
  Future<ResultEntity<String>> call(int params) async {
    return ResultEntity.success(data: 'params: $params');
  }
}

void main() {
  group('UseCase', () {
    test('should return success result', () async {
      final useCase = _ConcreteUseCase();
      final result = await useCase.call();

      expect(result, isA<ResultSuccess<String>>());
      expect(result.successOrNull, 'done');
    });
  });

  group('UseCaseWithParams', () {
    test('should pass params and return success result', () async {
      final useCase = _ConcreteUseCaseWithParams();
      final result = await useCase.call(42);

      expect(result, isA<ResultSuccess<String>>());
      expect(result.successOrNull, 'params: 42');
    });
  });
}
