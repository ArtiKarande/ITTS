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
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/Messages.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
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
import '../../CommunicationManager.dart';

/// [HomeView] Displays the grid of [Home]s.
/// With this view users can interact to choose which [Home] they want to control.
/// It uses [childList] of [Building] data set to form the view.
class HomeView extends StatefulWidget {
  /// Change event notifiers used here to notify changes in data/ui.
  /// Other classes can listen to these notifiers to take actions accordingly.

  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);

  /// Makes Object of [HomeView] class.
  ///
  /// Also adds replicate listeners to [sceneChangeNotifier] and [dataChangeNotifier] from state class {[_HomeViewState]}.
  /// Actual data/view change happens in state class these changes need to be propagated up in the display hierarchy.
  /// These propagation is done by these replication of event listeners.
  HomeView() {
    // Replication of change events on [_HomeViewState.sceneChangeNotifier].
    _HomeViewState.sceneChangeNotifier.addListener(() =>
        (sceneChangeNotifier.value = _HomeViewState.sceneChangeNotifier.value));

    // Replication of change events on [_HomeViewState.dataChangeNotifier].
    _HomeViewState.dataChangeNotifier.addListener(() =>
        (dataChangeNotifier.value = _HomeViewState.dataChangeNotifier.value));
  }

  /// Creating state class to manage states.
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

/// [_HomeViewState] is a state class of [HomeView].
/// It creates and maintains UI and its different states for [HomeView].
///
/// When user interacts with [HomeView], data-set or UI might need be updated,
/// [_HomeViewState] notifies these updates in data-set or UI.

