import 'dart:math';
import 'package:mysql1/mysql1.dart';
import 'package:date_format/date_format.dart';
import 'package:src/models/find_info_model/find_info_model.dart';
import 'package:src/models/lost_info_model/lost_info_model.dart';
import '../config/config.dart' as config;

class Sql {
  MySqlConnection db;
  ConnectionSettings settings;
  Sql({this.settings}) {
    if (this.settings == null) {
      this.settings = ConnectionSettings(
        host: 'landx.top',
        port: 3306,
        user: 'lsh',
        db: 'lost_and_found',
        password: 'lsh2xmz..',
      );
    }
  }

  List<FindInfoModel> transToFindInfo(List<Row> tmp) {
    var findInfoList = <Map<String, dynamic>>[];
    for (int i = 0; i < tmp.length; i++) {
      findInfoList.add(tmp[i].fields);
    }
    var transList = <FindInfoModel>[];
    for (var i = 0; i < findInfoList.length; i++) {
      var strPath = (findInfoList[i]['path'] as Blob).toString();
      var listStrPath = strPath.split(','); //坐标的字符串列表
      var listDoublePath = <List<double>>[];
      var point = <double>[];
      for (var i = 0; i < listStrPath.length; i++) {
        point.add(double.parse(listStrPath[i]));
        if (i % 2 == 1) {
          listDoublePath.add(point.toList());
          point.clear();
        }
      }
      findInfoList[i]['path'] = listDoublePath;
      findInfoList[i]['time'] = formatDate(findInfoList[i]['time'] as DateTime,
          [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss]);
      transList.add(FindInfoModel.fromJson(findInfoList[i]));
    }
    return transList;
  }

  static Future<Sql> NewSql() async {
    var sql = new Sql();
    await sql.connect();
    return sql;
  }

  //链接数据库
  void connect() async {
    db = await MySqlConnection.connect(settings);
  }

  void disconnect() async {
    await db.close();
  }

//插入早起签到信息
  Future<bool> insertGetUpInfo(String date) async {
    var result =
        await db.query('insert into get_up (date) values (?);', [date]);
    if (result.affectedRows == 0) {
      return false;
    } else {
      return true;
    }
  }

  //获取LostInfo
  Future<List<Map<String, dynamic>>> getLostInfo() async {
    var tmp = (await db.query('select * from lost_info;')).toList();
    var res = <Map<String, dynamic>>[];
    for (int i = 0; i < tmp.length; i++) {
      res.add(tmp[i].fields);
    }
    return res;
  }

  Future<List<FindInfoModel>> getFindInfo() async {
    var tmp = (await db.query('select * from find_info;')).toList();
    var res = await transToFindInfo(tmp);
    return res;
  }

  Future<bool> setToken(String token, String name) async {
    var timeNow = formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss]);
    var result = await db.query(
        'Update user set token = ?, last_time = ? where name =?;',
        [token, timeNow, name]);
    if (result.affectedRows == 0) {
      return false;
    } else {
      return true;
    }
  }

  //获取PassWord
  Future<String> getPassWord(String name) async {
    var tmp =
        (await db.query('select password from user where name = ?;', [name]))
            .toList();
    var res = '';
    if (tmp.length <= 0) {
      res = 'NO';
    } else {
      res = tmp[0].fields['password'];
    }
    return res;
  }

  bool nearByLine(List<double> p, List<double> start, List<double> end) {
    var x1 = start[0],
        y1 = start[1],
        x2 = end[0],
        y2 = end[1],
        x0 = p[0],
        y0 = p[1];
    var A = y2 - y1;
    var B = x1 - x2;
    var C = y1 * (x2 - x1) + x1 * (y1 - y2);
    if (A == 0 && B == 0) {
      var a = (p[0] - start[0]).abs();
      var b = (p[1] - start[1]).abs();
      return (p[0] - start[0]).abs() <= config.lat_prefix &&
          (p[1] - start[1]).abs() <= config.lon_prefix;
    }
    var div = (A * x0 + B * y0 + C).abs() / sqrt(A * A + B * B);
    var min_x = min(x1, x2) - config.lat_prefix;
    var max_x = max(x1, x2) + config.lat_prefix;
    var min_y = min(y1, y2) - config.lon_prefix;
    var max_y = max(y1, y2) + config.lon_prefix;
    return x0 <= max_x &&
        x0 >= min_x &&
        y0 <= max_y &&
        y0 >= min_y &&
        div <= config.minDiv;
  }

  //通过LostInfo筛选FindInfo
  Future<List<FindInfoModel>> fliterFindInfo(LostInfoModel lostInfo) async {
    var filterStr = <String>[];
    var filterParms = <Object>[];

    if (lostInfo.category != null && lostInfo.category != '') {
      filterStr.add('category = ?');
      filterParms.add(lostInfo.category);
    }
    if (lostInfo.time != null && lostInfo.time != '') {
      filterStr.add('time >= ?');
      filterParms.add(lostInfo.time);
    }
    if (lostInfo.name != null && lostInfo.name != '') {
      var name = lostInfo.name;
      filterStr.add('name like ?');
      var str = '%';
      for (var i = 0; i < name.length; i++) {
        str = str + name[i] + '%';
      }
      filterParms.add(str);
    }
    filterStr.add('1=1');
    var quaryStr =
        'select * from find_info where ' + filterStr.join(' and ') + ';';
    var res = <FindInfoModel>[];
    var tmp = (await db.query(quaryStr, filterParms)).toList();
    res = transToFindInfo(tmp);
    if (lostInfo.path == null || lostInfo.path.isEmpty) {
      return res;
    }
    var filterRes = <FindInfoModel>[];
    for (var i = 0; i < res.length; i++) {
      var old = lostInfo.path[0];
      for (var item in lostInfo.path) {
        var flag =
            nearByLine([res[i].path[0][0], res[i].path[0][1]], old, item);
        print(flag);
        if (flag) {
          filterRes.add(res[i]);
        }
      }
    }

    return filterRes;
  }
}
