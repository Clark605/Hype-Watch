import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/di/di.dart';
import 'package:world_cup_watch/features/matches/data/repo/matches_repo.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_cubit.dart';
import 'package:world_cup_watch/features/matches/presentation/screens/matches_screen.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Cup Watch',
      theme: ThemeData(useMaterial3: true),
      home: MultiRepositoryProvider(
        providers: [
          // ── NEW: expose repo so cards can access it on tap for navigation ────
          RepositoryProvider<MatchesRepository>(
            create: (_) => getIt<MatchesRepository>(),
          ),
        ],
        child: BlocProvider(
          create: (_) => getIt<MatchesCubit>(),
          child: const MatchesScreen(),
        ),
      ),
    );
  }
}
