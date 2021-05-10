/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 * Skroman Switches pvt ltd.
 */

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthMethods {
  SharedPreferences _preferences;
  String userId;
  String url = 'https://www.e-stree.com:6000/forgotpassword';
  String urlVerify = 'https://www.e-stree.com:6000/verify';
  String resetPassword = 'https://www.e-stree.com:6000/resetpassword';

  Map<String, String> headers = {"Content-type": "application/json"};

  /// http library is used
  /// send otp on user device
 sendOtp(email,) async {
    print("email == $email");

    Map data ={
      'email': '$email',
    };

    print(data);
    var response = await http.post(url, body: json.encode(data), headers: headers);

      print('---sendotpnew API Success----');
      var decodedData = jsonDecode(response.body);
      print('----');
      print(response.body.toString());

      if(decodedData !=null){
        return decodedData;
      }

  }

  /// if user get otp then verify this otp
  verifyOtp(email, otp) async {
    print("email == $email");

    Map data = {
      'email': '$email',
      'otp': '$otp',
    };

    print(data);
    var response = await http.post(urlVerify, body: json.encode(data), headers: headers);

      print('---verifyOtp API Success----');
      var decodedData = jsonDecode(response.body);
      print('----');
      print(response.body.toString());

      if(decodedData != null){
        return decodedData;
      }else{
        print('in else part::');
        return decodedData;

      }
  }

  /// if user forgot password of kitouch app then use this method to reset new password
 resetPasswordApi(email, newPassword) async {

    Map data ={
      'email': '$email',
      'password': '$newPassword',

    };
    print(data);

    var response = await http.post(resetPassword, body: json.encode(data),headers: headers);
      print('---reset password API Success----');

      var decodedData = jsonDecode(response.body);
      print(response.body.toString());

      if(decodedData != null){
        return decodedData;
      }else{
        print('in else part::');
        return decodedData;

      }


  }

}
