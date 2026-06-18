import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/network/result_api.dart';
import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/stadium_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';
import 'package:world_cup_watch/features/matches/data/repo/matches_repo.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/match_details_state.dart';

/// Cubit for the match details screen.
///
/// Design decision (diverges from Clark's initial plan):
/// groups and teams are passed in at construction — already fetched by
/// MatchesCubit and available in memory. This avoids a redundant parallel
/// re-fetch of all groups and teams just to show one match's details.
/// Only the stadium is fetched fresh (it's per-match and not cached globally).
class MatchDetailsCubit extends Cubit<MatchDetailsState> {
  final MatchesRepository _repository;
  final Match _match;
  final List<Groups> _groups;
  final List<Team> _teams;

  MatchDetailsCubit({
    required MatchesRepository repository,
    required Match match,
    required List<Groups> groups,
    required List<Team> teams,
  }) : _repository = repository,
       _match = match,
       _groups = groups,
       _teams = teams,
       super(MatchDetailsLoading());

  /// Called in [MatchDetailsScreen.initState].
  Future<void> load() async {
    emit(MatchDetailsLoading());

    // ── Build team lookup map ─────────────────────────────────────────────────
    final teamById = <String, Team>{for (final t in _teams) t.id: t};

    // ── Find the group for this match ─────────────────────────────────────────
    // match.group holds the group name (e.g. "Group A") — match against Groups.name
    Groups? matchGroup;
    final groupName = _match.group;
    if (groupName != null && groupName.isNotEmpty) {
      try {
        matchGroup = _groups.firstWhere(
          (g) => g.name?.toLowerCase() == groupName.toLowerCase(),
        );
      } catch (_) {
        // No group found — knockout stage or data mismatch. Stays null.
        matchGroup = null;
      }
    }

    // ── Fetch stadium ─────────────────────────────────────────────────────────
    Stadium? stadium;
    final stadiumId = _match.stadiumId;
    if (stadiumId != null && stadiumId.isNotEmpty) {
      final result = await _repository.getStadiumById(stadiumId);
      if (result is SuccessApi<Stadium>) {
        stadium = result.data;
      }

      // If the stadium fetch fails, stadium stays null — UI degrades gracefully
    }

    emit(
      MatchDetailsLoaded(
        stadium: stadium,
        group: matchGroup,
        teamById: teamById,
      ),
    );
  }
}
