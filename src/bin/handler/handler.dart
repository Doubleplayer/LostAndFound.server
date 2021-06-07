import 'dart:convert';
import 'dart:io';
import '../manager/FileManager.dart';
import '../manager/account_manager.dart';
import '../manager/sql_manager.dart';
import 'package:src/models/lost_info_model/lost_info_model.dart';
import 'package:src/models/user/user.dart';
import 'package:http_server/http_server.dart';

void safeResponse(var msg, HttpRequest req) {
  try {
    req.response
      ..write(jsonEncode(msg))
      ..close();
  } catch (e) {
    return;
  }
}

//返回丢失物品信息
void HandleLostInfo(HttpRequest req) async {
  try {
    var sql = await Sql.NewSql();
    var searchInfo = LostInfoModel(type: 0);
    var lostInfoList = await sql.fliterLostInfo(searchInfo);
    var transList = <Map<String, dynamic>>[];
    for (var i = 0; i < lostInfoList.length; i++) {
      transList.add(lostInfoList[i].toJson());
    }
    safeResponse({'points': transList, 'msg': 'SUCCESS'}, req);
  } catch (e) {
    safeResponse({'msg': '系统开小差了'}, req);
  }
}

void HandleFindInfo(HttpRequest req) async {
  try {
    var sql = await Sql.NewSql();
    var searchInfo = LostInfoModel(type: 1);
    var findInfoList = await sql.fliterLostInfo(searchInfo);
    var transList = <Map<String, dynamic>>[];
    for (var i = 0; i < findInfoList.length; i++) {
      transList.add(findInfoList[i].toJson());
    }
    safeResponse({'data': transList, 'msg': 'SUCCESS'}, req);
  } catch (e) {
    safeResponse({'msg': '系统开小差了'}, req);
  }
}

void HandleStatic(HttpRequest req) {
  var path = req.uri.path;
  FileManager.sendFile(req, '/webApp/dist' + path);
}

void ServerWebApp(HttpRequest req) {
  FileManager.sendFile(req, '/webApp/dist/index.html');
}

//返回开发信息页面
void HandleDevelopInfo(HttpRequest req) {
  FileManager.sendHtml(req);
}

//返回图片
void HandleImg(HttpRequest req) {
  var id = req.uri.queryParameters['action'];
  if (id == null) {
    safeResponse({'msg': '缺少id参数'}, req);
  } else {
    FileManager.sendImage(req, id);
  }
}

//返回首页
void HandleRoot(HttpRequest req) {
  FileManager.sendHtml(req);
}

void HandleNotFound(HttpRequest req) {
  safeResponse({'msg': '找不到页面～～～'}, req);
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
      var token = AccountManager.createToken();
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
    safeResponse(res, req);
  } catch (e) {
    safeResponse({'msg': '系统开小差了'}, req);
  }
}

void HandleSendVerify(HttpRequest req) async {
  try {
    var body = await HttpBodyHandler.processRequest(req);
    var result = body.body;
    if (result['email'].toString().isEmpty) {
      safeResponse({'ms': '请传入正确的邮箱'}, req);
    }
    if (await AccountManager.sendVerifyNum(result['email']) == true) {
      safeResponse({'ms': '发送邮件成功'}, req);
    } else {
      safeResponse({'ms': '发送邮件失败！'}, req);
    }
  } catch (e) {
    safeResponse({'ms': '系统开小差了'}, req);
  }
}

//验证登陆状态
Future CheckLoginStatus(HttpRequest req) async {
  return true;
}

//搜索推荐信息
void HandleSearchInfo(HttpRequest req) async {
  try {
    var sql = await Sql.NewSql();
    var res = {'data': [], 'msg': ''};
    var body = (await HttpBodyHandler.processRequest(req)).body;
    LostInfoModel model = LostInfoModel.fromJson(body);
    var findInfos = await sql.fliterLostInfo(model);
    var ret = <Map<String, dynamic>>[];
    for (var item in findInfos) {
      ret.add(item.toJson());
    }
    res['data'] = ret;
    res['msg'] = 'SUCCESS';
    safeResponse(res, req);
  } catch (e) {
    safeResponse({'msg': e.toString(), 'data': []}, req);
  }
}

//上传丢失物品信息
void HandleUploadInfo(HttpRequest req) async {
  try {
    var res = {'data': [], 'msg': ''};
    var body = (await HttpBodyHandler.processRequest(req)).body;
    if (body['picture'] != null) {
      HttpBodyFileUpload fileUploaded = body['picture'];
      var imgPath = await FileManager.save_image(
          fileUploaded.filename, fileUploaded.content);
      if (imgPath == 'FAILED') {
        safeResponse({'msg': '上传图片出错', 'data': []}, req);
        return;
      }
      body['picture'] = imgPath;
    }

    var model = LostInfoModel.fromJson(body);
    var sql = await Sql.NewSql();
    var flag = await sql.uploadInfo(model);
    if (flag) {
      res['data'] = '上传成功';
      res['msg'] = 'SUCCESS';
    } else {
      res['data'] = '入库不成功';
      res['msg'] = 'FAILED';
    }

    safeResponse(res, req);
  } catch (e) {
    safeResponse({'msg': e.toString(), 'data': []}, req);
  }
}

void HandleRegiste(HttpRequest req) async {
  try {
    var res = {'token': '', 'msg': ''};
    var body = (await HttpBodyHandler.processRequest(req)).body;
    if (body['name'] == null ||
        body['password'] == null ||
        body['email'] == null ||
        body['vnmu'] == null) {
      res['msg'] = '请求参数不全';
      safeResponse(res, req);
      return;
    }
    var resp = await AccountManager.saveUser(
        body['name'], body['email'], body['password'], body['vnum']);
    safeResponse(resp, req);
  } catch (e) {
    safeResponse({'msg': e.toString(), 'token': ''}, req);
  }
}
