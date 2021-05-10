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
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
import 'package:ioskitouchnew/screens/controlScreens/deleteDialog.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/addElementScreen.dart';
import 'package:ioskitouchnew/screens/settings/backupSuccessAnim.dart';
import 'package:ioskitouchnew/themeManager.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../CheckInternetConnection.dart';

/// [RoomView] Displays the grid of [Room]s.
/// With this view users can interact to choose which [Room] they want to control.
/// It uses [childList] of selected [Home] from [Building] data set to form the view.
class RoomView extends StatefulWidget {
  /// Change event notifiers used here to notify changes in data/ui.
  /// Other classes can listen to these notifiers to take actions accordingly.

  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);

  /// Makes Object of [RoomView] class.
  ///
  /// Also adds replicate listeners to [sceneChangeNotifier] and [dataChangeNotifier] from state class {[_RoomViewState]}.
  /// Actual data/view change happens in state class these changes need to be propagated up in the display hierarchy.
  /// These propagation is done by these replication of event listeners.
  RoomView() {
    // Replication of change events on [_RoomViewState.sceneChangeNotifier].
    _RoomViewState.sceneChangeNotifier.addListener(() =>
    (sceneChangeNotifier.value = _RoomViewState.sceneChangeNotifier.value));

    // Replication of change events on [_RoomViewState.dataChangeNotifier].
    _RoomViewState.dataChangeNotifier.addListener(() =>
    (dataChangeNotifier.value = _RoomViewState.dataChangeNotifier.value));
  }

  /// Creating state class to manage states.
  @override
  State<StatefulWidget> createState() => _RoomViewState();
}

