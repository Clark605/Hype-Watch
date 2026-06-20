class StadiumModel {
  Stadium? stadium;

  StadiumModel({this.stadium});

  StadiumModel.fromJson(Map<String, dynamic> json) {
    stadium = json['stadium'] != null
        ? Stadium.fromJson(json['stadium'])
        : null;
  }
}

class Stadium {
  String? sId;
  String? id;
  String? nameEn;
  String? fifaName;
  String? cityEn;
  String? countryEn;
  int? capacity;
  String? region;
  String? createdAt;

  Stadium({
    this.sId,
    this.id,
    this.nameEn,
    this.fifaName,
    this.cityEn,
    this.countryEn,
    this.capacity,
    this.region,
    this.createdAt,
  });

  Stadium.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    id = json['id'];
    nameEn = json['name_en'];
    fifaName = json['fifa_name'];
    cityEn = json['city_en'];
    countryEn = json['country_en'];
    capacity = json['capacity'];
    region = json['region'];
    createdAt = json['createdAt'];
  }
}
