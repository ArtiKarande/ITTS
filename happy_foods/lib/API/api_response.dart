/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

// To parse this JSON data, do
//
//     final apiResponse = apiResponseFromJson(jsonString);

import 'dart:convert';

ApiResponse apiResponseFromJson(String str) => ApiResponse.fromJson(json.decode(str));

String apiResponseToJson(ApiResponse data) => json.encode(data.toJson());

class ApiResponse {
  ApiResponse({
    this.success,
    this.plans,
  });

  String success;

  List<UserData> plans;

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
    success: json["success"],
    plans: List<UserData>.from(json["plans"].map((x) => UserData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "plans": List<dynamic>.from(plans.map((x) => x.toJson())),
  };
}

class UserData {
  UserData({this.id, this.plan, this.type, this.cost});

  String id;
  String plan;
  String type;
  String cost;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"],
    plan: json["plan"],
    type: json["type"],
    cost: json["cost"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "plan": plan,
    "type": type,
    "cost": cost,
  };
}
