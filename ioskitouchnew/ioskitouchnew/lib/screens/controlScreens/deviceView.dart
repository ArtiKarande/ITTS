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
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/deviceConfig.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/addElementScreen.dart';
import 'package:ioskitouchnew/screens/settings/backupSuccessAnim.dart';
import 'package:ioskitouchnew/themeManager.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// [DeviceView] Displays the grid of [Devices]s.
/// With this view users can interact to choose which [Devices] they want to control.
/// It uses [childList] of selected [Room] from [Building] data set to form the view.
class DeviceView extends StatefulWidget {
  /// Change event notifiers used here to notify changes in data/ui.
  /// Other classes can listen to these notifiers to take actions accordingly.

  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);

  /// Makes Object of [DeviceView] class.
  ///
  /// Also adds replicate listeners to [sceneChangeNotifier] and [dataChangeNotifier] from state class {[_DeviceViewState]}.
  /// Actual data/view change happens in state class these changes need to be propagated up in the display hierarchy.
  /// These propagation is done by these replication of event listeners.
  DeviceView() {
    // Replication of change events on [_DeviceViewState.sceneChangeNotifier].
    _DeviceViewState.sceneChangeNotifier.addListener(() => (sceneChangeNotifier
        .value = _DeviceViewState.sceneChangeNotifier.value));

    // Replication of change events on [_DeviceViewState.dataChangeNotifier].
    _DeviceViewState.dataChangeNotifier.addListener(() =>
        (dataChangeNotifier.value = _DeviceViewState.dataChangeNotifier.value));
  }

  /// Creating state class to manage states.
  @override
  State<StatefulWidget> createState() => _DeviceViewState();
}

