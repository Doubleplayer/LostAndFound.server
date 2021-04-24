import 'package:mysql1/mysql1.dart';

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

//插入早起签到信息
  Future<bool> insertGetUpInfo(String date) async {
    var result =
        await db.query("insert into get_up (date) values (?);", [date]);
    if (result.affectedRows == 0) {
      return false;
    } else {
      return true;
    }
  }

  //插入早起签到信息
  Future<String> getLostInfo() async {
    var result = await db.query("select * from lost_info;");
    return result.toString();
  }
}
