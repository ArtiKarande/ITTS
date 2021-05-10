/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/cupertino.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

/// when provider changes its state updates here with the help of
///   - getter and setter
///   - using [ChangeNotifier]
///   - using notifyListeners

class MQTTAppState with ChangeNotifier{
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = 'proceed'; //  proceed  start
  Map _response ;
  String mqttConnectionState = '';

  String _requestIdProvider;
  int _ack;

  bool upcomingReservation = false;

  /// set auto selected percentage and show at runtime
  double reqPercentage = 0;
  double estimatedCost = 0;
  double estimatedTime = 0;
  double livePercentage = 40.0;

  bool chargingSlideStatus = false; // only charging view slider purpose this param is used

  bool sliderMoveControl = false;
  bool mapVisibility = true;

  /// Animation params
  bool plugAnim = false;

 /// profileImage, wallet Amount, gold card balance

  String walletAmount = '';
  String goldCardAmount = '';

  /// Internet connection
  bool internet;

  void setSliderStatus(bool text) {
    chargingSlideStatus = text;
    notifyListeners();
  }

  void setSliderMoveControl(bool text) {
    sliderMoveControl = text;
    notifyListeners();
  }

  void setMapVisibility(bool text) {
    mapVisibility = text;
    notifyListeners();
  }

  void setUpcomingReservationVisibility(bool text) {
  upcomingReservation = text;
    notifyListeners();
  }

  void setPlugAnim(bool text) {
    plugAnim = text;
    notifyListeners();
  }

  void setInternet(bool text) {
    internet = text;
    notifyListeners();
  }

  void setReceivedText(String text) {
    _receivedText = text;

    print('mqtt app state val check---');
    print(_receivedText);
    notifyListeners();
  }

  void setRequestIdP(String text) {
    _requestIdProvider = text;
    notifyListeners();
  }

  void setRequestPercentage(double percentage) {
    reqPercentage = percentage;
    notifyListeners();
  }

  /// to calculate cost
  void setEstimatedCost(double cost) {
    estimatedCost = cost;
    notifyListeners();
  }
  /// to calculate time
  void setEstimatedTime(double time) {
    estimatedTime = time;
    notifyListeners();
  }

/// live percentage changes
  void setLivePercentage(double per) {
    livePercentage = per;
    notifyListeners();
  }
  void setAck(int text) {
    _ack = text;
    notifyListeners();
  }

  void setMqttConnectionState(String text) {
    mqttConnectionState = text;
    notifyListeners();
  }


  void setJsonResponse(Map response){
    _response = response;
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  /// profile methods

  void setWalletAmount(String amount) {
    walletAmount = amount;
    notifyListeners();
  }

  void setGoldCardAmount(String amount) {
    goldCardAmount = amount;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getMqttText => mqttConnectionState;

  String get getRequestId => _requestIdProvider;
  double get getRequestedPercentage => reqPercentage;
  double get getEstimatedCost => estimatedCost;
  double get getEstimatedTime => estimatedTime;
  double get getLivePercentage => livePercentage;
  int get getAck => _ack;
  Map get getJsonResponse => _response;

  bool get getSliderStatus => chargingSlideStatus;
  bool get getSliderMoveControl => sliderMoveControl;
  bool get getMapVisibility => mapVisibility;
  bool get getUpcomingReservationVisibility => upcomingReservation;
  bool get getPlugAnim => plugAnim;
  bool get getInternet => internet;

  /// profile
  String get getWalletAmount => walletAmount;
  String get getGoldCardAmount => goldCardAmount;

  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

}