/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */
import 'dart:async';
import 'dart:io';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:flutter/material.dart';

import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/room.dart';

/// [LocalNetworkManager] is a class with components required for local network communication.
/// In local network communication is happened in following steps.
///   - Device discovery.
///     - Mobile App
///       - For device discovery tcp server is created on port 54321.
///       - udp broadcast is sent for a device under interest.
///     - Physical device
///       - Device replies to udp broadcast on tcp port 54321.
///       - This reply has ip address of the device.
///   - Actual Communication
///     - using above IP address connection is made with device on port 51212.
///     - on this connection command/status are communicated.

class LocalNetworkManager {

  /// TCP server socket required to receive IP updates from device.
  ServerSocket tcpServerSocket;
  static List<TcpClient> cs = [];

  /// Mechanism to notify that data received on tcp Server.
  static ValueNotifier<String> tcpServerData = ValueNotifier('');

  /// Mechanism to notify that connection status of tcp Server.
  ValueNotifier<bool> tcpServerConnectionStatus = ValueNotifier(false);
  SharedPreference pref = new SharedPreference();

  /// method to start tcp Server on 54321
  void startTcpServer() async {
    // Close previous tcp server connection.
    if (tcpServerSocket != null) {  //if tcp null nasel tr
      print('------------tcp server already running, disconnecting-----------');
      closeTcpServer();
    }

    /// Starting new tcp server.
    print('-------creating new tcp server----------');
    tcpServerSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 54321);

    /// Adding listener to see data received on tcp server.
    tcpServerData.addListener(dataReceivedListener);
    tcpServerConnectionStatus.value = true;

    /// When new connection is received on tcp server
    /// Setting callback method to handle those connections.
    tcpServerSocket.listen((c) => handleIncomingConnection(c));

