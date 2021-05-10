/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/screens/controlScreens/homeView1.dart';
import 'package:ioskitouchnew/screens/settings/settingView.dart';
import 'package:ioskitouchnew/screens/settings/appDetails/appDetails.dart';
import 'package:ioskitouchnew/screens/settings/themes/themes.dart';
import 'package:ioskitouchnew/screens/settings/themes/themesView.dart';
import 'package:provider/provider.dart';

import '../../CheckInternetConnection.dart';

class Settings extends StatefulWidget {
  static final String tag = 'Settings';

  @override
  SettingView createState() => new SettingView();
}

abstract class SettingState extends State<Settings> {
  SharedPreference pref = new SharedPreference();
  String synchData,step2;
  String usrID;

  ProgressHUD dbLoadingProgressHUD;
  NetworkCheck networkCheck = new NetworkCheck();


  bool isTap = false;

  int onBackPressCounter = 0;

  Connectivity connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> streamSubscription;

  String status;

  var themeVal;

  // Replaces current screen with [nextScreen].
  void navigateToThemes() => Navigator.of(context).pushNamed(Themes.tag);

  void navigateToAddHome() => Navigator.of(context).pushNamed(HomeView1.tag);

  void navigateToAppDetails() =>
      Navigator.of(context).pushNamed(AppDetails.tag);

