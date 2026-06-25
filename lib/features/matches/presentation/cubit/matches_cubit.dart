import 'dart:async';

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

  // ── Raw match cache (all 104) ─────────────────────────────────────────────
  // Exposed so BracketScreen can filter to knockout matches without a new repo call.
  List<Match> _allMatches = [];

  /// All 104 raw Match objects from the API — used by BracketScreen.
  List<Match> get allMatches => _allMatches;

  /// All groups loaded so far (from cache or network).
  /// Exposed so HypeMatchCard can pass it to MatchDetailsCubit on tap.
  List<Groups> cachedGroups = [];

  /// All teams loaded so far (from cache or network).
  List<Team> cachedTeams = [];

  MatchesCubit(this._repository) : super(MatchesInitial());

  /// Entry point — called once from MatchesScreen.initState().
  ///
  /// Stale-while-revalidate:
  /// - Cache hit  -> emit MatchesLoaded immediately with the stale data
  ///   (isRefreshing: true), then refresh from network in the background.
  /// - Cache miss (first-ever app open) -> emit MatchesLoading and block
  ///   on the network fetch, same as before disk caching existed.
  Future<void> loadMatches() async {
    final diskMatches = await _repository.getCachedMatches();
    final diskTeams = await _repository.getCachedTeams();

    if (diskMatches != null && diskTeams != null) {
      final diskGroups = await _repository.getCachedGroups() ?? <Groups>[];

      cachedGroups = diskGroups;
      cachedTeams = diskTeams;
      _allMatches = diskMatches; // ← store raw matches

      final cards = _buildCards(diskMatches, diskGroups, diskTeams);
      _allMatchCards = cards;

      emit(
        MatchesLoaded(
          matchCards: _applyFilter(cards, MatchesFilter.today),
          activeFilter: MatchesFilter.today,
          isRefreshing: true,
        ),
      );

      // Don't await — the UI already has something useful to show.
      unawaited(_refreshFromNetwork());
      return;
    }

    emit(MatchesLoading());
    await _refreshFromNetwork(isFirstLoad: true);
  }

  /// Called from the UI's failure banner to retry a failed background refresh.
  Future<void> retryRefresh() async {
    final currentState = state;
    if (currentState is MatchesLoaded) {
      emit(currentState.copyWith(isRefreshing: true, refreshFailed: false));
    }
    await _refreshFromNetwork();
  }

  /// Called to dismiss the refresh failure banner without retrying.
  void dismissRefreshFailure() {
    final currentState = state;
    if (currentState is MatchesLoaded) {
      emit(currentState.copyWith(refreshFailed: false));
    }
  }

  /// Fetches matches/groups/teams from the network and emits the result.
  /// Used both for the background refresh after a cache hit, and for the
  /// original blocking flow on a cache miss ([isFirstLoad]).
  Future<void> _refreshFromNetwork({bool isFirstLoad = false}) async {
    final results = await Future.wait([
      _repository.getMatches(),
      _repository.getGroups(),
      _repository.getTeams(),
    ]);

    if (isClosed) return;

    final matchesResult = results[0] as ResultApi<List<Match>>;
    final groupsResult = results[1] as ResultApi<List<Groups>>;
    final teamsResult = results[2] as ResultApi<List<Team>>;

    final failed =
        matchesResult is ErrorApi<List<Match>> ||
        teamsResult is ErrorApi<List<Team>>;

    if (failed) {
      if (isFirstLoad) {
        // No stale data to fall back to — this is a real, full-screen error.
        final message = matchesResult is ErrorApi<List<Match>>
            ? (matchesResult as ErrorApi).errorMessage
            : (teamsResult as ErrorApi).errorMessage;
        emit(MatchesError(message));
        return;
      }

      // Background refresh failed — leave the stale data exactly as it
      // was, just surface the failure so the UI can show the banner.
      final currentState = state;
      if (currentState is MatchesLoaded) {
        emit(currentState.copyWith(isRefreshing: false, refreshFailed: true));
      }
      return;
    }

    final matches = (matchesResult as SuccessApi<List<Match>>).data;
    final groups = groupsResult is SuccessApi<List<Groups>>
        ? groupsResult.data
        : <Groups>[];
    final teams = (teamsResult as SuccessApi<List<Team>>).data;

    cachedGroups = groups;
    cachedTeams = teams;
    _allMatches = matches; // ← store raw matches

    final cards = _buildCards(matches, groups, teams);
    _allMatchCards = cards;

    // Preserve whatever filter the user already had selected — a
    // background refresh shouldn't silently reset their choice.
    final currentState = state;
    final activeFilter = currentState is MatchesLoaded
        ? currentState.activeFilter
        : MatchesFilter.today;

    emit(
      MatchesLoaded(
        matchCards: _applyFilter(cards, activeFilter),
        activeFilter: activeFilter,
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

  /// Builds and sorts match cards from raw matches/groups/teams data.
  /// Shared by both the cache-hit path and the network refresh path so
  /// the hype-input construction logic exists in exactly one place.
  List<MatchCard> _buildCards(
    List<Match> matches,
    List<Groups> groups,
    List<Team> teams,
  ) {
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
    return cards;
  }
}
