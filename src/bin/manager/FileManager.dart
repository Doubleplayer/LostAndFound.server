import 'dart:io';
import 'package:http_server/http_server.dart' as http_server;
import 'package:path/path.dart';

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

  static String save_image(String filename, var content) {
    try {
      var imagePath = myPath + r'/../image/' + filename;
      print(imagePath);
      var image = File(imagePath);
      image.writeAsBytesSync(content);
      return imagePath;
    } catch (e) {
      return 'FAILED';
    }
  }
}
