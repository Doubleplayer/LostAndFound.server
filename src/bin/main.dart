import 'dart:io';
import './handler/handler.dart' as handler;

String myHost = '172.17.13.219';
void main() async {
  {
    //创建服务器
    var requestServer = await HttpServer.bind(myHost, 9002);
    print('http服务启动起来');
    await for (HttpRequest req in requestServer) {
      try {
        handleRoute(req);
      } catch (e) {
        print(e);
      }
    }
  }
}

void handleRoute(HttpRequest req) async {
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
  }
}