class _HomeViewState extends State<HomeView> {
  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);
  bool defaultFlag = false;
  bool setNav = false;
  SharedPreference pref = new SharedPreference();
  int onBackPressCounter = 0;
  SharedPreferences sharedPreferences;
  bool prefHome=true, _loading = false, check = false;

  var deviceString;
  Map<String, dynamic> cMap = new HashMap();
  List<dynamic> mSynchData = new List();

  String userID, homeCheckValidations = '';

  int themeVal;
  String synchData, status;

  /// Method to build UI with grid of [Home]s.
  @override
  Widget build(BuildContext context) {
    // Grid view of [Home]s 2 in one row.
    // Other spacing parameters just for the clean and simple look.
    return ModalProgressHUD(
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
          ? Building.isDatabaseUpdating.value == true ? gridView() : gridView()
          : Building.isDatabaseUpdating.value == true
              ? gridViewLand()
              : gridViewLand();
        }),
      ),
    );
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
       //         CommunicationManager.getInstance().originalConnection();
                CommunicationManager.getInstance().connection();
              },
            ),
          ],
        );
      },
    );
  }

  void syncData() {
    print("synchData::$synchData");
    CommunicationManager.getInstance().connection();
    Future.delayed(const Duration(milliseconds: 15000), () async {
      setState(() {
        CommunicationManager.getInstance()
            .syncSubscribe(userID + "/kitouchplus_app_to_server_ack");
        CommunicationManager.getInstance()
            .publishSync("global_in_ack/kitouchplus_app_to_server", synchData);
      });
      ProgressBar.dismiss(context);
    });
  }

  Widget gridView() {
    return Column(verticalDirection: VerticalDirection.down, children: <Widget>[
      // Grid view of [Room]s 4 in one row.
      // Other spacing parameters just for the clean and simple look.
      Expanded(
          child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        children: makeGridView(),
      ))
    ]);
  }

  Widget gridViewLand() {
    return Column(verticalDirection: VerticalDirection.down, children: <Widget>[
      // Grid view of [Room]s 6 in one row.
      // Other spacing parameters just for the clean and simple look.
      Expanded(
          child: GridView.count(
        crossAxisCount: 8,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.all(5.0),
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        children: makeGridView(),
      ))
    ]);
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

  /// Making list of widgets to be displayed in grid view.
  /// It generates list of view elements for every [Home] of [Building].
  List<Widget> makeGridView() {
    List<Widget> list = List();
    if (Building.getInstance().childList.length != 0) {
      // Adding every [Home] of [Building].
      for (int index = 0;
          index < Building.getInstance().childList.length;
          index++) {
        // if(index!=0) {
        if (Building.getInstance().childList[index].name != "My Home") {
          list.add(makeGridCell(index));
          if (FlutterApp.counter != 0) {
       //     print("grid counter:::${FlutterApp.counter}");
          } else {
         //   print(" else grid counter:::${FlutterApp.counter}");
            getLocalValues(index);
          }
        } else {
          list.add(Material(
            child: InkWell(
              onTap: () {
                AddElementScreen.type = 0;
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
                        Center(child: Text('Add Home')),
                      ],
                    ),
                  ),
                  decoration: themeVal == 2
                      ? new BoxDecoration(
                          border: new Border.all(color: Colors.amber))
                      : new BoxDecoration(
                          border: new Border.all(color: Colors.yellowAccent)),
                );
              }),
            ),
          ));
        }
        // }
      }
    } else {
      // ADD button card to invoke preference screen to add [Device].
      // If users taps on this card, user is routed to preference screen after confirmation.
      list.add(Material(
        child: InkWell(
          onTap: () async{

            AddElementScreen.type = 0;
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
                    Center(child: Text('Add Home')),
                  ],
                ),
              ),
              decoration: themeVal == 2
                  ? new BoxDecoration(
                      border: new Border.all(color: Colors.amber))
                  : new BoxDecoration(
                      border: new Border.all(color: Colors.yellowAccent)),
            );
          }),
        ),
      ));
    }
    return list;
  }

  /// Single Element in grid,
  /// made with index pointing to [Home] in [childList] of [Building].
  ///
  /// It is a card like element which has different functionality for user interactions like tap, long press.
  Material makeGridCell(int index) {
    return Material(
      child: InkWell(
        // on long press we display alert dialog with more options.
        // on click on those more options we trigger respective methods.
        onLongPress: () {
          getLocalValues(index);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Edit - ' +
                    Building.getInstance().getHomeAtIndex(index).name),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      MaterialButton(
                          child: Text('Change Icon'),
                     //     onPressed: () => changeIcon(index)),

                          onPressed: ()async{
                            checkInternet();

                            if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {
                              CommunicationManager.getInstance().connection();
                              changeIcon(index);
                            }
                            else{
                        //      FToast.showRed(Messages.NO_INTERNET);
                            }
                          }),



                      MaterialButton(
                          child: Text('Change Name'),
                          onPressed: ()async{

                            checkInternet();

                          if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {
                            CommunicationManager.getInstance().connection();
                            getHomeListDataFromSelectedItem();
                            changeName(index);
                          }
                          else{
                         //   FToast.showRed(Messages.NO_INTERNET);
                            }
                          }

                          ),

                      MaterialButton(
                          child: Text('Add Room'),
                          onPressed: (){
                              addChild(index);
                          }
                      ),
                      MaterialButton(
                          child: Text('Delete Home'),
                          onPressed: () {
                            setState(() => (Building.getInstance().indexChildList = index));

                            print('home ye re..');

                            int roomLength = Building.getInstance().getSelectedHome().childList.length;
                            print(roomLength);

                            if(roomLength > 1){
                              Navigator.pop(context);

                              showDialog(context: context,
                                builder: (_) => DeleteDialog(msg: "You cannot delete Home directly! To delete home, please delete room one by one",
                                  msg1: "Alert",),
                              );

                            }
                            else if(roomLength == 0){
                              delete(index);

                              setState(() {
                                FlutterApp.homeName='';
                              });
                            }

                            else if(Building.getInstance().getRoomAtIndex(0).name == "Demo Room"){
                              getHomeDataJson(index);
                              delete(index);

                              setState(() {
                                FlutterApp.homeName='';
                              });
                            }
                            else{
                              Navigator.pop(context);

                              showDialog(context: context,
                                builder: (_) => DeleteDialog(msg: "You cannot delete Home directly! To delete home, please delete room one by one",
                                  msg1: "Alert",),);
                            }
                          }
                      ),
                      MaterialButton(
                          child: defaultFlag
                              ? Text('Default')
                              : Text('Set as default Home'),
                          onPressed: () => setAsDefault(index))
                    ],
                  ),
                ),
              );
            },
          );
        },

        // On tap of the [Home] view we set that [Home] as selected one,
        // And navigate UI to next tab so that user can interact with [Rooms]s.
        // Selected [Home] is marked with different color.
        onTap: () {

          getHomeDataJson(index);  // collect home json data in this method

          setState(() {

            FlutterApp.homeName = Building.getInstance().getSelectedHome().name;//getHomeAtIndex(index).name;
       //     print(FlutterApp.homeName);
       //     print(Building.getInstance().getSelectedHome().name);
          });

          setState(() => (Building.getInstance().indexChildList = index));
          sceneChangeNotifier.value = !sceneChangeNotifier.value;
    //       getHomeListDataFromSelectedItem();       //ontap  commented by previously its uncommented

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
                    ThemeManager.iconListForHome[Building.getInstance().getHomeAtIndex(index).iconIndex].icon,
                    size: 42,
                    color: themeVal == 2
                        ? (index == Building.getInstance().indexChildList)
                            ? ThemeManager.colorSelected
                            : ThemeManager.boxUnselectedColor
                        : (index == Building.getInstance().indexChildList)
                            ? ThemeManager.colorSelected
                            : ThemeManager.unselectedColor,
                  ),
                  Center(
                      child: Text(
                    Building.getInstance().getHomeAtIndex(index).name,
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            ),
            decoration: themeVal == 2
                ? new BoxDecoration(border: new Border.all(color: Colors.amber))
                : new BoxDecoration(
                    border: new Border.all(color: Colors.yellowAccent)),
            margin: const EdgeInsets.all(5.0),
          );
        }),
      ),
    );
  }

  /// Alert dialog to change the icon of the [Home].
  Future<Null> changeIcon(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // All icon options for [Home] are displayed to user,
    // user can select one of those icons to set new icon to the selected [Home],
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
              children: ThemeManager.iconListForHome.reversed.map((T) {
                return Material(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0))),
                  elevation: 5.0,
                  shadowColor: Colors.black,
                  color: themeVal == 2 ? Colors.black : Colors.grey,
                  child: InkWell(
                    onTap: () {

                    /*  setState(() => (Building.getInstance().getHomeAtIndex(index).iconIndex =
                          ThemeManager.iconListForHome.indexOf(T)));
                      dataChangeNotifier.value = !dataChangeNotifier.value;
                      Building.getInstance().updateDB();
                      Navigator.of(context).pop();*/


                      Navigator.of(context).pop();

                      setState(() {
                        _loading = true;
                      });

                      Map<String, dynamic> map = new HashMap();
                      map["user_id"] = FlutterApp.userID;
                      map["home_name"] = Building.getInstance().getHomeAtIndex(index).name;
                      map["iconIndex"] = ThemeManager.iconListForHome.indexOf(T);

                      String mMap = jsonEncode(map);

                      print(mMap);
                      print('homeIconsJsonData...');

                      Future.delayed(const Duration(seconds: 3), () async {

                        setState(() {
                          CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/global_in_ack/kitouchplus_update_home_icon_ack");
                          CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_update_home_icon",mMap);
                          setState(() {
                            _loading = false;

                            Building.getInstance().getHomeAtIndex(index).iconIndex =
                                ThemeManager.iconListForHome.indexOf(T);
                            dataChangeNotifier.value = !dataChangeNotifier.value;
                            Building.getInstance().updateDB();
                          });
                          dataChangeNotifier.value = !dataChangeNotifier.value;
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

  /// Alert dialog to change the name of the [Home].
  Future<Null> changeName(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Text editing UI is displayed to user.
    // User can change name of the [Home] and press Rename to change name,
    // or just select cancel to abort the icon change.
    final c = TextEditingController();
    final TextField tf = TextField(
      autofocus: true,
      controller: c,
      decoration: InputDecoration(
          labelText: 'Rename Home to: ', hintText: 'eg. My Home'),
    );
  //  c.text = Building.getInstance().getHomeAtIndex(index).name;  //by arti
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename : ' +
              '"' +
              Building.getInstance().getHomeAtIndex(index).name +
              '"'),
          content: tf,
          actions: <Widget>[
            FlatButton(
              child: Text('Rename',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {

                if(c.text.isEmpty){
                  FToast.showRed('Please enter home name');
                }
                else if(homeCheckValidations.contains(c.text)){
                  FToast.showRed('Home already exist!');
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
                  map["old_home_name"] = Building.getInstance().getHomeAtIndex(index).name;
                  map["new_home_name"] = c.text;

                  String mMap = jsonEncode(map);

                  print(mMap);
                  print('homeRenameJsonData...');

                  Future.delayed(const Duration(seconds: 3), () async {

                    setState(() {
                      CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/global_in_ack/kitouchplus_rename_home_ack");
                      CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_rename_home",mMap);
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

  /// Alert dialog to delete the [Home] from [Building].
  Future<Null> delete(int index) async {

    //arti changes
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences.setBool("sethome",false);
      sharedPreferences.setBool("setroom",false);
      sharedPreferences.commit();
      print('-----prefvalue delete function------');
      print(prefHome);
    });

    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Confirmation dialog to user to confirm about deleting [Home] from [Building].
    // [Home] is deleted from [Building] if user confirms or user can abort by clicking on cancel.
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('"' +
              Building.getInstance().getHomeAtIndex(index).name +
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

                    pref.getString(SharedKey().OneHomeAutobackup).then((valHome) {

                      if(valHome != null){
                        Future.delayed(const Duration(seconds: 3), () async {

                          setState(() {
                            CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/global_in_ack/kitouchplus_delete_home_ack");
                            CommunicationManager.getInstance().publishSync("global_in_ack/kitouchplus_delete_home",valHome);

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
                //  FToast.showRed(Messages.NO_INTERNET);
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

  TextEditingController _textFieldController = TextEditingController();

  displayDialog(BuildContext context) async {
    Navigator.of(context).pop();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "TextField in Dialog"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

 /* _showDialog() async {
    Navigator.of(context).pop();
    await showDialog<String>(
      context: context,
      child: new _SystemPadding(
        child: new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Full Name', hintText: 'eg. John Smith'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: const Text('OPEN'),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }*/

  /// Alert dialog to add a [Room] to selected [Home].
  Future<Null> addChild(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Confirmation dialog to take user to the preference screen to add a [Room] to the [Home] pointed by the [index].
    // User is routed to preference screen after confirmation to add [Room].
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Redirecting'),
          content:
              Text('You will be redirected to settings to add/edit rooms.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirm',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => (Building.getInstance().indexChildList = index));
                dataChangeNotifier.value = !dataChangeNotifier.value;
                Building.getInstance().updateDB();  //by arti
                AddElementScreen.type = 1;
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

  ///Method to get values from local
  void getLocalValues(int index) {
    pref.getInt(SharedKey().INDEX_KEY).then((val) {
      if (val != null) {
        if (mounted)
          setState(() {
            if (index == val) {
              print("indexChildList index::: inn");
              Building.getInstance().indexChildList = val;
              setNav = true;
              defaultFlag = true;
              print("Counter init::::${FlutterApp.counter}");
              setState(() {
                setState(() => (Building.getInstance().indexChildList == val));
                sceneChangeNotifier.value = !sceneChangeNotifier.value;
                FlutterApp.counter++;
                //  index =0;
                print("Counter inreament::::${FlutterApp.counter++}");
              });
            }
            // break;
          });
      } else {
        //index=0;
        defaultFlag = false;
      }
    });
  }

  /// Alert dialog to set selected home as default
  Future<Null> setAsDefault(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm',
              style: TextStyle(
                  color: themeVal == 2 ? Colors.black : Colors.white)),
          content: Text(
              'Are you sure want to set ${Building.getInstance().getHomeAtIndex(index).name} as default home.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.blue : Colors.blue)),
              onPressed: () {
                setState(() {
                  ///set default flag in local storage
                  pref.putInt(SharedKey().INDEX_KEY, index);
                  pref.putBool("$index", true);
                  //  getLocalValues();
                  Building.getInstance().indexChildList = index;
                  dataChangeNotifier.value = !dataChangeNotifier.value;
                });
                Building.getInstance().updateDB();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('No',
                  style: TextStyle(
                      color: themeVal == 2 ? Colors.black : Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }



  void removedDefaultData() {
    for (Home h in Building.getInstance().childList) {
      Home home = new Home("", "");
      if (h.name != "My Home") {
        home.name = h.name;
        home.iD = h.iD;
        home.childList = h.childList;
        home.indexChildList = h.indexChildList;
        home.iconIndex = h.iconIndex;
        home.sceneList = h.sceneList;
        mHomes.add(home);
        //   Building.getInstance().updateDB();
      }
      Building.getInstance().childList = mHomes;
      print(
          "mHomes::${Building.getInstance().childList.length}::${mHomes.length}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState

   /* pref.putString(SharedKey().roomBackupKey, '0');
    pref.putString(SharedKey().homeBackupKey, '0');
    pref.putString(SharedKey().deviceBackupKey, '');
    pref.putString(SharedKey().roomNameForBackup, '');
    pref.putString(SharedKey().homeNameForBackup, '');
    pref.putString(SharedKey().deviceNameForBackup, '');*/

    pref.getString(SharedKey().DEVICE_STRING).then((value) {
      setState(() {

        FlutterApp.roomName = '';
        FlutterApp.deviceName = '';
        deviceString = value;
     //   print("deviceStringzzz::$deviceString");
      });
      pref.getString(SharedKey().USER_ID).then((val) {
        setState(() {
          if (val != null) {
            userID = val;
   //         print("userID::$userID");
            FlutterApp.userID = userID;
          }
        });

        pref.getString(SharedKey().THEME_VALUE).then((val) {
          if (val != null) {
            themeVal = int.parse(val);
            FlutterApp.themeValue = int.parse((val));
            print("themeVal::$themeVal");
          }
        });
      });
      pref.getString(SharedKey().SYNC_DATA).then((val) {
        if (val != null) {
          synchData = val;
        // print("synchData 3::$synchData");
        } else {
          synchData = "";
        }
      });
    });

    checkInternet();

    super.initState();
    //  removedDefaultData();
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

      showDialog(
        context: context,
        builder: (_) => FunkyOverlay(msg: "You are not connected to Internet",),
      );
      setState(() {
        status = "ConnectivityResult.none";
      });

    }
  }

  ///forward this information to server for adding data at server side home data and rest to dummy
  getHomeDataJson(int index){

  /*  pref.putString(SharedKey().roomBackupKey, '0');
    pref.putString(SharedKey().homeBackupKey, '0');
    pref.putString(SharedKey().deviceBackupKey, '');
    pref.putString(SharedKey().roomNameForBackup, '');
    pref.putString(SharedKey().homeNameForBackup, '');
    pref.putString(SharedKey().deviceNameForBackup, '');*/


    Map<String, dynamic> cMap = new HashMap();
    List<dynamic> roomSyncData = new List();

    Map<String, dynamic> homeMap = new HashMap();
    homeMap["home_name"] = Building.getInstance().getHomeAtIndex(index).name;
    homeMap["iconIndex"] = Building.getInstance().getHomeAtIndex(index).iconIndex;
    homeMap["home_id"] = "dummy";

    homeMap["rooms"] = [];
    roomSyncData.add(homeMap);

    cMap["syncData"] = roomSyncData;
    cMap["user_id"] = FlutterApp.userID;
    String data = json.encode(cMap);

    print('single home data ');
    print(data);

    pref.putString(SharedKey().OneHomeAutobackup, data);
  }

  List<Home> mHomes = new List();
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
      homeCheckValidations = json.encode(cMap);
      print('homevalidations:--');
      log(homeCheckValidations);

    }
  }

  netConnection(bool isNetworkPresent) {
    print('11');
    print(isNetworkPresent);
    if(isNetworkPresent){

      return true;
    }else{
      setState(() {
        _loading = false;
      });
      FToast.show(Messages.NO_INTERNET);
      return false;
    }
  }
}
