import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:date_format/date_format.dart';
import 'dart:math';

class AccountManager {
  static Future<bool> sendVerifyNum(String targetMai) async {
    // var username = '2564300726@qq.com';
    // var password = 'xhoahtzkhfrpdiae';
    var username = 'lsh1125195347@163.com';
    var password = 'SAWNSWCPUSEDHZAN';
    final smtpServer = SmtpServer('smtp.163.com',
        port: 25, username: username, password: password);

    // Create our message.
    var timeNow = formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
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
}

main(List<String> args) async {
  await AccountManager.sendVerifyNum('1125195347@qq.com');
}
