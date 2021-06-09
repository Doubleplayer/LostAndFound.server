import 'dart:math';
import 'package:mysql1/mysql1.dart';
import 'package:date_format/date_format.dart';
import 'package:src/models/user/user.dart';
import 'package:src/models/lost_info_model/lost_info_model.dart';
import 'package:src/models/register_info/register_info.dart';
import 'package:src/models/filter_lost_info_model/filter_lost_info_model.dart';
import '../config/config.dart' as config;

class Sql {
  MySqlConnection db;
  ConnectionSettings settings;
  Sql({this.settings}) {
    if (settings == null) {
      var host = 'landx.top';
      if (config.env == config.LOCAL) {
        host = 'localhost';
      }
      settings = ConnectionSettings(
        host: host,
        port: 3306,
        user: 'lsh',
        db: 'lost_and_found',
        password: 'lsh2xmz..',
      );
    }
  }

  List<LostInfoModel> transToLostInfo(List<Row> tmp) {
    var lostInfoList = <Map<String, dynamic>>[];
    for (int i = 0; i < tmp.length; i++) {
      lostInfoList.add(tmp[i].fields);
    }
    var transList = <LostInfoModel>[];
    for (var i = 0; i < lostInfoList.length; i++) {
      var strPath = (lostInfoList[i]['path'] as Blob).toString();
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
      lostInfoList[i]['path'] = listDoublePath;
      lostInfoList[i]['time'] = formatDate(lostInfoList[i]['time'] as DateTime,
          [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
      transList.add(LostInfoModel.fromJson(lostInfoList[i]));
    }
    return transList;
  }

  User transToUser(Row tmp) {
    var fileds = tmp.fields;
    return User.fromJson(fileds);
  }

  RegisterInfo transToRegisterInfo(Row tmp) {
    var fileds = tmp.fields;
    return RegisterInfo.fromJson(fileds);
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

  Future<String> getCount() async {
    var result = await db.query('select count(*) from lost_info;');
    var tmp = result.toList()[0];
    return tmp[0].toString();
  }

  Future<bool> setToken(String token, String name) async {
    var timeNow = formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
    var result = await db.query(
        'Update user set token = ?, last_time = ? where name =?;',
        [token, timeNow, name]);
    if (result.affectedRows == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<RegisterInfo> getRegisteInfoByMail(String email) async {
    var result =
        await db.query('select * from registe_info where email= ?;', [email]);
    var list = result.toList();
    if (list.isEmpty) return null;
    return transToRegisterInfo(list[0]);
  }

  Future<bool> saveRegisteInfo(RegisterInfo r) async {
    var timeNow = formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
    var result = await db.query(
        'replace into registe_info (email,vnum,last_time) values (?,?,?);',
        [r.email, r.vnum, timeNow]);
    if (result.affectedRows == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> deleteRegisteInfoByEmail(String email) async {
    var result =
        await db.query('DELETE FROM  registe_info where email = ?;', [email]);
    if (result.affectedRows == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<User> getUserByEmail(String email) async {
    var result = await db.query('select * from user where email= ?;', [email]);
    var list = result.toList();
    if (list.isEmpty) return null;
    return transToUser(list[0]);
  }

  Future<User> getUserByName(String name) async {
    var result = await db.query('select * from user where name= ?;', [name]);
    var list = result.toList();
    if (list.isEmpty) return null;
    return transToUser(list[0]);
  }

  Future<bool> saveUser(User u) async {
    var time = formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
    var result = await db.query(
        'insert into user (name,password,last_time,token,email) values (?,?,?,?,?);',
        [u.name, u.password, time, u.token, u.email]);
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
    if (tmp.isEmpty) {
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

  bool isInPolygon(List<double> p, List<List<double>> poly) {
    var x = p[0];
    var y = p[1];
    int i, j = poly.length - 1;
    var oddNodes = false;

    for (i = 0; i < poly.length; i++) {
      if ((poly[i][1] < y && poly[j][1] >= y ||
              poly[j][1] < y && poly[i][1] >= y) &&
          (poly[i][0] <= x || poly[j][0] <= x)) {
        if (poly[i][0] +
                (y - poly[i][1]) /
                    (poly[j][1] - poly[i][1]) *
                    (poly[j][0] - poly[i][0]) <
            x) {
          oddNodes = !oddNodes;
        }
      }
      j = i;
    }

    return oddNodes;
  }

  //筛选LostInfo
  Future<List<LostInfoModel>> fliterLostInfo(
      FilterLostInfoModel lostInfo) async {
    var filterStr = <String>[];
    var filterParms = <Object>[];

    if (lostInfo.id != null) {
      filterStr.add('id = ?');
      filterParms.add(lostInfo.id);
    }

    if (lostInfo.category != null && lostInfo.category != '') {
      filterStr.add('category = ?');
      filterParms.add(lostInfo.category);
    }

    {
      filterStr.add('time between ? and ?');
      filterParms.add(lostInfo.startTime);
      filterParms.add(lostInfo.endTime);
    }

    if (lostInfo.ifFind != null) {
      filterStr.add('if_find = ?');
      filterParms.add(lostInfo.ifFind);
    }

    if (lostInfo.userName != null && lostInfo.userName.isNotEmpty) {
      filterStr.add('user_name = ?');
      filterParms.add(lostInfo.userName);
    }

    if (lostInfo.type != null) {
      filterStr.add('type = ?');
      filterParms.add(lostInfo.type);
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
        'select * from lost_info where ' + filterStr.join(' and ') + ';';
    var res = <LostInfoModel>[];
    var tmp = (await db.query(quaryStr, filterParms)).toList();
    res = transToLostInfo(tmp);
    if (lostInfo.path == null || lostInfo.path.isEmpty) {
      return res;
    }
    var filterRes = <LostInfoModel>[];
    for (var i = 0; i < res.length; i++) {
      // for (var item in lostInfo.path) {
      //   var flag =
      //       nearByLine([res[i].path[0][0], res[i].path[0][1]], old, item);
      //   print(flag);
      //   if (flag) {
      //     filterRes.add(res[i]);
      //     break;
      //   }
      // }
      for (var p in res[i].path) {
        if (isInPolygon(p, lostInfo.path)) {
          filterRes.add(res[i]);
          break;
        }
      }
    }

    return filterRes;
  }

  Future<bool> uploadInfo(LostInfoModel lostInfo) async {
    var queryStr = 'insert into lost_info ',
        filterStr = <String>[],
        filterStr2 = <String>[],
        filterParms = <Object>[];
    if (lostInfo.name != null && lostInfo.name.isNotEmpty) {
      filterStr.add('name');
      filterStr2.add('?');
      filterParms.add(lostInfo.name);
    }
    if (lostInfo.discrip != null && lostInfo.discrip.isNotEmpty) {
      filterStr.add('discrip');
      filterStr2.add('?');
      filterParms.add(lostInfo.discrip);
    }
    if (lostInfo.category != null && lostInfo.category.isNotEmpty) {
      filterStr.add('category');
      filterStr2.add('?');
      filterParms.add(lostInfo.category);
    }
    if (lostInfo.path != null && lostInfo.path.isNotEmpty) {
      var tmp = <String>[];
      for (var item in lostInfo.path) {
        for (var p in item) {
          tmp.add(p.toString());
        }
        tmp.add(item.join(','));
      }
      filterStr.add('path');
      filterStr2.add('?');
      filterParms.add(tmp.join(','));
    }
    if (lostInfo.time != null && lostInfo.time.isNotEmpty) {
      filterStr.add('time');
      filterStr2.add('?');
      filterParms.add(lostInfo.time);
    }
    {
      filterStr.add('if_find');
      filterStr2.add('?');
      filterParms.add(0);
    }
    if (lostInfo.userName != null && lostInfo.userName.isNotEmpty) {
      filterStr.add('user_name');
      filterStr2.add('?');
      filterParms.add(lostInfo.userName);
    }
    if (lostInfo.contactInfo != null && lostInfo.contactInfo.isNotEmpty) {
      filterStr.add('contact_info');
      filterStr2.add('?');
      filterParms.add(lostInfo.contactInfo);
    }
    if (lostInfo.picture != null && lostInfo.picture.isNotEmpty) {
      filterStr.add('picture');
      filterStr2.add('?');
      filterParms.add(lostInfo.picture);
    }
    if (lostInfo.type != null) {
      if (lostInfo.type < 0 || lostInfo.type > 1) return false;
      filterStr.add('type');
      filterStr2.add('?');
      filterParms.add(lostInfo.type);
    }
    queryStr = queryStr +
        '(' +
        filterStr.join(',') +
        ') values (' +
        filterStr2.join(',') +
        ');';
    var res = await db.query(queryStr, filterParms);
    if (res.affectedRows == 0) return false;
    return true;
  }

  Future<bool> updateIfFind(int id, int if_find, String solver) async {
    var res = await db.query(
        'Update lost_info set if_find = ? , solver = ?  where id=?;',
        [if_find, solver, id]);
    return res.affectedRows > 0;
  }
}
