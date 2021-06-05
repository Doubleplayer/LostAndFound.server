class LostInfoModel {
  int id;
  String name;
  String discrip;
  String category;
  List<List<double>> path;
  String time;
  int ifFind;
  String userName;
  String contactInfo;
  String picture;

  LostInfoModel({
    this.id,
    this.name,
    this.discrip,
    this.category,
    this.path,
    this.time,
    this.ifFind,
    this.userName,
    this.contactInfo,
    this.picture,
  });

  factory LostInfoModel.fromJson(Map<String, dynamic> json) {
    var list = <List<double>>[];
    var tmp = json['path'] as List;
    if (tmp == null) {
      list = null;
    } else {
      for (var i = 0; i < tmp.length; i++) {
        var a = <double>[];
        a.add(tmp[i][0]);
        a.add(tmp[i][1]);
        list.add(a);
      }
    }
    return LostInfoModel(
      id: json['id'] as int,
      name: json['name'] as String,
      discrip: json['discrip'] as String,
      category: json['category'] as String,
      path: list,
      time: json['time'] as String,
      ifFind: json['if_find'] as int,
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
      'path': path,
      'time': time,
      'if_find': ifFind,
      'user_name': userName,
      'contact_info': contactInfo,
      'picture': picture,
    };
  }
}
