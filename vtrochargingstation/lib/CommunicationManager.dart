/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/Invoice/Invoice.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'common/FToast.dart';
import 'common/sharedPreferece/SharedKeys.dart';
import 'common/sharedPreferece/SharedPreferneces.dart';
import 'mqttConnectionManager.dart';

class CommunicationManager {

  final MQTTAppState _currentState;
  SharedPreference pref = new SharedPreference();
  MqttConnectionManager mqttConnection;

  // Constructor
  CommunicationManager({
    @required MQTTAppState state
  }):  _currentState = state ;

  /// mqtt connection method
  connect() async {
    var r = await mqttConnection.connect();
    if (r['errorCode'] != 0) {
      await new Future.delayed(const Duration(seconds: 3));
      await connect();
      await new Future.delayed(const Duration(seconds: 2));
      syncSubscribe('vtro/' + FlutterApp.requestId.toString() + '/chargingstation/out/app');
    }
    else {
     addListenersMqttConnection();
    }
  }

  /// mqtt disconnect method
  disconnect() async {
    await disconnectMqttConnection();
  }

  disconnectMqttConnection() async {
    _currentState.setMqttConnectionState('no');
    print('MQTT: Disconnecting client');
    await mqttConnection.disconnect();

    connection();
  }

  /// Method to add listeners to the events on the mqtt connection.
 addListenersMqttConnection() {
    mqttConnection.mqttClient.updates.listen(onDataReceivedMqtt);
    mqttConnection.mqttClient.onSubscribed = onSubscribedListener;
    mqttConnection.mqttClient.onUnsubscribed = onUnsubscribeListener;
  }

  /// subscribe listener
  onSubscribedListener(t) {
    print('CM.oS: called with t -> $t;');
  }

  /// unsubscribe listener
  onUnsubscribeListener(t) {
    print('CM.oU: called with t111 -> $t; ');
  }

  /// when data received on mqtt this method gets called
  onDataReceivedMqtt(List<MqttReceivedMessage> messageList) async{

    SharedPreferences _prefs1 = await SharedPreferences.getInstance();
    print('--------------mqtt--------------');

    for (int i = 0; i < messageList.length; i++) {
      int i = 0;
      final String topic = messageList[i].topic;

      final MqttPublishMessage r = messageList[i].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(r.payload.message);

      print(" payload:::$payload");
      print(" topic:::$topic");

      Map<String, dynamic> map = jsonDecode(payload);
      String tag = map["tag"];

      /// ---------------------------- Start Charging -----------------------------------------*/

      /// plug is connected and i get [battery percentage] here

      /// 1st mqtt res
      if(tag == 'charger_connection'){
        print('in mqtt charger_connection');
        String status = map["charger_connection_status"];

        if(status == 'true'){
          String plug = map["plug_point"];
          String requestId = map["request_id"];

            /// store this value for initially check charging is started or not

            _prefs1.setString("plug", plug);
            _currentState.setSliderStatus(false);
            _currentState.setSliderMoveControl(false);   /// slider moving disabled

            _currentState.setReceivedText('per');   /// set to [per] for [chargerTypeNeu] screen navigation to [StartCharging]
            FlutterApp.requestId = requestId;
            FlutterApp.plugPoint = plug;

          if(map['battery_percentage'] != null){
            FToast.show('battery = ' + map['battery_percentage']);
            _currentState.setLivePercentage(double.parse(map['battery_percentage']));
            _currentState.setRequestPercentage(_currentState.getLivePercentage);
          }
        }
        else{
          /// when vehicle not attached to plug point - condition
          pref.putString(SharedKey().chargingStatus, "");
          pref.putString(SharedKey().REQUESTID, '0');

          _currentState.setReceivedText('map');  /// navigate to map screen if plug not attached to plug point
          _currentState.setSliderMoveControl(false);
       }
      }

      /// 2nd req from app start charging
      else if(tag == 'initiate_charging'){

        String status = map["success"];
        if(status == 'true'){
          _currentState.setReceivedText('stop');
          _currentState.setSliderMoveControl(true);
        }
        /// when user does not start charging from app side, then he can receive false
        else{
          _currentState.setReceivedText('notStarted');
          _currentState.setSliderMoveControl(false);
          pref.putString(SharedKey().chargingStatus, "");
          pref.putString(SharedKey().REQUESTID, '0');
        }
      }

      ///*---------------------------- stop charging -----------------------------------------*/

      else if(tag == 'stop_charging'){

        print('--- stop charging mqtt ---');
        Map<String, dynamic> map = jsonDecode(payload);
        String status = map["battery_charge_status"];

        if(status == 'stopped'){

          print('in [stopped][MQTT]');
          _currentState.setReceivedText('stopped');
          _currentState.setJsonResponse(map);
        }
        else{
          print('in [else][MQTT]');
          //       _currentState.setReceivedText('discard');  ///if vehicle not attach to plug point
          FToast.show('status - false');
        }
      }
      else if(tag == 'charging_status'){
        print('--- stop charging mqtt ---');
        Map<String, dynamic> map = jsonDecode(payload);
        String status = map["battery_charge_status"];

        if(status == 'partial' || status == 'power_failure'){
          pref.putString(SharedKey().chargingStatus, "");
          pref.putString(SharedKey().REQUESTID, '0');

          print('in [partial][MQTT]');
          /// store this value for initially check charging is started or not

          _currentState.setReceivedText('partial');
        }
       /* else if(status == 'power_failure'){
          print('-- mqtt [power failure] --');
          _currentState.setReceivedText('partial');  // using same word to save code, this code is about [power failure] set text here to partial only
        }*/

        else{
          FToast.show('charging complete!');
          _currentState.setReceivedText('partial');
        }
      }

      /// last will
      /*else if(topic.contains('vtro/chargingstation/lastwill')){
        String stationId = map["station_id"];
        if(FlutterApp.scanQR == stationId){
          print('mqtt -- station id is same');
          
          if(payload.contains('disconnected')){
            FToast.show('station is disconnected');
          }else{
            FToast.show('station is connected');
          }
        }else{
          print('mqtt -- station id not same');
        }
      }*/

      /// in future, when hardware gives you battery percentage continue then this will will,
      /// but u need to subscribe topic and change these parameter to hardware receiving values
      /// currently this are dummy values
      else if(payload.contains('percentage')){
        Map<String, dynamic> map = jsonDecode(payload);
        _currentState.setRequestPercentage(double.parse(map['percentage']));
        _currentState.setSliderMoveControl(false);
        _currentState.setLivePercentage(double.parse(map['percentage']));
  //     _currentState.setReceivedText('live');
      }
    }
  }

  /// make mqtt connection at port 1883
  connection() async {
    try {
      print('port starts.... 1883');
  //    mqttConnection = MqttConnectionManager(server: '148.66.133.252', port: 1883);  // old
 //     mqttConnection = MqttConnectionManager(server: 'https://v-tro.in', port: 1883);  // new

      mqttConnection = MqttConnectionManager(server: FlutterApp.changeMqttUrl, port: 1883);  //  url changing temporary [maaz n vaidehi]

      if (mqttConnection.mqttClient == null) {
        await connect();
      }
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  /// to subscribe data
  syncSubscribe(topic) async {
    if (mqttConnection != null) {
      await mqttConnection.subscribe(topic);
    } else {
      FToast.show("error in subscribe");
      print("error in subscribe");
    }
  }

  /// to publish data
  publishSync(topic, String message) async {
    if (mqttConnection != null) {
      await mqttConnection.publish(topic, message);
    } else {
      FToast.show("error in publish");
      print("error in publish");
    }
  }
}
