/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

///model class for registration user data fields name, email, password, etc...
class UserResponseModel{
  String name;
  String email;
  String password;
  String id;
  String phoneNumber;
  String googleId;

  UserResponseModel({this.name,this.email,this.password,this.id,this.phoneNumber,this.googleId});

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      id: json['_id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      googleId: json['googleId'] as String,
    );
  }
}