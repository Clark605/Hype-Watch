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
  String? nameFa;
  String? fifaName;
  String? cityEn;
  String? cityFa;
  String? countryEn;
  String? countryFa;
  int? capacity;
  String? region;
  String? createdAt;

  Stadium({
    this.sId,
    this.id,
    this.nameEn,
    this.nameFa,
    this.fifaName,
    this.cityEn,
    this.cityFa,
    this.countryEn,
    this.countryFa,
    this.capacity,
    this.region,
    this.createdAt,
  });

  Stadium.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    id = json['id'];
    nameEn = json['name_en'];
    nameFa = json['name_fa'];
    fifaName = json['fifa_name'];
    cityEn = json['city_en'];
    cityFa = json['city_fa'];
    countryEn = json['country_en'];
    countryFa = json['country_fa'];
    capacity = json['capacity'];
    region = json['region'];
    createdAt = json['createdAt'];
  }
}