/// [_RoomViewState] is a state class of [RoomView].
/// It creates and maintains UI and its different states for [RoomView].
///
/// When user interacts with [RoomView], data-set or UI might need be updated,
/// [_RoomViewState] notifies these updates in data-set or UI.
class _RoomViewState extends State<RoomView> {
  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);
  int themeVal;
  SharedPreferences sharedPreferences;
  bool prefHome=false, _loading = false;
  SharedPreference pref = new SharedPreference();
  String status;
  String homeBackup = '', roomCheckValidations = '';

  @override
  void initState() {
    super.initState();

    getPrefHomeVal();
    pref.getString(SharedKey().THEME_VALUE).then((val) {
      if (val != null) {

        if(mounted){
          setState(() {
            FlutterApp.deviceName = '';
            themeVal = int.parse(val);
            FlutterApp.themeValue = int.parse((val));
          });
        }
        print("themeVal home1::$themeVal");
      }
    });

    checkInternetForBackup();
  }

  /// Method to build UI with grid of [Room]s.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Colors.blue,
          size: 50,
        ),
        dismissible: false,
        child: Scaffold(
          resizeToAvoidBottomInset : false,
          body: OrientationBuilder(builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? Building.isDatabaseUpdating.value == true
                ? gridView()
                : gridView()
                : Building.isDatabaseUpdating.value == true
                ? gridViewLand()
                : gridViewLand();
          }),
        ),
      ),
      onWillPop: () => Future.value(false),

    );
  }

  Widget gridView() {
    return Column(
      verticalDirection: VerticalDirection.down,
      children: <Widget>[
        // Grid view of [Room]s 2 in one row.
        // Other spacing parameters just for the clean and simple look.
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            padding: const EdgeInsets.all(10.0),
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            children: makeGridView(),
          ),
        ),
      ],
    );
  }

  Widget gridViewLand() {
    return Column(
      verticalDirection: VerticalDirection.down,
      children: <Widget>[
        // Grid view of [Room]s 6 in one row.
        // Other spacing parameters just for the clean and simple look.
        Expanded(
          child: GridView.count(
            crossAxisCount: 8,
            childAspectRatio: 1.0,
            padding: const EdgeInsets.all(10.0),
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            children: makeGridView(),
          ),
        ),
      ],
    );
  }

  /// Making list of widgets to be displayed in grid view.
  /// It generates list of view elements for every [Room] of selected [Home].
  List<Widget> makeGridView() {
    List<Widget> list = List();

    if (Building.getInstance().getSelectedHome().childList.length != 0) {
      // Adding every [Room] of selected [Home].
      for (int index = 0;
      index < Building.getInstance().getSelectedHome().childList.length;
      index++) {
        //  if (index != 0) {
        if (Building.getInstance().getSelectedHome().childList[index].name !=
            "Demo Room") {
          list.add(makeGridCell(index));
        } else {

          list.add(Material(
            child: InkWell(
              onTap: () {

                if(prefHome==true){
                  AddElementScreen.type = 1;
                  Navigator.of(context).pushNamed(AddElementScreen.tag);
                  dataChangeNotifier.value = !dataChangeNotifier.value;
                }
                else if(Building.getInstance().childList[index].name=="My Home"){
                  FToast.show('Please add home first');
                }
               else{
                  AddElementScreen.type = 1;
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
                            child: Text('Add Room',
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
        //}
      }
    } else {
      print("else:::::::error");
      // ADD button card to invoke preference screen to add [Device].
      // If users taps on this card, user is routed to preference screen after confirmation.
      list.add(Material(
        child: InkWell(
          onTap: () {
            AddElementScreen.type = 1;
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
                        child:
                        Text('Add Room', style: TextStyle(fontSize: 12.0))),
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
  /// made with index pointing to [Room] in [childList] of selected [Home].
  ///
  /// It is a card like element which has different functionality for user interactions like tap, long press.
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
                    Building.getInstance().getRoomAtIndex(index).name),
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
                          child: Text('Add Device'),
                          onPressed: () => addChild(index)),

                      MaterialButton(
                          child: Text('Delete Room'),
                          onPressed: () {
                            setState(() => (Building.getInstance().getSelectedHome().indexChildList = index));
                            int deviceLength = Building.getInstance().getSelectedRoom().childList.length;
                            print(deviceLength);

                            if(deviceLength > 1){
                              Navigator.pop(context);

                              showDialog(context: context,
                              builder: (_) => DeleteDialog(msg: "You cannot delete room directly! To delete room, please delete devices one by one",
                                msg1: "Alert",),
                            );
                            }else if(deviceLength == 0){
                              getRoomData(index);
                              delete(index);
                            }

                            else if(Building.getInstance().getDeviceAtIndex(0).name == "Demo Device"){

                              getRoomData(index);
                              delete(index);

                            }else{
                              Navigator.pop(context);

                              showDialog(context: context,
                                  builder: (_) => DeleteDialog(msg: "You cannot delete room directly! To delete room, please delete devices one by one",
                                msg1: "Alert",),);
                            }


                          } ),
                    ],
                  ),
                ),
              );
            },
          );
        },

        // On tap of the [Room] view we set that [Device] as selected one,
        // And navigate UI to next tab so that user can interact with [Device]s.
        // Selected [Room] is marked with different color.
        onTap: () {

          getRoomData(index);  // collect data in this method

          setState(() => (Building.getInstance().getSelectedHome().indexChildList = index));
          sceneChangeNotifier.value = !sceneChangeNotifier.value;
          FlutterApp.roomName = Building.getInstance().getRoomAtIndex(index).name;

          CommunicationManager.getInstance().refreshMqttSubscription();

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
                        .iconListForRoom[Building.getInstance()
                        .getRoomAtIndex(index)
                        .iconIndex]
                        .icon,
                    size: 42,
                    color: themeVal == 2
                        ? (index ==
                        Building.getInstance()
                            .getSelectedHome()
                            .indexChildList)
                        ? ThemeManager.colorSelected
                        : ThemeManager.boxUnselectedColor
                        : (index ==
                        Building.getInstance()
                            .getSelectedHome()
                            .indexChildList)
                        ? ThemeManager.colorSelected
                        : ThemeManager.unselectedColor,
                  ),
                  Center(
                    child: Text(
                      Building.getInstance().getRoomAtIndex(index).name,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            decoration: themeVal == 2
                ? new BoxDecoration(border: new Border.all(color: Colors.amber))
                : new BoxDecoration(
                border: new Border.all(color: Colors.yellowAccent)),
            // margin: const EdgeInsets.all(5.0),
            // padding: const EdgeInsets.all(5.0),
          );
        }),
      ),
    );
  }

  /// Alert dialog to change the icon of the [Room].
  Future<Null> changeIcon(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // All icon options for [Room] are displayed to user,
    // user can select one of those icons to set new icon to the selected [Room],
    // or just select cancel to abort the icon change.
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose  icon'),
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
              children: ThemeManager.iconListForRoom.reversed.map((T) {
                return Material(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0))),
                  elevation: 5.0,
                  shadowColor: Colors.black,
                  color: themeVal == 2 ? Colors.black : Colors.grey,
                  child: InkWell(
                    onTap: () {
                      int iconIndexVal;
                      /*setState(() => (Building.getInstance().getRoomAtIndex(index).iconIndex = ThemeManager.iconListForRoom.indexOf(T)));
                      dataChangeNotifier.value = !dataChangeNotifier.value;
                      Building.getInstance().updateDB(); //by arti
                      Navigator.of(context).pop();*/

                      print('iconval...');
                      print(Building.getInstance().getRoomAtIndex(index).iconIndex);
                   //   print(ThemeManager.iconListForRoom.indexOf(T));

                      Navigator.of(context).pop();

                      setState(() {
                        _loading = true;
                     //   FlutterApp.indexValIcons = ThemeManager.iconListForRoom.indexOf(T);
                        FlutterApp.indexVal = index;
                        iconIndexVal = Building.getInstance().getRoomAtIndex(index).iconIndex;
                      });

                      Map<String, dynamic> map = new HashMap();
                      map["user_id"] = FlutterApp.userID;
                      map["home_name"] = Building.getInstance().getSelectedHome().name;
                      map["room_name"] = Building.getInstance().getRoomAtIndex(index).name;
                      map["iconIndex"] = ThemeManager.iconListForRoom.indexOf(T);

                      String mMap = jsonEncode(map);

                      print(mMap);
                      print('roomIconsJsonData...');

                      Future.delayed(const Duration(seconds: 3), () async {

                        setState(() {
                          CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/global_in_ack/kitouchplus_update_room_icon_ack");
                          CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_update_room_icon",mMap);
                          setState(() {
                            _loading = false;

                            Building.getInstance().getRoomAtIndex(index).iconIndex = ThemeManager.iconListForRoom.indexOf(T);
                            dataChangeNotifier.value = !dataChangeNotifier.value;
                            Building.getInstance().updateDB();
                          });
                        });
                      });

                    },
                    splashColor: Colors.blueGrey,  //blueGrey
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

  /// Alert dialog to change the name of the [Room].
  Future<Null> changeName(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Text editing UI is displayed to user.
    // User can change name of the [Room] and press Rename to change name,
    // or just select cancel to abort the icon change.
    final c = TextEditingController();
    final TextField tf = TextField(
      autofocus: true,
      controller: c,
      decoration: InputDecoration(
          labelText: 'Rename Room to: ', hintText: 'eg. My Room'),
    );
  //  c.text = Building.getInstance().getRoomAtIndex(index).name;
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename : ' +
              '"' +
              Building.getInstance().getRoomAtIndex(index).name +
              '"'),
          content: tf,
          actions: <Widget>[
            FlatButton(
              child: Text('Rename',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {

                if(c.text.isEmpty){
                  FToast.showRed('Please enter room name');
                }
                else if(roomCheckValidations.contains(c.text)){
                  FToast.showRed('Room already exist!');
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
                  map["user_id"] = FlutterApp.userID;
                  map["old_room_name"] = Building.getInstance().getRoomAtIndex(index).name;
                  map["new_room_name"] = c.text;
                  map["home_name"] = Building.getInstance().getSelectedHome().name;

                  String mMap = jsonEncode(map);

                  print(mMap);
                  print('roomRenameJsonData...');


                  Future.delayed(const Duration(seconds: 3), () async {

                    setState(() {
                      CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/global_in_ack/kitouchplus_rename_room_ack");
                      CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_rename_room",mMap);
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

  /// Alert dialog to delete the [Room] from selected [Home].
  Future<Null> delete(int index) async {

// arti changes to delete pref value
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences.setBool("setroom",false);
      sharedPreferences.commit();
      print('-----prefvalue [roomview] delete value------');
      print(prefHome);
    });

    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Confirmation dialog to user to confirm about deleting [Room] from [Home].
    // [Room] is deleted from [Home] if user confirms or user can abort by clicking on cancel.
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('"' +
              Building.getInstance().getRoomAtIndex(index).name +
              '" will be deleted permenantly.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes, Delete',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {

                checkInternet();


                if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {

                    CommunicationManager.getInstance().connection();
                    setState(() {
                      FlutterApp.indexVal = index;
                    });
                    Navigator.of(context).pop();
                    setState(() {
                      _loading = true;
                    });
                    pref.getString(SharedKey().OneRoomAutobackup).then((valRoom) {
                      if(valRoom != null){
                        Future.delayed(const Duration(seconds: 2), () async {

                          setState(() {
                            CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/global_in_ack/kitouchplus_delete_room_ack");
                            CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_delete_room",valRoom);

                            setState(() {
                              _loading = false;
                            });
                            dataChangeNotifier.value = !dataChangeNotifier.value;
                          });
                        });
                      }
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
                ///delete room from locally only

                pref.getString(SharedKey().roomNameForBackup).then((val) {

                  if(val == Building.getInstance().getRoomAtIndex(index).name){
                    Building.getInstance().getSelectedHome().childList.removeAt(index);
                    Building.getInstance().getSelectedHome().indexChildList = 0;


                    Navigator.of(context).pop();
                    Building.getInstance().updateDB();

                    setState(() {
                      dataChangeNotifier.value = !dataChangeNotifier.value;
                    });

                    pref.putString(SharedKey().OneRoomAutobackup, '');
                    pref.putString(SharedKey().roomBackupKey, '0');
                    pref.putString(SharedKey().roomNameForBackup, '');

                  }else{
                    FToast.showRed('This room cannot be deleted from locally!');
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

  /// Alert dialog to add a [Device] to selected [Room].
  Future<Null> addChild(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Confirmation dialog to take user to the preference screen to add a [Device] to the [Room] pointed by the [index].
    // User is routed to preference screen after confirmation to add [Room].
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Redirecting'),
          content:
          Text('You will be redirected to settings to add/edit Devices.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirm',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => (Building.getInstance().getSelectedHome().indexChildList = index));
                dataChangeNotifier.value = !dataChangeNotifier.value;

                Building.getInstance().updateDB();  //by arti

                AddElementScreen.type = 2;
                Navigator.of(context).pushNamed(AddElementScreen.tag);
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

  void getPrefHomeVal() async{

    sharedPreferences = await SharedPreferences.getInstance();

    if(mounted){
      setState(() {
        prefHome = sharedPreferences.getBool("sethome");
    //    print('----gotprefvalueAtRoomScreen----$prefHome');

      });
    }
  }

  ///forward this information to server for adding data at server side home and room data and rest to dummy
  getRoomData(int index){

    Map<String, dynamic> cMap = new HashMap();
    List<dynamic> roomSyncData = new List();

      Map<String, dynamic> homeMap = new HashMap();
      homeMap["home_name"] = Building.getInstance().getSelectedHome().name;
      homeMap["iconIndex"] = Building.getInstance().getSelectedHome().iconIndex;
      homeMap["home_id"] = "dummy";

      List<dynamic> mRoomList = new List();
      Map<String, dynamic> roomMap = new HashMap();
      roomMap["home_id"] = "dummy";
      roomMap["room_id"] = "dummy";
      roomMap["room_name"] = Building.getInstance().getRoomAtIndex(index).name;
      roomMap["iconIndex"] = Building.getInstance().getRoomAtIndex(index).iconIndex;

      roomMap["switchboxes"] = [];

      mRoomList.add(roomMap);
      homeMap["rooms"] = mRoomList;
      roomSyncData.add(homeMap);

      cMap["syncData"] = roomSyncData;
      cMap["user_id"] = FlutterApp.userID;
      String data = json.encode(cMap);

      print('single room data ');
      print(data);

      pref.putString(SharedKey().OneRoomAutobackup, data);
  }

  checkInternetForBackup() async {

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }

      pref.getString(SharedKey().homeBackupKey).then((valKey) {
        print('homekey..');
        print(valKey);

        pref.getString(SharedKey().homeNameForBackup).then((valHomeName) {

          if(valKey.contains('1') && valHomeName == Building.getInstance().getSelectedHome().name){

            pref.getString(SharedKey().OneHomeAutobackup).then((valHome) {

              homeBackup = valHome;

              print('homeJson');
              print(valHome);

              if ( valHome.length > 85 ) {

                ProgressBar.show(context);
                homeBackup = valHome;
                Future.delayed(const Duration(seconds: 2), () async {

                  setState(() {
                    CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/global_in_ack/kitouchplus_add_home_ack");
                    CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_add_home", homeBackup);
                  });

                  ProgressBar.dismiss(context);

                });
              }
            });

          }else{
            print('empty');
          }
        });
      });
    } on SocketException catch (_) {
      print('not connected');

      FToast.showRed("You are not connected to Internet");
      status = "ConnectivityResult.none";

    }
  }

  List<Home> mHomes = new List();
  Map<String, dynamic> cMap = new HashMap();

  getHomeListDataFromSelectedItem() {
    List<dynamic> mSynchData = new List();
    //todo get [userId] from login details
    for (Home h in Building
        .getInstance()
        .childList) {
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
          deviceMap["ip"] = d.ip; //by arti

          deviceMap["switches"] = FlutterApp.deviceString;

          String fApp = FlutterApp.deviceString;
          print("addElementDeviceString::$FlutterApp.deviceString");

          mRoomList.add(roomMap);
        }
        homeMap["rooms"] = mRoomList;
        mSynchData.add(homeMap);
      }
      cMap["syncData"] = mSynchData;
      cMap["user_id"] = FlutterApp.userID;
      roomCheckValidations = json.encode(cMap);
      print('roomvalidations:--');
      log(roomCheckValidations);

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
