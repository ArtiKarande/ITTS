/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:vtrochargingstation/common/FlutterApp.dart';

class UrlConstants {

 // static final String baseUrl = "https://v-tro.in/EV_ChargeStation/";         // new url
//  static final String baseUrl = "https://skromanglobal.com/EV_ChargeStation/";  //old url

  static final String baseUrl = FlutterApp.changeUrl;  // url changing temporary

  static final String currentLoc = baseUrl +  "/station/get_station";
  static final String getStation = baseUrl +  "station/get_station";

  static final String loginUrl = baseUrl + "login_api/login";
  static final String scanQr = baseUrl + "station/scan_qr";
  static final String sendUnit = baseUrl + "";
  static final String getProfile = baseUrl + "login_api/profile";

  static final String fcmUpdate = baseUrl + 'FCM/fcm_details';
  static final String splashScreen = baseUrl + 'login_api/splash_screen';

  /// dropdown
  static final String bikeName = baseUrl + 'bike/bike_read';
  static final String addBike = baseUrl + 'user/user_bikedetails';
  static final String cfToken = baseUrl + 'user/user_request';
  static final String userRequestApi = baseUrl + 'user/user_request_api';
  static final String plans = baseUrl + 'plans/get_plans';

  static final String getBooking = baseUrl + 'reservation/get_booking';
  static final String goldCard = baseUrl + 'gold_card/get_gold_details';
  static final String reservation = baseUrl + 'reservation/cancel_reservation';
  static final String group = baseUrl + 'groups/group_details';


  /// upload image
  static final String uploadImage = baseUrl + 'login_api/image_upload';

}