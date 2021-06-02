import 'package:mysql1/mysql1.dart';
import 'package:date_format/date_format.dart';

class Sql {
  MySqlConnection db;
  ConnectionSettings settings;
  Sql({this.settings}) {
    if (this.settings == null) {
      this.settings = ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'lsh',
        db: 'lost_and_found',
        password: 'lsh2xmz..',
      );
    }
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

  Future<List<Map<String, dynamic>>> getFindInfo() async {
    var tmp = (await db.query('select * from find_info;')).toList();
    var res = <Map<String, dynamic>>[];
    for (int i = 0; i < tmp.length; i++) {
      res.add(tmp[i].fields);
    }
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
}
