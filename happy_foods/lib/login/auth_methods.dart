/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happyfoods/Admin/adminDashboard.dart';
import 'package:happyfoods/Dashboard/DashboardTab.dart';
import 'package:happyfoods/constants.dart';
import 'package:happyfoods/productionHouse/productionDashboard.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/toast_snack.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class AuthMethods {
  SharedPreferences _preferences;
  String userId;

  ///1. register user API
  Future<Map<String, dynamic>>  registerUser(
      fname, lname,email,password, _scaffoldkey, context,type) async {

    Map data ={
      "tag":"registerForm",
      'fname': '$fname',
      "lname":"$lname",
      "email":"$email",
      "type": "$type",
      "password":"$password",
    };

    print("registerForm:::");
    print(data);

    var response = await http.post(Constants.signupverification, body: jsonEncode(data));
    var convertedData;
    convertedData = jsonDecode(response.body);

    print(response.body);

    if (response.statusCode == 200) {
      print('---- registration statuscode success -----');

      return convertedData;
    } else if (convertedData['success'] == 2) {
      ShowCustomSnack.getCustomSnack(
          context, _scaffoldkey, "User already exist");
      FToast.show("already");
    }
    return convertedData;

  }

  ///2.  Login API
  Future<String> loginUser(
      BuildContext context, String email, String password, String token,_scaffoldKey) async {
    print("email == $email");

    Map data ={
      "tag":"logindetails",
      'email': '$email',
      'password': '$password',
      'token':'$token',
    };

    print(data);

    var response = await http.post(Constants.signupverification, body: jsonEncode(data));

    if (response.statusCode == 200) {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      print('---Login API Success----');

      var convertedData = jsonDecode(response.body);
      print(response.body.toString());

      if (convertedData['success'] == '1') {
        _prefs.setString("user_id", convertedData['Id'],)
            .whenComplete(() {
          _prefs.setString("fname", convertedData['fname']);
          _prefs.setString("lname", convertedData['lname']);
          _prefs.setString("email", convertedData['email']);
          _prefs.setString("showcase", "enableDashboard");
          _prefs.setString("roleId", convertedData['roleId']);

          if(convertedData['roleId'] == '2' ){

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardTab(0)),
            );

            FToast.show("Hi " +convertedData['fname'] + ' Welcome to Hashtag Happy Food!');

          }else  if(convertedData['roleId'] == '1' ){

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );

            FToast.show("Hi " +convertedData['fname'] + ' Welcome to Hashtag Happy Food!');

          } else{
            FToast.show("Hi " +convertedData['fname'] + ' Welcome to Hashtag Happy Food!');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductionDashboard()),
            );
          }
          token = "";
        });

        return "true";
      } else if (convertedData['success'] == '0') {
        ShowCustomSnack.getCustomSnack(
            context, _scaffoldKey, "Please enter valid details");
        return "error";
      }

    } else {
      FToast.show('something went wrong');
      return response.body;
    }
  }

  /// 3. send otp
  sendOtp(
      BuildContext context, email, type, _scaffoldKey) async {
    print("email == $email");

    Map data ={
      "tag":"sendotp",
      'email': '$email',
      'type':'$type'
    };

    print(data);
    var response = await http.post(Constants.signupverification, body: json.encode(data));

    if(response.statusCode == 200){
      print('---sendotpnew API Success----');
      var decodedData = jsonDecode(response.body);
      print(response.body.toString());

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }

  }

  /// otp verification submit button
  otpVerification(
      BuildContext context, email,otp, token,type,otpsession, _scaffoldKey) async {
    print("email == $email");

    Map data ={
      "tag":"otpverify",
      'email': '$email',
      "otp":"$otp",
      "otpsession":"$otpsession",
      "type":"$type",
      'token':'$token',
    };

    print(data);
    var response = await http.post(Constants.signupverification, body: json.encode(data));

    if(response.statusCode == 200){

      print('---otpVerification API Success----');

      var decodedData = jsonDecode(response.body);
      print(response.body.toString());

      if(decodedData['success'] == "1"){

        return decodedData;
      }else if(decodedData['success'] == "0"){
        ShowCustomSnack.getCustomSnack(
            context, _scaffoldKey, "OTP does not match");

        return decodedData;
      }
      else if(decodedData['success'] == "2"){
        ShowCustomSnack.getCustomSnack(
            context, _scaffoldKey, "Email Id does not exist.");

        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return response.body;
    }

  }

  ///4. send OTP and new password
  Future<String> forgetPasswordWithOTP(
      BuildContext context, email, otp, newPassword,otpSession,type, _scaffoldKey,) async {
    print("email == $email");

    Map data ={
      "tag":"forgotpassword",
      'email': '$email',
      'otp': '$otp',
      'otpsession':'$otpSession',
      'type':'$type',
      'password': '$newPassword',

    };
    print(data);

    var response = await http.post(Constants.signupverification, body: json.encode(data));

    if(response.statusCode == 200){

      print('---Forget password API Success----');

      var decodedData = jsonDecode(response.body);
      print(response.body.toString());

      if(decodedData['success'] == "1"){

        return "1";
      }else if(decodedData['success'] == "0"){
        ShowCustomSnack.getCustomSnack(
            context, _scaffoldKey, "OTP does not match");

        return "0";
      }

    }else{
      print("error ${response.body}");
      return response.body;
    }

  }

  //----------------------------------------------------------------------------------------------------//

  ///attendance list
  attendanceList(empId) async {

    Map data ={
      "tag":"Employeelistsearh",
      "empId":"$empId"

      //   "deviceId": "$deviceId"
    };

    print(data);

    var response = await http.post(Constants.attendanceList, body: json.encode(data));

    print("statuscode:::getDetailsByDate::");
    print(response);

    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      print(response.body.toString());

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }
  }

  customerPlan() async {
    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");


    Map data ={
      "tag":"customer_subscription",
      "userId":"$userId"
    };

    print(data);

    var response = await http.post(Constants.subscription, body: json.encode(data));

    print("::customer_subscription::");

    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }
  }

  /// get All Plans

  planList() async {

    Map data ={
      "tag":"get_plan"
    };

    print(data);

    var response = await http.post(Constants.getPlan, body: json.encode(data));

    print("::getPlan::");
    print(response);

    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      print(response.body.toString());

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }
  }

  packageList(String planId) async {

    Map data ={
      "tag":"get_package",
      "type":"$planId"
    };

    print(data);

    var response = await http.post(Constants.getPlan, body: json.encode(data));

    print("::getPlan::");
    print(response);

    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      print(response.body.toString());

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }
  }

  snackList() async {

    Map data ={
      "tag":"get_snacks"
    };

    print(data);

    var response = await http.post(Constants.getPlan, body: json.encode(data));

    print("::get snacks::");
    print(response);

    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      print(response.body.toString());

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }
  }

 //---------------------------------------- edit profile ------------------------------------------------//

  Future<Map<String, dynamic>>  editProfile(
      fname, lname,email,type,age,dob,height_cms,weight,medicationCondition,address1,address2,userImage) async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "tag":"editprofiledetails",
      "userId":"$userId",
      'fname': '$fname',
      "lname":"$lname",
      "type": "$type",
      "age":"$age",
      "dob":"$dob",
      "height_cms":"$height_cms",
      "weight":"$weight",
      "medicalCondition":"$medicationCondition",
      "deliveryAddress1":"$address1",
      "deliveryAddress2":"$address2",
      "userImg":"$userImage",

      "email_id":'$email',
      "mobileNo":'$email',
    };

    print("editprofiledetails:::");
    print(data);

    var response = await http.post(Constants.signupverification, body: jsonEncode(data));
    var convertedData;
    convertedData = jsonDecode(response.body);

    print(response.body);

    if (response.statusCode == 200) {
      print('---- edit profile success -----');

      return convertedData;
    } else if (convertedData['success'] == 2) {

      FToast.show("already");
    }
    return convertedData;
  }

  getProfile() async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "tag":"get_profile",
      "userId":"$userId"
    };

    print(data);

    var response = await http.post(Constants.signupverification, body: json.encode(data));

    print("::get profile::");
    print(response);

    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }
  }


