import 'package:world_cup_watch/core/constants/rivalires.dart';

import '../constants/fifa_rankings.dart';
import '../constants/hype_reasons.dart';

/// The result of a hype score calculation for a single match.
/// Contains both the numeric score and the human-readable reason tags.
class HypeResult {
  /// Weighted hype score from 0.0 to 10.0
  final double score;

  /// Up to 3 human-readable reason tags explaining the score.
  /// Shown as chips/tags in the match card UI.
  final List<String> reasons;

  const HypeResult({required this.score, required this.reasons});

  @override
  String toString() => 'HypeResult(score: $score, reasons: $reasons)';
}

/// Input data the calculator needs per match.
/// Populated by the repository from API responses.
class MatchHypeInput {
  /// FIFA country code for home team (e.g. 'BRA')
  final String homeTeamCode;

  /// FIFA country code for away team (e.g. 'MAR')
  final String awayTeamCode;

  /// Match stage: 'group', 'round_of_32', 'round_of_16',
  /// 'quarter_final', 'semi_final', 'final'
  final String stage;

  /// Home team points in group standings (null if knockout stage)
  final int? homeTeamPoints;

  /// Away team points in group standings (null if knockout stage)
  final int? awayTeamPoints;

  /// Home team matches played so far
  final int? homeTeamMatchesPlayed;

  /// Away team matches played so far
  final int? awayTeamMatchesPlayed;

  /// Home team goals scored so far in tournament
  final int? homeTeamGoalsScored;

  /// Away team goals scored so far in tournament
  final int? awayTeamGoalsScored;

  /// Which matchday within the group stage (1, 2, or 3)
  /// null for knockout matches
  final int? groupMatchday;

  const MatchHypeInput({
    required this.homeTeamCode,
    required this.awayTeamCode,
    required this.stage,
    this.homeTeamPoints,
    this.awayTeamPoints,
    this.homeTeamMatchesPlayed,
    this.awayTeamMatchesPlayed,
    this.homeTeamGoalsScored,
    this.awayTeamGoalsScored,
    this.groupMatchday,
  });
}

/// Calculates a hype score (0.0–10.0) and generates reason tags for a match.
///
/// Pure Dart — no Dio, no Cubit, no Flutter dependencies.
/// Fully unit-testable.
///
/// Five weighted factors:
///   Stage Bonus      25% — knockout rounds score higher than group games
///   Group Stakes     30% — how much both teams need points
///   Team Quality     20% — average FIFA ranking of both teams
///   Rivalry          15% — historical rivalry intensity
///   Goal Threat      10% — average goals scored per game
///
/// Total always sums to 10.0 max.
class HypeScoreCalculator {
  HypeScoreCalculator._();

  // ─── Factor Weights (must sum to 1.0) ────────────────────────────────────────
  static const double _stageWeight = 0.25;
  static const double _stakesWeight = 0.30;
  static const double _qualityWeight = 0.20;
  static const double _rivalryWeight = 0.15;
  static const double _goalWeight = 0.10;

  /// Main entry point. Pass a [MatchHypeInput] → get a [HypeResult].
  static HypeResult calculate(MatchHypeInput input) {
    // ── 1. Calculate each factor score (0.0–10.0) ──────────────────────────────
    final stageScore = _stageScore(input.stage);
    final stakesScore = _stakesScore(input);
    final qualityScore = FifaRankings.matchQualityScore(
      input.homeTeamCode,
      input.awayTeamCode,
    );
    final rivalryScore = Rivalries.getRivalryScore(
      input.homeTeamCode,
      input.awayTeamCode,
    );
    final goalScore = _goalThreatScore(input);

    // ── 2. Apply weights ────────────────────────────────────────────────────────
    final weightedScore =
        (stageScore * _stageWeight) +
        (stakesScore * _stakesWeight) +
        (qualityScore * _qualityWeight) +
        (rivalryScore * _rivalryWeight) +
        (goalScore * _goalWeight);

    // ── 3. Clamp to 0.0–10.0 and round to 1 decimal ────────────────────────────
    final finalScore = double.parse(
      weightedScore.clamp(0.0, 10.0).toStringAsFixed(1),
    );

    // ── 4. Build reason tags ────────────────────────────────────────────────────
    final reasons = _buildReasons(
      input: input,
      stageScore: stageScore,
      stakesScore: stakesScore,
      qualityScore: qualityScore,
      rivalryScore: rivalryScore,
      goalScore: goalScore,
    );

    return HypeResult(score: finalScore, reasons: reasons);
  }

  // ─── Factor: Stage (0.0–10.0) ────────────────────────────────────────────────
  /// Knockout matches always score higher — the later the stage, the higher the score.
  static double _stageScore(String stage) {
    switch (stage.toLowerCase()) {
      case 'final':
        return 10.0;
      case 'semi_final':
        return 8.5;
      case 'quarter_final':
        return 7.0;
      case 'round_of_16':
        return 5.5;
      case 'round_of_32':
        return 4.0;
      case 'group':
        return 2.5;
      default:
        return 2.5;
    }
  }

