/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ioskitouchnew/guid/EnquiryDetails.dart';
import 'package:ioskitouchnew/videoGuide/AppGuideLink.dart';
import 'package:ioskitouchnew/videoGuide/videoGuide.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/guid/Guid.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/tile.dart';
import 'package:ioskitouchnew/screens/controlScreens/mainScreen.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/shareQRPrefScreen.dart';
import 'package:ioskitouchnew/screens/settings/settings.dart';
import 'package:ioskitouchnew/themeManager.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../common/FToast.dart';
import '../common/FToast.dart';
///
/// Displays Screen containing to Master and detail windows.
/// Also displays a button to switch communication between local and overTheNetCommunication.
///
class MasterDetail extends StatefulWidget {
  static final String tag = 'MasterDetail';

  /// Flag displaying whether communication is local or over net.
  static final ValueNotifier<bool> isCommunicationOverInternet = ValueNotifier(true);
  static final ValueNotifier<bool> isStatus = ValueNotifier(true);


 // static final ValueNotifier<bool> isCommunicationOverInternetClicked=ValueNotifier(false);   //solved by arti.. comment

  /// Creates Master Detail Screen.
  const MasterDetail({Key key}) : super(key: key);

  /// Creates State of Master Detail Screen and adds listener to update value of
  /// [isCommunicationOverInternet] in accordance with changes in state class.
  @override
  State<StatefulWidget> createState() {
    _MasterDetailState.isCommunicationOverInternet.addListener(() {
      isCommunicationOverInternet.value = _MasterDetailState.isCommunicationOverInternet.value;
    });

    _MasterDetailState.isStatus.addListener(() {
      isStatus.value = _MasterDetailState.isStatus.value;
    });

    return _MasterDetailState();
  }
}

///
/// State class of [MasterDetail] class.
///
/// It builds screen with master and detail screens.
/// UI is navigated to respective screen according to selection in master by user.
///
class _MasterDetailState extends State<MasterDetail> {
  /// Flag displaying whether communication is local or over net.
  static ValueNotifier<bool> isCommunicationOverInternet = ValueNotifier(true);
  static ValueNotifier<bool> isStatus = ValueNotifier(true);

  /// List of tiles for detail screens.
  final detailList = [
    Tile(Icons.power_settings_new, 'Control'),
    Tile(Icons.share, 'Share'),
   // Tile(Icons.add_to_photos, 'Add Homes'),
    Tile(Icons.settings, 'Settings'),
 //   Tile(Icons.info_outline, 'Guide'),
    Tile(Icons.video_call, 'App Guide'),
    Tile(Icons.call, 'Contact Us'),
  ];

  /// Index of selected detail screen.
  int selectedDetailIndex = 0;

  /// List of drawer element to be shown in Master view.
  List<Widget> drawerElementList = <Widget>[];

  SharedPreference pref = new SharedPreference();

  int onBackPressCounter=0;

  String userID,syncData,status;





  /// Detail screen based on selection in master screen.
  Widget get detailScreen {
    switch (selectedDetailIndex) {
      case 0:
        return MainScreen();
        break;
      case 1:
        return ShareQRPrefScreen();
        break;

      case 2:
        return Settings();
        break;

     /* case 3:
        return GuidScreen();
        break;*/


      case 3:
        return AppGuideLink();//YoutubePlayerDemoApp();
        break;

      case 4:
        return EnquiryDetails();
        break;


      default:
        return Text('Error');
        break;
    }
  }

  /// Body of screen with [dbLoadingProgressHUD].
  Widget get detailBody {
    return Stack(
      children: <Widget>[
        detailScreen,
        dbLoadingProgressHUD,
      ],
    );
  }

  /// Master view, constructed using drawer functionality.
  Widget get master {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('${FlutterApp.name}'),
            accountEmail: Text('${FlutterApp.emailId}'),
            currentAccountPicture:
                Image.asset('images/logo_skroman_kiTouch.png'),
          ),
          Column(children: drawerElementList),
        ],
      ),
    );
  }

