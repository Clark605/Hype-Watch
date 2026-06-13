import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/stadium_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';

abstract class MatchDetailsState {}

class MatchDetailsLoading extends MatchDetailsState {}

class MatchDetailsLoaded extends MatchDetailsState {
  /// The stadium for this match. Null if the API didn't provide a stadiumId
  /// or the fetch failed — the UI degrades gracefully (hides the stadium section).
  final Stadium? stadium;

  /// The group this match belongs to. Null for knockout-stage matches.
  final Groups? group;

  /// All 48 teams, keyed by ID — used to resolve team names in standings table.
  final Map<String, Team> teamById;

  MatchDetailsLoaded({
    required this.stadium,
    required this.group,
    required this.teamById,
  });
}

class MatchDetailsError extends MatchDetailsState {
  final String message;
  MatchDetailsError(this.message);
}
