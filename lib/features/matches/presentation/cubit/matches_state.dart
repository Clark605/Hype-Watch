import 'match_card.dart';

/// Base class for all matches states.
abstract class MatchesState {}

/// Initial state — app just opened, nothing loaded yet.
class MatchesInitial extends MatchesState {}

/// Loading state — API calls in progress.
class MatchesLoading extends MatchesState {}

/// Loaded state — matches sorted by hype score, ready to display.
class MatchesLoaded extends MatchesState {
  /// All match cards sorted by hype score descending.
  /// Already filtered based on [activeFilter].
  final List<MatchCard> matchCards;

  /// The currently active filter.
  final MatchesFilter activeFilter;

  MatchesLoaded({required this.matchCards, required this.activeFilter});

  /// Used by the Cubit to apply a new filter without re-fetching from API.
  MatchesLoaded copyWith({
    List<MatchCard>? matchCards,
    MatchesFilter? activeFilter,
  }) {
    return MatchesLoaded(
      matchCards: matchCards ?? this.matchCards,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

/// Error state — API call failed and no cache available.
class MatchesError extends MatchesState {
  final String message;
  MatchesError(this.message);
}

/// Filter options shown in the UI filter button.
enum MatchesFilter {
  today, // default — only today's matches
  all, // all 104 matches
  upcoming, // not yet played
  finished, // already played
}
