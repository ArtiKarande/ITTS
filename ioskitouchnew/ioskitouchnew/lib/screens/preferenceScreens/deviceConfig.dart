/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
import 'package:ioskitouchnew/common/Style.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:ioskitouchnew/models/state.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../../localNetworkManager.dart';

/// Class to change configurations of selected device.
///
/// Device configurations include its DeviceID, IP and Passwords.
/// After cancel/submit pressed Screen will be routed to previous Screen.
class DeviceConfig extends StatefulWidget {

  static final String tag = 'DeviceConfig';

  /// Creates Device configuration Screen to change configurations of selected device.
  const DeviceConfig({Key key}) : super(key: key);

  /// Creating state class to manage states of [DeviceConfig].
  @override
  State<StatefulWidget> createState() => _DeviceConfigState();
}

/// [_DeviceConfigState] is a state class of [DeviceConfig].
/// It creates and maintains UI, also its different states for [DeviceConfig].
class _DeviceConfigState extends State<DeviceConfig> {

  var flag=0;
  var deviceString ="";
  final LocalNetworkManager localNwConnection = new LocalNetworkManager(); // local n/w client
  int countLight = 0, countFan = 0,countMaster=0;

  /// Title of the screen
  String title = 'Change Device Configurations';
  String connectionInfo = 'Disconnected';

 // WifiConnectionStatus connectionStatus;

  /// Flag showing if passwords on the screen are visible or not.
  bool isPasswordHidden = true;
  bool isPasswordHidden1 = true;
  bool isPasswordHidden2 = true;

  /// Controller for text edit of Device ID.
  final editDeviceIdController = TextEditingController();

  /// Controller for text edit of Device password.
  final editPasswordController = TextEditingController();

  /// Controller for text edit of Device SSID Password.
  final editSsidPasswordController = TextEditingController();

  /// Controller for text edit of Device IP.
  final editIpController = TextEditingController();

  /// Controller for text edit of WiFi SSID.
  final editWifiController = TextEditingController();

  /// Controller for text edit of WiFi password.
  final editWifiPasswordController = TextEditingController();

  var themeVal;

  bool _loading = false;
  String status;

  Map<String, dynamic> mapPayload ;

  /// Fill the selected device information in controller.
  _DeviceConfigState() {
    editDeviceIdController.text = Building.getInstance().getSelectedDevice().deviceID;
    editPasswordController.text = Building.getInstance().getSelectedDevice().password;
    editSsidPasswordController.text = Building.getInstance().getSelectedDevice().password;   //ssidPassword  arti changes
    editIpController.text = Building.getInstance().getSelectedDevice().ip;

    CommunicationManager.getInstance().localNwConnection.tcpClientConnectionStatus.addListener(updateConnectionListener);
  }

  SharedPreference pref = new SharedPreference();

  getSyncData() {

    pref.getString(SharedKey().THEME_VALUE).then((val) {
      if (val != null) {
        themeVal = int.parse(val);
        FlutterApp.themeValue = int.parse((val));
        print("themeVal::$themeVal");
      }
    });
  }

  /// Show indication about connectivity with device.
  updateConnectionListener() {

    if(this.mounted){
      setState(() {
        if (CommunicationManager.getInstance().localNwConnection.tcpClientConnectionStatus.value) {
          FToast.showGreen('Connected');
          connectionInfo = 'Connected';
        } else {
          connectionInfo = 'Disconnected';
        }
      });
    }
  }

