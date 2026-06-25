class MatchModel {
  List<Match>? games;

  MatchModel({this.games});

  MatchModel.fromJson(Map<String, dynamic> json) {
    if (json['games'] != null) {
      games = <Match>[];
      json['games'].forEach((v) {
        games!.add(Match.fromJson(v));
      });
    }
  }
}

class Match {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeamNameEn;
  final String awayTeamNameEn;
  final String? homeTeamFlag;
  final String? awayTeamFlag;
  final int? homeScore;
  final int? awayScore;
  final String? homeScorers;
  final String? awayScorers;
  final String? group;
  final int? matchday;
  final String stage;
  final String localDate;
  final bool finished;
  final String timeElapsed;
  final String? stadiumId;

  /// For knockout matches with undetermined teams, the API sends labels like
  /// "Winner Match 74" or "3rd Group B/E/F/I/J" instead of a real team ID.
  final String? homeTeamLabel;
  final String? awayTeamLabel;

  Match({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamNameEn,
    required this.awayTeamNameEn,
    this.homeTeamFlag,
    this.awayTeamFlag,
    this.homeScore,
    this.awayScore,
    this.homeScorers,
    this.awayScorers,
    this.group,
    this.matchday,
    required this.stage,
    required this.localDate,
    required this.finished,
    required this.timeElapsed,
    this.stadiumId,
    this.homeTeamLabel,
    this.awayTeamLabel,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] ?? '',
      homeTeamId: json['home_team_id'] ?? '',
      awayTeamId: json['away_team_id'] ?? '',
      homeTeamNameEn: json['home_team_name_en'] ?? '',
      awayTeamNameEn: json['away_team_name_en'] ?? '',
      homeScore: int.tryParse(json['home_score'] ?? ''),
      awayScore: int.tryParse(json['away_score'] ?? ''),
      homeScorers: json['home_scorers'],
      awayScorers: json['away_scorers'],
      group: json['group'],
      matchday: int.tryParse(json['matchday'] ?? ''),
      // API uses "type" field for stage: "group", "r32", "r16",
      // "quarter_final", "semi_final", "final"
      stage: json['type'] ?? 'group',
      localDate: json['local_date'] ?? '',
      finished: json['finished'] == 'TRUE',
      stadiumId: json['stadium_id'] ?? json['stadium'],
      timeElapsed: json['time_elapsed'] ?? '',
      homeTeamLabel: json['home_team_label'],
      awayTeamLabel: json['away_team_label'],
    );
  }
}
