/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedKeys.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedPreferneces.dart';
import 'package:vtrochargingstation/common/urlConstant.dart';
import 'package:http/http.dart' as http;
import 'package:vtrochargingstation/models/message.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';

/// All http api integration methods
/// [dio: ^3.0.8] plugin has been used
///

class APICall {

  final MQTTAppState _currentState;
  String fcmToken = "";
  final List<Message> messages = [];

  SharedPreference pref = new SharedPreference();
  String userId;

  /// default token
  String _authHeader = 'Bearer be1faebe9d710e9f0ad968eff2312ca2b053a61309539224b3ec3795ac19898';

  Dio dio = new Dio();
  Map<String, dynamic> map = new HashMap();

  // Constructor
  APICall({
    @required MQTTAppState state
  }):  _currentState = state ;

  /// user login
  login(emailOrMobile, mode, loginType, platform) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    print('params[login]...  params---');
    print(emailOrMobile);print(mode);
    print(loginType);print(platform);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": _authHeader};
      var response = await dio.post(UrlConstants.loginUrl, data: {
        "tag": 'check_login',
        "email_or_mobile": "$emailOrMobile",
        "mode": '$mode',
        "login_type": "$loginType",
        "platform": "$platform"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {
          print('---login API Success----');
          print(response.data);

          pref.putString(SharedKey().otpSession, "${response.data['otpSession']}");
          pref.putString(SharedKey().token, "${response.data['bearertoken']}");
          FlutterApp.token = response.data['bearertoken'];

         /* if(loginType == '2'){
            _prefs.setString("email", emailOrMobile);
          }else{
            _prefs.setString("mobile", emailOrMobile);
          }
          _prefs.setString("full_name", '');*/

          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      print(e);
      if (e.response != null) {
      } else {

      }
    }
  }

  ///verify user OTP
  otpVerify(emailOrMobile, otpSession, otp, token, mode) async {

    print('emailOrMobile - ' + emailOrMobile);
    print('otpSession - ' + otpSession);
    print('otp - ' + otp);
    print('token - ' + token);
    print('mode - ' + mode);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + token};
      var response = await dio.post(UrlConstants.loginUrl, data: {
        "tag": 'otpverify',
        "email_or_mobile": "$emailOrMobile",
        "otpsession": "$otpSession",
        "otp": '$otp',
        "mode": "$mode"
      });

      print(response.data);
      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {
          pref.putString(SharedKey().userId, "${response.data['user_id']}");
          pref.putString(SharedKey().email_or_mobile, "${response.data['email_or_mobile']}");
   //       pref.putBool(SharedKey().IS_LOGGED_IN, true);
        }

        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('dio cache..');
        print(e);
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print('dio cache res..');
        print(e.request);
        print(e.message);
      }
    }
  }

  resendOTP(emailOrMobile, mode) async {

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.loginUrl, data: {
        "tag":"send_otp",
        "email_or_mobile":"$emailOrMobile",
        "mode":"$mode"
      });

      print(response.data);
      if (response.statusCode == 200 && response != null) {
        pref.putString(SharedKey().otpSession, "${response.data['otpSession']}");
       return response.data;
      }
    }  on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  fcmUpdate(fcm, token) async {

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + token};
      var response = await dio.post(UrlConstants.fcmUpdate, data: {
        "tag": 'add_fcmdetails',
        "fcm_token": "$fcm",
      });

      print(response.data);
      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {
          return response.data;
        }
        return response.data;

      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('dio cache..');
        print(e);
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print('dio cache res..');
        print(e.request);
        print(e.message);

        return false;
      }
    }
  }

  /// profile API

  getProfile() async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.getProfile, data: {
        "tag": 'get_profile',
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {
          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    }

    on DioError catch (e) {
      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
      }

      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  updateUserProfile(name, email, mobileNo) async {

    print('[edit_profile] params---');
    print('name:: ' + name);
    print('email:: ' + email);
    print('mobileNo:: ' + mobileNo);
    print('profilePic:: ' + FlutterApp.profilePic);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.getProfile, data: {
        "tag": "edit_profile",
        "full_name":name,
        "profile_image":FlutterApp.profilePic,
        "email":email,
        "mobile_number": mobileNo
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {
          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

 /* uploadProfileImage(File file)async{
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": 'Bearer ' +  FlutterApp.token
    };
//    var uri = Uri.parse('https://skromanglobal.com/vtro.in/login_api/image_upload'); //old url
//    var uri = Uri.parse("https://v-tro.in/EV_ChargeStation/login_api/image_upload");   // new

    var length = await file.length();

    print(file);
    http.MultipartRequest request = new http.MultipartRequest("POST", Uri.parse(UrlConstants.uploadImage))
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile("image", file.openRead(), length, filename: FlutterApp.token +".png",), //+'.png',
      );
    request.fields["tag"] = "image_upload";
 //   request.fields['userId'] = FlutterApp.token;
    request.fields["userId"] = "1296";

    var response = await http.Response.fromStream(await request.send());
  //  var decodedData = jsonDecode(response.body);

    var decodedData=json.decode(json.encode(response.body));

    print('---upload profile image---');

    if (response.statusCode == 200 && response != null) {
      return decodedData;
    }
  }*/

  uploadProfileImage(File file)async{
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": 'Bearer ' +  FlutterApp.token
    };

    var length = await file.length();

    print(file);
    http.MultipartRequest request = new http.MultipartRequest('POST', Uri.parse(UrlConstants.uploadImage))
   //   ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile("image", file.openRead(), length, filename: FlutterApp.token + ".png",), //+'.png',
      );
    request.fields["tag"] = "image_upload";
    request.fields['userId'] = FlutterApp.token;

    var response = await http.Response.fromStream(await request.send());
    var decodedData = jsonDecode(response.body);

    print('---upload profile image---');
    print(response.body);

    if (response.statusCode == 200 && response != null) {
      return decodedData;
    }

  }

  ///------------------------------------------ Bike Information ----------------------------------------------------------///

  /// new bike API
  Future getBikeDataById() async {
    print('bike_data_auto_fill');
    print(FlutterApp.token);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + FlutterApp.token};

      var response = await dio.post(UrlConstants.bikeName, data: {
        "tag":"bikedata_autofill",
        "bike_serial_no":"17"
      });

      print('checking');
      print(response.data);

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {

          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('timeout');
      }
      if (e.response != null) {
        print('here..');
        print(e.response.data);

      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.message);
      }
    }
  }

  /// take bike information from user total [ 5 API ]
  Future getBikeName() async {

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + FlutterApp.token};

      var response = await dio.post(UrlConstants.bikeName, data: {
        "tag": 'get_bikenamedetails',
      });

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {

          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
         FToast.show('timeout');
      }
      if (e.response != null) {
        print('here..');
        print(e.response.data);

      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.message);
      }
    }
  }

  ///2
  Future getBikeSeries(bikeName) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + FlutterApp.token};

      var response = await dio.post(UrlConstants.bikeName, data: {
        "tag":"get_bikeseriesdetails",
        "bike_name":bikeName,
      });

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {

          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);

      } else {
        print(e);
      }
    }
  }

  ///3
  Future getCompanyDetails(bikeName, bikeSeriesId) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + FlutterApp.token};

      var response = await dio.post(UrlConstants.bikeName, data: {
        "tag":"get_bikecompanydetails",
        "bike_name":"$bikeName",
        "bike_series":"$bikeSeriesId"
      });

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {

          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);

      } else {
        print(e);
      }
    }
  }

  ///4
  Future getModelDetails(bikeName, bikeSeriesId, bikeCompany) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + FlutterApp.token}; // temporary

      var response = await dio.post(UrlConstants.bikeName, data: {
        "tag":"get_bikemodeldetails",
        "bike_name":bikeName,
        "bike_series":"$bikeSeriesId",
        "bike_company":"$bikeCompany"
      });

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {

          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);

      } else {
        print(e);
      }
    }
  }

  ///5
  Future getKWDetails(bikeName, bikeSeriesId, bikeCompany, bikeModel) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + FlutterApp.token}; // temporary

      var response = await dio.post(UrlConstants.bikeName, data: {
        "tag":"get_bikekwdetails",
        "bike_name":bikeName,
        "bike_series":"$bikeSeriesId",
        "bike_company":"$bikeCompany",
        "bike_model":"$bikeModel"
      });

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {

          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);

      } else {
        print(e);
      }
    }
  }

  ///6 Add user bike details
  Future addUserBikeDetails(bikeName, bikeSeriesId, bikeCompany, batteryModel, bikeKW, String kwId) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + FlutterApp.token}; // temporary
      var response = await dio.post(UrlConstants.addBike, data: {
        "tag":"insertbikedetails",
        "bike_name":"$bikeName",
        "bike_series":"$bikeSeriesId",
        "bike_company":"$bikeCompany",
        "bike_model":"$batteryModel",
        "bike_kw":"$bikeKW",
        "bike_id":"$kwId"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {

          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);

      } else {
        print(e);
      }
    }
  }

  /// splash screen calling API
  getDetailsSplashScreen() async {

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.splashScreen, data: {
        "tag": 'get_details',
      });

      print('splash screen response::');
      print(response.data);

      if (response.statusCode == 200 && response != null) {

        print('check status:: ');
        print(response.data['status']);

        if(response.data['status'] == true){

          FlutterApp.profilePic = response.data['user_img'];
          FlutterApp.userBikeKw = response.data['user_bike_kw'];
          FlutterApp.normalBikeCost = response.data['normal_per_kw_amount'];
          FlutterApp.fastBikeCost = response.data['fast_per_kw_amount'];
          FlutterApp.normalBikeTime = response.data['normal_per_kw_time'];
          FlutterApp.fastBikeTime = response.data['fast_per_kw_time'];
          FlutterApp.gstFormula = response.data['gst_percent'];
          FlutterApp.fullName = response.data['user_name'];
          FlutterApp.userEmailStatus = response.data['email_status'];
          FlutterApp.userMobileStatus = response.data['mobile_status'];

          if(response.data['user_mobile'] == '0'){
            FlutterApp.userMobileNo = '';
          }else{
            FlutterApp.userMobileNo = response.data['user_mobile'];
          }

        //  FlutterApp.userMobileNo = response.data['user_mobile'];
          FlutterApp.userEmailId = response.data['user_email'];

          ///new
          FlutterApp.isGoldCardUser = response.data['is_gold_card_user'];
          FlutterApp.isGroupUser = response.data['is_group_user'];

          if(FlutterApp.isGoldCardUser == true){
            FlutterApp.userGoldCardNo = response.data['vtro_gold_card_no'];
          }

          /// when charging status is start / stop
          /// empty array condition []
          var array = response.data['current_request'];
          var reservationData = response.data['reservation_details'];
          if(array.length == 0){

            /// check if user has any current reservation request
            if(reservationData.length != 0){
              _currentState.setUpcomingReservationVisibility(true);
              FlutterApp.rStationName = response.data['reservation_details'][0]['station_name'];
              FlutterApp.rTimeSlot = response.data['reservation_details'][0]['time_slot'];
              FlutterApp.splashScreenReservationId = response.data['reservation_details'][0]['reservation_id'];
              FlutterApp.reservationStationImage = response.data['reservation_details'][0]['station_image'];
              FlutterApp.reservationStationID = response.data['reservation_details'][0]['station_id'];
              FlutterApp.reservationStartTime = response.data['reservation_details'][0]['stime'];
            }else{
              _currentState.setUpcomingReservationVisibility(false);
            }
          }
        }
        return response.data;
      }
    } on DioError catch (e) {
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
      }

      if (e.response != null) {
        print('here..');
        print(e);
      } else {
      }
    }
  }

  /// --------------------------------------- After scan QR flow API ---------------------------------------------------------///

  scanQR(stationId, reservationId) async {

    print('URL :: ');
    print(FlutterApp.changeUrl);
    print(FlutterApp.changeMqttUrl);

    print('[scan_qr] params---');
    print('stationID:: ' + stationId);
    print('reservationId:: ' + reservationId);
    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"scan_qr",
        "station_id":"$stationId",
        "reservation_id":reservationId      // useful only when reservation else this param is empty
      });

      print('--[scan qr http response]--');
      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  assignPlugPoint(reservationId, subId) async {

    print('-- [assign_plug_point] params---');
    print('checking.....');
    print('scan QR:: ' + FlutterApp.scanQR);
    print('plug:: ' + FlutterApp.plugPoint);
    print('charger type:: ' + FlutterApp.chargerType);
    print('reservationId:: ' + reservationId);
    print('Sub ID:: ' + subId);
    print('groupId :: ' + FlutterApp.groupId);

    print('URL :: ');
    print(FlutterApp.changeUrl);
    print(FlutterApp.changeMqttUrl);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"assign_plug_point",
        "station_id":FlutterApp.scanQR,
        "plug_point":FlutterApp.plugPoint,
        "charger_type":FlutterApp.chargerType,
        "reservation_id":reservationId,   // useful only when reservation else this param is empty
        "sub_id":"$subId",   // if user has plan then only this param useful else forward as empty
        "group_id": FlutterApp.groupId
      });

      print('-- [assign_plug_point] http --');
      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// payment gateway API - no.3
  estimateCostApi(amount) async {

    print('--[estimate_cost] params---');
    print('amount:: ' + amount.toString());

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};

      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"estimate_cost",
        "amount":amount,
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// payment gateway API QR flow
  getCFToken(percentage, amount, energyUnits, isWallet, isOther, amountWallet, amountOther, reservationId) async {
    print('---- [cftoken_generate] params---');
    print('checking.....');
    print('percentage:: ' + percentage.toString());
    print('amount:: ' + amount.toString());
    print('energy unit:: ' + energyUnits.toString());
    print('isWallet:: ' + isWallet.toString());
    print('isOther:: ' + isOther.toString());
    print('amount Wallet:: ' + amountWallet.toString());
    print('amount Other:: ' + amountOther.toString());
    print('reservationId:: ' + reservationId);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"cftoken_generate",
        "amount":'$amount',
        "is_wallet":isWallet,
        "is_other":isOther,
        "amt_wallet":amountWallet,
        "amt_other_pay":amountOther,
        "station_id":FlutterApp.scanQR,
        "plug_point":FlutterApp.plugPoint,
        "charger_type":FlutterApp.chargerType,
        "request_id":FlutterApp.requestId,
        "percentage_request":'$percentage',
        "energy_units":'$energyUnits',
        "reservation_id":reservationId

      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// payment gateway success API
  paymentSuccess(amount, referenceId, paymentMode, cfToken, orderId, paymentStatus, txMsg) async {

    print('--[payment_success] params---');
    print('checking.....');
    print('amount:: ' + amount.toString());
    print('referenceId:: ' + referenceId);
    print('paymentMode:: ' + paymentMode);
    print('cfToken:: ' + cfToken);
    print('orderId:: ' + orderId);
    print('paymentStatus:: ' + paymentStatus);
    print('txMsg:: ' + txMsg);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"payment_success",
        "order_id":"$orderId",
        "cftoken":"$cfToken",
        "payment_mode":'$paymentMode',
        "transaction_id":"$referenceId",
        "tx_status":paymentStatus,
        "tx_msg":txMsg,
      });

      print('payment success true--');
      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// start charging http api
  startChargingAPI(percentage, units) async {

    print('-- [initiate_charging] params---');
    print('checking.....');
    print('reqID:: ' + FlutterApp.requestId);
    print('scanQR:: ' + FlutterApp.scanQR);
    print('plug:: ' + FlutterApp.plugPoint);
    print('percentage:: ' + percentage.toString());
    print('units:: ' + units.toString());

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"initiate_charging",
        "request_id":FlutterApp.requestId,
        "station_id":FlutterApp.scanQR,
        "plug_point":FlutterApp.plugPoint,
        "percentage_request":"$percentage",
        "energy_units":"$units"
      });

      print('start charging http API....');
      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// stop charging http api
  stopChargingAPI() async {

    print('-- [stop_charging] params---');

    print('checking.....');
    print('reqID:: ' + FlutterApp.requestId);
    print('scanQR:: ' + FlutterApp.scanQR);
    print('Plug:: ' + FlutterApp.plugPoint);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"stop_charging",
        "request_id":FlutterApp.requestId,
        "command":"stop_charging",
        "station_id":FlutterApp.scanQR,
        "plug_point":FlutterApp.plugPoint
      });

      print('stop charging http API....');
      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// Invoice ///
  getInvoiceAPI(String requestId) async {

    print('-- [current_request_details] params---');
    print('checking.....');
    print('reqID:: ' + requestId);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"current_request_details",
        "request_id":requestId,

      });

      print('Invoice http API response');
      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }   on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  /// -------------------------------------------All History API------------------------------------------------------///
  getHistory(page) async {
    print('--[request_history] params---');
    print('Page:: ' + page.toString());

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag": "request_history",
        "page":"$page"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  filterHistory(page, monthYear) async {
    print('--[request_history filter] params---');
    print('Page:: ' + page.toString());
    print('monthYear:: ' + monthYear);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};

      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"request_history",
        "filter":"$monthYear",
        "page":"$page"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  /// ------------------------------------------- VTRO Wallet ------------------------------------------------------///

  /// generate [cf-Token] for Vtro wallet
  generateCFToken(amount) async {
    print('--[add_balance_order_token] params---');
    print('checking.....');

    print(amount);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"add_balance_order_token",
        "amount":"$amount"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      print(e);

    }
  }

  addBalanceWallet(orderId, cfToken, amount, transactionId, paymentMode, txStatus, txMsg) async {
    print('-- [add_balance] params---');
    print('checking.....');
    print(amount);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.userRequestApi, data: {
        "tag":"add_balance",
        "cftoken":"$cfToken",
        "amount":"$amount",
        "order_id":"$orderId",
        "transaction_id":"$transactionId",
        "payment_mode":"$paymentMode",
        "tx_status":"$txStatus",
        "tx_msg":"$txMsg"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      print(e);

    }
  }

  /// ------------------------------------------- PLANS --------------------------------------------------------------///

  /// get plans of list
  getPlans() async {

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};

      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.plans, data: {
        "tag": "our_plans",
     //   "page":"$page"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  /// get [own] plans list
  getMyPlans(planType, page) async {
    print('[getUpcomingPlans] params---');
    print(planType);
    print(page);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};

      var response = await dio.post(UrlConstants.plans, data: {
        "tag":"user_active_plans",
        "plan_type":"$planType",
        "page":"$page"
      });
      print(response.data);
      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  /// get previous plans detailed list
  getPreviousPlan(subId, int page) async {

    print('[previous_plan] params---');
    print('subID:: '+ subId.toString());
    print('page:: ' + page.toString());

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};

      var response = await dio.post(UrlConstants.plans, data: {
        "tag":"previous_plan",
        "sub_id":"$subId",
        "page":"$page"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  ///  payment gateway API - PLANS ////
  estimateCostPlans(planId) async {

    print('--[plan_estimate_cost] params---');
    print(planId);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.plans, data: {
        "tag":"plan_estimate_cost",
        "plan_id":"$planId",
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// payment gateway API
  getCFTokenPlans(amount, isWallet, isOther, amountWallet, amountOther, planId) async {
    print('-- [plan_cftoken] params---');
    print('-- checking --');

    print(amount.toString());
    print(planId);
    print(isWallet.toString());
    print(isOther.toString());
    print(amountWallet.toString());
    print(amountOther.toString());

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.plans, data: {
        "tag":"plan_cftoken",
        "amount":"$amount",
        "is_wallet":"$isWallet",
        "is_other":"$isOther",
        "amt_wallet":"$amountWallet",
        "amt_other_pay":"$amountOther",
        "plan_id":"$planId"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// payment gateway success API - Plans
  paymentSuccessPlans(referenceId, paymentMode, cfToken, orderId, paymentStatus, txMsg) async {

    print('-- paymentSuccess Api params[plans] params---');
    print('checking.....');

    print('referenceId ::' + referenceId);
    print('paymentMode ::' + paymentMode);
    print('cfToken ::' + cfToken);
    print('orderId ::' + orderId);
    print('paymentStatus ::' + paymentStatus);
    print('txMsg ::' + txMsg);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.plans, data: {
        "tag":"payment_success",
        "order_id":"$orderId",
        "cftoken":"$cfToken",
        "payment_mode":'$paymentMode',
        "transaction_id":"$referenceId",
        "tx_status":paymentStatus,
        "tx_msg":txMsg,
      });

      print('payment success true--');
      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// -------------------------- All Reservation API --------------------------------///

  getReservationList() async {
    print('[reservation_list] params--- ');

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.getBooking, data: {
        "tag": "reservation_list",
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  getBooking(String stationId, String chargerType) async {
    print('[get_dates] params---');
    print('stationId:: ' + stationId);
    print('chargerType:: ' + chargerType);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};

      var response = await dio.post(UrlConstants.getBooking, data: {
        "tag":"get_dates",
        "charger_type":"$chargerType",
        "station_id":"$stationId",
      });
      print(response.data);
      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }
    on DioError catch (e) {
      map["status"] = 'timeout';
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  getTimeSlot(String stationId, String currentDate, String chargerType) async {
    print('[get_timeslot] params---');
    print('chargerType:: ' + chargerType);
    print('stationId:: ' + stationId);
    print('currentDate:: ' + currentDate);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};

      var response = await dio.post(UrlConstants.getBooking, data: {
        "tag":"get_timeslot",
        "charger_type":"$chargerType",
        "station_id":"$stationId",
        "current_date":"$currentDate"
      });

      print(response.data);
      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  getReservationDetails() async{
    {
      print('[reservation_details] params---');
      print('reservation_id:: ' + FlutterApp.splashScreenReservationId);

      try {
        dio.options.headers['content-Type'] = 'application/json';
        dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
        dio.options.connectTimeout = 8000; //5s
        dio.options.receiveTimeout = 8000;//3s

        var response = await dio.post(UrlConstants.getBooking, data: {
          "tag": "reservation_details",
          "reservation_id":FlutterApp.splashScreenReservationId
        });

        print(response.data);

        if (response.statusCode == 200 && response != null) {
          return response.data;
        }
      }

      on DioError catch (e) {
        map["status"] = 'timeout';

        print('in timeout---');
        print(e);

        if (e.type == DioErrorType.CONNECT_TIMEOUT) {
          FToast.show('Timeout');
          return map;
        }
      }
    }
  }

  /// payment gateway API
  getCFTokenReservation(amount, isWallet, isOther, amountWallet, amountOther, chargerType, bookDate, timeSlot, stationId) async {
    print('-- [reservation_cftoken] [Reservation] params---');
    print('-- checking --');

    print('amount:: ' + amount.toString());
    print('isWallet:: ' + isWallet.toString());
    print('isOther:: ' + isOther.toString());
    print('amountWallet:: ' + amountWallet.toString());
    print('amountOther:: ' + amountOther.toString());
    print('chargerType:: ' + chargerType);
    print('bookDate:: ' + bookDate);
    print('timeSlot:: ' + timeSlot);
    print('stationId:: ' + stationId);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.getBooking, data: {
        "tag":"reservation_cftoken",
        "amount":"$amount",
        "is_wallet":"$isWallet",
        "is_other":"$isOther",
        "amt_wallet":"$amountWallet",
        "amt_other_pay":"$amountOther",
        "charger_type":"$chargerType",
        "book_date":"$bookDate",
        "time_slot":"$timeSlot",
        "station_id":"$stationId"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// payment gateway success API - Plans
  paymentSuccessReservation(referenceId, paymentMode, cfToken, orderId, paymentStatus, txMsg) async {

    print('-- [reservation_payment] Api [Reservation] params---');
    print('checking.....');

    print('referenceId:: ' + referenceId);
    print('paymentMode:: ' + paymentMode);
    print('cfToken:: ' + cfToken);
    print('orderId:: ' + orderId);
    print('paymentStatus:: ' + paymentStatus);
    print('txMsg:: ' + txMsg);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.getBooking, data: {
        "tag":"reservation_payment",
        "order_id":"$orderId",
        "cftoken":"$cfToken",
        "payment_mode":'$paymentMode',
        "transaction_id":"$referenceId",
        "tx_status":paymentStatus,
        "tx_msg":txMsg,
      });

      print('payment success true--');
      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// reason list
  Future getReasonList() async {
    print('[In Reservation]::');

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' + FlutterApp.token};
      var response = await dio.post(UrlConstants.getBooking, data: {
        "tag":"reservation_cancel_reason"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        if (response.data['status'] == true) {

          return response.data;
        }else if(response.data['status'] == false){
          return response.data;
        }
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('timeout');
      }
      if (e.response != null) {
        print('here..');
        print(e.response.data);

      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.message);
      }
    }
  }

 /// reservation estimate cost
  estimateCostReservation() async {

    print('-- [reservation_cancel_estimate] params---');
    print('reservationID:: ' + FlutterApp.reservationID);
    print('reservationID:: ' + FlutterApp.splashScreenReservationId);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.reservation, data: {
        "tag":"reservation_cancel_estimate",
     //  "reservation_id":FlutterApp.splashScreenReservationId,
        "reservation_id":FlutterApp.reservationID,
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// final cancel reservation
  cancelReservation(String refundAmount, String reasonName) async {

    print('-- [cancel_reservation] params---');
    print('reservationID:: ' + FlutterApp.reservationID);
    print(reasonName.toString());
    print('refundAmount::: ' + refundAmount.toString());

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.reservation, data: {
        "tag":"cancel_reservation",
        "reservation_id":FlutterApp.reservationID,
      //  "reservation_id":FlutterApp.splashScreenReservationId,
        "reason":"$reasonName",
        "refund_amt":"$refundAmount",
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('here..');
        print(e);
      } else {
        print(e);
      }
    }
  }

  /// ------------------------------------------- Gold Card ----------------------------------------------------------///

  /// generate [cf-Token] for gold card
  generateCFTokenGoldCard(totalAmount, isWallet, isOther, wallet, other) async {
    print('-- getCFToken [add_balance_order_token] params---');
    print('checking.....');

    print('totalAmount:: ' +totalAmount.toString());
    print('isWallet:: ' +isWallet.toString());
    print('isOther:: ' +isOther.toString());
    print('wallet:: ' +wallet.toString());
    print('other:: ' +other.toString());

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.goldCard, data: {
        "tag":"add_balance_order_token",
        "amount":"$totalAmount",
        "is_wallet":"$isWallet",
        "is_other":"$isOther",
        "amt_wallet":"$wallet",
        "amt_other_pay":"$other"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      print(e);

    }
  }

  addBalanceGoldCard(orderId, cfToken, amount, transactionId, paymentMode, txStatus, txMsg) async {
    print('-- [add_balance Gold] params---');
    print('checking.....');
    print('orderId ::' +orderId.toString());
    print('cfToken ::' +cfToken.toString());
    print('amount ::' +amount.toString());
    print('transactionId ::' +transactionId.toString());
    print('paymentMode ::' +paymentMode.toString());
    print('txStatus ::' +txStatus.toString());
    print('txMsg ::' +txMsg.toString());

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      var response = await dio.post(UrlConstants.goldCard, data: {
        "tag":"add_balance",
        "cftoken":"$cfToken",
        "amount":"$amount",
        "order_id":"$orderId",
        "transaction_id":"$transactionId",
        "payment_mode":"$paymentMode",
        "tx_status":"$txStatus",
        "tx_msg":"$txMsg"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    } on DioError catch (e) {
      print(e);

    }
  }

  getGoldCardDetails(page) async {
    print('[get_booking_details] params:::');

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};

      var response = await dio.post(UrlConstants.goldCard, data: {
        "tag":"get_booking_details",
        "page":"$page"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      print(e);

    }
  }

  filterHistoryGoldCard(page, monthYear) async {
    print('--[get_booking_details] params---');
    print('Page:: ' + page.toString());
    print('monthYear:: ' + monthYear);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};

      var response = await dio.post(UrlConstants.goldCard, data: {
        "tag":"get_booking_details",
        "filter":"$monthYear",
        "page":"$page"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

/// -------------- All Recommended API -------------------///

  recommendedBalance() async {
    print('--[recommendedBalance] params--');

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s


      var response = await dio.post(UrlConstants.getBooking, data: {
        "tag":"recommended_list",
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  /// -------------- All Group API-------------------///

  createGroup(String groupName, groupImage, groupContactNo) async {

    print('-- [create_groups] params---');
    print('group_name:: ' +groupName);
 //   print('groupContactNo:: ' +groupContactNo); vtro

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.group, data: {
        "tag":"create_groups",
        "group_name":"$groupName",
        "group_pic":"",
        "contact_no":"$groupContactNo"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }  on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  groupList() async {
    print('--[user_group_list] params--');

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.group, data: {
        "tag":"user_group_list",
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  groupInformation() async {
    print('--[group_info_details] params--');

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.group, data: {
        "tag":"group_info_details",
        "group_id":FlutterApp.groupId
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  groupHistory() async {
    print('--[group_history] params--');

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.group, data: {
        "tag":"group_history",
        "page":"1",
        "group_id":FlutterApp.groupId
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }

    on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

  generateCFTokenGroup(totalAmount, isWallet, isOther, wallet, other) async {
    print('-- [add_group_balance_cftoken] params---');
    print('checking.....');

    print('totalAmount:: ' + totalAmount.toString());
    print('isWallet:: ' + isWallet.toString());
    print('isOther:: ' + isOther.toString());
    print('wallet:: ' + wallet.toString());
    print('other:: ' + other.toString());
    print('group id:: ' + FlutterApp.groupId);

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.group, data: {
        "tag":"add_group_balance_cftoken",
        "amount":"$totalAmount",
        "is_wallet":"$isWallet",
        "is_other":"$isOther",
        "amt_wallet":"$wallet",
        "amt_other_pay":"$other",
        "group_id":FlutterApp.groupId
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }  on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);

      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
     //   FToast.show('Timeout');
        return map;
      }
    }
  }

  addBalanceGroupPayment(orderId, cfToken, transactionId, paymentMode, txStatus, txMsg) async {
    print('-- [ group payment_success] params---');
    print('checking.....');
    print('orderId ::' +orderId.toString());
    print('cfToken ::' +cfToken.toString());
    print('transactionId ::' +transactionId.toString());
    print('paymentMode ::' +paymentMode.toString());
    print('txStatus ::' +txStatus.toString());
    print('txMsg ::' +txMsg.toString());

    try {
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {"Authorization": 'Bearer ' +  FlutterApp.token};
      dio.options.connectTimeout = 8000; //5s
      dio.options.receiveTimeout = 8000;//3s

      var response = await dio.post(UrlConstants.group, data: {
        "tag":"payment_success",
        "order_id":"$orderId",
        "cftoken":"$cfToken",
        "payment_mode":"$paymentMode",
        "transaction_id":"$transactionId",
        "tx_status":"$txStatus",
        "tx_msg":"$txMsg"
      });

      print(response.data);

      if (response.statusCode == 200 && response != null) {
        return response.data;
      }
    }  on DioError catch (e) {
      map["status"] = 'timeout';

      print('in timeout---');
      print(e);
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        FToast.show('Timeout');
        return map;
      }
    }
  }

}
