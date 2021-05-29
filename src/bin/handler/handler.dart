import 'dart:convert';
import 'dart:io';
import '../FileManager.dart';
import '../manager/InfoManager.dart';
import 'package:http_server/http_server.dart';

void HandleLostInfo(HttpRequest req) async {
  var manager = new InfoManager();
  await manager.init();
  var action = req.uri.queryParameters['action'];
  if (action == null) {
    manager.allLostInfo().then((value) {
      req.response
        ..write(json.encode({
          'field': value,
        }))
        ..close();
    });
  } else if (action == 'getScores') {
    var value = {'a': 'b'};
    req.response
      ..write(json.encode(value))
      ..close();
  }
}

void HandleDevelopInfo(HttpRequest req) {
  FileManager.sendHtml(req);
}

void HandleImg(HttpRequest req) {
  var id = req.uri.queryParameters['action'];
  if (id == null) {
    req.response
      ..write(json.encode('缺少id参数'))
      ..close();
  } else
    FileManager.sendImage(req, id);
}

void HandleRoot(HttpRequest req) {
  FileManager.sendHtml(req);
}

void handlePOST(HttpRequest req) async {
  var body = await HttpBodyHandler.processRequest(req);
  var result = body.body;
  print(result);
  try {
    if (result['type'] == 'ORDER') {
      req.response
        ..write(jsonEncode('SUCCEED'))
        ..close();
    } else {
      req.response
        ..statusCode = 404
        ..write(jsonEncode('FAILED'))
        ..close();
    }
  } catch (e) {
    req.response
      ..write(jsonEncode('FAILED'))
      ..close();
  }
}