  getInternetStatus() {
    streamSubscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          if (mounted)
            setState(() {
              status = result.toString();
              print("Initstate : $status");
              if (status == "ConnectivityResult.mobile" ||
                  status == "ConnectivityResult.wifi") {
                print("Internet available now.");
              }
            });
        });
  }

  onSynchClick() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm to sync device'),
          content: Text("Are you sure want to sync devices?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Yes",
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                //todo add sync functionality
                print("status:$status");
                if (status == "ConnectivityResult.mobile" ||
                    status == "ConnectivityResult.wifi") {
                  Navigator.of(context).pop();
                  if (synchData != "") {
                    Map<String, dynamic> map = json.decode(synchData);
//                    String topic = map["syncData"][0]["rooms"][0]["switchboxes"]
//                        [0]["topic"];
                    //    print("topic::$topic");
                    if (step2.isNotEmpty) {
                      ProgressBar.show(context);
                      print("Pradip - Now calling syncData()");
                      syncData();

                    } else {                               //arti
                      ProgressBar.show(context);
                      syncData();
                    }
                  } else {
                    FToast.show("No data to sync");
                  }
                } else {
                  print("You are not connected to internet");
                  FToast.showRed("You are not connected to internet");
                }
              },
            ),
            FlatButton(
              child: Text("Cancel",
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.black : Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getRestoreData() {
    String isSignUp = FlutterApp.isSignUp;
    if (isSignUp == "Yes") {
      FToast.show("There is no data to restore");
    } else {
      getInternetStatus();
      onRestoreClick();
    }
  }

  void onRestoreClick() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm to restore devices'),
          content: Text("Are you sure want to restore devices?"),
          actions: <Widget>[
            FlatButton(
              child: Text("YES",
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                print("InitConnectivity : $status");
                if (status == "ConnectivityResult.mobile" ||
                    status == "ConnectivityResult.wifi") {
                  Navigator.of(context).pop();
                  ProgressBar.show(context);
                  restoreData();
                } else {
                  FToast.showRed("You are not connected to internet");
                }
              },
            ),
            FlatButton(
              child: Text("Cancel",
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.black : Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState

    setState(() {

      getHomeListDataFromSelectedItem();  //by arti comment 25 jully to check data removal
      checkInternet();
      getInternetStatus();
    });

  //  getSyncData();  //by arti
  //  CommunicationManager.getInstance().connection();   // no need to call here arti commented
    super.initState();
  }

  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }
    } on SocketException catch (_) {
      print('not connected');
      status = "ConnectivityResult.none";
    }
  }

  Future<Null> initConnectivity() async {
    String connectionStatus;
    try {
      connectionStatus = (await connectivity.checkConnectivity()).toString();
    } on Exception catch (e) {
      print(e.toString());
      connectionStatus = "Internet connectivity failed";
    }
    if (!mounted) {
      return;
    }

    if (status == "ConnectivityResult.wifi") {
    } else {
      setState(() {
        status = connectionStatus;
      });
    }
    print("InitConnectivity : $status");
  }

  getSyncData() {
    pref.getString(SharedKey().SYNC_DATA).then((val) {
      if (val != null) {
        synchData = val;
//        print("synchData 2::$synchData");
      } else {
        synchData = "";
      }
      pref.getString(SharedKey().USER_ID).then((value) {
        if (value != null) {
          usrID = value;
          FlutterApp.userID = usrID;
        }
      });
      pref.getString(SharedKey().THEME_VALUE).then((val) {
        if (val != null) {
          themeVal = int.parse(val);
          FlutterApp.themeValue = int.parse((val));
       //   print("themeVal::$themeVal");
        }
      });

      //arti
      pref.getString(SharedKey().RECEIVE_DATA).then((val) {
        if(val != null){
          step2 = val;
        }
        else{
          step2 = "";
        }
      });



    });
  }

  void syncData() async {

   CommunicationManager.getInstance().connection();
   //CommunicationManager.getInstance().originalConnection();


    Future.delayed(const Duration(seconds: 4), () async {

      setState(() {
        CommunicationManager.getInstance().syncSubscribe(usrID + "/kitouchplus_app_to_server_ack");
        CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_app_to_server", synchData);

      });

      ProgressBar.dismiss(context);

    });
  }


  showSyncPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm to exit'),
          content: Text("Are you sure want to Backup devices and exit?"),
          actions: <Widget>[
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text("YES, Exit"),
              onPressed: () {
                //todo add sync functionality
                ProgressBar.show(context);
                syncData();
                exit(0);
          //      CommunicationManager.getInstance().originalConnection();
                CommunicationManager.getInstance().connection();
              },
            ),
          ],
        );
      },
    );
  }

  ///old code of restore data
 /* void restoreData() {
    Map<String, dynamic> map = new HashMap();
    map["user_id"] = usrID;
    String mMap = jsonEncode(map);
    CommunicationManager.getInstance().connection();
    Future.delayed(const Duration(seconds: 30), () async {
      setState(() {
        FlutterApp.restoreVal++;
        CommunicationManager.getInstance()
            .syncSubscribe(usrID + "/kitouchplus_server_to_app_ack");
        CommunicationManager.getInstance()
            .publishSync("global_in/kitouchplus_server_to_app", mMap);
        FlutterApp.restoreVal++;
        print("restoreVal::${FlutterApp.restoreVal}");
      });

      if (FlutterApp.restoreVal <= 3) {
        print("restoreVal::${FlutterApp.restoreVal}");
        ProgressBar.dismiss(context);

        showDialog(
          context: context,
          builder: (_) => FunkyOverlay(msg: "Restored data successfully",),
        );

      } else {

          setState(() {
            ProgressBar.dismiss(context);
            CommunicationManager.getInstance().mqttConnection.disconnect();

            showDialog(
              context: context,
              builder: (_) => FunkyOverlay(msg: "Please try again",),
            );
         //   FToast.show("Failed to restore data, please try again");
          });
      }
    });
  }*/

  void restoreData() {
    Map<String, dynamic> map = new HashMap();
    map["user_id"] = usrID;
    String mMap = jsonEncode(map);
    CommunicationManager.getInstance().connection();
    Future.delayed(const Duration(seconds: 4), () async {
      setState(() {

        CommunicationManager.getInstance().syncSubscribe(usrID + "/kitouchplus_server_to_app_ack");
        CommunicationManager.getInstance().publishSync("global_in/kitouchplus_server_to_app", mMap);

      });


      //clear my pref values
      pref.putString(SharedKey().homeNameForBackup, '');
      pref.putString(SharedKey().homeBackupKey, '0');
      pref.putString(SharedKey().OneHomeAutobackup, '');
      pref.putString(SharedKey().roomBackupKey, '0');
      pref.putString(SharedKey().roomNameForBackup, '');
      pref.putString(SharedKey().OneRoomAutobackup, '');
      pref.putString(SharedKey().deviceBackupKey, '');
      pref.putString(SharedKey().deviceNameForBackup, '');
      pref.putString(SharedKey().ONEDEVICE_AUTOBACKUP, '');

      ProgressBar.dismiss(context);
    });
  }

  onBackPressed() {
    ++onBackPressCounter;
    if (onBackPressCounter == 1) {
      FToast.showShort(StringConstants.ON_BACK_PRESS);
    }
    new Future.delayed(const Duration(seconds: 2), () {
      onBackPressCounter > 1 ? exit(0) : onBackPressCounter = 0;
    });
  }

  Map<String, dynamic> cMap = new HashMap();
  List<dynamic> mSynchData = new List();

  getHomeListDataFromSelectedItem() {

    pref.getString(SharedKey().RECEIVE_DATA).then((val) {
      if (val != null) {

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
              Map<String, dynamic> map = json.decode(val);

              if (map.containsKey(d.deviceID)) {
                String payload = map[d.deviceID];
                print("payload::: $payload");
                deviceMap["switches"] = payload;
              }

              //print("homeViewDeviceString::$FlutterApp.deviceString");
              List<dynamic> mControlPoints = new List();
              for (ControlPoint c in d.childList) {
                Map<String, dynamic> pointMap = new HashMap();
                pointMap["name"] = c.name;
                pointMap["type"] = c.type;
                pointMap["isVisible"] = c.isVisible;
                pointMap["idChar"] = c.idChar;

                List<dynamic> mStates = new List();

                for(int i=0;i<c.listStates.length;i++){
                  Map<String, dynamic> stateMap = new HashMap();
                  stateMap["idChar"] = c.listStates[i].idChar;
                  stateMap["name"] = c.listStates[i].name;
                  stateMap["iconIndex"] = c.listStates[i].iconIndex;
                  mStates.add(stateMap);
                }
                pointMap["states"] = mStates;
                mControlPoints.add(pointMap);

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
      } else {
      }

      cMap["syncData"] = mSynchData;
      cMap["user_id"] = FlutterApp.userID;
      String data = json.encode(cMap);
      pref.putString(SharedKey().SYNC_DATA, data);
      getSyncData();
    });
  }

}
