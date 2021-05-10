/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:itts/Helper.dart';
import 'package:itts/login/verifyOtp.dart';
import 'package:itts/screens/DashboardGrid.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/toast_snack.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants.dart';

class AuthMethods {
  SharedPreferences _preferences;
  String userId;
  var dbHelper = Helper();

  ///1. register user API
  Future<Map<String, dynamic>>  registerUser(
      fname, lname,email,password, _scaffoldkey, context,type) async {

    Map data ={
      "tag":"registerForm",  //signup
      'fname': '$fname',
      "lname":"$lname",
      "email":"$email",
      "type": "$type",
      "password":"$password",
    };


    print("registerForm:::");
    print(data);

    var response = await http.post(Constants.forgetPassword, body: jsonEncode(data));
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

/*    if(decodedData['success'] == "1"){

      return decodedData;
    }
    else if(decodedData['success'] == "2"){

      ShowCustomSnack.getCustomSnack(
          context, _scaffoldkey, "User already exist");

      return "2";
    }
    else if(decodedData['success'] == "3"){
      return "3";
    }

    else if(decodedData['success'] == "0"){
      ShowCustomSnack.getCustomSnack(
          context, _scaffoldkey, "Email not sent");

      return "0";
    }*/

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

    var response = await http.post(Constants.loginUrl, body: jsonEncode(data));

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
    //      _prefs.setString("showcaseDevice", "enableDevice");

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),  //Demo
          );

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
      "tag":"sendotpnew",
      'email': '$email',
      'type':'$type'
    };

    print(data);
    var response = await http.post(Constants.forgetPassword, body: json.encode(data));

/*      if(response.statusCode == 200){

        print('---sendOtp API Success----');

        var decodedData = jsonDecode(response.body);
        print(response.body.toString());

        if(decodedData['success'] == "1"){

          return "1";
        }else if(decodedData['success'] == "0"){
          ShowCustomSnack.getCustomSnack(
              context, _scaffoldKey, "Email not sent");

          return "0";
        }
        else if(decodedData['success'] == "2"){
          ShowCustomSnack.getCustomSnack(
              context, _scaffoldKey, "Email Id does not exist.");

          return"2";
        }

      }else{
        print("error ${response.body}");
        return response.body;
      }*/

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
      "tag":"otpverifynew",
      'email': '$email',
      "otp":"$otp",
      "otpsession":"$otpsession",
      "type":"$type",
      'token':'$token',
    };

    print(data);
    var response = await http.post(Constants.forgetPassword, body: json.encode(data));

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
  Future<String> changePassword(
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

    var response = await http.post(Constants.forgetPassword, body: json.encode(data));

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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ///5. send UID,SSID,Password Post API  QR code API
  Future<String> addDeviceData(
      BuildContext context, String ssid, String password,String str_date,String str_time,String deviceName, _scaffoldKey) async {
    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");
    print("userID::authMethods:: $userId");

    Map data ={
        "userId":"$userId",
        "deviceId": "$ssid",
        "password": "$password",
        "devicename":"$deviceName"
    };

    print("myjsonData----");
    print(data);

    var response =
        await http.post(Constants.addDevice, body: json.encode(data),headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      print('---Add device API Success----');

      var convertedData = jsonDecode(response.body);

      if (convertedData['success'] == '1') {
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, "Device added");

        return "true";
      } else if (convertedData['success'] == '0') {
        ShowCustomSnack.getCustomSnack(
            context, _scaffoldKey, "Please enter valid details");
        return "error";
      } else if (convertedData['success'] == '2') {
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, "Device already exist");
        return "exist";
      }
    } else {
      FToast.show('something went wrong');
      return "false";
    }
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ///1. POST - get all device by UserID  [1st tab design]
  getUserDeviceData() async {
    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");
    Map data ={
      "userId":"$userId",
      "tag": "getdevicedata",
    };


    print(data);

    var response = await http.post(Constants.getDeviceDetails, body: json.encode(data));

    print("statuscode:::getdevicedata::");
    print(response.statusCode);

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

  ///2. POST - send UID, dateonwords,page,deviceID   [2nd tab data]
  getLatestData(int page, String deviceId, String dateOnwords, type) async {
    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "userId":userId,
      "deviceId":deviceId,
      "date_onwords": "$dateOnwords",
      "page":"$page",
      "type":"$type",
    };

    print('Indexdata::::api');
    print(page);

    print(data);

    var response = await http.post(Constants.getDetails, body: json.encode(data));

    print("statuscode:::");
    print(response.statusCode);

    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      print("responsegotgetlatestdata::");
      print(response.body.toString());

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      print("error ${response.body}");
      return {};
    }
  }

  ///3 rename device name

  editDeviceDetails(String deviceId, String devicename) async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "userId":"$userId",
      "tag":"editdevicedetails",
      "deviceId": "$deviceId",
      "devicename": "$devicename",
    };

    print(data);

    var response = await http.post(Constants.getDeviceDetails, body: json.encode(data));

    print("statuscode:::editdevicedetails:");
    print(response.statusCode);

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

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///  1. search by date
  getBySearch(fromDate, toDate, type) async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    print(fromDate+toDate);

    Map data ={
      "userId":"$userId",
      "sdate": "$fromDate",
      "edate": "$toDate",
      "type":"$type"
    };

    print(data);

    var response = await http.post(Constants.getDetailsByDate, body: json.encode(data));

    print("statuscode:::getDetailsByDate::");
    print(response.statusCode);

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

