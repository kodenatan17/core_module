import 'package:equatable/equatable.dart';

abstract class BaseException extends Equatable implements Exception {
  final String message;

  const BaseException(this.message);

  @override
  List<Object?> get props => [message];
}

class CacheException extends BaseException {
  const CacheException() : super("ERR_CACHE_EXCEPTION");
}