/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:ioskitouchnew/screens/account/userResponseModel.dart';

class LoginResponse {
  String message;
  UserResponseModel userResponseModel;

  LoginResponse({this.message,this.userResponseModel});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
     // userResponseModel: json['result'] as UserResponseModel,
    );
  }
}
