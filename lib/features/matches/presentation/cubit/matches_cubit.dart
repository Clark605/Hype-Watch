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

  // ── Raw data cache inside the Cubit ─────────────────────────────────────────
  // Kept so we can re-filter without re-fetching from API
  List<MatchCard> _allMatchCards = [];

  MatchesCubit(this._repository) : super(MatchesInitial());

  // ── loadMatches ──────────────────────────────────────────────────────────────
  /// Fetches matches, groups, and teams in parallel.
  /// Calculates hype scores and emits sorted match cards.
  Future<void> loadMatches() async {
    emit(MatchesLoading());

    // Fetch all three endpoints in parallel — faster than sequential
    final results = await Future.wait([
      _repository.getMatches(),
      _repository.getGroups(),
      _repository.getTeams(),
    ]);

    final matchesResult = results[0] as ResultApi<List<Match>>;
    final groupsResult = results[1] as ResultApi<List<Groups>>;
    final teamsResult = results[2] as ResultApi<List<Team>>;

    // If any critical call failed and no cache → emit error
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
        ? (groupsResult).data
        : <Groups>[]; // groups failed → hype score degrades gracefully
    final teams = (teamsResult as SuccessApi<List<Team>>).data;

    // ── Build lookup maps for O(1) access ──────────────────────────────────────
    final teamById = <String, Team>{for (final t in teams) t.id: t};

    // Map teamId → GroupTeamStanding for fast standings lookup
    final standingByTeamId = <String, GroupTeamStanding>{};
    for (final group in groups) {
      for (final standing in group.teams ?? <GroupTeamStanding>[]) {
        standingByTeamId[standing.teamId] = standing;
      }
    }

    // ── Build MatchCard for each match ─────────────────────────────────────────
    final cards = <MatchCard>[];

    for (final match in matches) {
      final homeTeam = teamById[match.homeTeamId];
      final awayTeam = teamById[match.awayTeamId];

      // Skip match if team data missing — shouldn't happen but safe guard
      if (homeTeam == null || awayTeam == null) continue;

      final homeStanding = standingByTeamId[match.homeTeamId];
      final awayStanding = standingByTeamId[match.awayTeamId];

      // Build hype input — standings may be null for first matchday
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

    // ── Sort by hype score descending ──────────────────────────────────────────
    cards.sort((a, b) => b.hypeScore.compareTo(a.hypeScore));

    _allMatchCards = cards;

    // ── Emit with default filter (today) ──────────────────────────────────────
    emit(
      MatchesLoaded(
        matchCards: _applyFilter(cards, MatchesFilter.today),
        activeFilter: MatchesFilter.today,
      ),
    );
  }

  // ── applyFilter ──────────────────────────────────────────────────────────────
  /// Filters already-loaded match cards without re-fetching from API.
  /// Called when user taps a filter button in the UI.
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
    print(
      'Emitted new state with ${_applyFilter(_allMatchCards, filter).length} matches after applying filter: $filter',
    );
  }

  // ── _applyFilter ─────────────────────────────────────────────────────────────
  List<MatchCard> _applyFilter(List<MatchCard> cards, MatchesFilter filter) {
    switch (filter) {
      case MatchesFilter.today:
        final filtered = cards.where((c) => c.isToday).toList();
        // If no matches today (e.g. rest day) → show all upcoming instead
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
