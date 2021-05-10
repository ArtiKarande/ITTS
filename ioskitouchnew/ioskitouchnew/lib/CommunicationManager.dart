/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ioskitouchnew/CheckInternetConnection.dart';
import 'package:ioskitouchnew/databaseHelper.dart';
import 'package:ioskitouchnew/models/tile.dart';
import 'package:ioskitouchnew/themeManager.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:ioskitouchnew/models/state.dart';
import 'package:ioskitouchnew/mqttConnectionManager.dart';
import 'package:ioskitouchnew/localNetworkManager.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';


/// [CommunicationManager] class to manage connections required by the application.
/// There are 2 types of communication in the application.
/// local network communication and over the net connection which is mqtt communication.

class CommunicationManager{

 DatabaseHelper database = DatabaseHelper();

//  ValueNotifier<bool> isStatus = ValueNotifier(true);

  /// Test configurations for the overTheNet communication.
  static const String tPT = 'Dart/Mqtt_client/testtopic'; // test publishing topic
  static const String tST = 'test/hw'; // test subscription topic
  static const String tM = 'Hello from mqtt_client'; // test message

  bool threadRunFlag = false;
  MqttConnectionManager mqttConnection = new MqttConnectionManager(server: 'e-stree.com', port: 1883);  //prev 1888

  /// mqtt client

  final MqttConnectionManager mqttConnection1 = new MqttConnectionManager(server: 'e-stree.com', port: 1883);
  final LocalNetworkManager localNwConnection = new LocalNetworkManager(); // local n/w client

  List<String> topicList = List();
  List<String> deviceList = List();

  SharedPreference pref = new SharedPreference();
  String synchDataBackup;

  /// Making object of the [CommunicationManager] class.
  /// Connection thread is initiated at start only.
  CommunicationManager() {
    connectionThread();
  }

  /// Singleton implementation of the [CommunicationManager].
  /// As only one instance of the [CommunicationManager] is expected throughout the application.
  static CommunicationManager instance;

  static CommunicationManager getInstance() {
    if (instance == null) instance = CommunicationManager();
    return instance;
  }

// final CounterBloc counterBloc = Provider.of<CounterBloc>(instance);

  /// Continues Connection thread.
  /// This thread is kept running in the background till the application is running.
  connectionThread() async {
    threadRunFlag = true;
    while (threadRunFlag) {
      // Check connection type local or over the net
      if (MasterDetail.isCommunicationOverInternet.value) {
        // for overTheNet mqtt connection.
        // check if connection is on, if not initiate connection.
        if (mqttConnection.mqttClient == null) {
          await connect();
          print('CM.cT: mqtt connection complete 1');
        }

        else if (mqttConnection.mqttClient.connectionState != ConnectionState.connected) {
          print('Connection Manager: mqtt Not connected, reconnecting...');
          await connect();
          print('CM.cT: mqtt connection complete 2');
        }

      } else {
        // for local network connection

        // tcp server connection
        // check if TCP server is active, initiate connecting if not active.
        if (!(localNwConnection.tcpServerConnectionStatus.value)) {
          // if not initiate and start TCP server on 54321
          localNwConnection.startTcpServer(); // start tcp server
          // ln.tSIC.addListener(oTCS); // Example usage: to subscribe connection status events
          LocalNetworkManager.tcpServerData.addListener(onDataReceivedTcpServer); // Example usage: to subscribe for data received on tcp server
        } else {
          //print('CM.cT: tcp server active.');
        }
        FlutterApp.isCommunicationOverNet = false;

        // tcp client connection for command/status exchange.
        // check if TCP client is active, initiate connecting if not active.
        // this connection is made with the selected device.
        try {
          if (localNwConnection.tcpClient != null) {
            if (localNwConnection.tcpClient.address != null) {
              // check if tcp client is connected to selected device ip
              if (localNwConnection.tcpClient.address.address !=
                  Building.getInstance().getSelectedDevice().ip) {
                print(
                    'cm.cT: stopping tcp client connection; Expected connection'
                    ' to ${Building.getInstance().getSelectedDevice().ip}; actually connected'
                    ' to ${localNwConnection.tcpClient.address.address}');
                // disconnect if remote ip is different
                localNwConnection.socketCloseHandler(); // stop tcp client
                CommunicationManager.getInstance().reconnect();

              }
            }
          }
        } catch (e) {
          print('CM.cT: Error in connection:\n e: $e');
          localNwConnection.tcpClient = null;
          localNwConnection.tcpClientConnectionStatus.value = false;
        }

        if (!(localNwConnection.tcpClientConnectionStatus.value)) {
          // check if tcp client is connected or not
          // if not connected
          // send udp broadcast for selected room
        //  localNwConnection.sendUdpBroadcast(Building.getInstance().getSelectedRoom());
          // connect tcp client using ip data of selected device
          await localNwConnection.startTcpClient(Building.getInstance().getSelectedDevice().ip);
          // Implement? on device selection change reconnect tcp client to new device

          // subscribe for data received on tcp client
          localNwConnection.tcpClientData.addListener(onDataReceivedTcpClient);
          // await ln.sTC('192.168.43.37'); // Example usage: to make new tcp client or change connection
          // ln.tTC('192.168.43.37', 'Hello world from client');  // Example usage: to send data on tcp client for given IP
          // ln.tCIC.addListener(oTCS); // Example usage: to subscribe connection status events
        } else {
          //print('CM.cT: TCP client connected to ${ln.tc?.address?.address}');
        }
      }
      await mqttConnection.mqttSleep(3);  //5
    }
    disconnect();
  }