/// [_DeviceViewState] is a state class of [DeviceView].
/// It creates and maintains UI and its different states for [DeviceView].
///
/// When user interacts with [DeviceView], data-set or UI might need be updated,
/// [_DeviceViewState] notifies these updates in data-set or UI.
class _DeviceViewState extends State<DeviceView> {
  static ValueNotifier<bool> isCommunicationOverInternet = ValueNotifier(true); //by arti
  ValueNotifier<bool> tcpServerConnectionStatus = ValueNotifier(false); //by arti

  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);

  String noConnection = 'Connection not available, please connect to the device hotspot or router...';

  SharedPreference pref = new SharedPreference();
  int themeVal;
  String synchData, status;

  bool prefHome = false, prefRoom = false, _loading = false;
  SharedPreferences sharedPreferences;
  String roomBackup = '', deviceValidations = '';

  /// Method to build UI with grid of [Devices]s.
  @override
  Widget build(BuildContext context) {
    // Scene controls and device selection are put in column one below another.
    // We have properties of columns and grid view as per our UI requirements.
    return  ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Colors.blue,
        size: 50,
      ),
      dismissible: false,
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        body: Column(
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            // List of Scenes at top of the view, just below the tabs.

            ///old UI of mood1,2,3,4 for now not needed, later on might be useful feature

           /* new Container(
              child: getSceneList(),
              height: 50.0,
              margin: const EdgeInsets.all(10.0),
            ),*/

            // Grid view of [Device]s below scenes, 2 in one row.
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
        ),
      ),
    );
  }

  Widget gridView() {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(10.0),
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      // Actual list of [Device] views which are put as grid.
      children: makeGridView(),
    );
  }

  Widget gridViewLand() {
    return GridView.count(
      crossAxisCount: 8,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(10.0),
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      // Actual list of [Device] views which are put as grid.
      children: makeGridView(),
    );
  }

  /// Making list of widgets to be displayed in grid view.
  /// It generates list of view elements for every [Devices] of selected [Room].
  List<Widget> makeGridView() {
    List<Widget> list = List();
    if (Building.getInstance().getSelectedRoom().childList.length != 0) {
      // Adding every [Device] of selected [Room].
      for (int index = 0;
          index < Building.getInstance().getSelectedRoom().childList.length;
          index++) {
        if (Building.getInstance().getSelectedRoom().childList[index].name !=
            "Demo Device") {
          //  if (index != 0) {
          list.add(makeGridCell(index));
        } else {
          list.add(Material(
            child: InkWell(
              onTap: () {
                /*AddElementScreen.type = 2;
                Navigator.of(context).pushNamed(AddElementScreen.tag);
                dataChangeNotifier.value = !dataChangeNotifier.value;
                */
                //arti changes
               /* if (prefRoom == true) {
                  AddElementScreen.type = 2;
                  Navigator.of(context).pushNamed(AddElementScreen.tag);
                  dataChangeNotifier.value = !dataChangeNotifier.value;
                } else*/

                  if (Building.getInstance().childList[index].name=="My Home") {
                  FToast.show('Please add home first');
                } else if (Building.getInstance().getRoomAtIndex(index).name=="Demo Room") {
                  FToast.show('Please add room first');
                } else {
                  AddElementScreen.type = 2;
                  Navigator.of(context).pushNamed(AddElementScreen.tag);
                  dataChangeNotifier.value = !dataChangeNotifier.value;
                }
              },
              splashColor: Colors.blueGrey,
              child: LayoutBuilder(builder: (ct, cr) {
                return new Container(
                  child: new Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      verticalDirection: VerticalDirection.down,
                      children: <Widget>[
                        Icon(Icons.add, size: 42),
                        Center(
                            child: Text('Add Device',
                                style: TextStyle(fontSize: 12.0))),
                      ],
                    ),
                  ),
                  decoration: themeVal == 2
                      ? new BoxDecoration(
                          border: new Border.all(color: Colors.amber))
                      : new BoxDecoration(
                          border: new Border.all(color: Colors.yellowAccent)),
                  margin: const EdgeInsets.all(3.0),
                );
              }),
            ),
          ));
        }
      }
    } else {
      // ADD button card to invoke preference screen to add [Device].
      // If users taps on this card, user is routed to preference screen after confirmation.
      list.add(Material(
        child: InkWell(
          onTap: () {
            AddElementScreen.type = 2;
            Navigator.of(context).pushNamed(AddElementScreen.tag);
            dataChangeNotifier.value = !dataChangeNotifier.value;
          },
          splashColor: Colors.blueGrey,
          child: LayoutBuilder(builder: (ct, cr) {
            return new Container(
              child: new Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    Icon(Icons.add, size: 42),
                    Center(
                        child: Text('Add Device',
                            style: TextStyle(fontSize: 12.0))),
                  ],
                ),
              ),
              decoration: themeVal == 2
                  ? new BoxDecoration(
                      border: new Border.all(color: Colors.amber))
                  : new BoxDecoration(
                      border: new Border.all(color: Colors.yellowAccent)),
              margin: const EdgeInsets.all(3.0),
            );
          }),
        ),
      ));
    }
    return list;
  }

  /// Single Element in grid,
  /// made with index pointing to [Devices] in [childList] of selected [Room].
  ///
  /// It is a card like element which has different functionality for user interactions like tap, long press.
  ///useful
  Material makeGridCell(int index) {
    return Material(
      child: InkWell(
        // on long press we display alert dialog with more options.
        // on click on those more options we trigger respective methods.
        onLongPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Edit - ' +
                    Building.getInstance().getDeviceAtIndex(index).name),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      MaterialButton(
                          child: Text('Change Icon'),
                        //  onPressed: () => changeIcon(index)),

                          onPressed: ()async{

                            checkInternet();

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

                          onPressed: (){

                            checkInternet();

                            if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {
                              CommunicationManager.getInstance().connection();
                              getHomeListDataFromSelectedItem();
                              changeName(index);
                            }
                            else{
                              FToast.showRed(Messages.NO_INTERNET);
                            }
                          }),


                      MaterialButton(
                          child: Text('Edit Config'),
                          onPressed: () => editDevice(index)),
                      MaterialButton(
                          child: Text('Delete Device'),
                          onPressed: () => delete(index)),
                    ],
                  ),
                ),
              );
            },
          );
        },

        // On tap of the [Device] view we set that [Device] as selected.
        // And navigate UI to next tab so that user can interact with [ControlPoint]s.
        // Selected [Device] is marked with different color.
        onTap: () {

          getEachDeviceData();

          setState(() => (Building.getInstance().getSelectedRoom().indexChildList = index));
          sceneChangeNotifier.value = !sceneChangeNotifier.value;


         /* if(MasterDetail.isCommunicationOverInternet.value){
            print(MasterDetail.isCommunicationOverInternet.value);
            CommunicationManager.getInstance().refreshMqttSubscription();
          }*/

          FlutterApp.deviceName = Building.getInstance().getDeviceAtIndex(index).name;
        },
        splashColor: Colors.blueGrey,
        child: LayoutBuilder(builder: (ct, cr) {
          return new Container(
            child: new Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Icon(
                    ThemeManager
                        .iconListForDevice[Building.getInstance()
                            .getDeviceAtIndex(index)
                            .iconIndex]
                        .icon,
                    size: 42,
                    color: themeVal == 2
                        ? (index ==
                                Building.getInstance()
                                    .getSelectedRoom()
                                    .indexChildList)
                            ? ThemeManager.colorSelected
                            : ThemeManager.boxUnselectedColor
                        : (index ==
                                Building.getInstance()
                                    .getSelectedRoom()
                                    .indexChildList)
                            ? ThemeManager.colorSelected
                            : ThemeManager.unselectedColor,
                  ),
                  Center(
                      child: Text(
                    Building.getInstance().getDeviceAtIndex(index).name,
                  )),
                ],
              ),
            ),
            decoration: themeVal == 2
                ? new BoxDecoration(border: new Border.all(color: Colors.amber))
                : new BoxDecoration(
                    border: new Border.all(color: Colors.yellowAccent)),
            //    margin: const EdgeInsets.all(3.0),
          );
        }),
      ),
    );
  }

  /// Alert dialog to change the icon of the [Devices].
  Future<Null> changeIcon(int index) async {

    String devicessidPassword = Building.getInstance().getDeviceAtIndex(index).deviceID + Building.getInstance().getDeviceAtIndex(index).password;


    // Close previous alert dialog.
    Navigator.of(context).pop();

    // All icon options for [Device] are displayed to user,
    // user can select one of those icons to set new icon to the selected [Device],
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
              children: ThemeManager.iconListForDevice.map((T) {
                return Material(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0))),
                  elevation: 5.0,
                  shadowColor: Colors.black,
                  color: themeVal == 2 ? Colors.black : Colors.grey,
                  child: InkWell(
                    onTap: () {
                     /* setState(() => (Building.getInstance().getDeviceAtIndex(index).iconIndex = ThemeManager.iconListForDevice.indexOf(T)));
                      dataChangeNotifier.value = !dataChangeNotifier.value;
                      Building.getInstance().updateDB();
                      Navigator.of(context).pop();*/

                      Navigator.of(context).pop();

                      setState(() {
                        _loading = true;
                      });

                      Map<String, dynamic> map = new HashMap();
                      map["user_id"] = FlutterApp.userID;
                      map["deviceid"] = devicessidPassword;
                      map["iconIndex"] = ThemeManager.iconListForDevice.indexOf(T);

                      String mMap = jsonEncode(map);

                      print(mMap);
                      print('homeIconsJsonData...');

                      Future.delayed(const Duration(seconds: 3), () async {

                        setState(() {
                          CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/global_in_ack/kitouchplus_update_device_icon_ack");
                          CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_update_device_icon",mMap);
                          setState(() {
                            _loading = false;

                            setState(() => (Building.getInstance().getDeviceAtIndex(index).iconIndex = ThemeManager.iconListForDevice.indexOf(T)));
                            dataChangeNotifier.value = !dataChangeNotifier.value;

                            Building.getInstance().updateDB();
                          });
                        });
                      });





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

  /// Alert dialog to change the name of the [Devices].
  Future<Null> changeName(int index) async {

    String devicessidPassword = Building.getInstance().getDeviceAtIndex(index).deviceID + Building.getInstance().getDeviceAtIndex(index).password;

    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Text editing UI is displayed to user.
    // User can change name of the [Device] and press Rename to change name,
    // or just select cancel to abort the icon change.
    final c = TextEditingController();
    final TextField tf = TextField(
      autofocus: true,
      controller: c,
      decoration: InputDecoration(
          labelText: 'Rename Device to: ', hintText: 'eg. My Device'),
    );
 //   c.text = Building.getInstance().getDeviceAtIndex(index).name;   //by arti
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename : ' +
              '"' +
              Building.getInstance().getDeviceAtIndex(index).name +
              '"'),
          content: tf,
          actions: <Widget>[
            FlatButton(
              child: Text('Rename',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {

                if(c.text.isEmpty){
                  FToast.showRed('Please enter device name');
                }
                else if(deviceValidations.contains(c.text)){
                  FToast.showRed('Device already exist!');
                }

                else{

                  setState(() {
                    FlutterApp.indexVal = index;
                    FlutterApp.renameDeviceVal = c.text;
                  });
                  Navigator.of(context).pop();

                  setState(() {
                    _loading = true;
                  });

                  Map<String, dynamic> map = new HashMap();
                  map["deviceid"] = devicessidPassword;
                  map["user_id"] = userID;
                  map["new_name"] = c.text;
                  String mMap = jsonEncode(map);

                  print(mMap);

                  CommunicationManager.getInstance().connection();

                  Future.delayed(const Duration(seconds: 3), () async {

                    setState(() {
                      CommunicationManager.getInstance().syncSubscribe(userID + "/global_in_ack/kitouchplus_rename_device_ack");
                      CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_rename_device",mMap);
                      setState(() {
                        _loading = false;
                      });

                      dataChangeNotifier.value = !dataChangeNotifier.value;
                    });
                  });
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

  /// Alert dialog to delete the [Devices] from selected [Room].
  Future<Null> delete(int index) async {

    String devicessidPassword = Building.getInstance().getDeviceAtIndex(index).deviceID + Building.getInstance().getDeviceAtIndex(index).password;

    print("getssidpassword:::");
    print(devicessidPassword);
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Confirmation dialog to user to confirm about deleting [Device] from selected [Room].
    // [Device] is deleted from selected [Room] if user confirms or user can abort by clicking on cancel.

    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('"' +
              Building.getInstance().getDeviceAtIndex(index).name +
              '" will be deleted permenantly.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes, Delete',
                  style: TextStyle(color: themeVal == 2 ? Colors.blue : Colors.red)),
              onPressed: () {
                checkInternet();
                ///added this delete device from server via mqtt first n then from local database

                if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {

                    CommunicationManager.getInstance().connection();
                    setState(() {
                      FlutterApp.indexVal = index;
                    });
                    Navigator.of(context).pop();

                    setState(() {
                      _loading = true;
                    });

                    Map<String, dynamic> map = new HashMap();
                    map["deviceid"] = devicessidPassword;
                    map["user_id"] = userID;
                    String mMap = jsonEncode(map);


                    Future.delayed(const Duration(seconds: 2), () async {

                      setState(() {
                        CommunicationManager.getInstance().syncSubscribe(userID + "/global_in_ack/kitouchplus_delete_device_ack");
                        CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_delete_device",mMap);
                        setState(() {
                          _loading = false;
                        });

                        dataChangeNotifier.value = !dataChangeNotifier.value;
                      });
                    });

                }
                else{
                  FToast.showRed(Messages.NO_INTERNET);
                }
              },
            ),
            FlatButton(
              child: Text('Remove',
                  style: TextStyle(color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                ///delete device from locally only

                pref.getString(SharedKey().deviceNameForBackup).then((val) {

                  print(val);
                  print('prefchecl..');

                  if(val == Building.getInstance().getDeviceAtIndex(index).name){
                    Building.getInstance().getSelectedRoom().childList.removeAt(index);
                    Building.getInstance().getSelectedRoom().indexChildList = 0;
                    Navigator.of(context).pop();
                    Building.getInstance().updateDB();

                    setState(() {
                      dataChangeNotifier.value = !dataChangeNotifier.value;
                    });

                    pref.putString(SharedKey().ONEDEVICE_AUTOBACKUP, '');
                    pref.putString(SharedKey().deviceBackupKey, '0');
                    pref.putString(SharedKey().deviceNameForBackup, '');

                  }else{
                    FToast.showRed('This device cannot be deleted from locally!');
                  }
                });
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

  /// Alert dialog to edit configurations of the [Devices] pointed by [index] from selected [Room].
  Future<Null> editDevice(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Confirmation dialog to user to confirm about changing configuration of the [Device].
    // User us routed to the preference screen to change configuration if user confirms,
    // or user can abort by clicking on cancel.
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Redirecting'),
          content:
              Text('You will be redirected to change devices configurations.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirm',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();

                setState(() => (Building.getInstance().getSelectedRoom().indexChildList = index));
                dataChangeNotifier.value = !dataChangeNotifier.value;
                Navigator.of(context).pushNamed(DeviceConfig.tag);

                setState(() {
                  MasterDetail.isCommunicationOverInternet.value = false;
                  FlutterApp.checkMqttConnection = false;

                });
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
//    ));

    // Returning single row grid view with above list as child.
    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? gridViewScene(sceneList)
            : gridViewSceneLand(sceneList);
      },
    );
  }

  Widget gridViewScene(List<Widget> sceneList) {
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(1.0),
      childAspectRatio: 2.0,
      shrinkWrap: true,
      children: sceneList,
    );
  }

  Widget gridViewSceneLand(List<Widget> sceneList) {
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(1.0),
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
          Building.getInstance().getSelectedRoom().sceneList.length, 1),
    );
  }

  /// Scene list of required [length].
  ///
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
                        .getRoomSceneAtIndex(index)
                        .listStates[Building.getInstance()
                            .getRoomSceneAtIndex(index)
                            .stateIndex]
                        .iconIndex]
                    .icon,
                size: Device.get().isTablet
                    ? cr.biggest.height * .3
                    : cr.biggest.height * .6,
                color: themeVal == 2
                    ? (Building.getInstance()
                            .getRoomSceneAtIndex(index)
                            .flagOnOff)
                        ? ThemeManager.colorSelected
                        : ThemeManager.boxUnselectedColor
                    : (Building.getInstance()
                            .getRoomSceneAtIndex(index)
                            .flagOnOff)
                        ? ThemeManager.colorSelected
                        : ThemeManager.unselectedColor,
              ),
              Center(
                  child: Text(
                Building.getInstance().getRoomSceneAtIndex(index).name,
              )),
            ],
          );
        }),

        // On tap of the scene element, command is sent to set the scene.
        onTap: () async {

    //      FToast.showRed('deviceview code');

          String displayMessage = 'Sending Command to set scene: ' +
              Building.getInstance().getDeviceSceneAtIndex(index).name +
              '...';
          print("Mood::displayMessage::$displayMessage");

          // [indexList] is needed by the communication engine to send commands.
          // This list has all the information required to send the the command.
          List<int> indexList = [
            Building.getInstance().indexChildList, // Selected [Home].
            Building.getInstance().getSelectedHome().indexChildList, // Selected [Room].
            index // index of scene of which state needs to be changed.
          ];

          // Sending command using mechanism provided by [ConnectionManager].
          // Waiting for result of the command send,
          // if command send is failed, user sees message in red
          bool result = await CommunicationManager.getInstance().sendCommand(indexList);

          print(result);
          print(indexList);
          print('check11...');

          // Notifying changes on UI, as after command is sent UI should be updated.
          dataChangeNotifier.value = !dataChangeNotifier.value;

          // If all scenes are visible we need to close alert dialog.
          if (type == 1) Navigator.of(context).pop();

          // Showing confirmation/failure message to user about command.
          /*Scaffold.of(context).showSnackBar(SnackBar(
            backgroundColor: result ? null : Colors.red,
            duration: Duration(seconds: 1),
            content: result ? Text("") : Text(noConnection),
          ));*/
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
                    Building.getInstance().getRoomSceneAtIndex(index).name),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      MaterialButton(
                          child: Text('Change Icon'),
                          onPressed: () => changeIconOfScene(index)),
                      MaterialButton(
                          child: Text('Change Name'),
                          onPressed: () => changeNameOfScene(index)),
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
  Future<Null> changeIconOfScene(int index) async {
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
                              .getRoomSceneAtIndex(index)
                              .listStates[Building.getInstance()
                                  .getRoomSceneAtIndex(index)
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
    c.text = Building.getInstance().getRoomSceneAtIndex(index).name;
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename : ' +
              '"' +
              Building.getInstance().getRoomSceneAtIndex(index).name +
              '"'),
          content: tf,
          actions: <Widget>[
            FlatButton(
              child: Text('Rename',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                setState(() => (Building.getInstance()
                    .getRoomSceneAtIndex(index)
                    .name = c.text));
                dataChangeNotifier.value = !dataChangeNotifier.value;
                Building.getInstance().updateDB();
              //  getHomeListDataFromSelectedItem();
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

  var deviceString;
  Map<String, dynamic> cMap = new HashMap();
  List<dynamic> mSynchData = new List();
  String userID;

  getHomeListDataFromSelectedItem() {

    var deviceStr = [];

    pref.getString(SharedKey().RECEIVE_DATA).then((val) {
      if (val != null) {
        deviceStr = val.split(",");
        print("deviceStr:: $deviceStr");
      } else {}
    });

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
          deviceMap["ip"] = d.ip;   //by arti

          deviceMap["switches"] = FlutterApp.deviceString;
          print("deviceViewDeviceString::$FlutterApp.deviceString");

          List<dynamic> mControlPoints = new List();
          for (ControlPoint c in d.childList) {
            Map<String, dynamic> pointMap = new HashMap();
            pointMap["name"] = c.name;
            pointMap["type"] = c.type;
            pointMap["isVisible"] = c.isVisible;
            pointMap["idChar"] = c.idChar;

            List<dynamic> mStates = new List();

            for(int i=0; i < c.listStates.length; i++){
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
    cMap["syncData"] = mSynchData;
    cMap["user_id"] = userID;
    deviceValidations = json.encode(cMap);
    pref.putString(SharedKey().SYNC_DATA, deviceValidations);
    print("cMap::$cMap");
    print("cMap v::${cMap}");
  }

  @override
  void initState() {
    // TODO: implement
    super.initState();

    getPrefHomeVal();

    pref.getString(SharedKey().DEVICE_STRING).then((value) {

      if(mounted){
        setState(() {
          deviceString = value;
          print("deviceString::$deviceString");
        });
      }

      pref.getString(SharedKey().SYNC_DATA).then((val) {
        if (val != null) {
          synchData = val;

        } else {
          synchData = "";
        }});


      pref.getString(SharedKey().USER_ID).then((val) {
        if(mounted){
          setState(() {
            if (val != null) {
              userID = val;
              print("userID::$userID");

            }
          });
        }

      });
      pref.getString(SharedKey().THEME_VALUE).then((val) {
        if (val != null) {

          if(mounted){
            setState(() {
              themeVal = int.parse(val);
              FlutterApp.themeValue = int.parse((val));
            });
          }
        }
      });
    });


    checkInternetForBackup();
  }

  void getPrefHomeVal() async {
    sharedPreferences = await SharedPreferences.getInstance();

    if(mounted){
      setState(() {
        prefHome = sharedPreferences.getBool("sethome");
        prefRoom = sharedPreferences.getBool("setroom");
        print('----gotprefvalueAt[DeviceView]----$prefHome ---- $prefRoom');
      });
    }
  }

  /// backup for device json data collected here
  getEachDeviceData(){
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
          List<dynamic> mStates = new List();

          for(int i=0; i < c.listStates.length; i++){
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

        roomMap["switchboxes"] = mSwitchBoxes;
        mRoomList.add(roomMap);
        homeMap["rooms"] = mRoomList;
        mSynchData.add(homeMap);

        cMap["syncData"] = mSynchData;
        cMap["user_id"] = FlutterApp.userID;
        String data = json.encode(cMap);

        print('single device backup deviceview');
        log(data);

        pref.putString(SharedKey().ONEDEVICE_AUTOBACKUP, data);
      }
    });
  }

  checkInternetForBackup() async {

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }

      pref.getString(SharedKey().roomBackupKey).then((valKey) {
        print('roomkey..');
        print(valKey);

        pref.getString(SharedKey().roomNameForBackup).then((valRoomName) {

          if(valKey.contains('1') && valRoomName == Building.getInstance().getSelectedRoom().name){

            pref.getString(SharedKey().OneRoomAutobackup).then((valRoom) {

              roomBackup = valRoom;

              print('roomJson');
              print(valRoom);

              ProgressBar.show(context);
                roomBackup = valRoom;
                Future.delayed(const Duration(seconds: 2), () async {

                  setState(() {
                    CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/global_in_ack/kitouchplus_add_room_ack");
                    CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_add_room", roomBackup);
                  });

                  ProgressBar.dismiss(context);

                });
            });

          }else{}
        });
      });
    } on SocketException catch (_) {
      print('not connected');

      FToast.showRed("You are not connected to Internet");
      status = "ConnectivityResult.none";

    }
  }

  checkInternet()async{
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