  // ─── Factor: Group Stakes (0.0–10.0) ─────────────────────────────────────────
  /// How much pressure each team is under in the group stage.
  /// Based on points and matchday — a team with 0 points in matchday 3 is desperate.
  /// Knockout matches always return max stakes (10.0) — every knockout is must-win.
  static double _stakesScore(MatchHypeInput input) {
    // Knockout stage — always maximum stakes
    if (input.stage.toLowerCase() != 'group') return 10.0;

    // No standings data available — return neutral score
    final homePoints = input.homeTeamPoints;
    final awayPoints = input.awayTeamPoints;
    final matchday = input.groupMatchday ?? 1;

    if (homePoints == null || awayPoints == null) return 5.0;

    // How desperate are each team based on points + matchday?
    final homeDesperation = _desperationScore(homePoints, matchday);
    final awayDesperation = _desperationScore(awayPoints, matchday);

    // Average desperation of both teams drives the stakes score
    // If both teams are desperate → very high stakes
    // If both are comfortable → lower stakes
    return ((homeDesperation + awayDesperation) / 2).clamp(0.0, 10.0);
  }

  /// Returns how desperate a team is based on their current points and matchday.
  /// 10.0 = must win or eliminated, 2.0 = already qualified comfortably.
  static double _desperationScore(int points, int matchday) {
    if (matchday == 1) {
      // First game — everyone is equal, moderate stakes
      return 5.0;
    } else if (matchday == 2) {
      if (points == 0) return 9.0; // Lost first game — must win
      if (points == 1) return 7.0; // Drew — needs a result
      if (points == 3) return 5.0; // Won — comfortable but not through
      return 5.0;
    } else {
      // Matchday 3 — final group game, highest pressure
      if (points == 0) return 10.0; // Must win to have any chance
      if (points == 1) return 9.0; // Need a win or favorable result
      if (points == 3) return 7.0; // Win = certain qualification
      if (points == 4) return 5.0; // Draw likely enough
      if (points == 6) return 2.0; // Already qualified — dead rubber
      return 5.0;
    }
  }

  // ─── Factor: Goal Threat (0.0–10.0) ──────────────────────────────────────────
  /// Average goals per game for both teams combined.
  /// 3+ goals/game combined = 10.0, 0 goals/game = 0.0
  static double _goalThreatScore(MatchHypeInput input) {
    final homeGF = input.homeTeamGoalsScored;
    final awayGF = input.awayTeamGoalsScored;
    final homeMatches = input.homeTeamMatchesPlayed;
    final awayMatches = input.awayTeamMatchesPlayed;

    // Not enough data yet (first match of tournament) — return neutral
    if (homeGF == null ||
        awayGF == null ||
        homeMatches == null ||
        awayMatches == null ||
        homeMatches == 0 ||
        awayMatches == 0) {
      return 5.0;
    }

    final homeAvg = homeGF / homeMatches;
    final awayAvg = awayGF / awayMatches;
    final combinedAvg = homeAvg + awayAvg;

    // Scale: 0 goals/game combined = 0.0, 3+ goals/game combined = 10.0
    return (combinedAvg / 3.0 * 10.0).clamp(0.0, 10.0);
  }

  // ─── Reason Builder ───────────────────────────────────────────────────────────
  /// Builds up to 3 reason tags explaining the hype score.
  /// First checks for hardcoded match narratives, then falls back to generic tags.
  static List<String> _buildReasons({
    required MatchHypeInput input,
    required double stageScore,
    required double stakesScore,
    required double qualityScore,
    required double rivalryScore,
    required double goalScore,
  }) {
    // Check for specific narrative first (e.g. BRA vs MAR → "2022 WC Rematch")
    final narrative = HypeReasons.getNarrative(
      input.homeTeamCode,
      input.awayTeamCode,
    );
    if (narrative.isNotEmpty) {
      return narrative.take(3).toList();
    }

    // Build generic reason tags based on factor scores
    final reasons = <String>[];

    // Stage reason
    switch (input.stage.toLowerCase()) {
      case 'final':
        reasons.add(HypeReasons.worldCupFinal);
        break;
      case 'semi_final':
        reasons.add(HypeReasons.semifinal);
        break;
      case 'quarter_final':
        reasons.add(HypeReasons.quarterFinal);
        break;
      case 'round_of_16':
        reasons.add(HypeReasons.roundOf16);
        break;
      case 'round_of_32':
        reasons.add(HypeReasons.roundOf32);
        break;
      case 'group':
        if (stakesScore >= 8.5) {
          reasons.add(HypeReasons.mustWinGame);
        } else if (stakesScore >= 6.5) {
          reasons.add(HypeReasons.groupStageDecider);
        } else if (stakesScore <= 2.5) {
          reasons.add(HypeReasons.deadRubber);
        }
        break;
    }

    // Rivalry reason
    if (rivalryScore >= 9.0) {
      reasons.add(HypeReasons.classicRivalry);
    } else if (rivalryScore >= 7.0) {
      reasons.add(HypeReasons.historicRivalry);
    } else if (rivalryScore >= 5.0) {
      reasons.add(HypeReasons.continentalDerby);
    } else if (rivalryScore <= 2.5) {
      reasons.add(HypeReasons.davidVsGoliath);
    }

    // Team quality reason
    if (qualityScore >= 9.0) {
      reasons.add(HypeReasons.bothTopFive);
    } else if (qualityScore >= 7.5) {
      reasons.add(HypeReasons.bothTopTen);
    } else if (qualityScore >= 6.0) {
      reasons.add(HypeReasons.titleContender);
    }

    // Goal threat reason
    if (goalScore >= 8.0) {
      reasons.add(HypeReasons.goalFest);
    } else if (goalScore >= 6.0) {
      reasons.add(HypeReasons.highScoring);
    }

    // Stakes reason (if not already covered by stage)
    if (input.stage.toLowerCase() == 'group') {
      if (stakesScore >= 9.0 && !reasons.contains(HypeReasons.mustWinGame)) {
        reasons.add(HypeReasons.eliminationThreat);
      }
    }

    // Always return max 3 reasons
    return reasons.take(3).toList();
  }
}
