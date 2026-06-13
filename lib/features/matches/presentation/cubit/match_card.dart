import 'package:intl/intl.dart';
import 'package:world_cup_watch/core/utils/hype_score_calculator.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';

/// View model representing a single match card in the UI.
///
/// Combines raw API data ([match], [homeTeam], [awayTeam])
/// with the calculated hype result ([hype]) into one object
/// the UI can render directly — no logic needed in the widget layer.
class MatchCard {
  final Match match;
  final Team homeTeam;
  final Team awayTeam;
  final HypeResult hype;

  const MatchCard({
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.hype,
  });

  /// Convenience getters so widgets don't reach into nested objects
  String get homeTeamName => homeTeam.nameEn;
  String get awayTeamName => awayTeam.nameEn;
  String get homeFlag => homeTeam.flag;
  String get awayFlag => awayTeam.flag;
  double get hypeScore => hype.score;
  List<String> get reasons => hype.reasons;
  bool get isFinished => match.finished;
  bool get isToday {
    final matchDate = DateFormat(
      "MM/dd/yyyy HH:mm",
    ).parse(match.localDate).toUtc();
    print(
      'Checking if match on ${matchDate.toString()} is today (${DateTime.now().toLocal()})',
    );
    final nowUtc = DateTime.now().toUtc();

    final difference = matchDate.difference(nowUtc).inHours.abs();
    return difference <= 20;
  }
}
