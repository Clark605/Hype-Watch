import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/network/result_api.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/stadium_model.dart';
import 'package:world_cup_watch/features/matches/data/repo/matches_repo.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/match_details_state.dart';

/// Cubit for the match details screen.
/// Only responsibility: fetch the stadium for this match.
/// groups and teams are already in memory (passed via MatchDetailsScreen
/// constructor) — no re-fetch needed, no state needed for them.
class MatchDetailsCubit extends Cubit<MatchDetailsState> {
  final MatchesRepository _repository;
  final Match _match;

  MatchDetailsCubit({
    required MatchesRepository repository,
    required Match match,
  }) : _repository = repository,
       _match = match,
       super(StadiumLoading());

  /// Called in [MatchDetailsScreen.initState].
  /// Fetches stadium only — everything else is already available in the screen.
  Future<void> load() async {
    final stadiumId = _match.stadiumId;

    if (stadiumId == null || stadiumId.isEmpty) {
      // No stadium to fetch — emit null so the UI hides the stadium section.
      emit(StadiumLoaded(stadium: null));
      return;
    }

    emit(StadiumLoading());

    final result = await _repository.getStadiumById(stadiumId);

    if (result is SuccessApi<Stadium>) {
      emit(StadiumLoaded(stadium: result.data));
    } else {
      // Degrade gracefully — show the rest of the screen without stadium.
      emit(StadiumLoaded(stadium: null));
    }
  }
}