  /// method to stop connectionThread.
  stop() => (threadRunFlag = false);

  /// Connection method to handle overTheNet connection.
  /// when connected to mqtt server, handle the subscriptions to the intended topics.
  connect() async {
    var r = await mqttConnection.connect();
    if (r['errorCode'] != 0) {
  //    print('MQTT: Connection failed with result code: $r');
  //    FToast.show("mqtt Connection failed");
       await connect();
    } else {
      await subscribeTopics();

      FlutterApp.checkMqttConnection = true;
      addListenersMqttConnection();
    //  delayedReconnect();     //by arti
    }

    FlutterApp.isCommunicationOverNet = true;
  }

  /// Method to disconnect the local and overTheNet connection.
  disconnect() async {
    await disconnectMqttConnection();  //by arti
    await disconnectLocalNwConnection();
  }

  /// Method to unsubscribe and disconnect from mqtt server.
  disconnectMqttConnection() async {
 //   await unsubscribeAllTopics();       // 14 aug arti
    print('MQTT: Disconnecting client');
    await mqttConnection.disconnect();


 //   FToast.showRed('mqtt disconnected');
    connection();
  }

  /// Method to disconnect form local network.
  disconnectLocalNwConnection() {
    localNwConnection.socketCloseHandler(); // stop tcp client
    localNwConnection.closeTcpServer(); // stop tcp server
  }

  /// Method to add listeners to the events on the mqtt connection.
  addListenersMqttConnection() {
    mqttConnection.mqttClient.updates.listen(onDataReceivedMqtt);
    mqttConnection.mqttClient.onSubscribed = onSubscribedListener;
    mqttConnection.mqttClient.onUnsubscribed = onUnsubscribeListener;
  }

  /// Callback method, invoked when a topic is subscribed to the mqtt connection.
  onSubscribedListener(t) {
    //print('CM.oS: called with t -> $t; <${cl.cl.getSubscriptionsStatus(t)}>');
  }

  /// Callback method, invoked when a topic is unsubscribe from the mqtt connection.
  onUnsubscribeListener(t) {
    //print('CM.oU: called with t -> $t; <${cl.cl.getSubscriptionsStatus(t)}>');
  }

  /// Method to validate and correct subscription of topics on mqtt connection.

  refreshMqttSubscription() async {

    List<String> tempTopicList = List();
    List<String> mTempDList = new List();

    getTempDevicesListFromLocal((List<dynamic> tempDevicesList) {
      if (tempDevicesList.length != 0) {
        for (var temp in tempDevicesList) {
          var t = temp + '/' + 'lastwill';
          print("temp::$t");
          if (!mTempDList.contains(t)) {
            mTempDList.add(t);
          }
        }
      }
    });

    for (var temp in deviceList) {
      if (!mTempDList.contains(temp)) {
        print('CM.rADT: lastwill to unsubscribe: $temp');
        await mqttConnection.unsubscribe(temp);
      }
    }

    // Parse through all devices and make list topics for subscription.
    for (Home h in Building.getInstance().childList) {
      for (Room r in h.childList) {
        for (Devices d in r.childList) {
          var t = d.deviceID + d.password + '/' + 'status';
          if (!tempTopicList.contains(t)) {
            tempTopicList.add(t);
          }
        }
      }
    }
    // Unsubscribe the topic if that topic subscribed previously, and is not in current subscription list.
    for (String t in topicList) {
      if (!tempTopicList.contains(t)) {
    //    print('CM.rADT: Topic to unsubscribe: $t');
        await mqttConnection.unsubscribe(t);
      }
    }

    // Fill topicList with new list.
    topicList.clear();
    topicList.addAll(tempTopicList);
    deviceList.clear();
    deviceList.addAll(mTempDList);

    // Check subscription status of the each topic in topicList.
    // If it is not actively subscribed, try to subscribe for those topics
    for (String topic in topicList) {
      if (mqttConnection?.mqttClient?.getSubscriptionsStatus(topic) !=
          SubscriptionStatus.active) {
  //      print('CM.rADT: Topic to subscribe: $topic');
        await mqttConnection.subscribe(topic);
      }
    }

    for (String deviceName in deviceList) {
      if (mqttConnection?.mqttClient?.getSubscriptionsStatus(deviceName) !=
          SubscriptionStatus.active) {
   //     print('CM.rADT: last will to subscribe: $deviceName');
        await mqttConnection.subscribe(deviceName);
      }
    }
  }

  /// Method to close previous connections and make new connections.
  reconnect() async {
    await disconnect();

  //  localNwConnection.startTcpServer();   // by arti
  //  LocalNetworkManager.tcpServerData.addListener(onDataReceivedTcpServer);

    // new connection will be made by reconnection thread.
  }

