class TeamModel {
  List<Team>? teams;

  TeamModel({this.teams});

  TeamModel.fromJson(Map<String, dynamic> json) {
    if (json['teams'] != null) {
      teams = <Team>[];
      json['teams'].forEach((v) {
        teams!.add(Team.fromJson(v));
      });
    }
  }
}

class Team {
  final String id;
  final String nameEn;
  final String flag;
  final String fifaCode;

  Team({
    required this.id,
    required this.nameEn,
    required this.flag,
    required this.fifaCode,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? '',
      nameEn: json['name_en'] ?? '',
      flag: json['flag'] ?? '',
      fifaCode: json['fifa_code'] ?? '',
    );
  }
}
