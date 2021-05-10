/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

class UserModel {
  String name;
  String email;
  String password;
  String mobile;

  UserModel({this.name, this.email, this.password, this.mobile});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      mobile: json['mobile'] as String,
    );
  }
}
