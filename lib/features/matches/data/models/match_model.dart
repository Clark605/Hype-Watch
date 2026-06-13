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
  final String? group;
  final int? matchday;
  final String stage;
  final String localDate;
  final bool finished;

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
    this.group,
    this.matchday,
    required this.stage,
    required this.localDate,
    required this.finished,
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
      group: json['group'],
      matchday: int.tryParse(json['matchday'] ?? ''),
      stage: json['type'] ?? 'group',
      localDate: json['local_date'] ?? '',
      finished: json['finished'] == 'TRUE',
    );
  }
}