//  _refreshAction() {
//    setState(() {
//      print("isCommunicationOverInternetClicked icon::::${isCommunicationOverInternetClicked.value}");
//      pref.getBool(SharedKey().IS_COMMUNICATION_OVER_INTERNET).then((val){
//        if(val!=null) {
//          if (val) {
//            print("1");
//            setState(() {
//              isCommunicationOverInternetClicked.value = true;
//            });
//          } else {
//            print("2");
//            // Initialising [ConnectionManager].
//            CommunicationManager _ = CommunicationManager.getInstance();
//            isCommunicationOverInternet.value =
//            !isCommunicationOverInternet.value;
//            isCommunicationOverInternetClicked.value = false;
//          }
//        }else{
//          print("3");
//          CommunicationManager _ = CommunicationManager.getInstance();
//          isCommunicationOverInternet.value =
//          !isCommunicationOverInternet.value;
//        }
//      });
//    });
//  }

  /// Communication switch button to switch communication between local and overTheNetCommunication.
  Widget get communicationSwitch {
    return IconButton(
      icon: Icon(
        isCommunicationOverInternet.value ? Icons.cloud : Icons.cloud_off,
        color: Colors.lightBlueAccent,
      ),
      onPressed: () {
        ProgressBar.show(context);

        Future.delayed(const Duration(seconds: 1), () async {

          setState(() {

              if(isCommunicationOverInternet.value){
                print('if');
                isStatus.value = false;
                FlutterApp.checkMqttConnection = false;
               // isCommunicationOverInternet.value=false;

                MasterDetail.isCommunicationOverInternet.value=false;
                CommunicationManager.getInstance().connectionThread();


                ProgressBar.dismiss(context);

                FToast.showRed('Cloud Deactivated');

              }else{
                print('ifelse');
                FlutterApp.checkMqttConnection = true;
                CommunicationManager.getInstance().connection();
                ProgressBar.dismiss(context);

                FToast.showGreen('Colud Activated');

              }
              // _refreshAction();
              //   CommunicationManager _ = CommunicationManager.getInstance();
              isCommunicationOverInternet.value = !isCommunicationOverInternet.value;
            },
          );
        });
      },
    );
  }

  /// After change in selection by user in master screen,
  /// remove previous detail screen form navigation and add new detail screen.
  void onSelectionChangeTo(int index) {
    setState(() => selectedDetailIndex = index);
    Navigator.of(context).pop();
  }

  /// Recreate drawer elements to be shown in Master view.
  void recreateDrawerElementList() {
    drawerElementList.clear();
    for (var index = 0; index < detailList.length; index++) {
      drawerElementList.add(
        ListTile(
          leading: Icon(detailList[index].icon),
          title: Text(detailList[index].name),
          selected: index == selectedDetailIndex,
          onTap: () => onSelectionChangeTo(index),
        ),
      );
    }
  }

  // Build application screen with master and detail views.
  @override
  Widget build(BuildContext context) {
    recreateDrawerElementList();

    return WillPopScope(child: Scaffold(
        resizeToAvoidBottomPadding:false,
      appBar: new PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight - 10),
        child: AppBar(
          primary: true,
          centerTitle: true,
          title: Text(ThemeManager.applicationName),
          actions: <Widget>[communicationSwitch,

 //         isStatus.value ? Image.asset("images/blue.png") : Image.asset("images/red.png"),

          /*IconButton(

            icon: Icon(
              isStatus.value ? Icons.check : Icons.close,
              color: Colors.lightBlueAccent,
            ),
            onPressed: () {
              setState(
                    () {
                  print("FlutterApp.isStatus::::${FlutterApp.isSignalOnNet}");

                  isStatus.value = ! isStatus.value;
                },
              );
            },
          ),*/

          /*  PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext context){
                return Constants.choices.map((String choice){
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )*/

          ],
        ),
      ),
      drawer: master,
      body: detailBody,
    ), onWillPop: (){
      onBackPressed();
    });
  }

  /*void choiceAction(String choice){
    if(choice == Constants.Refresh){

      ///to reconnect mqtt connection

  //    CommunicationManager.getInstance().disconnectMqttConnection();

  //    CommunicationManager.getInstance().connect();   // arti 24 aug
      print('refresh');
    }else if(choice == Constants.Settings){
      print('Subscribe');
    }else if(choice == Constants.SignOut){
      print('SignOut');
    }
  }*/

 /* void synchData() {
    print("synchData::$syncData");
    CommunicationManager.getInstance().connection();
    Future.delayed(const Duration(milliseconds: 100), () async {
      setState(() {
        CommunicationManager.getInstance()
            .syncSubscribe(userID + "/kitouchplus_app_to_server_ack");
        CommunicationManager.getInstance()
            .publishSync("global_in_ack/kitouchplus_app_to_server", syncData);
      });
    });
    Future.delayed(const Duration(milliseconds: 30000), () async {
      setState(() {
        ProgressBar.dismiss(context);
        exit(0);
      });
    });
  }*/

  ///alert dialog to sync data
  showSyncPopup(){
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
              //  synchData();
              //  CommunicationManager.getInstance().originalConnection();
              },
            ),
          ],
        );
      },
    );
  }

  /// To show loading status while database is updating.
  ProgressHUD dbLoadingProgressHUD;

  /// Need to make object of [dbLoadingProgressHUD] for showing database update.
  /// Also subscribing to change events of [Building.isDatabaseUpdating].
  @override
  void initState() {

    print('in details');

    super.initState();
    //restoreData(FlutterApp.userID);  // arti
//    });
 //   CommunicationManager.getInstance().originalConnection();
    dbLoadingProgressHUD = ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Colors.blueGrey,
      borderRadius: 5.0,
      text: 'Please Wait...',
    );
    // Subscribe to change events of [B.isDatabaseUpdating] flag.
    Building.isDatabaseUpdating.addListener(updatingDatabase);

    pref.getString(SharedKey().USER_ID).then((val) {
      setState(() {
        if (val != null) {
          userID = val;
          print("userID::$userID");
          FlutterApp.userID = userID;
        }
      });

      pref.getString(SharedKey().SYNC_DATA).then((val) {
        if (val != null) {
          syncData = val;
      //    print("synchData::$synchData");
        } else {
          syncData = "";
        }
      });
      pref.getString(SharedKey().DEVICE_STRING).then((value) {
        setState(() {
          if(value==null){
            dbLoadingProgressHUD.state.dismiss();
          }else {
            String deviceString = value;
            dbLoadingProgressHUD.state.dismiss();//arti
          }
        });
      });
    });
 }




  /// Need to unsubscribe from change events of [Building.isDatabaseUpdating].
  @override
  void dispose() {
    // Unsubscribe change events of [B.isDatabaseUpdating] flag.
    Building.isDatabaseUpdating.removeListener(updatingDatabase);
    super.dispose();
  }

  /// Callback to show/dismiss loading state of [dbLoadingProgressHUD] in accordance with [Building.isDatabaseUpdating] flag.
  void updatingDatabase() {
    if (dbLoadingProgressHUD?.state != null) {
      setState(() {
        if (Building.isDatabaseUpdating.value)
          dbLoadingProgressHUD.state.show();
        else
          dbLoadingProgressHUD.state.dismiss();
      });
    }
  }

  /// Callback to back - when user pressed back button of mobile then this method will execute
  onBackPressed() {
    ++onBackPressCounter;
    if (onBackPressCounter == 1) {
      FToast.showShort(StringConstants.ON_BACK_PRESS);
    }
    new Future.delayed(const Duration(seconds: 2), () {
      onBackPressCounter > 1 ? exit(0) : onBackPressCounter = 0;
    });
  }

  /*void restoreData(String usrID) {
    Map<String, dynamic> map = new HashMap();
    map["user_id"] = usrID;
    String mMap = jsonEncode(map);
    CommunicationManager.getInstance().connection();
    Future.delayed(const Duration(milliseconds: 15000), () async {
      setState(() {
        FlutterApp.restoreVal++;
        CommunicationManager.getInstance().syncSubscribe(usrID + "/kitouchplus_server_to_app_ack");
        CommunicationManager.getInstance().publishSync("global_in/kitouchplus_server_to_app", mMap);
        FlutterApp.restoreVal++;
        print("restoreVal::${FlutterApp.restoreVal}");
      });
      if (FlutterApp.restoreVal <= 3) {
        print("restoreVal::${FlutterApp.restoreVal}");
        ProgressBar.dismiss(context);
      } else {
        Future.delayed(const Duration(milliseconds: 20000), () async {
          setState(() {
            ProgressBar.dismiss(context);
            CommunicationManager.getInstance().mqttConnection.disconnect();
            FToast.show("Failed to restore data[masterDetail]");
          });
        });
      }
    });
  }*/

}

class Constants{
  static const String Refresh = 'Refresh';
  static const String Settings = 'Status';
  static const String SignOut = 'Sign out';

  static const List<String> choices = <String>[
    Refresh,
    Settings,
    SignOut
  ];
}