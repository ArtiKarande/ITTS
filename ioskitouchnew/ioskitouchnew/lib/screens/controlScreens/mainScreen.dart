/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:ioskitouchnew/screens/controlScreens/controlPointView.dart';
import 'package:ioskitouchnew/screens/controlScreens/deviceView.dart';
import 'package:ioskitouchnew/screens/controlScreens/homeView.dart';
import 'package:ioskitouchnew/screens/controlScreens/roomView.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/tile.dart';
import 'package:ioskitouchnew/screens/settings/backupSuccessAnim.dart';
import 'package:ioskitouchnew/themeManager.dart';

/// [MainScreen] is a screen with title and tab bars.
/// Tab views corresponding to tabs are generated using [HomeView], [RoomView], etc.
/// As this is a [MainScreen] it sees all events from various parts of code.
/// And take actions according to those events.

class MainScreen extends StatefulWidget {
  /// [tag] is used by the navigator to control screen navigation.
  static final String tag = 'MainScreen';

  /// Creating state class to manage states of [MainScreen].
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

/// [_MainScreenState] is a state class of [MainScreen].
/// It creates and maintains UI, also its different states for [MainScreen].
class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  /// Controller to control tab bar views.
  TabController tabController;

  /// List of tabs to be displayed on screen.
  List<Tile> tabList = List();
  SharedPreference pref = new SharedPreference();

  String status;

