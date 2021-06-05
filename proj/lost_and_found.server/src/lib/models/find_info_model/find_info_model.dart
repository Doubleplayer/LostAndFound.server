import 'place.dart';

class FindInfoModel {
  int id;
  String name;
  String discrip;
  String category;
  Place place;
  String time;
  String userName;
  String contactInfo;
  String picture;

  FindInfoModel({
    this.id,
    this.name,
    this.discrip,
    this.category,
    this.place,
    this.time,
    this.userName,
    this.contactInfo,
    this.picture,
  });

  factory FindInfoModel.fromJson(Map<String, dynamic> json) {
    return FindInfoModel(
      id: json['id'] as int,
      name: json['name'] as String,
      discrip: json['discrip'] as String,
      category: json['category'] as String,
      place: json['place'] == null
          ? null
          : Place.fromJson(json['place'] as Map<String, dynamic>),
      time: json['time'] as String,
      userName: json['user_name'] as String,
      contactInfo: json['contact_info'] as String,
      picture: json['picture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discrip': discrip,
      'category': category,
      'place': place?.toJson(),
      'time': time,
      'user_name': userName,
      'contact_info': contactInfo,
      'picture': picture,
    };
  }
}