///1. PDF API

  getPdf() async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "userId":"10000000",
    };

    print(data);

    var response = await http.post(Constants.getpdf, body: json.encode(data));

    print("statuscode:::PDF::");
    print(response.statusCode);

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

  deactivateDevice(String deviceId,String tag) async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "tag": "$tag",
      "userId":"$userId",
      "deviceId": "$deviceId",
    };

    print(data);

    var response = await http.post(Constants.deactivate, body: json.encode(data));

    print("statuscode:::deactivate api::");
    print(response.statusCode);

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

  ///attendance list
  attendanceList(empId) async {

    Map data ={
      "tag":"Employeelistsearh",  //changes for month and year
      "empId":"$empId",
      /*"month":"6",
      "year":"2020"*/
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


///attendance
  addAttendance(deviceId, password, date, time, attendanceType) async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "tag": "attendencedevice",
      "userId":"$userId",
      "deviceId": "$deviceId",
      "password": "$password",
      "timedate": "$date"+" " + "$time",
      "timetype":"$attendanceType"
    };

    print(data);

    var response = await http.post(Constants.attendance, body: json.encode(data));

    print("statuscode:::attendance api::");
    print(response.statusCode);

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

///Add employee
  Future<Map<String, dynamic>>  addEmployee(
      fname, lname,email, _scaffoldkey, context,type,deviceId) async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "tag":"addemployee",
      "userId": "$userId",
      'fname': '$fname',
      "lname":"$lname",
      "email_or_mobile":"$email",
      "deviceId":"$deviceId",
      "type": "$type",
    };

    print("Add employee API:::");
    print(data);

    var response = await http.post(Constants.loginUrl, body: jsonEncode(data));
    var convertedData;
    convertedData = jsonDecode(response.body);

    print(response.body);

    if (response.statusCode == 200) {
      print('---- Add employee statuscode success -----');

      return convertedData;
    }
    return convertedData;

  }

  employeeList() async {

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "tag":"EmployeeList",
      "userId":"$userId",
    };

    print(data);

    var response = await http.post(Constants.attendanceList, body: json.encode(data));

    print("statuscode:::employeeList api::");
    print(response.statusCode);

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

  ///excell sheet api
  attendanceExport(month, year ) async {


    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

  /*  Map data ={
      "userId":"$userId",
      "month":"$month",
      "year":"$year"
    };*/
//    print(data);

    String url = Constants.attendenceexport + "userId="+userId+"&month="+month.toString()+"&year="+year.toString();
    print(url);
    var response = await http.post(url);

    print("statuscode:::attendanceExport api::");



   return url;

/*    if(response.statusCode == 200){
      var decodedData = jsonDecode(response.body);

      FToast.show("success");

      if(decodedData !=null){
        return decodedData;
      }

    }else{
      FToast.show("error");
      print("error ${response.body}");
      return {};
    }*/
  }

  logoutApi() async {

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _preferences = await SharedPreferences.getInstance();
    userId = _preferences.getString("user_id");

    Map data ={
      "userId":"$userId",
      "tag":"logout",

    };

    print(data);

    var response = await http.post(Constants.loginUrl, body: json.encode(data));

    print("statuscode:::editdevicedetails:");
    print(response.statusCode);

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

}
