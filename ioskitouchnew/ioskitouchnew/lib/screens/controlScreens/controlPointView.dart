/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ioskitouchnew/CheckInternetConnection.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/Messages.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
import 'package:ioskitouchnew/common/Style.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/databaseHelper.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';
import 'package:ioskitouchnew/themeManager.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

/// [ControlPointView] Displays the grid of [ControlPoint]s.
/// With this view users can interact to change [State]s of [ControlPoint]s.
/// Eg. Turn on/off the light/fan/socket, etc.
/// It uses [childList] of selected [Devices] from [Building] data set to form the view.

class ControlPointView extends StatefulWidget {
  /// Change event notifiers used here to notify changes in data/ui.
  /// Other classes can listen to these notifiers to take actions accordingly.

  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);

  /// Makes Object of [ControlPointView] class.
  ///
  /// Also adds replicate listeners to [sceneChangeNotifier] and [dataChangeNotifier] from state class {[_ControlPointViewState]}.
  /// Actual data/view change happens in state class these changes need to be propagated up in the display hierarchy.
  /// These propagation is done by these replication of event listeners.
  ControlPointView() {
    // Replication of change events on [_ControlPointViewState.sceneChangeNotifier].
    _ControlPointViewState.sceneChangeNotifier.addListener(() =>
        (sceneChangeNotifier.value =
            _ControlPointViewState.sceneChangeNotifier.value));

    // Replication of change events on [_ControlPointViewState.dataChangeNotifier].
    _ControlPointViewState.dataChangeNotifier.addListener(() =>
        (dataChangeNotifier.value =
            _ControlPointViewState.dataChangeNotifier.value));
  }

  /// Creating state class to manage states.
  @override
  State<StatefulWidget> createState() => _ControlPointViewState();
}

