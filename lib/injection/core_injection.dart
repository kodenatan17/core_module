import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'core_injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'initCore',
  preferRelativeImports: true,
  asExtension: true,
)
void setupCoreInjection() => getIt.initCore();
