class FindInfoModel {
  int id;
  String name;
  String discrip;
  String category;
  List<List<double>> path;
  String time;
  String userName;
  String contactInfo;
  String picture;

  FindInfoModel({
    this.id,
    this.name,
    this.discrip,
    this.category,
    this.path,
    this.time,
    this.userName,
    this.contactInfo,
    this.picture,
  });

  factory FindInfoModel.fromJson(Map<String, dynamic> json) {
    var list = <List<double>>[];
    var tmp = json['path'] as List;
    if (tmp == null || tmp.isEmpty) {
      list = null;
    } else {
      var a = <double>[];
      a.add(tmp[0][0]);
      a.add(tmp[0][1]);
      list.add(a);
    }
    return FindInfoModel(
      id: json['id'] as int,
      name: json['name'] as String,
      discrip: json['discrip'] as String,
      category: json['category'] as String,
      path: list,
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
      'place': path,
      'time': time,
      'user_name': userName,
      'contact_info': contactInfo,
      'picture': picture,
    };
  }
}
