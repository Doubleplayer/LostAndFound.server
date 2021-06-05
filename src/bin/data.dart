import 'dart:convert';
import 'dart:io';
import './handler/handler.dart' as handler;
import 'package:http_server/http_server.dart';
import 'package:crypto/crypto.dart';

String myHost = '172.17.13.219';
String localHost = '127.0.0.1';

void main() async {
  {
    //创建服务器
    // var requestHttpsServer= await HttpServer.bindSecure(myHost, 9002, context)
    var requestServer = await HttpServer.bind(myHost, 9004);
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
  //跨域配置
  var path = req.requestedUri.path;
  req.response.headers.add("Access-Control-Allow-Origin", "*");
  req.response.headers.add("Access-Control-Allow-Credentials", "true");
  req.response.headers.add("Access-Control-Allow-Methods", "*");
  req.response.headers
      .add("Access-Control-Allow-Headers", "Content-Type,Access-Token");
  req.response.headers.add("Access-Control-Expose-Headers", "*");

  if (req.method == 'OPTIONS') {
    req.response
      ..statusCode = 200
      ..write("")
      ..close();
    return;
  }
  print(req);
  if (path == '/') {
    handler.HandleRoot(req);
  } else if (path == '/accept') {
    HandleAccept(req);
  } else if (path == '/deny') {
    HandleDeny(req);
  }
}

//返回丢失物品信息
void HandleAccept(HttpRequest req) async {
  try {
    var body = await HttpBodyHandler.processRequest(req);
    var result = body.body;
    var bytes = utf8.encode('2faed1b0-c461-11eb-9a23-f3dfbc201fdf' +
        result['timestamp'] +
        result['biz_params']); // data being hashed
    var digest = md5.convert(bytes);
    var remote = result['sign'];
    var local = digest.toString();
    var flag = local == remote;
    req.response
      ..write(jsonEncode({'msg': '系统开小差了'}))
      ..close();
  } catch (e) {
    req.response
      ..write(jsonEncode({'msg': '系统开小差了'}))
      ..close();
  }
}

//上传丢失物品信息
void HandleDeny(HttpRequest req) async {
  try {
    var body = await HttpBodyHandler.processRequest(req);
    var result = body.body;
    var bytes = utf8.encode('2faed1b0-c461-11eb-9a23-f3dfbc201fdf' +
        result['timestamp'] +
        result['biz_params']); // data being hashed
    var digest = md5.convert(bytes);
    var remote = result['sign'];
    var local = digest.toString();
    var flag = local == remote;
    req.response
      ..write(jsonEncode({'msg': '系统开小差了'}))
      ..close();
  } catch (e) {
    req.response
      ..write(jsonEncode({'msg': '系统开小差了'}))
      ..close();
  }
}
