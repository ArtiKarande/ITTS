/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

/// to store data locally shared preferences is used, these are predefined variables

class SharedKey {
  final String HOME = "home";
  final String RECEIVE_DATA = "receiveData";
  final String INDEX_KEY = "index";
  final String CHILD_LIST = "childList";
  final String IS_LOGGED_IN = "isLoggedIn";
  final String EMAIL_ID = "emailId";
  final String FIRST_NAME = "name";
  final String THEME_VALUE = "themeValue";
  final String SYNC_DATA = "syncData";

  final String ONEDEVICE_DATA = "onedata"; //arti

  final String deviceBackupKey = "keyBackup"; //arti
  final String ONEDEVICE_AUTOBACKUP = "deviceBackup"; //arti  add backup of 1 device data whole string here
  final String deviceNameForBackup = "dname"; //arti  last added device name to check while taking backup data



  ///room backup params
  final String roomNameForBackup = "rName";         // set room name value
  final String roomBackupKey = "roomKeyBackup";     // set to 1 when add room
  final String OneRoomAutobackup = "roomBackup";    // json of whole 1 room


  ///home backup params
  final String homeNameForBackup = "hName";         // set room name value
  final String homeBackupKey = "homeKeyBackup";     // set to 1 when add room
  final String OneHomeAutobackup = "homeBackup";    // json of whole 1 room


  final String Status = "0"; //arti

  String DEVICE_STRING = "deviceString";
  String USER_ID = "userId";
  String DEVICES_LIST = "devicesList";
  String TEMP_DEVICE_LIST = "tempDeviceList";
  String IS_COMMUNICATION_OVER_INTERNET = "isCommunicationOverInternet";


  ///registration otp verify pref value

  final String setAuthValue = '0';

}
