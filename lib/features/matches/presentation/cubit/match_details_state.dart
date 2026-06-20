import 'package:world_cup_watch/features/matches/data/models/stadium_model.dart';

abstract class MatchDetailsState {}

class StadiumLoading extends MatchDetailsState {}

class StadiumLoaded extends MatchDetailsState {
  /// Null if the match has no stadiumId or the fetch failed —
  /// the UI degrades gracefully (hides the stadium section).
  final Stadium? stadium;
  StadiumLoaded({this.stadium});
}

class StadiumError extends MatchDetailsState {
  final String message;
  StadiumError(this.message);
}
