import 'dart:convert';
import 'dart:io';
import 'package:http_server/http_server.dart';
import 'FileManager.dart';
import 'manager/InfoManager.dart';

String myHost = '172.17.13.219';
InfoManager manager = new InfoManager();
void main() async {
  {
    //创建服务器
    var requestServer = await HttpServer.bind(myHost, 9002);
    var pre_time = DateTime.now().millisecondsSinceEpoch;
    await manager.init();
    print('http服务启动起来');
    print(requestServer);
    await for (HttpRequest request in requestServer) {
      try {
        int time_now = DateTime.now().millisecondsSinceEpoch;
        if (time_now - pre_time > 27000000) {
          await manager.reconnect_sql();
        }
        handleMessage(request, requestServer);
      } catch (e) {
        print(e);
      }
    }
  }
}

void handleMessage(HttpRequest request, HttpServer server) {
  print(request.uri);
  if (request.method == 'GET') {
    handleGET(request, server);
  } else if (request.method == 'POST') {
    handlePOST(request);
  }
}

void handleGET(HttpRequest request, HttpServer server) async {
  var action = request.uri.queryParameters['action'];
  if (request.uri.toString() == '/') {
    if (action == null) {
      print('123123');
      FileManager(server, request).sendHtml();
    } else if (action == 'getScores') {
      var value = {'a': 'b'};
      request.response
        ..write(json.encode(value))
        ..close();
    }
  }
  if (request.uri.toString() == '/lostInfo') {
    if (action == null) {
      manager.allLostInfo().then((value) {
        request.response
          ..write(json.encode(value))
          ..close();
      });
    } else if (action == 'getScores') {
      var value = {'a': 'b'};
      request.response
        ..write(json.encode(value))
        ..close();
    }
  }
}

void handlePOST(HttpRequest request) async {
  var body = await HttpBodyHandler.processRequest(request);
  var result = body.body;
  print(result);
  try {
    if (result['type'] == 'ORDER') {
      request.response
        ..write(jsonEncode('SUCCEED'))
        ..close();
    } else {
      request.response
        ..statusCode = 404
        ..write(jsonEncode('FAILED'))
        ..close();
    }
  } catch (e) {
    request.response
      ..write(jsonEncode('FAILED'))
      ..close();
  }
}