  /// initializing state of the [MainScreen] class.
  @override
  void initState() {

    print('in main screen init call');
    super.initState();
    // Initialising [ConnectionManager].
    CommunicationManager _ = CommunicationManager.getInstance();

    CommunicationManager.getInstance().connection();
 //   checkInternet();



    // Refreshing UI views.
    refresh();

    // Adding scene change listeners.
    // When scenes of child screens are changed, We need to update ui,
    // Also user should be navigated to next tab.
    HomeView.sceneChangeNotifier.addListener(homeViewSceneChangeListener);
    RoomView.sceneChangeNotifier.addListener(roomViewSceneChangeListener);
    DeviceView.sceneChangeNotifier.addListener(deviceViewSceneChangeListener);

    // Adding data change listeners.
    // When data is changed in child screens, We need to refresh ui.
    HomeView.dataChangeNotifier.addListener(homeViewDataChangeListener);
    RoomView.dataChangeNotifier.addListener(roomViewDataChangeListener);
    DeviceView.dataChangeNotifier.addListener(deviceViewDataChangeListener);
    ControlPointView.dataChangeNotifier.addListener(controlPointViewDataChangeListener);

    // Adding data change listeners for background activities.
    // When data is changed by the background activities, UI should be updated.
    Building.getInstance().dataChangeNotifier.addListener(communicationDataChangeListener);

    // Listing to events for tab navigation.
    WidgetsBinding.instance.addObserver(this);



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
      print('internet not connected');

      status = "ConnectivityResult.none";
    }
  }

  /// While closing the main screen we need to close all listeners and views generated.
  /// All listeners added in [initState] are removed here.
  @override
  void dispose() {
    // Removing listener - Listing to events for tab navigation.
    WidgetsBinding.instance.removeObserver(this);

    // Removing listener - Adding data change listeners for background activities.
 //   Building.getInstance().dataChangeNotifier.removeListener(communicationDataChangeListener);

    // Halting communication manager.
    CommunicationManager.getInstance().stop();

    // Removing listeners - Adding scene change listeners.
    HomeView.sceneChangeNotifier.removeListener(homeViewSceneChangeListener);
    RoomView.sceneChangeNotifier.removeListener(roomViewSceneChangeListener);
    DeviceView.sceneChangeNotifier
        .removeListener(deviceViewSceneChangeListener);

    // Removing listeners - Adding data change listeners.
    HomeView.dataChangeNotifier.removeListener(homeViewDataChangeListener);
    RoomView.dataChangeNotifier.removeListener(roomViewDataChangeListener);
    ControlPointView.dataChangeNotifier.removeListener(controlPointViewDataChangeListener);

    // Closing tab views.
    tabController.dispose();
    super.dispose();
  }

  /// When user presses back button, we navigate user to the tab to the left.
  /// Eg. if user is on [DeviceView], we navigate user to [RoomView].
  /// When user is on [HomeView], we close the application.
  /// Views are associated with the tab indexes, like [HomeView] is at '0' index.
  /// [RoomView] is at '1', [DeviceView] is at '2', and [ControlPointView] is at '3'.
  /// So these indexes are used to achieve back button navigation.
  @override
  didPopRoute() {
    if (tabController.index != 0) {
      tabController.animateTo(tabController.index - 1,
          curve: ElasticInCurve(0.1), duration: Duration(milliseconds: 30));
      return Future<bool>.value(true);
    } else
      return Future<bool>.value(false);
  }

  /// When data is changed in background activities, we need to update UI views.
  /// While updating views we intimate user about changing of UI using [SnackBar].
  /// Using [Widget.setState] we can achieve updating of the UI.
  /// { See Flutter framework documentation for more info about [Widget.setState], [SnackBar]}.
  void communicationDataChangeListener() {
    print('hs: need to update views');
    // getDataFromList();
//    Scaffold.of(context).showSnackBar(SnackBar(
//      backgroundColor: Colors.blueGrey,
//      duration: Duration(seconds: 1),
//      content: Text('Updating display'),
//    ));

    if(mounted){
      this.setState(() => {});
    }


  }

  void getDataFromList() {
    List<Home> mHomeList = new List();
    List<dynamic> mHomes = new List();
    List<dynamic> mRooms = new List();
    List<dynamic> mDevices = new List();
    pref.getString(SharedKey().CHILD_LIST).then((val) {
      if (val != null) {
        print("val::$val");
        Map<String, dynamic> mMap = jsonDecode(val);
        print("mMap:::$mMap");
        mHomes = mMap["homes"];
        for (int i = 0; i < mHomes.length; i++) {
          Home home = new Home("", "");
          home.name = mHomes[i]["name"];
          home.iD = mHomes[i]["id"];
          home.iconIndex = mHomes[i]["iconIndex"];
          home.indexChildList = mHomes[i]["indexChildList"];
          mRooms = mHomes[i]["childList"];
          List<Room>mRoomList = new List();
          for (int j = 0; j < mRooms.length; j++) {
            Room room = new Room("", "");
            room.name = mRooms[j]["name"];
            room.iD = mRooms[j]["id"];
            room.iconIndex = mRooms[j]["iconIndex"];
            room.indexChildList = mRooms[j]["indexChildList"];
            mRoomList.add(room);
            mDevices = mRooms[j]["childList"];
            List<Devices> mDeviceList = new List();
            for (int k = 0; k < mDevices.length; k++) {
              Devices device = new Devices("", "", "");
              device.name = mDevices[k]["name"];
              device.ip = mDevices[k]["ip"];
              device.deviceID = mDevices[k]["deviceID"];
              device.iconIndex = mDevices[k]["iconIndex"];
              mDeviceList.add(device);
            }
            room.childList = mDeviceList;
          }
          home.childList = mRoomList;
          mHomeList.add(home);
        }
        Building
            .getInstance()
            .childList = mHomeList;
        print("mHomeList:::${mHomeList.length}");
        Building.getInstance().updateDB();
      }
    });
  }

  /// When scene of [HomeView] is changed, we need to refresh and update UI views.
  void homeViewSceneChangeListener() {
    /// For refreshing we reused the method [MainScreen.homeViewDataChangeListener].
    homeViewDataChangeListener();

    /// After refreshing user is navigated to the next tab which shows [RoomView].
    tabController.animateTo(1,
        curve: ElasticInCurve(0.1), duration: Duration(milliseconds: 30));
  }

  /// Actions to be taken when data is changed in [HomeView],
  void homeViewDataChangeListener() {
    /// Checking and validating data for correctness.
    Building.getInstance().checkChild();

    /// Setting selected [Room] and [Device] to 1st of the list.
    Building
        .getInstance()
        .getSelectedHome()
        .indexChildList = 0;
    Building
        .getInstance()
        .getSelectedRoom()
        .indexChildList = 0;

    /// Refreshing UI.
    refresh();

    /// Setting Tab controller to [RoomView].
    tabController.animateTo(0,
        curve: ElasticInCurve(0.1), duration: Duration(milliseconds: 30));
  }

  /// When scene of [RoomView] is changed, we need to refresh and update UI views.
  void roomViewSceneChangeListener() {
    /// For refreshing we reused the method [MainScreen.roomViewDataChangeListener].
    roomViewDataChangeListener();

    /// After refreshing user is navigated to the next tab which shows [DeviceView].
    tabController.animateTo(2,
        curve: ElasticInCurve(0.1), duration: Duration(milliseconds: 30));
  }

  /// Actions to be taken when data is changed in [RoomView],
  void roomViewDataChangeListener() {
    /// Checking and validating data for correctness.
    Building.getInstance().checkChild();

    /// Setting selected [Device] to 1st of the list.
    Building
        .getInstance()
        .getSelectedRoom()
        .indexChildList = 0;

    /// Refreshing UI.
    refresh();

    /// Setting Tab controller to [RoomView].
    tabController.animateTo(1,
        curve: ElasticInCurve(0.1), duration: Duration(milliseconds: 30));
  }

  /// When scene of [DeviceView] is changed, we need to refresh and update UI views.
  void deviceViewSceneChangeListener() {
    /// For refreshing we reused the method [MainScreen.deviceViewDataChangeListener].
    deviceViewDataChangeListener();

    /// After refreshing user is navigated to the next tab which shows [ControlPointView].
    tabController.animateTo(3,
        curve: ElasticInCurve(0.1), duration: Duration(milliseconds: 30));

    /// Dummy Command is sent to validate connection and get updated status.
    // [indexList] is needed by the communication engine to send commands.
    // This list has all the information required to send the the command.
    List<int> indexList = [
      Building.getInstance().indexChildList, // Selected [Home].
      Building.getInstance().getSelectedHome().indexChildList, // Selected [Room]
      Building.getInstance().getSelectedRoom().indexChildList, // Selected [Device]
      0, 0, 0 // for configuring command as dummy command.
    ];
    // Sending command using mechanism provided by [ConnectionManager].

//    CommunicationManager.getInstance().sendCommand(indexList);      //arti 21 aug


  }

  /// Actions to be taken when data is changed in [DeviceView],
  void deviceViewDataChangeListener() {
    /// Refreshing UI.
    refresh();

    /// Setting Tab controller to [DeviceView].
    tabController.animateTo(2,
        curve: ElasticInCurve(0.1), duration: Duration(milliseconds: 30));
  }

  /// Actions to be taken when data is changed in [ControlPointView],
  void controlPointViewDataChangeListener() {
    /// Refreshing UI.
    refresh();

    /// Setting Tab controller to [ControlPointView].
    tabController.animateTo(3,
        curve: ElasticInCurve(0.1), duration: Duration(milliseconds: 30));
  }

  /// Method to refresh UI when data/userSelection are changed.
  void refresh() {
    /// Checking and validating data for correctness.
    Building.getInstance().checkChild();

    /// Removing all previous tabs.
    if (mounted)
      setState(() => tabList.clear());

    /// Adding new/refreshed tabs, updates are mostly the icons of the tabs.
    tabList.add(Tile(Icons.all_inclusive, 'Select \n Home')); // 1
    tabList.add(Tile(
        ThemeManager
            .iconListForHome[Building
            .getInstance()
            .getSelectedHome()
            .iconIndex]
            .icon,
        'Select \n Room')); // 1
    tabList.add(Tile(
        ThemeManager
            .iconListForRoom[Building
            .getInstance()
            .getSelectedRoom()
            .iconIndex]
            .icon,
        'Select \nDevice')); // 1
    tabList.add(Tile(
        ThemeManager
            .iconListForDevice[
        Building.getInstance().getSelectedDevice().iconIndex].icon,
        'Control')); // 1

    ///by arti added
    if(mounted){
      setState(() {
        tabController = TabController(vsync: this, length: tabList.length);
      });
    }

    ///arti commented

//    setState(() =>
//    (tabController = TabController(vsync: this, length: tabList.length)));
  }

  /// Method to build UI with tabBar and tabs.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,  //added by arti for design purpose overflow error

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40), //40
        child: AppBar(
          primary: true,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(FlutterApp.homeName + ' - ' + FlutterApp.roomName + ' - ' + FlutterApp.deviceName, style: TextStyle(fontSize: 15, color: Colors.white),),
          bottom: bottomTabBar,
        ),
      ),
      body: body,
    );
  }

  /// Title of the window, it is constructed with the current selection of the [Home], [Room] and [Devices].
  /*Widget get title {
    return Container(
      height: 200,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
     //     Text(FlutterApp.homeName + ' - ' + FlutterApp.roomName + ' - ' + FlutterApp.deviceName, style: TextStyle(fontSize: 10, color: Colors.white),)
        //  Text(Building.getInstance().getSelectedHome().name + '-' +  Building.getInstance().getSelectedRoom().name)

          Text('artii'),

        ],
      ),
    );
  }*/

  /// Tab bar with tabs according to the elements in th [tabList].
  Widget get bottomTabBar {
    return (tabList.isEmpty
        ? TabBar(tabs: <Tab>[], controller: tabController)
        : TabBar(
      tabs: tabList.map((dynamicContent) {
        return Tab(
            icon: Icon(dynamicContent.icon), text: dynamicContent.name);
      }).toList(),
      controller: tabController,
    ));
  }

  /// Body of the screen, it is constructed with the views for each tab.
  Widget get body {
    List<Widget> tabViewList = <Widget>[];
    tabViewList.add(HomeView());
    tabViewList.add(RoomView());
    tabViewList.add(DeviceView());
    tabViewList.add(ControlPointView());
    return TabBarView(
      physics: NeverScrollableScrollPhysics(), // to disable tab swipe sept changes
        controller: tabController,
        children: tabList.isEmpty ? <Widget>[] : tabViewList);
  }


}
