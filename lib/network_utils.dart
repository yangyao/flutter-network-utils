import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/common/functions/getToken.dart';
import 'package:flutter_app/common/functions/saveUserToken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/functions/showDialogSingleButton.dart';

class NetworkUtil {
  // 单例模式
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  Future<dynamic> get(BuildContext context, String url) async {
    Map<String, String> headers = {};

    await getToken().then((result) {
      headers['Authorization'] = result;
    });

    try {
      final response = await http.get(url, headers: headers);
      final int statusCode = response.statusCode;
      print("请求接口${url}，请求头${headers},响应头${response.headers}，响应结果${response.body}");
      // 如果包含Token ，那么更新TOKEN
      if (response.headers.containsKey('authorization')) {
        saveUserToken(response.headers['authorization']);
      }
      // 如果Token 过期，强制跳转到登陆页面
      if (statusCode == 401) {
        return Navigator.of(context).pushReplacementNamed('/login');
      }
      if (statusCode == 404) {
        throw new Exception("404，请求页面${url}不存在！");
      }
      if (statusCode == 500) {
        throw Exception("网络500错误,错误信息：${response.body}，请联系开发人员处理");
      }
      if (statusCode == 200) {
        return json.decode(response.body);
      }
      throw new Exception("网络异常:(HTTP:${statusCode})，请检查网络后重试！");
    } on Exception catch (e) {
      showDialogSingleButton(context, "网络错误！",
          e.toString().replaceAll(new RegExp(r'Exception: '), ''), "OK");
    }
  }

  Future<dynamic> post(BuildContext context, String url,
      {Map headers, body, encoding}) async {
    await getToken().then((result) {
      headers['Authorization'] = result;
    });

    try {
      final response = await http.post(url,
          body: body, headers: headers, encoding: encoding);
      final int statusCode = response.statusCode;
      print("请求接口${url}，请求头${headers}，请求body:${body}，响应头${response.headers}，响应结果${response.body}");
      // 如果包含Token ，那么更新TOKEN
      if (response.headers.containsKey('authorization')) {
        saveUserToken(response.headers['authorization']);
      }
      // 如果Token 过期，强制跳转到登陆页面
      if (statusCode == 401) {
        return Navigator.of(context).pushReplacementNamed('/login');
      }
      if (statusCode == 404) {
        throw new Exception("404，请求页面${url}不存在！");
      }
      if (statusCode == 500) {
        throw Exception("网络500错误,错误信息：${response.body}，请联系开发人员处理");
      }
      if (statusCode == 200) {
        return json.decode(response.body);
      }
      throw new Exception("网络异常:(HTTP:${statusCode})，请检查网络后重试！");
    } on Exception catch (e) {
      showDialogSingleButton(context, "网络错误！",
          e.toString().replaceAll(new RegExp(r'Exception: '), ''), "OK");
    }
  }

  Future<dynamic> upload(
      BuildContext context, String url, List<http.MultipartFile > imageFileList,
      {Map headers, body, encoding}) async {
    await getToken().then((result) {
      headers['Authorization'] = result;
    });

    // 增加body 字段 (使用很挫的方式，因为field加入会报错)
    url = url + "?1=1";
    body.forEach((k, v) {
      url = url+"&${k}=${v}";
    });

    var uri = Uri.parse(url);

    var request = new http.MultipartRequest("POST", uri);

    // 添加需要上传的图片
    imageFileList.forEach((imageFile){
      request.files.add(imageFile);
    });

    // 增加body 字段，这里有bug
    body.forEach((k, v) {
      //request.fields[k] = v;
    });
    // 增加header字段
    headers.forEach((k, v) {
      request.headers[k] = v;
    });
    // 开始发送请求
    try {
      final responseStream = await request.send();
      String data = await Utf8Codec(allowMalformed: true)
          .decodeStream(responseStream.stream);
      final int statusCode = responseStream.statusCode;
      // 如果包含Token ，那么更新TOKEN
      if (responseStream.headers.containsKey('authorization')) {
        saveUserToken(responseStream.headers['authorization']);
      }
      // 如果Token 过期，强制跳转到登陆页面
      if (statusCode == 401) {
        return Navigator.of(context).pushReplacementNamed('/login');
      }
      if (statusCode == 404) {
        throw new Exception("404，请求页面${url}不存在！");
      }
      if (statusCode == 500) {
        throw Exception("网络500错误,错误信息：，请联系开发人员处理");
      }
      if (statusCode == 200) {
        print("请求接口${url}，请求头${headers}，请求body:${body}，请求结果${data}");
        return json.decode(data);
      }
      throw new Exception("网络异常:(HTTP:${statusCode})，请检查网络后重试！");
    } on Exception catch (e) {
      showDialogSingleButton(context, "网络错误！",
          e.toString().replaceAll(new RegExp(r'Exception: '), ''), "OK");
    }
  }
}