//---------------------------------------- add subscription ------------------------------------------------//


  Future<Map<String, dynamic>>  addSubscription(plan,pkg,cost,days,fromDate,toDate,noofmeals,totalCost,address,) async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "tag":"add_subscription",
      "userId":"$userId",
      "planType":"$plan",
      "packageType":"$pkg",
      "cost":"$cost",
      "days":"$days",
      "snakType":"",
      "snacktotal":"",
      "fromDate":"$fromDate",
      "toDate":"$toDate",
      "noofmeals":"$noofmeals",
      "totalcost":"$totalCost",
      "address":"$address",


    };

    print("registerForm:::");
    print(data);

    var response = await http.post(Constants.getPlan, body: jsonEncode(data));
    var convertedData;
    convertedData = jsonDecode(response.body);

    print(response.body);

    if (response.statusCode == 200) {
      print('---- edit profile success -----');

      return convertedData;
    } else if (convertedData['success'] == 2) {

      FToast.show("already");
    }
    return convertedData;
  }


//---------------------------------------- admin API ------------------------------------------------//

  getSubscription(tag) async {

    Map data ={
      "tag":"$tag"
    };

    print(data);

    var response = await http.post(Constants.subscription, body: json.encode(data));

    print("statuscode:::getSubscriptionApi::");
    print(response);

    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      print(response.body.toString());

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }
  }

  updateSubscription(subId,status) async {
    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data =
    {
      "tag":"update_status",
      "userId":"$userId",
      "sub_Id":"$subId",
      "status":"$status"
    };

    print(data);

    var response = await http.post(Constants.subscription, body: json.encode(data));

    print("statuscode:::getSubscriptionApi::");
    print(response);

    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      print(response.body.toString());

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }
  }

//---------------------------------------------------------------------------------------------------//

  getUserId()async{
    _preferences = await SharedPreferences.getInstance();

    userId = _preferences.getString("user_id");
    return userId;

  }

}
