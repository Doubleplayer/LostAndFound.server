import 'package:path/path.dart';
import 'dart:io';
import 'sql_manager.dart';

String myPath = dirname(Platform.script.toFilePath());

class InfoManager {
  File file;
  File awards_file;
  File getUpTime_file;
  File version;
  File order;
  File identification_file;
  File image;
  String imagePath;
  String versionPath;
  String scorePath;
  String awardPath;
  String getUpTimePath;
  String orderPath;
  String identificationPath;
  Sql sql;
  Map awards;
  int pre_time;

  InfoManager() {
    pre_time = DateTime.now().millisecondsSinceEpoch;
    sql = Sql();
    this.scorePath = myPath + r'/../data/scores.txt';
    this.awardPath = myPath + r'/../data/awards.txt';
    this.getUpTimePath = myPath + r'/../data/getUpTime.txt';
    this.versionPath = myPath + r'/../data/version.txt';
    this.orderPath = myPath + r'/../data/order.txt';
    try {
      this.file = new File(scorePath);
      this.awards_file = new File(awardPath);
      this.getUpTime_file = new File(getUpTimePath);
      this.version = new File(versionPath);
      this.order = new File(orderPath);
    } catch (e) {}
  }

  void init() async {
    await sql.connect();
  }

  void reconnect_sql() async {
    int time_now = DateTime.now().millisecondsSinceEpoch;
    if (time_now - this.pre_time > 27000000) {
      await sql.db.close();
      await sql.connect();
      print("reconnect to sql");
    }
  }

  Future getIdentification(String username) async {
    this.identificationPath =
        myPath + r'/../data/' + username + '/identyfication.txt';
    var result = identification_file.readAsString();
    if (result == null)
      return '{}';
    else
      return result;
  }

  Future<bool> save_image(
      String filename, var content, String date, String time) async {
    this.imagePath = myPath +
        r'/../image/' +
        date +
        '_Sign_in' +
        filename.substring(filename.lastIndexOf('.'));
    print(imagePath);
    // bool flag = await sql.insertSignInInfo(date, imagePath, time);
    bool flag = true;
    if (flag == true) {
      image = File(imagePath);
      image.writeAsBytesSync(content);
      return true;
    } else {
      return false;
    }
  }

  Future<String> allLostInfo() async {
    var res = await sql.getLostInfo();
    return res;
  }
}
