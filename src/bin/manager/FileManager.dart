import 'dart:io';
import 'package:http_server/http_server.dart' as http_server;
import 'package:path/path.dart';
import 'sql_manager.dart';
import 'account_manager.dart';
import '../config/config.dart' as config;

String myPath = dirname(Platform.script.toFilePath());

class FileManager {
  static void sendHtml(HttpRequest request) {
    http_server.VirtualDirectory staticFiles =
        new http_server.VirtualDirectory('.');
    staticFiles.serveFile(
        new File(myPath + r'/../webApp/index.html'), request); //win系统使用该代码
  }

  static void sendImage(HttpRequest request, String path) {
    http_server.VirtualDirectory staticFiles =
        new http_server.VirtualDirectory('.');
    staticFiles.serveFile(
        new File(myPath + r'/../image/' + path), request); //win系统使用该代码
  }

  static void sendApk(HttpRequest request) async {
    http_server.VirtualDirectory staticFiles =
        new http_server.VirtualDirectory('.');

    staticFiles.serveFile(
        new File(myPath + r'/../apk/APP.apk'), request); //win系统使用该代码
  }

  static void sendFile(HttpRequest request, String pathFromSrc) async {
    http_server.VirtualDirectory staticFiles =
        new http_server.VirtualDirectory('.');
    String filepath = myPath + r'/..' + pathFromSrc;
    staticFiles.serveFile(new File(filepath), request); //win系统使用该代码
  }

  static Future<String> save_image(String filename, var content) async {
    try {
      var sql = await Sql.NewSql();
      var name = await sql.getCount();
      name = name +
          AccountManager.createRandomVerifyNum(20 - name.length) +
          filename.substring(filename.lastIndexOf('.'), filename.length);
      var imagePath = myPath + r'/../image/' + name;
      print(imagePath);
      var image = File(imagePath);
      image.writeAsBytesSync(content);
      if (config.env == config.REMOTE) {
        return 'http://127.0.0.1:' +
            config.PORT.toString() +
            '/img?action=' +
            name;
      } else if (config.env == config.LOCAL) {
        return 'http://landx.top:' +
            config.PORT.toString() +
            '/img?action=' +
            name;
      }
    } catch (e) {
      return 'FAILED';
    }
  }
}
