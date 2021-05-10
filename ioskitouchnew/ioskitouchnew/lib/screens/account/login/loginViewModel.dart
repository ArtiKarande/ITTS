/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/jsonContants.dart';
import 'package:ioskitouchnew/common/urlConstants.dart';
import 'package:ioskitouchnew/screens/account/login/loginModel.dart';
import 'package:ioskitouchnew/screens/account/login/loginResponseModel.dart';

///rest API is used, to login user, http library is used

class LoginViewModel {
  Future loginUser(BuildContext context, LoginUser loginUser,
      Function errorHandler, Function completionHandler) async {
    String url = UrlConstants.LOGIN_URL;
    print('url:::$url');
    Map map = {
      JsonConstants.EMAIL: loginUser.email,
      JsonConstants.PASSWORD: loginUser.password,
    };
    print('map::$map');
    print(await loginApiRequest(
        context, url, map, errorHandler, completionHandler)
    );
  }

  Future<String> loginApiRequest(BuildContext context, String url, Map postMap,
    Function errorHandler, Function completionHandler) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(postMap)));
    HttpClientResponse response = await request.close();

    var result = await response.transform(utf8.decoder).join();
    print('result:::$result');
    Map<String, dynamic> userMap = jsonDecode(result);
    print('userMap:::$userMap');
    LoginResponse mResponse = LoginResponse.fromJson(userMap);

    if (mResponse.message == 'Sucessfull login') {
      completionHandler(userMap);
    } else {
      errorHandler(mResponse.message);
    }
    return result;
  }
}
