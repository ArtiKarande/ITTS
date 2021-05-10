/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

/// common predefined variables are define here

class FlutterApp {

  static String chargingStatus = '';
  static String balance = '';
  static String requestId = '0';
  static String token = '';
  static String percentage = '' ;
  static String scanQR = '' ;
  static String chargerType = 'Normal' ;   /// normal / fast
  static String activeStatus = '' ;   /// plug available / not - status

  static String typeOfAll = '' ; // it has normal type / reservation type / reservation & plan type / reservation and normal type etc.
  static String subID = '';
  static String remainingEnergy = '';


  /// calculate percentage and time params
  static String userBikeKw = '10'; //empty
  static int normalBikeCost = 0;
  static int fastBikeCost = 0;
  static double normalBikeTime = 0;
  static double fastBikeTime = 0;
  static int gstFormula = 0;
  static bool isGoldCardUser = false;
  static String userGoldCardNo = '';


  /// group
  static bool isGroupUser;
  static String groupId = '';
  static String groupName = '';
  static double groupBalance = 0;
  static String groupImage = '';

  /// reservation
  static double reservationNormalCoast = 0.0;
  static double reservationFastCoast = 0.0;
  static String reservationID = '';

  /// show current reservation
  static String rStationName = '';
  static String rTimeSlot = '';
  static String splashScreenReservationId = '';
  static String reservationStationImage = '';
  static String reservationStationID = '';
  static String reservationStartTime = '';

  static int userChargerSelectionType = 0; /// 1 for normal and 2 for turbo
  static String plugPoint = '0';

  static String userWalletAmount = '0';
  static String profilePic = '';
//  static String profilePicBaseUrl = 'https://skromanglobal.com/vtro.in/upload/';
  static String profilePicBaseUrl = 'https://v-tro.in/upload/';
  static String fullName = '';
  static String userMobileNo = '';
  static String userEmailId = '';
  static String userEmailStatus = '';
  static String userMobileStatus = '';

  static String strImage = 'https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg';

  /// location
  static double currentLatitude = 0.0;
  static double currentLongitude = 0.0;


  /// login
  static int resendCount = 0;


  static String changeUrl = 'https://skromanglobal.com/EV_ChargeStation/'; //old
  static String changeMqttUrl = '148.66.133.252';

//   static String changeUrl = 'https://v-tro.in/EV_ChargeStation/';  //new
//   static String changeMqttUrl = 'v-tro.in';

}
