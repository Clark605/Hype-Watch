import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:world_cup_watch/core/network/result_api.dart';
import 'package:world_cup_watch/core/utils/hype_score_calculator.dart';
import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';
import 'package:world_cup_watch/features/matches/data/repo/matches_repo.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_state.dart';
import 'match_card.dart';

@injectable
class MatchesCubit extends Cubit<MatchesState> {
  final MatchesRepository _repository;

  List<MatchCard> _allMatchCards = [];

  // ── NEW: exposed so HypeMatchCard can pass to MatchDetailsCubit on tap ───────
  /// All groups loaded from the API. Empty list until [loadMatches] succeeds.
  List<Groups> cachedGroups = [];

  /// All teams loaded from the API. Empty list until [loadMatches] succeeds.
  List<Team> cachedTeams = [];

  MatchesCubit(this._repository) : super(MatchesInitial());

  Future<void> loadMatches() async {
    emit(MatchesLoading());

    final results = await Future.wait([
      _repository.getMatches(),
      _repository.getGroups(),
      _repository.getTeams(),
    ]);

    final matchesResult = results[0] as ResultApi<List<Match>>;
    final groupsResult = results[1] as ResultApi<List<Groups>>;
    final teamsResult = results[2] as ResultApi<List<Team>>;

    if (matchesResult is ErrorApi<List<Match>>) {
      emit(MatchesError((matchesResult as ErrorApi).errorMessage));
      return;
    }
    if (teamsResult is ErrorApi<List<Team>>) {
      emit(MatchesError((teamsResult as ErrorApi).errorMessage));
      return;
    }

    final matches = (matchesResult as SuccessApi<List<Match>>).data;
    final groups = groupsResult is SuccessApi<List<Groups>>
        ? groupsResult.data
        : <Groups>[];
    final teams = (teamsResult as SuccessApi<List<Team>>).data;

    // ── Cache for details screen ──────────────────────────────────────────────
    cachedGroups = groups;
    cachedTeams = teams;

    final teamById = <String, Team>{for (final t in teams) t.id: t};

    final standingByTeamId = <String, GroupTeamStanding>{};
    for (final group in groups) {
      for (final standing in group.teams ?? <GroupTeamStanding>[]) {
        standingByTeamId[standing.teamId] = standing;
      }
    }

    final cards = <MatchCard>[];

    for (final match in matches) {
      final homeTeam = teamById[match.homeTeamId];
      final awayTeam = teamById[match.awayTeamId];
      if (homeTeam == null || awayTeam == null) continue;

      final homeStanding = standingByTeamId[match.homeTeamId];
      final awayStanding = standingByTeamId[match.awayTeamId];

      final hypeInput = MatchHypeInput(
        homeTeamCode: homeTeam.fifaCode,
        awayTeamCode: awayTeam.fifaCode,
        stage: match.stage,
        groupMatchday: match.matchday,
        homeTeamPoints: homeStanding?.points,
        awayTeamPoints: awayStanding?.points,
        homeTeamGoalsScored: homeStanding?.goalsFor,
        awayTeamGoalsScored: awayStanding?.goalsFor,
        homeTeamMatchesPlayed: homeStanding?.matchesPlayed,
        awayTeamMatchesPlayed: awayStanding?.matchesPlayed,
      );

      final hypeResult = HypeScoreCalculator.calculate(hypeInput);

      cards.add(
        MatchCard(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          hype: hypeResult,
        ),
      );
    }

    cards.sort((a, b) => b.hypeScore.compareTo(a.hypeScore));
    _allMatchCards = cards;

    emit(
      MatchesLoaded(
        matchCards: _applyFilter(cards, MatchesFilter.today),
        activeFilter: MatchesFilter.today,
      ),
    );
  }

  void applyFilter(MatchesFilter filter) {
    final currentState = state;
    emit(MatchesLoading());
    if (currentState is! MatchesLoaded) return;
    emit(
      currentState.copyWith(
        matchCards: _applyFilter(_allMatchCards, filter),
        activeFilter: filter,
      ),
    );
  }

  List<MatchCard> _applyFilter(List<MatchCard> cards, MatchesFilter filter) {
    switch (filter) {
      case MatchesFilter.today:
        final filtered = cards.where((c) => c.isToday).toList();
        return filtered.isNotEmpty
            ? filtered
            : cards.where((c) => !c.isFinished).toList();
      case MatchesFilter.upcoming:
        return cards.where((c) => !c.isFinished).toList();
      case MatchesFilter.finished:
        return cards.where((c) => c.isFinished).toList();
      case MatchesFilter.all:
        return cards;
    }
  }
}
