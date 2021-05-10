/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/jsonContants.dart';
import 'package:ioskitouchnew/common/urlConstants.dart';
import 'package:ioskitouchnew/screens/account/login/loginResponseModel.dart';
import 'package:ioskitouchnew/screens/account/signUpModel.dart';

///rest API is used, to login user, http library is used

class SignUpViewModel{

  Future signUpUser(BuildContext mContext,UserModel userModel,Function completionHandler,Function errorHandler) async {
    String url = UrlConstants.SIGN_UP_URL;
    print('url:::$url');
    Map map = {
      JsonConstants.NAME: userModel.name,
      JsonConstants.EMAIL: userModel.email,
      JsonConstants.PASSWORD: userModel.password,
      JsonConstants.MOBILE_NUMBER: userModel.mobile,
    };
    print('map::$map');
    print(await signUpApiRequest(mContext, url, map, errorHandler, completionHandler));
  }

  Future<String> signUpApiRequest(BuildContext context, String url, Map postMap,
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

    if (mResponse.message == 'Sucessfull') {
      completionHandler(userMap);
    }
    else if(mResponse.message == 'Email already Used!!'){
//      ProgressBar.dismiss(context);
      completionHandler(userMap);




      FToast.show('Email already Used, verifying!');
    }

    else {
      errorHandler(mResponse.message);
    }
    return result;
  }
}