    // No need to have tcp server in different thread that should work until stop is called.
  }

  /// Callback method to handle data received on tcp server.
  void dataReceivedListener() {
    print('LN.sL: data received on server: ${tcpServerData.value}');
    tcpServerConnectionStatus.value = true;
  }

  /// Method to handle incoming connection on the tcp server.
  void handleIncomingConnection(Socket c){
    print('-------- Connection from--- ${c.remoteAddress.address}:${c.remotePort}');
    cs.add(TcpClient(c));
    tcpServerConnectionStatus.value = true;
  }

  /// Method to stop tcp Server on 54321
  void closeTcpServer() {
    if (tcpServerSocket != null) {
      tcpServerData.removeListener(dataReceivedListener);
      for (TcpClient c in cs) {
        c.doneHandler();
      }
      tcpServerSocket.close();
    }
    tcpServerConnectionStatus.value = false;
  }

  /* ******* local network tcp client to send/receive commands/status *******/
  Socket tcpClient;
  ValueNotifier<String> tcpClientData = ValueNotifier('');
  ValueNotifier<bool> tcpClientConnectionStatus = ValueNotifier(false);

  /// Method to start tcp client for local network communication.
  startTcpClient(String host, {port=51212}) async {      //51212 prev maazsathi changes
    print('LN.sTC: start');
    //pref.putBool(SharedKey().IS_COMMUNICATION_OVER_INTERNET, false);

    // mechanism to change connection of tcp client to another IP
    // Closing previous connection.
    if (tcpClient != null) {
      print('--------start tcp client-------');
      try {
        await tcpClient.close();
      } catch (e) {
        print('--------- exception in closing previous socket--------- $e');
      }
    }

    print('LN.sTC: creating tcp client socket');

    // Making new connection
    tcpClient = await Socket.connect(host, port, timeout: Duration(seconds: 1)).catchError((e) {
      print("LN.sTC: Unable to connect: $e");
      tcpClientConnectionStatus.value = false;
    });

    // Check the new connection and if success, put socket in listing.
    if (tcpClient != null) {
      tcpClient.listen(dataHandler, onError: errorHandler, onDone: socketCloseHandler, cancelOnError: true);
      tcpClient.setOption(SocketOption.tcpNoDelay, true);
      tcpClientConnectionStatus.value = true;
    }
  }

  /// Method to handle data received on TCP client.
  /// We extract data and notify on the listener on new data.
  dataHandler(data) async {
    String d = new String.fromCharCodes(data).trim();
    // mechanism to notify that data received on tcp client
    tcpClientData.value = d;
    tcpClientConnectionStatus.value = true;
  }

  /// Handle error on tcp client.
  errorHandler(error, StackTrace trace) {
    print('-----------LN.eHTC: error...121--------$error,\n trace - $trace');
    tcpClientConnectionStatus.value = false;
  }

  /// Method to stop tcp clien
  socketCloseHandler() {
    print('LN.cHTC: Closing tcp client socket');
    if (tcpClient != null) tcpClient.destroy();
    tcpClientConnectionStatus.value = false;
  }

  /// Method to send data on tcp client
  /// Check if current connection is to desired ip.
  /// if not change connection to desired ip.
  /// then send message on the connection.
  sendDataOnTcpClient(String ip, String message) async {
    try {
      if (tcpClient != null) {
        // check if we are connected to same remote ip
        if (ip.toLowerCase() != tcpClient.address.address.toLowerCase()) {
          print(
              'ln.tTC: Changing client connection; Expected connection to $ip;'
                  ' actually connected to ${tcpClient.address.address}');
          // if different ip make new connection and then send message
          await startTcpClient(ip);
        }
      }
    } catch(e) {
      print('ln.tTC: 1: Error in sending data:\n e: $e');
      tcpClient = null;
      tcpClientConnectionStatus.value = false;
    }

    if (tcpClient == null) startTcpClient(ip);

    try {
      tcpClient.write(message);
      await tcpClient.flush();
      tcpClientConnectionStatus.value = true;
    }
    catch(e) {
      print('---write nai zal catch error---\n e: $e');
      tcpClientConnectionStatus.value = false;
     // FToast.show('Please check WIFI connection');

    }
  }
  /* ********** end tcp client to send/receive commands/status *****/

  /* ********** start udp client to send broadcast messages *****/
  /// Method to send udp broadcast for every device in the room.
 /* sendUdpBroadcast(Room room) async {
    String sIP = (await selfIP).address;
    for (Devices d in room.childList) {
      await udpBroadcast('-${d.deviceID}-$sIP', 2807);
    }
  }*/

  /// Method to send UDP broadcast message on port.
  /// For sending udp broadcast we use [RawDatagramSocket].
  /// Broadcast message is normal message send to the broadcast IP.
  /*udpBroadcast(String message, int port) async {
    RawDatagramSocket datagramSocket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    datagramSocket.broadcastEnabled = true;

    // Get Broadcast IP address.
    InternetAddress broadcastAddress = await broadcastIP;
    if (broadcastAddress == null) broadcastAddress = InternetAddress('255.255.255.255');

    print('LN.uB: Sending broadcast on address: $broadcastAddress:$port, Message: $message');

    // send udp broadcast.
    datagramSocket.send(message.codeUnits, broadcastAddress, port);
  }*/

  /// Method to get IP address of the mobile device on which application is running.
  /*Future<InternetAddress> get selfIP async {
    return InternetAddress(await Wifi.ip);
  }*/

  /// Method to get broadcast IP address of the mobile device on which application is running.
  /// Broadcast ip address is formed using selfIP.
  /// Last past of the ip address is set to 255 for getting broadcast ip address.
 /* Future<InternetAddress> get broadcastIP async {
    InternetAddress address = await selfIP;

    if (address.type == InternetAddressType.IPv4) {
      List<String> addressParts = address.address.split('.');
      addressParts.last = '255';
      address = InternetAddress(addressParts.join('.'));
    } else {
      List<String> addressParts = address.address.split(':');
      addressParts.last = 'FF';
      address = InternetAddress(addressParts.join(':'));
    }
    return address;
  }*/
/* ********** end udp client to send broadcast messages *****/
}

/// [TcpClient] is the class to handle client socket.
/// It has interface to create socket, write and onData, onError, onDone handlers.
class TcpClient {
  /// Placeholders for the required elements of the tcp client.
  Socket socket;
  String address;
  int port;

  /// Making object of the [TcpClient] class.
  /// It starts listing on the socket else closes the socket.
  TcpClient(Socket s) {
    socket = s;
    address = socket.remoteAddress.address;
    port = socket.remotePort;
    
    print('------TcpClient: initiating listening on socket----------- $address:$port');
    
    if (socket != null) socket.listen(onDataReceived, onError: errorHandler, onDone: doneHandler);
    else doneHandler();
  }

  /// Callback method to handle received data on socket.
  void onDataReceived(data) {
    String message = new String.fromCharCodes(data).trim();
    print('TC.mH: new data received on $address:$port; data: $message');
    // Update data and notify the listeners about data change.
    LocalNetworkManager.tcpServerData.value = message;
    // disconnect client socket after data received.
    doneHandler();
  }

  /// Callback method to handle error on socket.
  /// Close the connection after displaying message.
  void errorHandler(error){
    print('--TC.eH:==== $address:$port Error: $error');
    doneHandler();
  }

  /// Cleanup method to close connection and free resources.
  void doneHandler() {
    print('TC.fH: $address:$port Disconnected');
    LocalNetworkManager.cs.remove(this);
    socket.destroy();
  }

  /// Method to send data on socket.
  /// If there is error in sending data close connection.
  void write(String message) {
    try {
      socket.write(message);
      socket.flush();
    }
    catch(exception) {
      print('--------$address:$port Error in sending data:\n --- $exception');
      doneHandler();
    }
  }
}