  /// Method to handle data received on tcp server.
  ///
  /// After receiving data on tcp server we try to extract ip information for the device.
  /// Store that IP information in the data-set if it is a new information, different than the old one.
  onDataReceivedTcpServer() {
    String receivedData = LocalNetworkManager.tcpServerData.value;
   // print('CM.oTSD: Data received: $receivedData');
    // sample data received : 'SKIT476j4f-192.168.8.103-1212-'
    final List<String> receivedDataParts = receivedData.split('-');
    if (receivedDataParts.length > 1) {
      // Extract device id and password form received data
      String id = receivedDataParts[0];
      String ip = receivedDataParts[1];

      // update database/live variable for received ip update for a device
      for (Home h in Building.getInstance().childList) {
        for (Room r in h.childList) {
          for (Devices d in r.childList) {
            if (d.deviceID == id) {
              print('matching device found for received update;');
              if (d.ip != ip) {
                print('new IP received for device: $id, new ip: $ip, old ip: ${d.ip}');
                d.ip = ip;
                Building.getInstance().updateDB(); // update database
                if (!(MasterDetail.isCommunicationOverInternet.value)) {
                  //    check if connection is local
                  // check if device id matches to current selected device
                  if (d.deviceID == Building.getInstance().getSelectedDevice().deviceID) {
                    // invoke tcp client connection reconnect to new ip
                    localNwConnection.startTcpClient(ip);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  /// Method to handle data received on the local tcp client connection.
  ///
  /// This data is the status information form the device.
  /// We extract this status information from the received data and update ui accordingly.
  /// We have reused the updateStatus method to achieve extraction and UI update.
  Map<String, dynamic> receiveMap = new HashMap();
  Map<String, dynamic> aaa = new HashMap();

  onDataReceivedTcpClient() {
    String receivedData = localNwConnection.tcpClientData.value;
    List<String> val = receivedData.split("-");
    String deviceName = val[0];
    String devicePoints = val[1];
    receiveMap[deviceName] = devicePoints;
  //  print("[onDataReceivedTcpClient] receivedData deviceName : ${deviceName}:devicePoints:${devicePoints}");
  //  print("receivedData onDataReceivedTcpClient:::${receivedData}");
//    print("receivedData receiveMap:::${receiveMap}");
    String mapData = jsonEncode(receiveMap);
  //  pref.putString(SharedKey().RECEIVE_DATA, mapData);    //arti 21 aug


    pref.putString(SharedKey().ONEDEVICE_DATA, '');  // clear data n then fill with points
    pref.putString(SharedKey().ONEDEVICE_DATA, devicePoints);   // used in get data button

    final List<String> receivedDataParts = receivedData.split('-');
    String topic = receivedDataParts[0];
    if (receivedDataParts.length > 1) {
      for (Home h in Building.getInstance().childList) {
        for (Room r in h.childList) {
          for (Devices d in r.childList) {
            if (topic == d.deviceID)
              topic = d.deviceID + d.password + '/' + 'status';
          }
        }
      }
      updateStatus(topic, receivedDataParts[1]);      //arti removed 8 sept
    } else {
      print('CM.oTCD: invalid status received: $receivedData');
    }

 //  database.getHomeListDataFromSelectedItem();  //28 jully commented
  //  FToast.showShort('got response from device');
  }

  onChangeTcpClientConnectionStatus() {
    print('CM.oTCS: called with ln.tCIC -> ${localNwConnection.tcpClientConnectionStatus.value};');
    // implement? handle tcp client connection change events
  }

  /// Method to handle data received on mqtt connection,
  /// We parse each data and handle status change on UI.
  /// {"message":"disconnected","name":"SKIT7d8946"}


  onDataReceivedMqtt(List<MqttReceivedMessage> messageList) {

    for (int i = 0; i < messageList.length; i++) {
      int i = 0;
      final String topic = messageList[i].topic;
      FlutterApp.topic = topic;

      final MqttPublishMessage r = messageList[i].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(r.payload.message);
      print('---mqtt---');
      print(" payload:::$payload");
      print(" topic:::$topic");

      FlutterApp.isSignalOn = true;
      FlutterApp.checkMqttConnection = true;

      /// backup topic functionality implemented here
      if (topic.contains("kitouchplus_app_to_server_ack")) {      //backup code

        FlutterApp.isYesTap = false;
        FlutterApp.syncVal=3;  //by arti
        if(payload.contains('sync_success":1')){

          FToast.showGreen("Data backup successfully");
    //      CommunicationManager.getInstance().mqttConnection.disconnect();

        }

        else{
          FToast.showRed("Backup fail! please try again ");
        }
      }

      ///add home
      else if(topic.contains("global_in_ack/kitouchplus_add_home_ack")){     // backup for 1 home

        if(payload.contains('Home added Successfully')){

          pref.putString(SharedKey().homeNameForBackup, '');
          pref.putString(SharedKey().homeBackupKey, '0');
          pref.putString(SharedKey().OneHomeAutobackup, '');
          FToast.showGreen('Home added successfully!');

        }else if(payload.contains('Home with same name already present.')){
          FToast.showRed('Home with same name already present.');
          pref.putString(SharedKey().homeNameForBackup, '');
          pref.putString(SharedKey().homeBackupKey, '0');
          pref.putString(SharedKey().OneHomeAutobackup, '');


        }
        else{
          FToast.showRed("Home backup fail");
        }
      }

      ///add room
      else if(topic.contains("global_in_ack/kitouchplus_add_room_ack")){     // backup for 1 room

        if(payload.contains('Room added Successfully')){

          pref.putString(SharedKey().roomNameForBackup, '');
          pref.putString(SharedKey().roomBackupKey, '0');
          pref.putString(SharedKey().OneRoomAutobackup, '');
          FToast.showGreen('Room added successfully!');

        }else if(payload.contains('Room with same name already present')){
          FToast.showRed('Room with same name already present');
          pref.putString(SharedKey().roomNameForBackup, '');
          pref.putString(SharedKey().roomBackupKey, '0');
          pref.putString(SharedKey().OneRoomAutobackup, '');
        }

        else{
          FToast.showRed("Room backup fail");
        }
      }

      ///add device
      else if(topic.contains("global_in_ack/kitouchplus_configure_device_ack")){     // backup for 1 device

        if(payload.contains('"success":1}')){

          pref.putString(SharedKey().ONEDEVICE_AUTOBACKUP, '');
          pref.putString(SharedKey().deviceBackupKey, 'keyBackup');
          pref.putString(SharedKey().deviceNameForBackup, '');
          FToast.showGreen('device backup success');

        }else{

          FToast.showRed("Device backup fail");

        }
      }

      /// to delete device -> mqtt response handling method
      else if(topic.contains('global_in_ack/kitouchplus_delete_device_ack')){         //delete

        if(payload.contains('"success":1}')){

          if(FlutterApp.indexVal == -1){      // -1 bcoz if i take 0 then it will delete 0th value from db

          }else{

            Building.getInstance().getSelectedRoom().childList.removeAt(FlutterApp.indexVal);
            Building.getInstance().getSelectedRoom().indexChildList = 0;
            Building.getInstance().updateDB();

            FToast.showGreen("Device deleted successfully! ");

          }
          FlutterApp.indexVal = -1;

        }else{

          FToast.showRed("Device not deleted, please try again!");

        //  print("ethe else");
          FlutterApp.indexVal = -1;
        }
      }

      /// to delete room -> mqtt response handling method
      else if(topic.contains('global_in_ack/kitouchplus_delete_room_ack')){         //delete 1 room only

        if(payload.contains('"success":1}')){

          if(FlutterApp.indexVal == -1){      // -1 bcoz if i take 0 then it will delete 0th value from db

          }else{

            Building.getInstance().getSelectedHome().childList.removeAt(FlutterApp.indexVal);
            Building.getInstance().getSelectedHome().indexChildList = 0;
            Building.getInstance().updateDB();

            FToast.showGreen("Room deleted successfully! ");

          }
          FlutterApp.indexVal = -1;

        }else{

          FToast.showRed("Room delete fail!");

          //  print("ethe else");
          FlutterApp.indexVal = -1;
        }
      }

      /// to delete home -> mqtt response handling method
      else if(topic.contains('global_in_ack/kitouchplus_delete_home_ack')){         //delete 1 room only

        if(payload.contains('"success":1}')){

          if(FlutterApp.indexVal == -1){      // -1 bcoz if i take 0 then it will delete 0th value from db

          }else{

            Building.getInstance().childList.removeAt(FlutterApp.indexVal);
            Building.getInstance().indexChildList = 0;
            Building.getInstance().updateDB();

            FToast.showGreen("Home deleted successfully! ");

          }
          FlutterApp.indexVal = -1;

        }else{

          FToast.showRed("Home delete fails!");
          FlutterApp.indexVal = -1;
        }
      }

      //---------------------//

      else if (topic.contains("kitouchplus_server_to_app_ack")) {         //restore
        FlutterApp.restoreVal=4;

        if(payload != null || payload != "" ) {
          getServerData(payload);

          FToast.showGreen("Restored data successfully");      //by arti

    //      CommunicationManager.getInstance().mqttConnection.disconnect();

        }else{
          FToast.show("There is no data");
        }
        //  updateStatus(topic, payload);
      }

      /// rename response for - Home
      else if(topic.contains("global_in_ack/kitouchplus_rename_home_ack")){

        if(payload.contains('"success":1}')){

          if(FlutterApp.indexVal == -1){

          }else{

            Building.getInstance().getHomeAtIndex(FlutterApp.indexVal).name = FlutterApp.renameDeviceVal;
            Building.getInstance().updateDB();

            FlutterApp.homeName = FlutterApp.renameDeviceVal;
            FToast.showGreen("Rename Successful! ");

          }
          FlutterApp.indexVal = -1;
          FlutterApp.renameDeviceVal = '';

        }else{

          FToast.showRed("Rename failed, please try again!");
          FlutterApp.indexVal = -1;
        }
      }

      /// rename response for - Room
      else if(topic.contains("global_in_ack/kitouchplus_rename_room_ack")){     //rename function response

        if(payload.contains('"success":1}')){

          if(FlutterApp.indexVal == -1){      // -1 bcoz if i take 0 then it will delete 0th value from db

          }else{

            Building.getInstance().getRoomAtIndex(FlutterApp.indexVal).name = FlutterApp.renameDeviceVal; // reuse this param
            Building.getInstance().updateDB();

            FlutterApp.roomName = FlutterApp.renameDeviceVal;

            FToast.showGreen("Room Rename Successfully! ");

          }
          FlutterApp.indexVal = -1;
          FlutterApp.renameDeviceVal = '';

        }else{

          FToast.showRed("Rename failed, please try again!");
          FlutterApp.indexVal = -1;
        }
      }

      /// rename response for - Devices
      else if(topic.contains("global_in_ack/kitouchplus_rename_device_ack")){     //rename function response

          if(payload.contains('"success":1}')){

            if(FlutterApp.indexVal == -1){      // -1 bcoz if i take 0 then it will delete 0th value from db

            }else{

              Building.getInstance().getDeviceAtIndex(FlutterApp.indexVal).name = FlutterApp.renameDeviceVal;
              Building.getInstance().updateDB();

              FlutterApp.deviceName = FlutterApp.renameDeviceVal;
              FToast.showGreen("Device Rename Successfully! ");

            }
            FlutterApp.indexVal = -1;
            FlutterApp.renameDeviceVal = '';

          }else{

            FToast.showRed("Device Rename failed, please try again!");
            FlutterApp.indexVal = -1;
          }
      }

      else if(topic.contains("global_in_ack/kitouchplus_rename_switch")){     //rename lights/fans not master

        if(payload.contains('"success":1}')){

          if(FlutterApp.indexVal == -1){      // -1 bcoz if i take 0 then it will delete 0th value from db

          }else{

            Building.getInstance().getControlPointAtIndex(FlutterApp.indexVal).name = FlutterApp.renameDeviceVal;

            Building.getInstance().updateDB();

            FToast.showGreen("Rename Successfully! ");

          }
          FlutterApp.indexVal = -1;
          FlutterApp.renameDeviceVal = '';

        }else{

          FToast.showRed("Control Points Rename failed, please take backup before rename points!");
          FlutterApp.indexVal = -1;
        }
      }



      /// icons - Home
      else if(topic.contains("global_in_ack/kitouchplus_update_home_icon_ack")){

        if(payload.contains('"success":1}')){
          FToast.showGreen("Icon updated! ");

        }else{

          FToast.showRed("Icon update failed, please try again!");
          FlutterApp.indexVal = -1;
          FlutterApp.indexValIcons = -1;
        }
      }

      /// icons - Room
      else if(topic.contains("global_in_ack/kitouchplus_update_room_icon_ack")){

        if(payload.contains('"success":1}')){
          FToast.showGreen("Icon updated! ");
        }else{

          FToast.showRed("Icon update failed, please try again!");
          FlutterApp.indexVal = -1;
        }
      }

      /// icons - Devices
      else if(topic.contains("global_in_ack/kitouchplus_update_device_icon_ack")){

        if(payload.contains('"success":1}')){
          FToast.showGreen("Icon updated! ");
        }else{

          FToast.showRed("Icon update failed, please try again!");
          FlutterApp.indexVal = -1;
        }
      }

      /// icons - Control points
      else if(topic.contains("global_in_ack/kitouchplus_update_switch_icon_ack")){

        if(payload.contains('"success":1}')){
          FToast.showGreen("Icon updated! ");
        }else{

          FToast.showRed("Icon update failed, please try again!");
          FlutterApp.indexVal = -1;
        }
      }



      else if(payload.startsWith("{")){
        updateLocalStatus(topic, payload);      // deviceid and device status (connected/disconnected) is stored here
      }

      else if(payload.isNotEmpty){
        String deviceName = topic.substring(0, 10);
        String devicePoints = payload;
        receiveMap[deviceName] = devicePoints;

        String mapData = jsonEncode(receiveMap);
        print("onDataReceivedMqtt RECEIVE_DATA receiveMap:::$mapData");

        if(devicePoints.isNotEmpty){
          pref.putString(SharedKey().RECEIVE_DATA, mapData);
          pref.putString(SharedKey().DEVICE_STRING, payload);
          FlutterApp.deviceString = payload;
          updateStatus(topic, payload);

          // update db here try later

        }else{
          FToast.showRed('points empty...');
        }
      }

      else if (topic.contains("lastwill")) {

        updateLocalStatus(topic, payload);      // uncomment 27 aug evening

        if(payload.contains("disconnected")){

          FlutterApp.isSignalOn = false;
          MasterDetail.isStatus.value = false;

        }else{

        }
      }

      else{
   //     print('mqtt else..got empty..');
      }



    }
  }

  /// Method to run reconnect procedure to after some delay.
  delayedReconnect() async {
    print("in delay reconnect:::");
    await mqttConnection.mqttSleep(600); //600
    await reconnect();

   // CommunicationManager.getInstance().originalConnection(); //added by arti which will help for over the net
    CommunicationManager.getInstance().connection(); //added by arti which will help for over the net
  }

  /// Method to subscribe all device topics,
  /// Every device is parsed and new topicList is generated for subscription.
  /// All topics found in above steps are subscribed on the mqtt connection.

  subscribeTopics() async {
    topicList.clear();
    deviceList.clear();

    getTempDevicesListFromLocal((List<dynamic> tempDevicesList) {
      for (var temp in tempDevicesList) {
        var t = temp + '/' + 'lastwill';
     //   print("temp::$t");
        if (!deviceList.contains(t)) {
          deviceList.add(t);
        }
      }
    });

    for (Home home in Building.getInstance().childList) {
      for (Room room in home.childList) {
        for (Devices device in room.childList) {
          var t = device.deviceID + device.password + '/' + 'status';
          if (!topicList.contains(t)) {
            topicList.add(t);
          }
        }
      }
    }

    print('Topic to subscribe: $topicList');
    print('lastwill to lenght subscribes: ${deviceList.length}');
    print('lastwill to subscribe: $deviceList');
    for (String t in topicList) await mqttConnection.subscribe(t);
    for (String temp in deviceList) await mqttConnection.subscribe(temp);
  }

  // Method to unsubscribe all topics from topicList.
  unsubscribeAllTopics() async {
    print('Topic to unsubscribe: $topicList');
    print('lastwill to unsubscribe: $deviceList');

    if (mqttConnection != null) {
      if (mqttConnection.mqttClient != null) {
        for (String t in topicList) {
          await mqttConnection.unsubscribe(t);
          await mqttConnection.mqttSleep(1);
        }
        for (String temp in deviceList) {
          await mqttConnection.unsubscribe(temp);
          await mqttConnection.mqttSleep(1);
        }
      }
    }
  }

  /// Method to send command on the communication interface.
  /// It determines which type of command needs to be sent,
  /// Forms the command accordingly and sends it on communication channel.
  Future<bool> sendCommand(List<int> indexList) async {
    bool status = false;
    // print('connectionManager: sendCommand: using index list $iL');
    switch (indexList.length) {
      case 3:
        print('in case 3:');
        // sending scene set command from [DeviceView].
        Home h = Building.getInstance().childList[indexList[0]];
        Room r = h.childList[indexList[1]];
        ControlPoint c = r.sceneList[indexList[2]];

        status = true; // assuming status is success
        for (Devices d in r.childList) {
          // sending mood command to every device in this room.
          String command = 'moods' + '-' + c.idChar;
          bool tempStatus = await sendCommandOnNetwork(command, d);
          // if current scene command to device is success
          // if previous status is success then collective status will be success
          // else if previous status is failed then overall is failed

          // now if current scene command to device is failed
          // then overall status is failed.
          if (tempStatus == false) status = false;
        }
        break;
      case 7:
        print('in case 7:');
        // sending scene set command from [ControlPointView].
        Home h = Building.getInstance().childList[indexList[0]];
        Room r = h.childList[indexList[1]];
        Devices d = r.childList[indexList[2]];
        ControlPoint c = d.sceneList[indexList[3]];

        Map<String, dynamic> map = new HashMap();
        map["mood_no"] = int.parse(c.idChar);

        String mMap = jsonEncode(map);

        print('moodcommand case7::');
        print(mMap);


        String command = 'moods' + '-' + c.idChar;
        status = await sendCommandOnNetwork(mMap, d);
        break;
      case 8:
        print('in case 8:');



        //{"mood_set":1}

        // sending command to save current status as scene.
        Home h = Building.getInstance().childList[indexList[0]];
        Room r = h.childList[indexList[1]];
        Devices d = r.childList[indexList[2]];
        ControlPoint c = d.sceneList[indexList[3]];

        Map<String, dynamic> map = new HashMap();
        map["mood_set"] = int.parse(c.idChar);

        String mMap = jsonEncode(map);

        print('moodcommand::');
        print(mMap);

        String command = 'moodc' + '-' + c.idChar + '-';
        for (ControlPoint c1 in d.childList)
          command += c1.idChar +
              ':' +
              c1.type +
              ':' +
              (c1.flagOnOff ? '1' : '0') +
              ((c1.listStates.length > 1)
                  ? (':' + c1.listStates[c1.stateIndex].idChar + ';')
                  : ';');
        status = await sendCommandOnNetwork(mMap, d);
        break;



      case 4:
        // sending command to chane on/off state of the [ControlPoint].
        Home h = Building.getInstance().childList[indexList[0]];
        Room r = h.childList[indexList[1]];
        Devices d = r.childList[indexList[2]];
        ControlPoint c = d.childList[indexList[3]];
        String command = c.idChar +
            ':' +
            c.type +
            ':' +
            (c.flagOnOff ? '0' : '1') +
            ((c.listStates.length > 1)
                ? (':' + c.listStates[c.stateIndex].idChar + ';')
                : ';');
        status = await sendCommandOnNetwork(command, d);
        break;
      case 5:
        print('in case 5:');
        // sending command to chane other state of the [ControlPoint].
        Home h = Building.getInstance().childList[indexList[0]];
        Room r = h.childList[indexList[1]];
        Devices d = r.childList[indexList[2]];
        ControlPoint c = d.childList[indexList[3]];
        StateS s = c.listStates[indexList[4]];
        String command = c.idChar +
            ':' +
            c.type +
            ':' +
            (c.flagOnOff ? '1' : '0') +
            ':' +
            s.idChar +
            ';';
        status = await sendCommandOnNetwork(command, d);
        break;

      case 9:

     //   print('got dummy command case9..');
        print(indexList);
        Home h = Building.getInstance().childList[indexList[0]];
        Room r = h.childList[indexList[1]];
        Devices d = r.childList[indexList[2]];
        status = await sendCommandOnNetwork('M:L:1;', d);
        status = await sendCommandOnNetwork('M:L:0;', d);

        break;

      case 6:
      // sending Dummy command
        print('got dummy command case6...');
        print(indexList);
        Home h = Building.getInstance().childList[indexList[0]];
        Room r = h.childList[indexList[1]];
        Devices d = r.childList[indexList[2]];
        status = await sendCommandOnNetwork('ABCDEF123456', d);
        break;

      default:
        print('cm.sC: Invalid index list length ${indexList.length}');
        break;
    }

    return status;
  }

  /// Method which actually sends command data on connection.

  /// arti - command part
  Future<bool> sendCommandOnNetwork(String command, Devices device) async {
    bool status = false;

    // check connection type local or over the net
    if (MasterDetail.isCommunicationOverInternet.value) {

      print('over the net command:: $command');
      // send command in mqtt connection
      // topic to publish
      String topic = device.deviceID + device.password;

      if (!(mqttConnection?.mqttClient == null)) {
        await mqttConnection.publish(topic + '/command', command);
        try {
          if (mqttConnection.mqttClient.getSubscriptionsStatus(topic + '/status') ==
              SubscriptionStatus.active) status = true;
        } catch (e) {
          print('cm.sc: error in getSubscriptionsStatus: $e');
        }
      }
    } else {
      // send command in local connection [ when over the net is off ]
                                                                                         //on/off send commands

      command = '-' + device.deviceID + '-' + command + '-\n'; // form command
      // Command send mechanism for local network
      localNwConnection.sendDataOnTcpClient(device.ip, command);
      if (localNwConnection.tcpClientConnectionStatus.value) status = true;
      print('CM::Sending command in local network: command: $command');
    }
    return status;
  }

  /// Method to send configuration data on local network.
  Future<bool> sendConfigOnLocalNetwork(String command, Devices device) async {
    bool status = false;

    command += '\n'; // forming command

    // Command send mechanism for local network.
    localNwConnection.sendDataOnTcpClient(device.ip, command);
    if (localNwConnection.tcpClientConnectionStatus.value) status = true;
    print('----command------: $command');

    return status;
  }

  /// Method to update status,
  /// this method extracts the status information, stores it, and updates UI accordingly.
  updateStatus(topic, message) {


    final String tag = 'connectionManager: updateStatus: ';
    bool dataChangeFlag = false;

    /// We parse every device to find match for the topic.
    /// When we find matching topic we update the status of that particular device.
    for (Home home in Building.getInstance().childList) {
      for (Room room in home.childList) {
        for (Devices device in room.childList) {
          if (topic == (device.deviceID + device.password + '/' + 'status')) {
            /// Match found for the device.
            if (message.length > 3) {

              // check if received data is not blank
              // Hiding all the previous views.
              for (ControlPoint c in device.childList) {
                c.isVisible = false;
              }
            }
            else{
            //  FToast.showRed('no match found');
            }
            // Extracting the status information from the received message.
            // Mood status and normal status are separated by '@' char.
            final List<String> sPP = message.toString().split('@');

            // check if status is available in the incoming message.
            if (sPP.length > 0) {
              final String deviceStatus = sPP[0];
              if (deviceStatus.length > 3) {
                // check if valid data is available in the status.
                // extract the information from the status and update the control point states accordingly.
                for (String deviceStatusParts in deviceStatus.split(';')) {
                  final List<String> controlPointStatusParts =
                      deviceStatusParts.split(':');
                  if (controlPointStatusParts.length > 2) {
                    bool flagStatusMatchFound = false;
                    bool flagOnOff = (controlPointStatusParts[2] == '1');

                    for (ControlPoint controlPoint in device.childList) {

                      if ((controlPoint.type == controlPointStatusParts[1]) &&
                          (controlPoint.idChar == controlPointStatusParts[0])) {
                        if (controlPoint.flagOnOff != flagOnOff) {
                          controlPoint.flagOnOff = flagOnOff;
                          dataChangeFlag = true;
                        }
                        if (controlPointStatusParts.length > 3) {
                          for (int i = 0;
                              i < controlPoint.listStates.length;
                              i++) {
                            if (controlPoint.listStates[i].idChar
                                    .toLowerCase() ==
                                controlPointStatusParts[3].toLowerCase()) {
                              if (controlPoint.stateIndex != i) {
                                controlPoint.stateIndex = i;
                                dataChangeFlag = true;
                              }
                            }
                          }
                        }
                        controlPoint.isVisible = true;
                        flagStatusMatchFound = true;
                      }
                    }
                    // create new control point if the match not found.
                    if (flagStatusMatchFound == false) {
                      print(tag + 'No match found for status $deviceStatusParts; creating new element');
                      ControlPoint controlPoint = ControlPoint(
                          controlPointStatusParts[1],
                          controlPointStatusParts[0],
                          flagOnOff);

                      if (controlPointStatusParts.length > 3) {
                        for (int i = 0;
                            i < controlPoint.listStates.length;
                            i++) {
                          if (controlPoint.listStates[i].idChar.toLowerCase() ==
                              controlPointStatusParts[3].toLowerCase()) {
                            if (controlPoint.stateIndex != i) {
                              controlPoint.stateIndex = i;
                              dataChangeFlag = true;
                            }
                          }
                        }
                      }
                      device.childList.add(controlPoint);
                      dataChangeFlag = true;

                      Building.getInstance().updateDB();  // point isssue solved here

                    }

                  }
                }
              }
              // updating scene status.

              if (sPP.length > 1) {
                final String dSM = sPP[1];
                for (String dSPE in dSM.split(';')) {
                  final List<String> dSPEP = dSPE.split(':');
                  if (dSPEP.length > 1) {
                    bool fOF = (dSPEP[1] == '1');
                    for (ControlPoint c in device.sceneList) {
                      if (c.idChar == dSPEP[0]) {
                        if (c.flagOnOff != fOF) {
                          c.flagOnOff = fOF;
                          dataChangeFlag = true;
                        }
                      }
                    }
                  }
                }
              } else{
                //       print(tag + 'Wrong status format, mood status not present');
              }

            } else{
              //    print(tag + 'Wrong status format, not enough status parts');
            }
          }

          // sorting control points.
          if (dataChangeFlag) device.sortChild();  // temperary hide arti 17 aug
        }
      }
    }
    // notifying the ui that needs to be updated as new status is received.
    if (dataChangeFlag)
      Building.getInstance().dataChangeNotifier.value = !Building.getInstance().dataChangeNotifier.value;
  }

  Future<bool> synchData(topic, data) async {
    bool status = false;
//    if (MasterDetail.isCommunicationOverInternet.value) {
//      if (!(mqttConnection?.mqttClient == null)) {
    await mqttConnection.publish(topic, data);
    //   }
//    }else{
//      FToast.show("local network");
//    }
    return status;
  }

  // for overTheNet mqtt connection.
  // check if connection is on, if not initiate connection.
  connection() async {

    print('port starts.... 1883');
    mqttConnection = MqttConnectionManager(server: 'e-stree.com', port: 1883); //148.66.133.252

    print(mqttConnection.mqttClient);

    if (MasterDetail.isCommunicationOverInternet.value) {

      if (mqttConnection.mqttClient == null) {
        await connect();
      }
      else if (mqttConnection.mqttClient.connectionState != ConnectionState.connected) {
        await connect();
        FlutterApp.checkMqttConnection = true;
      }
    }
  }

  ///this connection is removed bcoz changing port is tough in app every time
  ///so this function is not useful in app for now
  originalConnection() async {

    print('port starts.... 1888');
    mqttConnection = new MqttConnectionManager(
        server: 'kitouch.mn.skromanswitches.com', port: 1888);
    if (MasterDetail.isCommunicationOverInternet.value) {
      // for overTheNet mqtt connection.
      // check if connection is on, if not initiate connection.
      if (mqttConnection.mqttClient == null) {
        await connect();
        print('CM.cT: mqtt connection complete 5');
        // await connect();
      }

      else if (mqttConnection.mqttClient.connectionState !=
          ConnectionState.connected) {
        print('Connection Manager: mqtt Not connected, reconnecting...');
        await connect();
        print('CM.cT: mqtt connection complete 6');
        FlutterApp.checkMqttConnection = true;
      //  FToast.show("O Connected");
      }


    }
  }

  syncSubscribe(topic) async {
    // Future.delayed(const Duration(milliseconds: 5000), () async {
    if (mqttConnection != null) {
      await mqttConnection.subscribe(topic);
    } else {

      FToast.show("error in connection");
    }
    // });
  }

  publishSync(topic, String message) async {
    if (mqttConnection != null) {
      await mqttConnection.publish(topic, message);
    } else {
      FToast.show("error in connection");
    }
  }

  getTempDevicesListFromLocal(Function completionHandler) {
    List<dynamic> mTempList = new List();
    pref.getString(SharedKey().TEMP_DEVICE_LIST).then((val) {
      if (val != null) {
        mTempList = jsonDecode(val);
        print("getTempDevicesListFromLocal::$val");
        completionHandler(mTempList);
      }
    });
  }

  void updateLocalStatus(String topic, String payload) {

    print('inside updateLocalStatus');
    //{"deviceId":"SKIT5SkF9I","status":"disconnected"}
    Map devicesList = new HashMap();
    Map valueMap = json.decode(payload);
    print("valueMap payload:::$valueMap");
    pref.getString(SharedKey().DEVICES_LIST).then((val) {
      if (val != null) {
        devicesList = jsonDecode(val);
        print("updateLocalStatus::$val");
        // for (String dID in devicesList) {
        if (devicesList.containsKey(valueMap["deviceId"])) {

          FlutterApp.deviceStatus=valueMap["status"];  //arti changes 13 jully removed commment

          String deviceName = valueMap["deviceId"];
          devicesList["$deviceName"] = valueMap["status"];

          print("devicesList:::$devicesList");
          String encodeDeviceList = jsonEncode(devicesList);
          pref.putString(SharedKey().DEVICES_LIST, encodeDeviceList);
        }
        // }
      }
    });
  }

  void getServerData(String payload) {
    List<Home> syncData = new List();
    List<dynamic> mHomes = new List();
    List<dynamic> mRooms = new List();
    List<dynamic> mDevices = new List();
    List<dynamic> mControlPoints = new List();
    List<dynamic> mStates = new List();
    Map<String, dynamic> map = jsonDecode(payload);
    mHomes = map["restore_data"]["syncData"];
    String mapData;


    for (int i = 0; i < mHomes.length; i++) {
      Home home = new Home("", "");
      home.iD = mHomes[i]["home_id"];
      home.name = mHomes[i]["home_name"];
      home.iconIndex = mHomes[i]["iconIndex"];
      mRooms = mHomes[i]["rooms"];
      List<Room> mRoomList = new List();
      for (int j = 0; j < mRooms.length; j++) {
        Room room = new Room("", "");
        room.name = mRooms[j]["room_name"];
        room.iconIndex = mRooms[j]["iconIndex"];
        room.iD = mRooms[j]["room_id"];
        mDevices = mRooms[j]["switchboxes"];
        List<Devices> mDeviceList = new List();
        for (int k = 0; k < mDevices.length; k++) {
          Devices device = new Devices("", "", "");
          device.name = mDevices[k]["name"];
          device.iconIndex = mDevices[k]["iconIndex"];
          device.ip = mDevices[k]["ip"];
          device.deviceID = mDevices[k]["switchbox_id"];
          device.ssidPassword = mDevices[k]["ssid"];
          device.password = mDevices[k]["password"];
          mControlPoints = mDevices[k]["points"];

          //arti
           String deviceName = mDevices[k]["name"];
          String devicePoints = mDevices[k]["switches"];
          receiveMap[deviceName] = devicePoints;
          mapData = jsonEncode(receiveMap);
          pref.putString(SharedKey().RECEIVE_DATA, mapData);

          List<ControlPoint> mControlPointList = new List();
          // if(mControlPointList.length==0){
          if (mControlPoints != null) {
            for (int l = 0; l < mControlPoints.length; l++) {
              ControlPoint controlPoint = new ControlPoint("", "");
              controlPoint.name = mControlPoints[l]["name"];
              controlPoint.type = mControlPoints[l]["type"];
              controlPoint.isVisible = mControlPoints[l]["isVisible"];
              controlPoint.idChar = mControlPoints[l]["idChar"];
              mStates = mControlPoints[l]["states"];
              List<StateS> listStates = new List();
              if (mStates != null) {
                for (int m = 0; m < mStates.length; m++) {
                  StateS state = new StateS();
                  state.idChar = mStates[m]["idChar"];
                  state.name =  mStates[m]["name"];
                  state.iconIndex =  mStates[m]["iconIndex"];
                  listStates.add(state);
                }
                controlPoint.listStates = listStates;
              }
              mControlPointList.add(controlPoint);
            }
            device.childList = mControlPointList;
            mDeviceList.add(device);
            //}
          }
        }
        room.childList = mDeviceList;
        mRoomList.add(room);
      }
      home.childList = mRoomList;
      syncData.add(home);
    }
    Building.getInstance().childList = syncData;
    Building.getInstance().updateDB();
//    print("Restored data successfully.");
  }
}
