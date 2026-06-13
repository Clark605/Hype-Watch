// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/matches/data/repo/matches_repo.dart' as _i1021;
import '../../features/matches/data/repo/matches_repo_impl.dart' as _i702;
import '../../features/matches/presentation/cubit/matches_cubit.dart' as _i206;
import '../network/dio_client.dart' as _i667;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i667.DioClient>(() => _i667.DioClient());
    gh.lazySingleton<_i1021.MatchesRepository>(
      () => _i702.MatchesRepositoryImpl(gh<_i667.DioClient>()),
    );
    gh.factory<_i206.MatchesCubit>(
      () => _i206.MatchesCubit(gh<_i1021.MatchesRepository>()),
    );
    return this;
  }
}