  /// Building Contents of the screen.
  /// Text edits to edit device configurations.
  /// Buttons to show/hide passwords, Also submit and cancel buttons.
  List<Widget> get content {
    return [
      SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            Center(
                child: Text('Change Configuration of device : "' +
                    Building.getInstance().getSelectedDevice().deviceID +
                    '"')),

            TextField(
              autofocus: false,  //arti change.. true
              controller: editDeviceIdController,
              decoration: InputDecoration(
                  enabled: false,   //arti
                  labelText: 'Change Device ID to: ', hintText: 'eg. SKIT6982Y0'),
            ),

            TextField(
              controller: editSsidPasswordController,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(

                  labelText: 'Hotspot Password', hintText: 'password', suffixIcon: new IconButton(
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color:themeVal == 2? Colors.black:Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  })),
            ),
            TextField(
              controller: editPasswordController,
              obscureText: isPasswordHidden1,
              decoration: InputDecoration(
                  enabled: false,   //arti
                  labelText: 'Control Password', hintText: 'password', suffixIcon: new IconButton(
                  icon: Icon(
                    isPasswordHidden1 ? Icons.visibility : Icons.visibility_off,
                    color: themeVal == 2? Colors.black:Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden1 = !isPasswordHidden1;
                    });
                  })),
            ),

      //      SizedBox(height: 20,),

            /// hide by arti
            Visibility(
              visible: true,
              child: TextField(
                enabled: false,   //arti
                autofocus: false,  //arti change.. true
                controller: editIpController,
                decoration: InputDecoration(
                    labelText: 'Change IP to: ', hintText: 'eg. 192.168.43.1'),
              ),
            ),

            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: RaisedButton(
                color: Colors.blue,
            //    onPressed: connectionInfo == 'Connected' ? null : updateConfig, //by arti
                onPressed: (){

                  setState(() {
                    _loading = true;
                    updateConfig();
                  });
                },
                child: Text('Submit Changes'),
              ),
            ),
            new Container(
              margin: const EdgeInsets.all(5.0),
              child: new Column(
                children: <Widget>[
                  Center(child: Text('Upload Wifi information to Device')),
                  Text('1. Connect to device in local network.\n'
                      '  > If there is hotspot by the name: ${Building.getInstance().getSelectedDevice().deviceID}\n'
                      '  > Then connect to that hostpot using password ${Building.getInstance().getSelectedDevice().password}'), //ssidPassword arti changes
                  Center(child: Text('$connectionInfo'),
                  ),

                ],
              ),
            ),
//          Opacity(opacity: 1.0,child: RaisedButton(
//            child: Text('Connect to device'),
//            onPressed: () {
//              // force local connection.
//              MasterDetail.isCommunicationOverInternet.value = false;
//              CommunicationManager.getInstance().reconnect();
//            },
//          ),),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child:

              RaisedButton(
                color: Colors.blue,
                child: Text('Connect to device'),
                onPressed: connectionInfo == 'Connected' ? null : connection,
              ),
            ),

            Container(
              margin: const EdgeInsets.all(5.0),
              child: new Column(
                children: <Widget>[
                  TextField(
                    autofocus: false,
                    controller: editWifiController,
                    decoration: InputDecoration(
                        labelText: 'WiFi SSID: ', hintText: 'eg. SKIT6982Y0'),
                    enabled: shouldEnable(), //arti


                  ),
                  TextField(
                    enabled: shouldEnable(),  //arti
                    autofocus: false,
                    controller: editWifiPasswordController,
                    obscureText: isPasswordHidden2,
                    decoration: InputDecoration(
                        labelText: 'WiFi Password',
                        hintText: 'password',
                        suffixIcon: new IconButton(
                            icon: Icon(
                              isPasswordHidden2
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color:themeVal == 2? Colors.black:Colors.white,
                              size: 26,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordHidden2 = !isPasswordHidden2;
                              });
                            })),
                  ),
                ],
              ),
            ),

            /////////////////////////////////////// bottom part///////////////////////////////////////////////////////////////

            new Container(
              width: MediaQuery.of(context).size.width*0.8,
              child: RaisedButton(
                color: Colors.green,
                child: Text('Upload New Wifi Config to device'),

                onPressed: flag==1?uploadNewWifiConfigButton:null,
              ),
            ),

            new Container(
                width: MediaQuery.of(context).size.width*0.8,
                height: 150.0,
                child:

                Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(child: Text('Get Data'),
                      splashColor: Colors.blueGrey,
                      onPressed: connectionInfo=='Connected' ? getData : null,
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(deviceString.isEmpty ? '' : 'Total Lights = $countLight'),
                        Padding(
                          padding: const EdgeInsets.only(top:5.0),
                          child: Text(deviceString.isEmpty ? '' : 'Total Fan = $countFan'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:5.0),
                          child: Text(deviceString.isEmpty ? '' : 'Master Switch = $countMaster'),
                        ),


                      ],
                    ),


                  ],
                )






            ),

            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom))
//         ListView(
//           padding: EdgeInsets.all(20.0),
//           shrinkWrap: true,
//           children: <Widget>[
//
////          RaisedButton(
////            child: Text('Change device connection to WiFi'),
////            onPressed: () {
////              print('`Change device connection to WiFi` has been pressed.');
////              CommunicationManager.getInstance().sendConfigOnLocalNetwork(
////                  'configw-', Building.getInstance().getSelectedDevice());
////              Navigator.of(context).pop();
////            },
////          ),
//           ],
//         ),
          ],
        ),
      )
