import 'package:world_cup_watch/core/network/result_api.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';

/// Abstract repository for the matches feature.
/// Implemented by [MatchesRepositoryImpl].
///
/// Keeps three concerns separate so each can be reused independently:
/// - [getMatches]  → used by matches feature + tournament feature
/// - [getGroups]   → used by matches feature (hype score stakes factor)
/// - [getTeams]    → used by matches feature (flags) + tournament feature
abstract class MatchesRepository {
  /// Returns all 104 World Cup matches.
  /// Cubit is responsible for filtering by date or stage.
  Future<ResultApi<List<Match>>> getMatches();

  /// Returns all 12 groups with standings per team.
  /// Used to build [MatchHypeInput] stakes and goal threat factors.
  Future<ResultApi<List<Groups>>> getGroups();

  /// Returns all 48 teams with flags and FIFA codes.
  /// Used to enrich match cards with flag images and team names.
  Future<ResultApi<List<Team>>> getTeams();
}
