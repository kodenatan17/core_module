// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../infrastructure/services/base_dio_error_handler.dart' as _i75;
import '../infrastructure/services/generic_event_bus.dart' as _i55;
import '../infrastructure/services/pae_indexer.dart' as _i407;
import '../infrastructure/services/session_event_bus.dart' as _i1002;
import '../infrastructure/services/workspace_monitor.dart' as _i406;
import 'network_module.dart' as _i567;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt initCore({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    gh.singleton<_i55.EventBus>(() => _i55.EventBus());
    gh.singleton<_i1002.SessionEventBus>(
      () => _i1002.SessionEventBus(),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i75.BaseDioErrorHandler>(() => _i75.BaseDioErrorHandler());
    gh.singletonAsync<_i407.PaeIndexer>(
      () {
        final i = _i407.PaeIndexer();
        return i.init().then((_) => i);
      },
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.singletonAsync<_i406.WorkspaceMonitor>(
      () async => _i406.WorkspaceMonitor(await getAsync<_i407.PaeIndexer>()),
      dispose: (i) => i.dispose(),
    );
    return this;
  }
}

class _$NetworkModule extends _i567.NetworkModule {}
