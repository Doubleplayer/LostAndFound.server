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
  int type;

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
    this.type,
  });

  factory LostInfoModel.fromJson(Map<String, dynamic> json) {
    var list = <List<double>>[];
    var tmp = [];
    if (json['path'].runtimeType == String) {
      var listStrPath = (json['path'] as String).split(',');
      var point = <double>[];
      for (var i = 0; i < listStrPath.length; i++) {
        point.add(double.parse(listStrPath[i]));
        if (i % 2 == 1) {
          tmp.add(point.toList());
          point.clear();
        }
      }
    } else {
      tmp = json['path'];
    }
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

    if (json['id'].runtimeType == String) {
      if (json['id'] = null || json['id'] == '') {
        json['id'] = null;
      } else {
        json['id'] = int.parse(json['id']);
      }
    }
    if (json['type'].runtimeType == String) {
      if (json['type'] == null || json['type'] == '') {
        json['type'] = null;
      } else {
        json['type'] = int.parse(json['type']);
      }
    }
    if (json['if_find'].runtimeType == String) {
      if (json['if_find'] == null || json['if_find'] == '') {
        json['if_find'] = null;
      } else {
        json['if_find'] = int.parse(json['if_find']);
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
      type: json['type'] as int,
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
      'type': type,
    };
  }
}
