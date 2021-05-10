/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:vtrochargingstation/CommunicationManager.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'common/FToast.dart';
import 'common/sharedPreferece/SharedPreferneces.dart';

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
  MqttClient mqttClient;

  CommunicationManager _manager;

  /// Makes Object of [MqttConnectionManager] with values provided by invoker.
  MqttConnectionManager(
      {this.server = testServer,
      this.port = testPort,
      this.clientIdentifier = testClientIdentifier});

  /// Makes new Mqtt connection using available parameters.
  Future<dynamic> connect({username, password}) async {

    int errorCode = -1; // error code
    String errorMessage = 'Unknown Error';

    // New mqtt connection.
    mqttClient = new MqttClient.withPort(this.server, this.clientIdentifier, this.port);

    // Disabling logging of communication.
    mqttClient.logging(false);

    // Setting keep alive period.
    mqttClient.keepAlivePeriod = 30;

    // Setting callback function when connection drops.
    mqttClient.onDisconnected = onDisconnect;

    // generating and setting connectionMessage using properties available.
    final MqttConnectMessage connectionMessage = new MqttConnectMessage()
        // need to generate unique client identifier for mqtt communication.
        .withClientIdentifier(new DateTime.now().millisecondsSinceEpoch.toString())
        .keepAliveFor(30) // Must agree with the keep alive set above or not set.
        .withWillQos(MqttQos.atLeastOnce);
    mqttClient.connectionMessage = connectionMessage;

    // Connecting to mqtt server.
    // Disconnect if there is problem in connection.
    try {
      if (username != null && password != null){
        await mqttClient.connect(username, password);
      }

      else{
        await mqttClient.connect();
      }

    } catch (Exception) {
      print('connect: Exception in connect ' + Exception.toString());
      mqttClient.disconnect();
   //   FToast.show(Exception.toString());
    }

    /// check the connection state and set the error code accordingly.
    if (mqttClient.connectionState == ConnectionState.connected) {
      errorCode = 0;
      errorMessage = 'Connected: Connection Success.';

      print('MQTT: connected Mosquitto $errorMessage');

    } else {
      errorCode = -2;
      errorMessage = 'Disconnected: Connection Faild; State: ${mqttClient.connectionState}';
      print('MQTT: ERROR Mosquitto $errorMessage');
      mqttClient.disconnect();
    }
    return {'errorCode': errorCode, 'errorMsg': errorMessage};
  }

  /// mqtt publish
  publish(topic, message) async {
    final MqttClientPayloadBuilder builder = new MqttClientPayloadBuilder();
    builder.addString(message);
    try {
      mqttClient.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
    } catch (exception) {
      FToast.show("Error while publishing ");

      print('publish: Error while publishing : $exception');
    }
  }

  /// mqtt subscribe
  subscribe(final topic) async {
    try {
      mqttClient.subscribe(topic, MqttQos.atLeastOnce);
    } catch (exception) {
      //FToast.show('mqtt error');
      print('Error while subscribing: $exception');
      connect();
      //todo
    }
  }

  /// mqtt unsubscribe
  unsubscribe(final topic) async {
    try {
      mqttClient.unsubscribe(topic);
    } catch (exception) {
      print('MqttConnectionManager.unsubscribe: Error while unsubscribing: $exception');
    }
  }

  disconnect() async {
    try {
      mqttClient.disconnect();
    } catch (exception) {
      print('Error while disconnecting: $exception');
    }
  }

  void onDisconnect() {
    try {
      mqttClient.disconnect();
    } catch (exception) {
      print('MqttConnectionManager.onDisconnect: Error while disconnecting1: $exception');
    }
  }

  mqttSleep(period) async {
    try {
      await MqttUtilities.asyncSleep(period);
    } catch (exception) {
      print('MqttConnectionManager.mqttSleep: Error in asyncSleep: $exception');
    }
  }

}