//      RaisedButton(
//        onPressed: () => setState(() => (isPasswordHidden = !isPasswordHidden)),
//        child: Text(isPasswordHidden ? 'Show Passwords' : 'Hide Passwords'),
//      ),
//      RaisedButton(
//        onPressed: () => Navigator.of(context).pop(),
//        child: Text('Cancel'),
//        color: Colors.blueGrey,
//      ),
    ];
  }

  uploadNewWifiConfigButton(){

    if (editWifiPasswordController.text.length > 0) {
      if (editWifiController.text.length > 0) {
        CommunicationManager.getInstance().sendConfigOnLocalNetwork(
            'config-${editWifiController.text}-${editWifiPasswordController.text}-',
            Building.getInstance().getSelectedDevice());

        setState(() {
          pref.putString(SharedKey().deviceBackupKey, '1');
          pref.putString(SharedKey().deviceNameForBackup, editDeviceIdController.text);
        });

        uploadNewWifiConfig();
      } else
        FToast.show('Please enter password');
    } else
      FToast.show('Please enter ssid');
  }

  uploadNewWifiConfig() {
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        alertToUploadNewWifi();
      });
    });
  }

  /*connectToWifi() async {

    ProgressBar.show(context);
    MasterDetail.isCommunicationOverInternet.value = false;

    String ssid = "${Building.getInstance().getSelectedDevice().deviceID}";
    String password =
        "${Building.getInstance().getSelectedDevice().ssidPassword}";
    print("ssid::$ssid - password::$password");
    var result = await Wifi.connection("$ssid", "$password");
    print("result:::$result");
    // });

  }*/

  connection() async {
    MasterDetail.isCommunicationOverInternet.value = false;
    setState(() {
      _loading =true;
    });

      String ssid = "${Building.getInstance().getSelectedDevice().deviceID}";
      String password = "${Building.getInstance().getSelectedDevice().password}";   //by arti changes ssidPassword

    //  getConnectionState(ssid, password);
  }

  /*void getConnectionState(String ssid, String password) async {
 //   var listAvailableWifi = await WifiConfiguration.getWifiList();
 //   print("get wifi list : " + listAvailableWifi.toString());

    connectionStatus = await WifiConfiguration.connectToWifi(ssid, password, "com.skroman.iTouch");

    switch (connectionStatus) {
      case WifiConnectionStatus.connected:
        connectionInfo = 'Connected';
        FToast.showGreen("Connected");
        setState((){
          _loading =false;
        });
        break;

      case WifiConnectionStatus.alreadyConnected:
        connectionInfo = 'Connected';
        FToast.showGreen("already Connected");
        print("connection2");
        setState((){
          _loading =false;
        });
        connectionStatus = await WifiConfiguration.connectToWifi(ssid, password, "com.skroman.iTouch");
        break;

      case WifiConnectionStatus.notConnected:
        connectionInfo = 'Disconnected';
        FToast.showRed("not Connected");
        print("connection3");
        setState((){
          _loading =false;
        });

        checkDeviceAlreadyConnection();
        CommunicationManager.getInstance().localNwConnection.tcpClientConnectionStatus.addListener(updateConnectionListener);
        break;

      case WifiConnectionStatus.platformNotSupported:
        connectionInfo = 'Disconnected';
        FToast.showRed("platform Not Supported");
        print("connection4");
        setState((){
          _loading =false;
        });
        break;

      case WifiConnectionStatus.profileAlreadyInstalled:
        connectionInfo = 'Disconnected';
        print("connection5");
        FToast.showRed("profile Already Installed");
        setState((){
          _loading =false;
        });
        break;

      case WifiConnectionStatus.locationNotAllowed:
        connectionInfo = 'Disconnected';
        FToast.showRed("location Not Allowed");
        print("connection6");
        setState((){
          _loading =false;
        });
        break;
    }
  }*/
  /// Updates configurations when Submit button is pressed.
  /// Update new information into the database.
  /// As selected device configurations are changed. connection need to change.

  updateConfig() {

        Building.getInstance().getSelectedDevice().deviceID = editDeviceIdController.text;
        Building.getInstance().getSelectedDevice().password = editPasswordController.text;
        Building.getInstance().getSelectedDevice().password = editSsidPasswordController.text;//ssidPassword  arti changes
        Building.getInstance().getSelectedDevice().ip = editIpController.text;
        Building.getInstance().updateDB();
     //   CommunicationManager.getInstance().reconnect();

        Future.delayed(const Duration(seconds: 6), () async {
          setState(() {
            _loading = false;
          });
        });
  }

  /// Build application screen with content for editing of device.

  @override
  void initState() {

    pref.getString(SharedKey().ONEDEVICE_DATA).then((val) {
      print(val);
      print('prefcheck');
    });

    ///to check device id is already connected or not
    checkDeviceAlreadyConnection();

    getEachDeviceData();
    super.initState();
  }

  @override
  void dispose() {

    _loading = false;
    print('dispose called');

    ///need to reconnect again bcoz it gets call of tcp so for reconnection used here
    MasterDetail.isCommunicationOverInternet.value = true;
    CommunicationManager.getInstance().connection();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController();
    return ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Colors.blue,
          size: 50,
        ),
        dismissible: false,
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(this.title)),
        body: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _controller,
          padding: EdgeInsets.all(20.0),
          shrinkWrap: true,
          children: content,
        ),
      ),
    );
  }

  ///confirmation alert dialog box for -  to change device connection to WiFi
  alertToUploadNewWifi() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return new AlertDialog(
          title: new Text(
            "Alert",
            style: CommonStyle().dialogTitle,
          ),
          content: new Text(
            'Are you sure want to change device connection to WiFi?',
            style: CommonStyle().dialogSubTitle,
          ),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {

                  CommunicationManager.getInstance().sendConfigOnLocalNetwork('configw-',
                      Building.getInstance().getSelectedDevice());
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  FToast.showGreen('Device shifted! ');

                  setState(() {
                    MasterDetail.isCommunicationOverInternet.value = true;
                    FlutterApp.checkMqttConnection = true;
                  });

                 CommunicationManager.getInstance().connection();

                },
                child: new Text(StringConstants.OK,
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.blue))),
            new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text(StringConstants.CANCEL,
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.blue))),
          ],
        );
      },
    );
  }

  ///get Data button by arti
  ///this method is created for to know how many lights fan and master switch are there currently presented

  void getData() {
    if(connectionInfo == 'Connected') {
      pref.getString(SharedKey().ONEDEVICE_DATA).then((val) {
        if (val != null) {

          setState(() {
            print('--got data[arti]---$val');
            deviceString = val.toString();

            print('--countoflightandFan--');
            print('L'.allMatches(deviceString).length);
            print('F'.allMatches(deviceString).length);

            countLight = 'L'.allMatches(deviceString).length;
            countFan = 'F'.allMatches(deviceString).length;
            countMaster = 'M'.allMatches(deviceString).length;

            flag = 1; //arti
          });

        } else {
          FToast.show('No points found, please use remote to reset device points!');
        }
      });
    }
  }

  ///this is useful for if status is connected then enable text field else disabled it
  shouldEnable() {
    bool shouldEnable = false;

    if(connectionInfo == 'Connected' && flag==1){
      shouldEnable = true;

      setState(() {
        _loading = false;
      });
    }
    else{
      shouldEnable = false;
    }
    return shouldEnable;
  }

  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";

        connection();
      }


    } on SocketException catch (_) {
      print('not connected');

      FToast.show("You are not connected to Internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }

  getHomeListDataFromSelectedItem() {

    Map<String, dynamic> cMap = new HashMap();
    List<dynamic> mSynchData = new List();

    for (Home h in Building.getInstance().childList) {
      Map<String, dynamic> homeMap = new HashMap();
      homeMap["home_name"] = h.name;
      homeMap["iconIndex"] = h.iconIndex;
      homeMap["home_id"] = "dummy";
      List<dynamic> mRoomList = new List();
      for (Room r in h.childList) {
        Map<String, dynamic> roomMap = new HashMap();
        roomMap["home_id"] = "dummy";
        roomMap["room_id"] = "dummy";
        roomMap["room_name"] = r.name;
        roomMap["iconIndex"] = r.iconIndex;
        List<dynamic> mSwitchBoxes = new List();
        for (Devices d in r.childList) {
          Map<String, dynamic> deviceMap = new HashMap();
          deviceMap["room_id"] = "dummy";
          deviceMap["switchbox_id"] = d.deviceID;
          deviceMap["topic"] = "${d.deviceID}${d.password}";
          deviceMap["mac_address"] = "dummy";
          deviceMap["ssid"] = "${d.deviceID}";
          deviceMap["password"] = "${d.password}";
          deviceMap["name"] = d.name;
          deviceMap["iconIndex"] = d.iconIndex;
          deviceMap["ip"] = d.ip;   //solved by arti

          List<dynamic> mControlPoints = new List();
          for (ControlPoint c in d.childList) {
            Map<String, dynamic> pointMap = new HashMap();
            pointMap["name"] = c.name;
            pointMap["type"] = c.type;
            pointMap["isVisible"] = c.isVisible;
            pointMap["idChar"] = c.idChar;        // used for switch point for rename points [at backend side useful]
            pointMap["demo"] = "hello";  //by arti
            mControlPoints.add(pointMap);

            List<dynamic> mStates = new List();
            for (StateS s in c.listStates) {
              Map<String, dynamic> stateMap = new HashMap();
              stateMap["idChar"] = s.idChar;
              stateMap["name"] = s.name;
              stateMap["iconIndex"] = s.iconIndex;

              mStates.add(stateMap);
            }
            pointMap["states"] = mStates;
            // syncData    mControlPoints.add(pointMap);
          }
          deviceMap["points"] = mControlPoints;
          mSwitchBoxes.add(deviceMap);
        }
        roomMap["switchboxes"] = mSwitchBoxes;
        mRoomList.add(roomMap);
      }
      homeMap["rooms"] = mRoomList;
      mSynchData.add(homeMap);
    }
    cMap["syncData"] = mSynchData;
    cMap["user_id"] = FlutterApp.userID;
    String data = json.encode(cMap);
    pref.putString(SharedKey().SYNC_DATA, data);
      print("--database[getHomeListDataFromSelectedItem()]--$cMap");
  }

  getEachDeviceData()async{

    Map<String, dynamic> cMap = new HashMap();
    List<dynamic> mSynchData = new List();

    pref.getString(SharedKey().RECEIVE_DATA).then((val) {

      print('..');
      print(val);

      if (val != null) {

        Map<String, dynamic> homeMap = new HashMap();
        homeMap["home_name"] = Building.getInstance().getSelectedHome().name;
        homeMap["iconIndex"] = Building.getInstance().getSelectedHome().iconIndex;
        homeMap["home_id"] = "dummy";

        List<dynamic> mRoomList = new List();
        Map<String, dynamic> roomMap = new HashMap();
        roomMap["home_id"] = "dummy";
        roomMap["room_id"] = "dummy";
        roomMap["room_name"] = Building.getInstance().getSelectedRoom().name;
        roomMap["iconIndex"] = Building.getInstance().getSelectedRoom().iconIndex;

        List<dynamic> mSwitchBoxes = new List();

        Map<String, dynamic> deviceMap = new HashMap();
        deviceMap["room_id"] = "dummy";
        deviceMap["switchbox_id"] = Building.getInstance().getSelectedDevice().deviceID;
        deviceMap["topic"] = "${Building.getInstance().getSelectedDevice().deviceID}${Building.getInstance().getSelectedDevice().password}";
        deviceMap["mac_address"] = "dummy";
        deviceMap["ssid"] = "${Building.getInstance().getSelectedDevice().deviceID}";
        deviceMap["password"] = "${Building.getInstance().getSelectedDevice().password}";
        deviceMap["name"] = Building.getInstance().getSelectedDevice().name;
        deviceMap["iconIndex"] = Building.getInstance().getSelectedDevice().iconIndex;
        deviceMap["ip"] = Building.getInstance().getSelectedDevice().ip;   //solved by arti

        Map<String, dynamic> mapP = json.decode(val);

        if (mapP.containsKey(Building.getInstance().getSelectedDevice().deviceID)) {
          String payload = mapP[Building.getInstance().getSelectedDevice().deviceID];
          print("payload::: $payload");
          deviceMap["switches"] = payload;
        }

        List<dynamic> mControlPoints = new List();

        for (ControlPoint c in Building.getInstance().getSelectedDevice().childList) {
          Map<String, dynamic> pointMap = new HashMap();
          pointMap["name"] = c.name;
          pointMap["type"] = c.type;
          pointMap["isVisible"] = c.isVisible;
          pointMap["idChar"] = c.idChar; // used for switch point for rename points [at backend side useful]
          pointMap["demo"] = "hello"; //by arti
          mControlPoints.add(pointMap);
        }

        deviceMap["points"] = mControlPoints;
        mSwitchBoxes.add(deviceMap);

        roomMap["switchboxes"] = mSwitchBoxes;
        mRoomList.add(roomMap);
        homeMap["rooms"] = mRoomList;
        mSynchData.add(homeMap);

        cMap["syncData"] = mSynchData;
        cMap["user_id"] = FlutterApp.userID;
        String data = json.encode(cMap);

     //   print('single device backup');
    //    log(data);

        pref.putString(SharedKey().ONEDEVICE_AUTOBACKUP, data);
      }
    });
    }

  void checkDeviceAlreadyConnection() async{

      setState(() {
        MasterDetail.isCommunicationOverInternet.value = false;
        FlutterApp.checkMqttConnection = false;
      });

      CommunicationManager.getInstance().connectionThread();
      updateConnectionListener();


  }

}
