import 'dart:convert';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:mysql1/mysql1.dart';
import 'package:src/models/find_info_model/find_info_model.dart';
import '../manager/FileManager.dart';
import '../manager/account_manager.dart';
import '../manager/sql_manager.dart';
import 'package:src/models/lost_info_model/lost_info_model.dart';
import 'package:http_server/http_server.dart';

//返回丢失物品信息
void HandleLostInfo(HttpRequest req) async {
  try {
    var sql = await Sql.NewSql();
    var lostInfoList = await sql.getLostInfo();
    var transList = <Map<String, dynamic>>[];
    for (var i = 0; i < lostInfoList.length; i++) {
      var strPath = (lostInfoList[i]['path'] as Blob).toString();
      var listStrPath = strPath.split(','); //坐标的字符串列表
      var listDoublePath = <List<double>>[];
      var point = <double>[];
      for (var i = 0; i < listStrPath.length; i++) {
        point.add(double.parse(listStrPath[i]));
        if (i % 2 == 1) {
          listDoublePath.add(point.toList());
          point.clear();
        }
      }
      lostInfoList[i]['path'] = listDoublePath;
      lostInfoList[i]['time'] = formatDate(lostInfoList[i]['time'] as DateTime,
          [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss]);
      transList.add(LostInfoModel.fromJson(lostInfoList[i]).toJson());
    }
    req.response
      ..write(jsonEncode({'points': transList, 'msg': 'SUCCESS'}))
      ..close();
  } catch (e) {
    req.response
      ..write(jsonEncode({'msg': '系统开小差了'}))
      ..close();
  }
}

//返回开发信息页面
void HandleDevelopInfo(HttpRequest req) {
  FileManager.sendHtml(req);
}

//返回图片
void HandleImg(HttpRequest req) {
  var id = req.uri.queryParameters['action'];
  if (id == null) {
    req.response
      ..write(json.encode('缺少id参数'))
      ..close();
  } else {
    FileManager.sendImage(req, id);
  }
}

//返回首页
void HandleRoot(HttpRequest req) {
  FileManager.sendHtml(req);
}

//登陆
void HandleLogin(HttpRequest req) async {
  try {
    var sql = await Sql.NewSql();
    var res = {'msg': '', 'token': ''};
    var body = (await HttpBodyHandler.processRequest(req)).body;
    var checkStatus =
        await AccountManager.checkPassword(body['name'], body['password']);
    if (checkStatus == 1) {
      var token = AccountManager.createRandomNum(25);
      if (await sql.setToken(token, body['name'])) {
        res['msg'] = 'SUCCESS';
        res['token'] = token;
      } else {
        res['msg'] = 'FAILD';
      }
    } else if (checkStatus == 0) {
      res['msg'] = 'WRONG PASSWORD';
    } else if (checkStatus == -1) {
      res['msg'] = 'NO SUCH USER';
    }
    req.response
      ..write(jsonEncode(res))
      ..close();
  } catch (e) {
    req.response
      ..write(jsonEncode({'ms': '系统开小差了'}))
      ..close();
  }
}

void HandleSendVerify(HttpRequest req) async {
  try {
    var body = await HttpBodyHandler.processRequest(req);
    var result = body.body;
    if (await AccountManager.sendVerifyNum(result['email']) == true) {
      req.response
        ..write(jsonEncode({'ms': '发送邮件成功'}))
        ..close();
    } else {
      req.response
        ..write(jsonEncode({'ms': '发送邮件失败！'}))
        ..close();
    }
  } catch (e) {
    req.response
      ..write(jsonEncode({'ms': '系统开小差了'}))
      ..close();
  }
}

//注册
void HandleRegiste(HttpRequest req) async {}

//验证登陆状态
Future CheckLoginStatus(HttpRequest req) async {
  return true;
}

void HandleFindInfo(HttpRequest req) async {
  try {
    var sql = await Sql.NewSql();
    var findInfoList = await sql.getFindInfo();
    var transList = <Map<String, dynamic>>[];
    for (var i = 0; i < findInfoList.length; i++) {
      transList.add(findInfoList[i].toJson());
    }
    req.response
      ..write(jsonEncode({'data': transList, 'msg': 'success'}))
      ..close();
  } catch (e) {
    req.response
      ..write(jsonEncode({'msg': '系统开小差了'}))
      ..close();
  }
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

//搜索推荐信息
void HandleSearchFindInfo(HttpRequest req) async {
  try {
    var sql = await Sql.NewSql();
    var res = {'data': [], 'msg': ''};
    var body = (await HttpBodyHandler.processRequest(req)).body;
    LostInfoModel model = LostInfoModel.fromJson(body);
    var findInfos = await sql.fliterFindInfo(model);
    var ret = <Map<String, dynamic>>[];
    for (var item in findInfos) {
      ret.add(item.toJson());
    }
    res['data'] = ret;
    res['msg'] = 'SUCCESS';
    req.response
      ..write(jsonEncode(res))
      ..close();
  } catch (e) {
    req.response
      ..write(jsonEncode({'msg': e.toString(), 'data': []}))
      ..close();
  }
}

//上传丢失物品信息
void HandleUploadLostInfo(HttpRequest req) async {
  try {
    var sql = await Sql.NewSql();
    var res = {'data': [], 'msg': ''};
    var body = (await HttpBodyHandler.processRequest(req)).body;
    if (body['picture'] != null) {
      HttpBodyFileUpload fileUploaded = body['picture'];
      var imgPath = await FileManager.save_image(
          fileUploaded.filename, fileUploaded.content);
      if (imgPath == 'FAILED') {
        req.response
          ..write(jsonEncode({'msg': '上传图片出错', 'data': []}))
          ..close();
      }
      body['picture'] = imgPath;
    }

    var model = LostInfoModel.fromJson(body);
    var flag = await sql.uploadLostInfo(model);
    if (flag) {
      res['data'] = '上传成功';
      res['msg'] = 'SUCCESS';
    } else {
      res['data'] = '入库不成功';
      res['msg'] = 'FAILED';
    }
  } catch (e) {
    req.response
      ..write(jsonEncode({'msg': e.toString(), 'data': []}))
      ..close();
  }
}
