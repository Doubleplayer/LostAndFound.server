import 'dart:convert';
import 'dart:io';
import './handler/handler.dart' as handler;

String myHost = '172.17.13.219';
String localHost = '127.0.0.1';
void main() async {
  {
    //创建服务器
    var requestServer = await HttpServer.bind(localHost, 9004);
    print('http服务启动起来');
    await for (HttpRequest req in requestServer) {
      try {
        handleRoute(req);
      } catch (e) {
        req.response
          ..write(jsonEncode({"msg": '系统开小差了'}))
          ..close();
        print(e);
      }
    }
  }
}

void handleRoute(HttpRequest req) async {
  if (await handler.CheckLoginStatus(req) == false) {
    return;
  }
  var path = req.requestedUri.path;
  req.response.headers.add("Access-Control-Allow-Origin", "*");
  if (path == '/') {
    handler.HandleRoot(req);
  } else if (path == '/lostInfo') {
    handler.HandleLostInfo(req);
  } else if (path == '/developInfo') {
    handler.HandleDevelopInfo(req);
  } else if (path == '/img') {
    handler.HandleImg(req);
  } else if (path == '/uploadInfo') {
    handler.HandleUploadLostInfo(req);
  } else if (path == '/login') {
    handler.HandleLogin(req);
  } else if (path == '/registe') {
    handler.HandleRegiste(req);
  } else if (path == '/findInfo') {
    handler.HandleFindInfo(req);
  }
}
