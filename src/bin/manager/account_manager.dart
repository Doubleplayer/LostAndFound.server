import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:date_format/date_format.dart';
import 'sql_manager.dart';
import 'dart:math';

class AccountManager {
  static Future<bool> sendVerifyNum(String targetMai) async {
    var username = '2564300726@qq.com';
    var password = 'xhoahtzkhfrpdiae';

    final smtpServer = qq(username, password);

    // Create our message.
    var timeNow = formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss]);
    final message = Message()
      ..from = Address(username, 'LostAndFound')
      ..recipients.add(targetMai)
      ..subject = '欢迎注册北大LostAndFound失物招领系统😀'
      ..html =
          '<h1>注册验证码</h1>\n<p>Hey! 您的注册验证码为${createRandomVerifyNum(6)}，有效时间为5分钟</p><p>$timeNow</p>';
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
}

main(List<String> args) async {
  await AccountManager.sendVerifyNum('2823665238@qq.com');
}