/// [_ControlPointViewState] is a state class of [ControlPointView].
/// It creates and maintains UI and its different states for [ControlPointView].
///
/// When user interacts with [ControlPointView], data-set or UI might need be updated,
/// [_ControlPointViewState] notifies these updates in data-set or UI.
class _ControlPointViewState extends State<ControlPointView> {
  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);
  String noConnection =
      'Connection not available, please connect to the device hotspot or router...';

  /// Database required to read/store/update the data of the system.
  DatabaseHelper database = DatabaseHelper();

  int themeVal;
  bool _loading = false;
  String status;

  /// Method to build UI with grid of [ControlPoint]s.
  @override
  Widget build(BuildContext context) {
    print(
        "len control:::${Building.getInstance().getSelectedDevice().childList.length}");
    print("len control child:::${Building.getInstance().childList.length}");

    ///after 2 sec this block wil execute bcoz at first time we get 0, n then get correct length..
    Timer(Duration(seconds: 2), () {
      print("len control:::${Building.getInstance().getSelectedDevice().childList.length}");

      if (Building.getInstance().getSelectedDevice().childList.length == 0) {
        checkInternet();  // send M:L:! command
      }
    });

    /// Reading and storing data in required fields.
    ///database.extractDataFromDatabase();
    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Colors.blue,
        size: 50,
      ),
      dismissible: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: RefreshIndicator(
          // Swipe Down refresh to send dummy command.
          // Which will result in checking the connection before sending command.
          // And device will send the current status in response to this command.
          onRefresh: sendDummyCommandAllTime,//sendDummyCommand,

          // Scene control and general controls are put in column one below another.
          // We have properties of columns and grid view as per our UI requirements.
          child: Building.getInstance().getSelectedDevice().childList.length > 0
              ? new Column(
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                   /* Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[

                        *//*FlutterApp.checkMqttConnection
                            ? Image.asset("images/blue.png", height: 20,)
                            : Image.asset("images/red.png", height: 20,),*//*


                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text('Device Status : '),
                              Text(FlutterApp.isSignalOn
                                  ? 'connected'
                                  : 'disconnected'),
                            ],
                          ),
                        ),
                      ],
                    ),*/

                    // List of Scenes at top of the view, just below the tabs.
                    Container(
                      child: getSceneList(),
                      height: 60.0,
                      margin: const EdgeInsets.all(10.0),
                    ),
                    // Grid view of [ControlPoint]s below scenes, 3 in one row.
                    // Other spacing parameters just for the clean and simple look.
                    Expanded(
                      child: OrientationBuilder(
                        builder: (context, orientation) {
                          return orientation == Orientation.portrait
                              ? gridView()
                              : gridViewLand();
                        },
                      ),
                    ),
                  ],
                )
              : new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Text(
                        StringConstants.MESSAGE,      //arti - if device not connected then show this text

                        style: CommonStyle().dialogSubTitle,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  //first step
  Widget gridView() {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(5.0),
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      // Actual list of [ControlPoint] views which are put as grid.
      children: makeGridView(),
    );
  }

  Widget gridViewLand() {
    return GridView.count(
      crossAxisCount: 8,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(5.0),
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      // Actual list of [ControlPoint] views which are put as grid.
      children: makeGridView(),
    );
  }

  /// Sends dummy command to the selected [Devices].
  /// Which will result in checking the connection before sending command.
  /// And device will send the current status in response to this command.
  Future<Null> sendDummyCommand() async {
    CommunicationManager.getInstance().connect();
    // [indexList] is needed by the communication engine to send commands.
    // This list has all the information required to send the the command.
    List<int> indexList = [
      Building.getInstance().indexChildList, // Selected [Home].
      Building.getInstance()
          .getSelectedHome()
          .indexChildList, // Selected [Room]
      Building.getInstance()
          .getSelectedRoom()
          .indexChildList, // Selected [Device]
      0, 0, 0 // for dummy command
    ];
    // Sending command using mechanism provided by [ConnectionManager].
    CommunicationManager.getInstance().sendCommand(indexList);
  }

  ///command - used for if there is no any control points present then this command will execute M:L:! and M:L:0
  Future<Null> sendDummyCommandNew() async {
 //   CommunicationManager.getInstance().connect();
    // [indexList] is needed by the communication engine to send commands.
    // This list has all the information required to send the the command.
    List<int> indexList = [
      Building.getInstance().indexChildList, // Selected [Home].
      Building.getInstance()
          .getSelectedHome()
          .indexChildList, // Selected [Room]
      Building.getInstance()
          .getSelectedRoom()
          .indexChildList, // Selected [Device]
      0, 0, 0, 0, 0, 0 // for dummy command
    ];
    // Sending command using mechanism provided by [ConnectionManager].

    CommunicationManager.getInstance().sendCommand(indexList);


    Timer(Duration(seconds: 3), () {

      CommunicationManager.getInstance().connection();
    });
  }


  Future<Null> sendDummyCommandAllTime() async {
    //   CommunicationManager.getInstance().connect();
    // [indexList] is needed by the communication engine to send commands.
    // This list has all the information required to send the the command.
    List<int> indexList = [
      Building.getInstance().indexChildList, // Selected [Home].
      Building.getInstance()
          .getSelectedHome()
          .indexChildList, // Selected [Room]
      Building.getInstance()
          .getSelectedRoom()
          .indexChildList, // Selected [Device]
      0, 0, 0, 0, 0, 0 // for dummy command
    ];
    // Sending command using mechanism provided by [ConnectionManager].

    CommunicationManager.getInstance().sendCommand(indexList);

  }


  ///before sending command check interet connection
  checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }

      sendDummyCommandNew();
    } on SocketException catch (_) {
      print('not connected');

      FToast.showRed("You are not connected to Internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }

  checkInternetForBackup() async {

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }

      pref.getString(SharedKey().deviceBackupKey).then((val) {

        pref.getString(SharedKey().deviceNameForBackup).then((valDName) {

          print('data...');
          print(valDName);

          if(val.contains('1') && valDName == Building.getInstance().getSelectedDevice().name){

            pref.getString(SharedKey().ONEDEVICE_AUTOBACKUP).then((val) {

              print('data......');
              print(val);

              if ( val.length > 590 ) {

                ProgressBar.show(context);
                deviceBackup = val;
                Future.delayed(const Duration(seconds: 2), () async {

                  setState(() {
                    CommunicationManager.getInstance().syncSubscribe(userID + "/global_in_ack/kitouchplus_configure_device_ack");
                    CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_configure_device", deviceBackup);
                  });

                  ProgressBar.dismiss(context);

                });
              }
            });
          }else{}
        });
      });
    } on SocketException catch (_) {
      print('not connected');

      FToast.showRed("You are not connected to Internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }

  /// Making list of widgets to be displayed in grid view.
  /// It generates list of view elements for every [ControlPoint] of selected [Devices].

  List<Widget> makeGridView() {
    List<Widget> list = List();

    // Adding every [ControlPoint] of selected [Device] if it marked as visible.
    for (int index = 0;
        index < Building.getInstance().getSelectedDevice().childList.length;
        index++) {
      if (Building.getInstance().name != "Demo Device" || index != 0) {
        if (Building.getInstance().getControlPointAtIndex(index).isVisible)
          list.add(makeGridCell(index));
      }
    }
    return list;
  }

  /// Single Element in grid,
  /// made with index pointing to [ControlPoint] in [childList] of [Devices].
  ///
  /// It is a card like element which has different functionality for user interactions like tap, long press.

  //third
  Material makeGridCell(int index) {
    return Material(
//      shape: BeveledRectangleBorder(
//          borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.0))),
//      elevation: 15.0,
//      shadowColor: Colors.black,
      child: LayoutBuilder(builder: (ct, cr) {
        return new InkWell(
          child: new Container(
            child: new Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                verticalDirection: VerticalDirection.down,
                // Check if slider needs to be displayed or not.
                // 1st state is for on/off,
                // so if [ControlPoint] has more than 1 states slider is displayed fot remaining states.
                children: (Building.getInstance().getControlPointAtIndex(index).listStates.length <= 1)
                    ? <Widget>[
                        // Card without slider.
                        InkWell(
                            // on long press we display alert dialog with more options.
                            // on click on those more options we trigger respective methods.
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Edit - ' +
                                        Building.getInstance()
                                            .getControlPointAtIndex(index)
                                            .name),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          MaterialButton(
                                              child: Text('Change Icon'),
                                          //    onPressed: () => changeIcon(index)),

                                              onPressed: ()async{
                                                checkInternetNew();
                                                if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {
                                                  CommunicationManager.getInstance().connection();
                                                  changeIcon(index);
                                                }
                                                else{
                                                  FToast.showRed(Messages.NO_INTERNET);
                                                }
                                              }),


                                          MaterialButton(
                                              child: Text('Change Name'),
                                           //   onPressed: () => changeName(index)),

                                              onPressed: (){

                                                checkInternetNew();

                                                if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {
                                                  CommunicationManager.getInstance().connection();
                                                  getHomeListDataFromSelectedItem();
                                                  changeName(index);
                                                }
                                                else{
                                                  FToast.showRed(Messages.NO_INTERNET);
                                                }

                                              }),


                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            // On tap of the [ControlPoint] view we send command to change on/off state of that [ControlPoint].

                            ///  code of - tap on lights/fan/master
                            ///  useful code for points

                            onTap: () async {
                              setState(() {
                                FlutterApp.isSignalOn = false;
                              });

                              //  Message to be displayed on UI.

                              String
                                  displayMessage = //arti commented snakbar msg
                                  'Sending Command to switch ' +
                                      Building.getInstance()
                                          .getControlPointAtIndex(index)
                                          .name +
                                      '...';
                              // [indexList] is needed by the communication engine to send commands.
                              // This list has all the information required to send the the command.
                              List<int> indexList = [
                                Building.getInstance().indexChildList,
                                // Selected [Home].
                                Building.getInstance()
                                    .getSelectedHome()
                                    .indexChildList,
                                // Selected [Room].
                                Building.getInstance()
                                    .getSelectedRoom()
                                    .indexChildList,
                                // Selected [Device].
                                index
                                // [ControlPoint] of which state needs to be changed.
                              ];

                              // Sending command using mechanism provided by [ConnectionManager].
                              // Waiting for result of the command send,
                              // if command send is failed, user sees message in red
                              bool result =
                                  await CommunicationManager.getInstance()
                                      .sendCommand(indexList);

                              // Notifying changes on UI, as after command is sent UI should be updated.
                              sceneChangeNotifier.value =
                                  !sceneChangeNotifier.value;

                              // Showing confirmation/failure message to user about command.

                              ///commented by arti at 14 Aug
                              if (!result) {
                               /* Scaffold.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 1),
                                  content: Text(noConnection),
                                ));*/

                            //    CommunicationManager.getInstance().connect();   //25 aug
                              }
                            },

                            // To have splash effect after tap/longClick on this view.
                            splashColor: Colors.blueGrey,

                            // Icon and name of the [ControlPoint] are displayed in vertical column as children to the card.
                            // Color of icon and name is decided upon on/off state of the control point.
                            child: new Container(
                              margin: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                verticalDirection: VerticalDirection.down,
                                children: <Widget>[
                                  new Image(
                                      image: ThemeManager
                                          .iconList[Building.getInstance()
                                              .getControlPointAtIndex(index)
                                              .listStates[Building.getInstance()
                                                  .getControlPointAtIndex(index)
                                                  .stateIndex]
                                              .iconIndex]
                                          .icon,
                                      width: 32.0,
                                      height: 32.0,
                                      color: themeVal == 2
                                          ? (Building.getInstance()
                                                  .getControlPointAtIndex(index)
                                                  .flagOnOff)
                                              ? ThemeManager.boxCSelected
                                              : ThemeManager.boxUnselectedColor
                                          : (Building.getInstance()
                                                  .getControlPointAtIndex(index)
                                                  .flagOnOff)
                                              ? ThemeManager.boxSelected
                                              : ThemeManager
                                                  .boxUnselectedColor),
                                  Center(
                                      child: new Container(
                                    child: Text(
                                      Building.getInstance()
                                          .getControlPointAtIndex(index)
                                          .name,
                                      style: TextStyle(
                                          color: themeVal == 2
                                              ? Building.getInstance()
                                                      .getControlPointAtIndex(
                                                          index)
                                                      .flagOnOff
                                                  ? ThemeManager.boxCSelected
                                                  : ThemeManager
                                                      .boxUnselectedColor
                                              : Building.getInstance()
                                                      .getControlPointAtIndex(
                                                          index)
                                                      .flagOnOff
                                                  ? ThemeManager.boxSelected
                                                  : ThemeManager
                                                      .boxUnselectedColor),
                                    ),
                                    margin: const EdgeInsets.only(top: 5.0),
                                  )),
                                ],
                              ),
                            )),
                      ]
                    : <Widget>[
                        // Card with slider.
                        InkWell(
                            // on long press we display alert dialog with more options.
                            // on click on those more options we trigger respective methods.
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Edit - ' +
                                        Building.getInstance()
                                            .getControlPointAtIndex(index)
                                            .name),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          MaterialButton(
                                              child: Text('Change Icon'),
                                          //    onPressed: () => changeIcon(index)),

                                              onPressed: ()async{

                                                checkInternetNew();

                                                if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {
                                                  CommunicationManager.getInstance().connection();
                                                  changeIcon(index);
                                                }
                                                else{
                                                  FToast.showRed(Messages.NO_INTERNET);
                                                }

                                              }),

                                          MaterialButton(
                                              child: Text('Change Name'),
                                            //  onPressed: () => changeName(index)),

                                              onPressed: ()async{

                                                checkInternetNew();

                                                if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {
                                                  CommunicationManager.getInstance().connection();
                                                  changeName(index);
                                                }
                                                else{
                                                  FToast.showRed(Messages.NO_INTERNET);
                                                }

                                              }),

                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            // On tap of the [ControlPoint] view we send command to change on/off state of that [ControlPoint].
                            onTap: () async {
                          //    FToast.showGreen('message1');

                              //Message to be displayed on UI.
                              String displayMessage =
                                  'Sending Command to swich ' +
                                      Building.getInstance()
                                          .getControlPointAtIndex(index)
                                          .name +
                                      '...';

                              // [indexList] is needed by the communication engine to send commands.
                              // This list has all the information required to send the the command.
                              List<int> indexList = [
                                Building.getInstance().indexChildList,
                                // Selected [Home].
                                Building.getInstance()
                                    .getSelectedHome()
                                    .indexChildList,
                                // Selected [Room].
                                Building.getInstance()
                                    .getSelectedRoom()
                                    .indexChildList,
                                // Selected [Device].
                                index
                                // [ControlPoint] of which state needs to be changed.
                              ];

                              // Sending command using mechanism provided by [ConnectionManager].
                              // Waiting for result of the command send,
                              // if command send is failed, user sees message in red else in blueGrey color.
                              bool result =
                                  await CommunicationManager.getInstance()
                                      .sendCommand(indexList);

                              // Notifying changes on UI, as after command is sent UI should be updated.
                              sceneChangeNotifier.value =
                                  !sceneChangeNotifier.value;

                              // Showing confirmation/failure message to user about command.
                             /* if (!result) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                  content: Text(noConnection),
                                ));
                              }*/
                            },

                            // To have splash effect after tap/longClick on this view.
                            splashColor: Colors.blueGrey,

                            // Icon and name of the [ControlPoint] are displayed in vertical column as children to the card.
                            // Color of icon and name is decided upon on/off state of the control point.
                            child: new Container(
                              child: Column(
                                //  crossAxisAlignment: CrossAxisAlignment.stretch,
                                //   mainAxisSize: MainAxisSize.min,
                                // verticalDirection: VerticalDirection.down,
                                children: <Widget>[
                                  new Image(
                                      image: ThemeManager
                                          .iconList[Building.getInstance()
                                              .getControlPointAtIndex(index)
                                              .listStates[Building.getInstance()
                                                  .getControlPointAtIndex(index)
                                                  .stateIndex]
                                              .iconIndex]
                                          .icon,
                                      width: 32.0,
                                      height: 32.0,
                                      color: (Building.getInstance()
                                              .getControlPointAtIndex(index)
                                              .flagOnOff)
                                          ? ThemeManager.boxSelected
                                          : ThemeManager.boxUnselectedColor),
                                  Container(
                                    child: Slider(
                                      activeColor: ThemeManager.boxSelected,
                                      min: 0.0,
                                      max: (Building.getInstance()
                                                  .getControlPointAtIndex(index)
                                                  .listStates
                                                  .length -
                                              1) *
                                          1.0,
                                      divisions: Building.getInstance()
                                              .getControlPointAtIndex(index)
                                              .listStates
                                              .length -
                                          1,
                                      value: Building.getInstance()
                                              .getControlPointAtIndex(index)
                                              .stateIndex *
                                          1.0,
                                      label: Building.getInstance()
                                          .getControlPointAtIndex(index)
                                          .listStates[Building.getInstance()
                                              .getControlPointAtIndex(index)
                                              .stateIndex]
                                          .idChar,
                                      // while user changes slider, display ui to respective values.
                                      onChanged: (double value) {
                                        setState(() => (Building.getInstance()
                                            .getControlPointAtIndex(index)
                                            .stateIndex = value.round()));
                                      },
                                      // when user completes sliding send command to change states.
                                      onChangeEnd: (double value) async {
                                        // Message to be displayed on UI.
//                                        String displayMessage =
//                                            'Sending Command to change value of ${Building.getInstance().getControlPointAtIndex(index).name} to ${Building.getInstance().getControlPointAtIndex(index).listStates[Building.getInstance().getControlPointAtIndex(index).stateIndex].idChar} ...';

                                        // [indexList] is needed by the communication engine to send commands.
                                        // This list has all the information required to send the the command.
                                        List<int> indexList = [
                                          Building.getInstance().indexChildList,
                                          // Selected [Home].
                                          Building.getInstance()
                                              .getSelectedHome()
                                              .indexChildList,
                                          // Selected [Room].
                                          Building.getInstance()
                                              .getSelectedRoom()
                                              .indexChildList,
                                          // Selected [Device].
                                          index,
                                          // [ControlPoint] of which state needs to be changed.
                                          value.round(),
                                          // value of [State] to be set.
                                        ];

                                        // Sending command using mechanism provided by [ConnectionManager].
                                        // Waiting for result of the command send,
                                        // if command send is failed, user sees message in red else in blueGrey color.
                                        bool result = await CommunicationManager
                                                .getInstance()
                                            .sendCommand(indexList);

                                        // Notifying changes on UI, as after command is sent UI should be updated.
                                        sceneChangeNotifier.value =
                                            !sceneChangeNotifier.value;

                                        // Showing confirmation/failure message to user about command.

                                        /*Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: result
                                              ? Colors.blueGrey
                                              : Colors.red,
                                          duration: Duration(seconds: 1),
                                          content: Text(displayMessage),
                                        ));*/
                                      },
                                    ),
                                    height: 25.0,
                                    // width: 25.0,
                                  ),
                                  Text(
                                      Building.getInstance()
                                          .getControlPointAtIndex(index)
                                          .name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Building.getInstance()
                                                  .getControlPointAtIndex(index)
                                                  .flagOnOff
                                              ? ThemeManager.boxSelected
                                              : ThemeManager
                                                  .boxUnselectedColor)),
                                ],
                              ),
                              margin: const EdgeInsets.only(top: 8.0),
                            )),
                        // Slider to display/control states other than on/off state of the [ControlPoint].
                      ],
              ),
            ),
            decoration: new BoxDecoration(
                border: new Border.all(
                    color: themeVal == 2
                        ? Building.getInstance()
                                .getControlPointAtIndex(index)
                                .flagOnOff
                            ? ThemeManager.boxCSelected
                            : ThemeManager.boxUnselectedColor
                        : Building.getInstance()
                                .getControlPointAtIndex(index)
                                .flagOnOff
                            ? ThemeManager.boxSelected
                            : ThemeManager.boxUnselectedColor)),
          ),

          /// code of - click on outsider container same code is at upper side also for lights/fan/master buttons
          onTap: () async {
            setState(() {
              FlutterApp.isSignalOn = false;
            });

            List<int> indexList = [
              Building.getInstance().indexChildList,
              // Selected [Home].
              Building.getInstance()
                  .getSelectedHome()
                  .indexChildList, // Selected [Room].
              Building.getInstance().getSelectedRoom().indexChildList,
              // Selected [Device].
              index
              // [ControlPoint] of which state needs to be changed.
            ];

            // Sending command using mechanism provided by [ConnectionManager].
            // Waiting for result of the command send,
            // if command send is failed, user sees message in red else in blueGrey color.
            bool result =
                await CommunicationManager.getInstance().sendCommand(indexList);

            // Notifying changes on UI, as after command is sent UI should be updated.
            sceneChangeNotifier.value = !sceneChangeNotifier.value;

            // Showing confirmation/failure message to user about command.
            if (!result) {
              Scaffold.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
                content: Text(noConnection),
              ));
            }
          },

          // To have splash effect after tap/longClick on this view.
          splashColor: Colors.blueGrey,
        );
      }),
    );
  }

  /// Alert dialog to change the icon of the [ControlPoint].
  Future<Null> changeIcon(index) async {

    // Close previous alert dialog.
    Navigator.of(context).pop();

    // All icon options for [ControlPoint] are displayed to user,
    // user can select one of those icons to set new icon to the selected [ControlPoint],
    // or just select cancel to abort the icon change.
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose icon'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.black : Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          content: Container(
            width: MediaQuery.of(context).size.width * .7,
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              shrinkWrap: true,
              padding: const EdgeInsets.all(4.0),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: ThemeManager.iconList.map((T) {
                return Material(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0))),
                  elevation: 5.0,
                  shadowColor: Colors.black,
                  color: themeVal == 2 ? Colors.black : Colors.grey,
                  child: InkWell(
                    onTap: () {
                      /*setState(() {
                        Building.getInstance()
                            .getControlPointAtIndex(index)
                            .listStates[Building.getInstance()
                                .getControlPointAtIndex(index)
                                .stateIndex]
                            .iconIndex = ThemeManager.iconList.indexOf(T);
                        dataChangeNotifier.value = !dataChangeNotifier.value;

                        Building.getInstance().updateDB(); //by arti
                        //      getHomeListDataFromSelectedItem();
                      });
                      Building.getInstance().updateDB();
                      Navigator.of(context).pop();*/

                      String devicesSidPassword = Building.getInstance().getSelectedDevice().deviceID + Building.getInstance().getSelectedDevice().password;

                      print(Building.getInstance().getControlPointAtIndex(index).type);

                      String type = Building.getInstance().getControlPointAtIndex(index).type;

                      if (type == 'M') {
                        ///do not update master switch

                        FToast.showRed('You cannot update Master Switch Icon!');
                        //       Navigator.of(context).pop();
                      }
                      else {

                        Navigator.of(context).pop();

                        setState(() {
                          _loading = true;
                        });

                        Map<String, dynamic> map = new HashMap();
                        map["deviceid"] = devicesSidPassword;
                        map["user_id"] = userID;
                        map["switch_id"] = Building.getInstance().getControlPointAtIndex(index).idChar;
                        map["type"] = type;
                        map["iconIndex"] = ThemeManager.iconList.indexOf(T);

                        String mMap = jsonEncode(map);

                        print('cmmap');
                        print(mMap);

                        Future.delayed(const Duration(seconds: 3), () async {
                          setState(() {
                            CommunicationManager.getInstance().syncSubscribe(userID + "/global_in_ack/kitouchplus_update_switch_icon_ack");
                            CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_update_switch_icon", mMap);

                            setState(() {
                              _loading = false;
                              Building.getInstance()
                                  .getControlPointAtIndex(index)
                                  .listStates[Building.getInstance()
                                  .getControlPointAtIndex(index)
                                  .stateIndex]
                                  .iconIndex = ThemeManager.iconList.indexOf(T);
                              dataChangeNotifier.value = !dataChangeNotifier.value;

                              Building.getInstance().updateDB();
                            });

                          });
                        });
                      }




                    },
                    splashColor: Colors.blueGrey,
                    child: LayoutBuilder(builder: (ct, cr) {
                      return new Image(image: T.icon);
//                        Icon(
//                        T.icon,
//                        size: cr.biggest.height - 4,
//                        color: ThemeManager.unselectedColor,
//                      );
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// Alert dialog to change the name of the [ControlPoint].
  Future<Null> changeName(index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Text editing UI is displayed to user.
    // User can change name of the control point and press Rename to change name,
    // or just select cancel to abort the icon change.
    final c = TextEditingController();
    final TextField tf = TextField(
      autofocus: true,
      controller: c,
      decoration: InputDecoration(
          labelText: 'Rename Device to: ', hintText: 'eg. My Device'),
    );
    //  c.text = Building.getInstance().getControlPointAtIndex(index).name;  //by arti
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename : ' +
              '"' +
              Building.getInstance().getControlPointAtIndex(index).name +
              '"'),
          content: tf,
          actions: <Widget>[
            FlatButton(
              child: Text('Rename',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                if (c.text.isEmpty) {
                  FToast.showRed('Please enter name');
                } else {
                  String devicesSidPassword =
                      Building.getInstance().getSelectedDevice().deviceID + Building.getInstance().getSelectedDevice().password;

                  print(Building.getInstance().getControlPointAtIndex(index).type);

                  String type = Building.getInstance().getControlPointAtIndex(index).type;

                  if (type == 'M') {
                    ///do not update master switch

                    FToast.showRed('You cannot update Master Switch!');
             //       Navigator.of(context).pop();
                  }
                  else {
                    setState(() {
                      FlutterApp.indexVal = index;
                      FlutterApp.renameDeviceVal = c.text;
                    });
                    Navigator.of(context).pop();

                    setState(() {
                      _loading = true;
                    });

                    Map<String, dynamic> map = new HashMap();
                    map["deviceid"] = devicesSidPassword;
                    map["user_id"] = userID;
                    map["switch_id"] = Building.getInstance()
                        .getControlPointAtIndex(index)
                        .idChar;
                    map["type"] = type;
                    map["new_name"] = c.text;

                    String mMap = jsonEncode(map);

                    print(mMap);

                    CommunicationManager.getInstance().connection();

                    Future.delayed(const Duration(seconds: 3), () async {
                      setState(() {
                        CommunicationManager.getInstance().syncSubscribe(
                            userID +
                                "/global_in_ack/kitouchplus_rename_switch_ack");
                        CommunicationManager.getInstance().publishSync(
                            "global_in_ack/kitouchplus_rename_switch", mMap);

                        setState(() {
                          _loading = false;
                        });
                        dataChangeNotifier.value = !dataChangeNotifier.value;
                      });
                    });
                  }
                }
              },
            ),
            FlatButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.black : Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// View with 1st three scenes and option button to display remaining scenes.
  Widget getSceneList() {
    List<Widget> sceneList = List();

    // 1st three scenes.
    sceneList.addAll(getSceneListOfLength(4));

    // Option button (More) to display remaining scenes.
//    sceneList.add(InkWell(
//      child: ListView(
//        children: <Widget>[
//          Icon(Icons.more_vert),
//          Padding(
//            padding: EdgeInsets.only(left: 4.0),
//            child: Center(child: Text('More')),
//          ),
//        ],
//      ),
//      onTap: () {
//        showDialog(
//          context: context,
//          builder: (BuildContext context) {
//            return AlertDialog(
//              title: Center(child: Text('All Scenes')),
//              content: Container(
//                  width: MediaQuery.of(context).size.width * .7, child: getSceneListAll()),
//            );
//          },
//        );
//      },
//    )
    // );

    // Returning single row grid view with above list as child.
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(3.0),
      childAspectRatio: 2.0,
      shrinkWrap: true,
      children: sceneList,
    );
  }

  /// View with all scenes to display on UI.
  Widget getSceneListAll() {
    // Returning two column grid view with all scenes.
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(10.0),
      childAspectRatio: 1.0,
      shrinkWrap: true,
      children: getSceneListOfLength(
          Building.getInstance().getSelectedDevice().sceneList.length, 1),
    );
  }

  /// Scene list of required [length].
  /// [type] = 1 => specifies that all scenes are displayed in alert dialog.
  /// [type] = 0 => specifies that only 1st three scenes are displayed in normal ui.
  getSceneListOfLength(length, [type = 0]) {
    List<Widget> sceneList = List();
    for (int index = 0; index < length; index++) {
      sceneList.add(InkWell(
        child: LayoutBuilder(builder: (ct, cr) {
          return ListView(
            children: <Widget>[
              Icon(
                ThemeManager
                    .iconListForScene[Building.getInstance()
                        .getDeviceSceneAtIndex(index)
                        .listStates[Building.getInstance()
                            .getDeviceSceneAtIndex(index)
                            .stateIndex]
                        .iconIndex]
                    .icon,
                size: Device.get().isTablet
                    ? cr.biggest.height * .3
                    : cr.biggest.height * .6,
                color: themeVal == 2
                    ? (Building.getInstance()
                            .getDeviceSceneAtIndex(index)
                            .flagOnOff)
                        ? ThemeManager.colorSelected
                        : ThemeManager.boxUnselectedColor
                    : (Building.getInstance()
                            .getDeviceSceneAtIndex(index)
                            .flagOnOff)
                        ? ThemeManager.colorSelected
                        : ThemeManager.unselectedColor,
              ),
              Center(
                  child: Text(
                Building.getInstance().getDeviceSceneAtIndex(index).name,
              )),
            ],
          );
        }),

        // On tap of the scene element, command is sent to set the scene.
        /// mood tap code
        onTap: () async {
          String displayMessage = 'Sending Command to set scene: ' +
              Building.getInstance().getDeviceSceneAtIndex(index).name +
              '...';

          // [indexList] is needed by the communication engine to send commands.
          // This list has all the information required to send the the command.
          List<int> indexList = [
            Building.getInstance().indexChildList, // Selected [Home].
            Building.getInstance()
                .getSelectedHome()
                .indexChildList, // Selected [Room].
            Building.getInstance()
                .getSelectedRoom()
                .indexChildList, // Selected [Device].
            index, // [ControlPoint] of which state needs to be changed.
            0, 0, 0 // to configure command as scene control command.
          ];

          //check wheather cloud is ON or OFF
          bool isCloud = MasterDetail.isCommunicationOverInternet.value;

          // Sending command using mechanism provided by [ConnectionManager].
          // Waiting for result of the command send,
          // if command send is failed, user sees message in red else in blueGrey color.
          bool result =
              await CommunicationManager.getInstance().sendCommand(indexList);

          // Notifying changes on UI, as after command is sent UI should be updated.
          sceneChangeNotifier.value = !sceneChangeNotifier.value;

          // If all scenes are visible we need to close alert dialog.
          if (type == 1) Navigator.of(context).pop();

          // Showing confirmation/failure message to user about command.
          /* if (isCloud) {
            Scaffold.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
              content: Text(Messages.MOOD_ERROR),
            ));
          }*/
        },

        // on long press we display alert dialog with more options.
        // on click on those more options we trigger respective methods.
        onLongPress: () {
          if (type == 1) Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Edit - ' +
                    Building.getInstance().getDeviceSceneAtIndex(index).name),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[

                      /// currently not needed, but maybe useful in future
                    /*  MaterialButton(
                          child: Text('Change Icon'),
                          onPressed: () => changeIconOfScene(index)),
                      MaterialButton(
                          child: Text('Change Name'),
                          onPressed: () => changeNameOfScene(index)),*/


                      MaterialButton(
                          child: Text('Save current state in this scene'),
                          onPressed: () => updateScene(index)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ));
    }
    return sceneList;
  }

  /// Alert dialog to change the icon of the scene.
  Future<Null> changeIconOfScene(index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // All icon options are displayed to user,
    // user can select one of those icons to set new icon to the scene,
    // or just select cancel to abort the icon change.
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose icon'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.black : Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          content: Container(
            width: MediaQuery.of(context).size.width * .7,
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              shrinkWrap: true,
              padding: const EdgeInsets.all(4.0),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: ThemeManager.iconListForScene.map((T) {
                return Material(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0))),
                  elevation: 5.0,
                  shadowColor: Colors.black,
                  color: themeVal == 2 ? Colors.black : Colors.grey,
                  child: InkWell(
                    onTap: () {
                      setState(() => (Building.getInstance()
                              .getDeviceSceneAtIndex(index)
                              .listStates[Building.getInstance()
                                  .getDeviceSceneAtIndex(index)
                                  .stateIndex]
                              .iconIndex =
                          ThemeManager.iconListForScene.indexOf(T)));
                      dataChangeNotifier.value = !dataChangeNotifier.value;
                      Building.getInstance().updateDB();

                      Navigator.of(context).pop();
                    },
                    splashColor: Colors.blueGrey,
                    child: LayoutBuilder(builder: (ct, cr) {
                      return Icon(
                        T.icon,
                        size: cr.biggest.height - 4,
                        color: ThemeManager.unselectedColor,
                      );
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// Alert dialog to change the name of the scene.
  Future<Null> changeNameOfScene(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Text editing UI is displayed to user.
    // User can change name of the scene and press Rename to change name,
    // or just select cancel to abort the icon change.
    final c = TextEditingController();
    final TextField tf = TextField(
      autofocus: true,
      controller: c,
      decoration: InputDecoration(
          labelText: 'Rename Device to: ', hintText: 'eg. My Device'),
    );
    c.text = Building.getInstance().getDeviceSceneAtIndex(index).name;
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename : ' +
              '"' +
              Building.getInstance().getDeviceSceneAtIndex(index).name +
              '"'),
          content: tf,
          actions: <Widget>[
            FlatButton(
              child: Text('Rename',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                setState(() => (Building.getInstance()
                    .getDeviceSceneAtIndex(index)
                    .name = c.text));
                dataChangeNotifier.value = !dataChangeNotifier.value;
                Building.getInstance().updateDB();
                //     getHomeListDataFromSelectedItem(); //change name
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.black : Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Current states of device can be stored as the scene.
  /// Command need to be sent to configure current states as scene.
  Future<Null> updateScene(index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Confirmation dialog to user to confirm about changing scene config.
    // Command is sent if user confirms or user can abort update by clicking on cancel.
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Scene Update'),
          content: Text('Current State of device will be stored in "' +
              Building.getInstance().getDeviceSceneAtIndex(index).name +
              '"'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes, Update',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.black : Colors.white)),
              onPressed: () async {
                String displayMessage = 'Sending Command to update scene: ' +
                    Building.getInstance().getDeviceSceneAtIndex(index).name +
                    '...';
                List<int> indexList = [
                  Building.getInstance().indexChildList, // Selected [Home].
                  Building.getInstance()
                      .getSelectedHome()
                      .indexChildList, // Selected [Room].
                  Building.getInstance()
                      .getSelectedRoom()
                      .indexChildList, // Selected [Device].
                  index, // [ControlPoint] of which state needs to be changed.
                  0, 0, 0, 0 // to configure command as scene update command.
                ];

                // Sending command using mechanism provided by [ConnectionManager].
                // Waiting for result of the command send,
                // if command send is failed, user sees message in red else in blueGrey color.
                bool result = await CommunicationManager.getInstance()
                    .sendCommand(indexList);

                // Notifying changes on UI, as after command is sent UI should be updated.
                sceneChangeNotifier.value = !sceneChangeNotifier.value;

                // Printing result and display message in console.
                print(
                    'Show user command is sent - with $result; [command - $displayMessage]');
                /*
                // Showing confirmation/failure message to user about command.
                Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: result ? Colors.blueGrey : Colors.red,
                  duration: Duration(seconds: 1),
                  content: Text(dM),
                ));*/
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.black : Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///1 device backup call
    checkInternetForBackup(); //init

    sendDummyCommandAllTime();

    pref.getString(SharedKey().DEVICE_STRING).then((value) {
      setState(() {
        deviceString = value;
        print("deviceStringcheck::$deviceString");
        print('----getAllDeviceString----');
      });

      pref.getString(SharedKey().USER_ID).then((val) {
        setState(() {
          if (val != null) {
            userID = val;
            print("userID::$userID");
          }
        });
      });

      pref.getString(SharedKey().THEME_VALUE).then((val) {
        if (val != null) {
          setState(() {
            themeVal = int.parse(val);
            FlutterApp.themeValue = int.parse((val));
          });
          print("themeVal home1::$themeVal");
        }
      });
    });

    getDeviceStatus();
    getReceiveData();

  }

  SharedPreference pref = new SharedPreference();
  bool isConnected = false;
  String connectionStatus = "";

  void getDeviceStatus() {
    pref.getString(SharedKey().DEVICES_LIST).then((val) {
      print('prefDeviceList');
      print(val);

      if (val != null) {
        Map devicesList = jsonDecode(val);
        print("updateLocalStatus control::$val");
        if (devicesList.containsKey(FlutterApp.deviceName)) {
          print("devicesList control:::$devicesList");
          String status = devicesList["${FlutterApp.deviceName}"];

          print('getDeviceStatus::');
          print(status);

          if (status != "") {

            if (status == "disconnected") {
              FlutterApp.isSignalOn = false;
              // isConnected=false;
              Building.isLocalConnectionUpdating.value = false;
              connectionStatus = "Device is offline";
              Scaffold.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
                content: Text(connectionStatus),
              ));
            }
          }
        }
      } else {}
    });
  }

  void getReceiveData() {
    pref.getString(SharedKey().RECEIVE_DATA).then((val) {
      print('control screen---getReceiveData---');
      print(val);

      if (val != null) {
        Map<String, dynamic> rMap = jsonDecode(val);

        //todo check getting child list empty or not
        if (Building.getInstance().getSelectedDevice().childList.length == 0) {
          //  if (Building.getInstance().childList.length > 0) {
          setState(() {
            if (rMap.containsKey(Building.getInstance().getSelectedDevice().name)) {
              String name = Building.getInstance().getSelectedDevice().name;
              print("name:::$name");
              String rValue = rMap[name];
              String topic = name;
              print("topic:::$topic");
              if (rMap.length > 1) {
                for (Home h in Building.getInstance().childList) {
                  for (Room r in h.childList) {
                    for (Devices d in r.childList) {
                      if (topic == d.deviceID)
                        topic = d.deviceID + d.password + '/' + 'status';
                    }
                  }
                }
                CommunicationManager.getInstance().updateStatus(topic, rValue);
              }
            }
          });
        }
      }
    });
  }

  var deviceString;
  Map<String, dynamic> cMap = new HashMap();
  List<dynamic> mSynchData = new List();
  String userID;
  String deviceBackup='';

  getHomeListDataFromSelectedItem() {
    print("inside getHomeListDataFromSelectedItem");

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
          //  deviceMap["ip"] = '192.168.41.1';  //by arti
          deviceMap["ip"] = d.ip; //by arti
          deviceMap["switches"] =
              FlutterApp.deviceString; // todo get device string

          print(FlutterApp.deviceString);
          print("---[controlpointview]---");

          List<dynamic> mControlPoints = new List();
          for (ControlPoint c in d.childList) {
            Map<String, dynamic> pointMap = new HashMap();
            pointMap["name"] = c.name;
            pointMap["type"] = c.type;
            pointMap["isVisible"] = c.isVisible;

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
    cMap["syncData"] = mSynchData;
    cMap["user_id"] = userID;
    String data = json.encode(cMap);
    pref.putString(SharedKey().SYNC_DATA, data);
    print("--[controlpointview]--arti---$cMap");
  }


  checkInternetNew()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');

        setState(() {
          status = "ConnectivityResult.mobile";
          status = "ConnectivityResult.wifi";
        });
      }
    } on SocketException catch (_) {
      print('not connected');

      setState(() {
        status = "ConnectivityResult.none";
      });

    }
  }



}
