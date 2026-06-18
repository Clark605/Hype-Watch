import 'match_card.dart';

/// Base class for all matches states.
abstract class MatchesState {}

/// Initial state — app just opened, nothing loaded yet.
class MatchesInitial extends MatchesState {}

/// Loading state — used only on a true cold start (no cache exists yet).
class MatchesLoading extends MatchesState {}

/// Loaded state — matches sorted by hype score, ready to display.
class MatchesLoaded extends MatchesState {
  /// All match cards sorted by hype score descending.
  /// Already filtered based on [activeFilter].
  final List<MatchCard> matchCards;

  /// The currently active filter.
  final MatchesFilter activeFilter;

  /// True while a background refresh is in flight behind already-shown
  /// (possibly stale) data. Drives the "Updating..." indicator.
  final bool isRefreshing;

  /// True when the most recent background refresh failed after retries.
  /// [matchCards] still holds the last good (stale) data — this only
  /// drives a dismissible failure banner, never replaces the screen.
  final bool refreshFailed;

  MatchesLoaded({
    required this.matchCards,
    required this.activeFilter,
    this.isRefreshing = false,
    this.refreshFailed = false,
  });

  /// Used by the Cubit to apply a new filter or refresh status without
  /// losing the fields that didn't change.
  MatchesLoaded copyWith({
    List<MatchCard>? matchCards,
    MatchesFilter? activeFilter,
    bool? isRefreshing,
    bool? refreshFailed,
  }) {
    return MatchesLoaded(
      matchCards: matchCards ?? this.matchCards,
      activeFilter: activeFilter ?? this.activeFilter,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshFailed: refreshFailed ?? this.refreshFailed,
    );
  }
}

/// Error state — only reached on a true cold start with no cache to fall
/// back to. If a refresh fails while stale data is already on screen, that
/// stays a MatchesLoaded with refreshFailed: true instead — see above.
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
