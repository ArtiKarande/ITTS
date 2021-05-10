/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:collection';

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

  static String controlStrings;

  static String homeName = "";

  static String roomName = "";
  static String deviceName = "";

  static String deviceStatus = "";

  static bool isCommunicationOverNet = true;
  static bool isYesTap = false;
  static String keys = "";

  static String topic;

//  static int check =0;

  static void resetData() {
    setDefaultHome = null;
    setIndex = null;
    counter = 0;
  }
}
