/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'dart:collection';

import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/tile.dart';

/// predefined variables are declared

class FlutterApp {
  static bool setDefaultHome;
  static int setIndex;
  static int counter = 0;
  static String emailId;

  static String name;
  static String isSignUp;

  static String id;
  static String userID;
  static String deviceString;

  static int themeValue;
  static int restoreVal = 0;
  static int syncVal = 0;
  static int deleteVal = 0; //to delete devices use this
  static int indexVal = -1;
  static int indexValIcons = -1;
  static String renameDeviceVal = '';

  static String controlStrings;

  static String homeName = "";

  static String roomName = "";
  static String deviceName = "";

  static String deviceStatus = "";
  static bool checkMqttConnection = true;  //arti added to check mqtt connection on or off

  static bool isCommunicationOverNet = true;          //isCommunicationOverInternet

  static bool isSignalOn = true;  // to check device status on control screen
  static bool isYesTap = false;
  static List<Home> childList = new List();
  static String keys = "";

  static String topic;
  static String autoBackup = '';


  ///arti uses these parameters
 // static int deviceBackupKey = 1;

//  static int check =0;

  static void resetData() {
    setDefaultHome = null;
    setIndex = null;
    counter = 0;
  }
}
