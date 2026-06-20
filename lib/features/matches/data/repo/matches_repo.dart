import 'package:world_cup_watch/core/network/result_api.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/stadium_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';

/// Abstract repository for the matches feature.
/// Implemented by [MatchesRepositoryImpl].
///
/// Keeps three concerns separate so each can be reused independently:
/// - [getMatches]  → used by matches feature + tournament feature
/// - [getGroups]   → used by matches feature (hype score stakes factor)
/// - [getTeams]    → used by matches feature (flags) + tournament feature
/// - [getStadiumById] → used by match details screen only, so separate to avoid unnecessary data fetching in matches list
///
/// [getCachedMatches]/[getCachedGroups]/[getCachedTeams] read the on-disk
/// JSON cache without hitting the network — used by the Cubit for the
/// stale-while-revalidate flow (show cached data instantly, refresh in background).
/// Return null when no cache exists yet (first-ever app open).
abstract class MatchesRepository {
  /// Returns all 104 World Cup matches.
  /// Cubit is responsible for filtering by date or stage.
  /// On success, writes the response to the on-disk cache.
  /// On failure (after retries), always returns the real [ErrorApi] —
  /// does not silently fall back to cached data. The Cubit decides what
  /// to show on failure using [getCachedMatches] itself.
  Future<ResultApi<List<Match>>> getMatches();

  /// Returns all 12 groups with standings per team.
  /// Used to build [MatchHypeInput] stakes and goal threat factors.
  Future<ResultApi<List<Groups>>> getGroups();

  /// Returns all 48 teams with flags and FIFA codes.
  /// Used to enrich match cards with flag images and team names.
  Future<ResultApi<List<Team>>> getTeams();

  /// Returns stadium details for a given [stadiumId].
  /// Called by [MatchDetailsCubit] when the details screen opens.
  Future<ResultApi<Stadium>> getStadiumById(String stadiumId);

  /// Reads matches from the on-disk cache. Null if no cache exists yet.
  Future<List<Match>?> getCachedMatches();

  /// Reads groups from the on-disk cache. Null if no cache exists yet.
  Future<List<Groups>?> getCachedGroups();

  /// Reads teams from the on-disk cache. Null if no cache exists yet.
  Future<List<Team>?> getCachedTeams();
}
