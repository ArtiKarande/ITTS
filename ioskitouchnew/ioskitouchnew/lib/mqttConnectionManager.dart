/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'dart:async';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';
import 'common/sharedPreferece/SharedPreferneces.dart';

/// [MqttConnectionManager] is a class to manage the mqtt connection required by the application.
/// It provides interface with functions to connect, publish, subscribe and disconnect to the mqtt server.
/// User can also access [mqttClient] if deeper functionality are needed.

class MqttConnectionManager {
  /// Configurations of test mqtt server.
  static const String testServer = 'test.mosquitto.org'; // test server
  static const int testPort = 1883; // test port
  static const String testClientIdentifier = ''; // test clientIdentifier

  /// Place holders of configurations needed for the mqtt connection.
  String server; // server
  String clientIdentifier; // clientIdentifier
  int port; // port

  SharedPreference pref = new SharedPreference();

  /// Object of [MqttClient] for mqtt connection.
  /// For more information see flutter library documentation for {mqtt_client: ^3.1.0}.
  MqttClient mqttClient; // client

  /// Makes Object of [MqttConnectionManager] with values provided by invoker.
  MqttConnectionManager(
      {this.server = testServer, this.port = testPort,
        this.clientIdentifier = testClientIdentifier});

  /// Makes new Mqtt connection using available parameters.
  Future<dynamic> connect({username, password}) async {
    int errorCode = -1; // error code
    String errorMessage = 'Unknown Error';

    // New mqtt connection.
    mqttClient =
    new MqttClient.withPort(this.server, this.clientIdentifier, this.port);

    // Disabling logging of communication.
    mqttClient.logging(false);

    // Setting keep alive period.
    mqttClient.keepAlivePeriod = 30;

    // Setting callback function when connection drops.
    mqttClient.onDisconnected = onDisconnect;

    // generating and setting connectionMessage using properties available.
    final MqttConnectMessage connectionMessage = new MqttConnectMessage()
    // need to generate unique client identifier for mqtt communication.
        .withClientIdentifier(
        new DateTime.now().millisecondsSinceEpoch.toString())
        .keepAliveFor(30) // Must agree with the keep alive set above or not set.
        .withWillQos(MqttQos.atLeastOnce);
    mqttClient.connectionMessage = connectionMessage;

    // Connecting to mqtt server.
    // Disconnect if there is problem in connection.
    try {
      if (username != null && password != null)
        await mqttClient.connect(username, password);
      else
        await mqttClient.connect();
    } catch (Exception) {
   //   print('MqttConnectionManager.connect: Exception in connect ' + Exception.toString());
      mqttClient.disconnect();
    }

    // check the connection state and set the error code accordingly.
    if (mqttClient.connectionState == ConnectionState.connected) {
      errorCode = 0;
      errorMessage = 'Connected: Connection Success.';
      FlutterApp.isCommunicationOverNet = true;
      //  MasterDetail.isCommunicationOverInternetClicked.value = true;
      //  pref.putBool(SharedKey().IS_COMMUNICATION_OVER_INTERNET, true);
      //    print("MasterDetail.isCommunicationOverInternetClicked.value:::${MasterDetail.isCommunicationOverInternetClicked.value}");
    } else {
      errorCode = -2;
      errorMessage =
      'Disconnected: Connection Faild; State: ${mqttClient.connectionState}';
//      print('MQTT: ERROR Mosquitto $errorMessage');     25 aug
      FlutterApp.isCommunicationOverNet = false;

      //   MasterDetail.isCommunicationOverInternetClicked.value=false;
      //  pref.putBool(SharedKey().IS_COMMUNICATION_OVER_INTERNET, false);
      mqttClient.disconnect();
    }
    return {'errorCode': errorCode, 'errorMsg': errorMessage};
  }

  /// Method to publish data on given [topic].
  publish(topic, message) async {
    final MqttClientPayloadBuilder builder = new MqttClientPayloadBuilder();
    builder.addString(message);
    try {
      mqttClient.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
    } catch (exception) {

  //    FToast.show("Failed to backup data, please try again");  //arti
      print(FlutterApp.syncVal);
      FlutterApp.syncVal = 4;  //by arti prev 4
      FlutterApp.restoreVal = 4;  //by arti
      FlutterApp.deleteVal = 4;  //by arti

      print('MqttConnectionManager.publish: Error while publishing : $exception');
    }
  }

  /// Method to subscribe to given [topic].
  subscribe(final topic) async {
    try {
      mqttClient.subscribe(topic, MqttQos.atLeastOnce);
    } catch (exception) {

      //FToast.show('mqtt error');
      print('Error while subscribing: $exception');

      connect();  // aug arti
      //todo
    }
  }

  /// Method to unsubscribe from given [topic].
  unsubscribe(final topic) async {
    try {
      mqttClient.unsubscribe(topic);
    } catch (exception) {
      print(
          'MqttConnectionManager.unsubscribe: Error while unsubscribing: $exception');
    }
  }

  /// Method to close mqtt connection.
  disconnect() async {

    FlutterApp.restoreVal=0;
    FlutterApp.syncVal=0;
    FlutterApp.deleteVal=0;
    print("mqttt:::disconnect");
    try {

      mqttClient.disconnect();
    } catch (exception) {
      FlutterApp.checkMqttConnection = false;
      print(
          'Error while disconnecting: $exception');
    }
  }

  /// onDisconnect - The unsolicited disconnect callback
  void onDisconnect() {
    try {
      mqttClient.disconnect();
    } catch (exception) {
      print('MqttConnectionManager.onDisconnect: Error while disconnecting1: $exception');
    }
  }

  /// Method to generate delay as some delays are required by mqtt connection.
  mqttSleep(period) async {
    try {
      await MqttUtilities.asyncSleep(period);
    } catch (exception) {
      print('MqttConnectionManager.mqttSleep: Error in asyncSleep: $exception');
    }
  }
}
