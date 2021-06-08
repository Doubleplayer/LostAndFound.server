import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:date_format/date_format.dart';
import 'package:src/models/register_info/register_info.dart';
import 'package:src/models/user/user.dart';
import 'sql_manager.dart';
import 'dart:math';

class AccountManager {
  static Future<bool> sendMessage(String targetMai, String info) async {
    if (targetMai.isEmpty) {
      return false;
    }
    var username = '2564300726@qq.com';
    var password = 'xhoahtzkhfrpdiae';

    final smtpServer = qq(username, password);

    // Create our message.
    var timeNow = formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
    final message = Message()
      ..from = Address(username, 'LostAndFound')
      ..recipients.add(targetMai)
      ..subject = 'LostAndFound失物招领系统😀'
      ..html = '<h1>来自系统的信息</h1>\n<p>$info</p><p>$timeNow</p>';
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      if (sendReport.toString().contains('success')) {
        return true;
      } else {
        return false;
      }
    } on MailerException catch (e) {
      print('Message not sent.$e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }

  static Future<bool> sendVerifyNum(String targetMail) async {
    var sql = await Sql.NewSql();
    var vnum = createRandomVerifyNum(6);
    var message = 'Hey! 您的注册验证码为${vnum}，有效时间为5分钟';
    var if_send = await sendMessage(targetMail, message);
    if (!if_send) {
      return false;
    }
    var now = formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
    await sql.saveRegisteInfo(
        RegisterInfo(email: targetMail, vnum: vnum, lastTime: now));
    return true;
  }

  static String createToken() {
    return createRandomNum(25);
  }

  ///生成随机字符串
  static String createRandomNum(int lenth) {
    var alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    var strlenght = lenth;

    /// 生成的字符串固定长度
    var left = '';
    for (var i = 0; i < strlenght; i++) {
      left = left + alphabet[Random().nextInt(alphabet.length)];
    }
    return left;
  }

  ///生成随机数字
  static String createRandomVerifyNum(int lenth) {
    var alphabet = '0123456789';
    var strlenght = lenth;

    /// 生成的字符串固定长度
    var left = '';
    for (var i = 0; i < strlenght; i++) {
      left = left + alphabet[Random().nextInt(alphabet.length)];
    }
    return left;
  }

//检验密码是否相同，-1为没有该用户，0为密码错误，1为正确
  static Future<int> checkPassword(String name, String password) async {
    var sql = Sql();
    await sql.connect();
    var truePass = await sql.getPassWord(name);
    await sql.db.close();
    if (truePass == 'NO') {
      return -1;
    } else if (truePass == password) {
      return 1;
    } else {
      return 0;
    }
  }

//保存用户信息
  static Future<Map<String, String>> saveUser(
      String name, String email, String password, String vnum) async {
    var sql = await Sql.NewSql();

    if ((await sql.getUserByName(name)) != null) {
      return {'msg': '用户名已被注册'};
    }
    if ((await sql.getUserByEmail(email)) != null) {
      return {'msg': '邮箱已被注册'};
    }
    var registInfo = await sql.getRegisteInfoByMail(email);
    if (registInfo == null || registInfo.vnum != vnum) {
      return {'msg': '验证码错误'};
    }
    var last = DateTime.parse(registInfo.lastTime);
    if (DateTime.now().difference(last).inMinutes >= 5) {
      return {'msg': '验证码过期'};
    }
    var token = createToken();
    var u = User(
        token: createToken(), email: email, name: name, password: password);
    if (!(await sql.saveUser(u))) {
      return {'msg': '系统开小差了'};
    }
    if (!(await sql.deleteRegisteInfoByEmail(email))) {
      return {'msg': '系统开小差了'};
    }
    return {'msg': 'SUCESS', 'token': token};
  }

  static Future<bool> existEmail(String email) async {
    var sql = await Sql.NewSql();
    if ((await sql.getUserByEmail(email)) != null) {
      return true;
    }
    return false;
  }

  static Future<bool> existUserName(String name) async {
    var sql = await Sql.NewSql();
    if ((await sql.getUserByEmail(name)) != null) {
      return true;
    }
    return false;
  }
}

main(List<String> args) async {
  await AccountManager.sendVerifyNum('1125195347@qq.com');
}
