class GroupModel {
  List<Groups>? groups;

  GroupModel({this.groups});

  GroupModel.fromJson(Map<String, dynamic> json) {
    if (json['groups'] != null) {
      groups = <Groups>[];
      json['groups'].forEach((v) {
        groups!.add(Groups.fromJson(v));
      });
    }
  }
}

class Groups {
  String? sId;
  String? name;
  List<GroupTeamStanding>? teams;
  String? createdAt;
  int? iV;

  Groups({this.sId, this.name, this.teams, this.createdAt, this.iV});

  Groups.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    if (json['teams'] != null) {
      teams = <GroupTeamStanding>[];
      json['teams'].forEach((v) {
        teams!.add(GroupTeamStanding.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    iV = json['__v'];
  }
}

class GroupTeamStanding {
  final String teamId;
  final int matchesPlayed;
  final int won;
  final int lost;
  final int drawn;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  GroupTeamStanding({
    required this.teamId,
    required this.matchesPlayed,
    required this.won,
    required this.lost,
    required this.drawn,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
  });

  factory GroupTeamStanding.fromJson(Map<String, dynamic> json) {
    return GroupTeamStanding(
      teamId: json['team_id'] ?? json['teamId'] ?? json['_id'] ?? '',
      matchesPlayed: int.tryParse(json['mp'] ?? '0') ?? 0,
      won: int.tryParse(json['w'] ?? '0') ?? 0,
      lost: int.tryParse(json['l'] ?? '0') ?? 0,
      drawn: int.tryParse(json['d'] ?? '0') ?? 0,
      points: int.tryParse(json['pts'] ?? '0') ?? 0,
      goalsFor: int.tryParse(json['gf'] ?? '0') ?? 0,
      goalsAgainst: int.tryParse(json['ga'] ?? '0') ?? 0,
      goalDifference: int.tryParse(json['gd'] ?? '0') ?? 0,
    );
  }
}
