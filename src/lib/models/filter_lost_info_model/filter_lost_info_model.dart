import 'package:date_format/date_format.dart';

class FilterLostInfoModel {
  int id;
  String name;
  String discrip;
  String category;
  List<List<double>> path;
  String startTime;
  String endTime;
  int ifFind;
  String userName;
  String contactInfo;
  String picture;
  int type;

  FilterLostInfoModel({
    this.id,
    this.name,
    this.discrip,
    this.category,
    this.path,
    this.startTime,
    this.endTime,
    this.ifFind,
    this.userName,
    this.contactInfo,
    this.picture,
    this.type,
  });

  factory FilterLostInfoModel.fromJson(Map<String, dynamic> json) {
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
    var res = FilterLostInfoModel(
      id: json['id'] as int,
      name: json['name'] as String,
      discrip: json['discrip'] as String,
      category: json['category'] as String,
      path: list,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      ifFind: json['if_find'] as int,
      userName: json['user_name'] as String,
      contactInfo: json['contact_info'] as String,
      picture: json['picture'] as String,
      type: json['type'] as int,
    );
    if (res.startTime == null || res.startTime == '') {
      res.startTime = '2020-01-02 03:14:07';
    }
    if (res.endTime == null || res.endTime == '') {
      res.endTime = formatDate(
          DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
    }
    return res;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discrip': discrip,
      'category': category,
      'path': path,
      'start_time': startTime,
      'end_time': endTime,
      'if_find': ifFind,
      'user_name': userName,
      'contact_info': contactInfo,
      'picture': picture,
      'type': type,
    };
  }
}
