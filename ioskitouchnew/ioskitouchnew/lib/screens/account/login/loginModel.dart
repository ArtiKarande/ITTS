/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

///model class for login user data fields email password

class LoginUser{
  String email;
  String password;

  LoginUser({this.email, this.password});

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      email: json['email'] as String,
      password: json['password'] as String,
    );}
}