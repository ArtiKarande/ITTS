/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/fileUtils.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/interLogin.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:ioskitouchnew/screens/account/login/login.dart';
import 'package:ioskitouchnew/screens/account/signUp.dart';
import 'package:ioskitouchnew/screens/controlScreens/homeView1.dart';
import 'package:ioskitouchnew/screens/controlScreens/mainScreen.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/deviceConfig.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/shareQRPrefScreen.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/addElementScreen.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/shareQRScreen.dart';
import 'package:ioskitouchnew/screens/settings/appDetails/appDetails.dart';
import 'package:ioskitouchnew/screens/settings/settings.dart';
import 'package:ioskitouchnew/screens/settings/themes/customTheme.dart';
import 'package:ioskitouchnew/screens/settings/themes/themes.dart';
import 'package:ioskitouchnew/screens/settings/themes/themesKeys.dart';
import 'package:ioskitouchnew/screens/settings/themes/themesView.dart';
import 'package:ioskitouchnew/themeManager.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//void main() => runApp(MainApp());

///check git changes or not only here

int themeVal=0;
SharedPreference pref = new SharedPreference();
void main() {

  WidgetsFlutterBinding.ensureInitialized();

  pref.getString(SharedKey().THEME_VALUE).then((val) {
    if (val != null) {
      themeVal = int.parse(val);
      FlutterApp.themeValue = int.parse((val));
      print("themeVal::$themeVal");
    }
  });

//  if(Device.get().isAndroid) {

    if(Device.get().isTablet){
      print("tablet");
      SystemChrome.setPreferredOrientations([])
          .then((_) {
        runApp(
          CustomTheme(
            initialThemeKey: themeVal == 3
                ? MyThemeKeys.DARKER
                : themeVal == 2
                ? MyThemeKeys.LIGHT
                : themeVal == 1 ? MyThemeKeys.DARK : null,
            child: MainApp(),
          ),
        );
      });
    }else {
      print("phone");
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
        runApp(CustomTheme(
            initialThemeKey: themeVal == 3
                ? MyThemeKeys.DARKER
                : themeVal == 2
                ? MyThemeKeys.LIGHT
                : themeVal == 1 ? MyThemeKeys.DARK : null,
            child: MainApp(),
          ),
        );
      });
    }
 // }
}

///
/// Root Application class used to build kiTouch plus application.
///
/// It has [firebaseAnalytics] and [firebaseAnalyticsObserver] needed for firebase setup.
///
/// Material routes are defined for every screen so that [navigator] can be used.
///

class MainApp extends StatefulWidget {
  @override
  App createState() => new App();
}

class App extends State<MainApp> {
//  static FirebaseAnalytics firebaseAnalytics = new FirebaseAnalytics();
//  static FirebaseAnalyticsObserver firebaseAnalyticsObserver =
//      new FirebaseAnalyticsObserver(analytics: firebaseAnalytics);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pref.getString(SharedKey().THEME_VALUE).then((val) {
      if (val != null) {
        themeVal = int.parse(val);
        FlutterApp.themeValue = int.parse((val));
        print("themeVal::$themeVal");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //  home: SplashScreen(nextScreen: MasterDetail.tag),
      home: SplashScreen(nextScreen: Login.tag),
      title: ThemeManager.applicationName,
      theme: CustomTheme.of(context),
      routes: <String,WidgetBuilder>{
        MasterDetail.tag: (context) => MasterDetail(),
        MainScreen.tag: (context) => MainScreen(),
        AddElementScreen.tag: (context) => AddElementScreen(),
        ShareQRPrefScreen.tag: (context) => ShareQRPrefScreen(),
        ShareQRScreen.tag: (context) => ShareQRScreen(),
        DeviceConfig.tag: (context) => DeviceConfig(),
        SignUp.tag: (context) => SignUp(""),
        Login.tag: (context) => Login(),
        Themes.tag: (context) => Themes(),
        Settings.tag: (context) => Settings(),
        AppDetails.tag: (context) => AppDetails(),
        HomeView1.tag: (context) => HomeView1(),
        ButtonOptions.tag: (context) => ButtonOptions(),
      },
      // theme: FlutterApp.themeValue==1?ThemeManager.darkTheme:FlutterApp.themeValue==2?ThemeManager.lightTheme:ThemeManager.blueTheme,
      /*navigatorObservers: <NavigatorObserver>[firebaseAnalyticsObserver],
      routes: <String, WidgetBuilder>{
        MasterDetail.tag: (context) => MasterDetail(),
        MainScreen.tag: (context) => MainScreen(),
        AddElementScreen.tag: (context) => AddElementScreen(),
        ShareQRPrefScreen.tag: (context) => ShareQRPrefScreen(),
        ShareQRScreen.tag: (context) => ShareQRScreen(),
        DeviceConfig.tag: (context) => DeviceConfig(),
        SignUp.tag: (context) => SignUp(""),
        Login.tag: (context) => Login(),
        Themes.tag: (context) => Themes(),
        Settings.tag: (context) => Settings(),
        AppDetails.tag: (context) => AppDetails(),
        HomeView1.tag: (context) => HomeView1(),
        ButtonOptions.tag: (context) => ButtonOptions(),
        // ThemesViewNew.tag: (context) => ThemesViewNew(),
      },*/
    );
  }
}

///
/// Generates and shows Splash Screen to user.
///
/// Shows image from [imageAssetPath] for [duration] seconds.
///
/// UI is navigated to [nextScreen] after [duration] is over.
///
class SplashScreen extends StatefulWidget {
  /// Creates a Splash screen
  const SplashScreen({
    Key key,
    this.imageAssetPath = 'images/logo_skroman_kiTouch.png',
    this.duration = 3,
    @required this.nextScreen,
  }) : super(key: key);

  /// Path of the image asset to be shown in splash screen.
  final String imageAssetPath;

  /// Number of seconds for which splash screen to be shown.
  final int duration;

  /// Navigation information of the screen to be shown after splash.
  final String nextScreen;

  /// Creates state of the class.
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

///
/// State class of [SplashScreen] class.
///
/// It builds screen having splash image and starts timer for given [duration].
/// Also sets navigation to [nextScreen] after timer is over.
///
class _SplashScreenState extends State<SplashScreen> {
  SharedPreference pref = new SharedPreference();

  String fileContents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Image.asset(widget.imageAssetPath, fit: BoxFit.scaleDown)));
  }

  /// Timer should be started when state is constructed.
  @override
  void initState() {
    super.initState();
    //start();
    getLocalData();
    //getDataFromList();
 //   readDataFromFile();   // by arti 1 Aug
  }

  /// Starting a timer with [duration] second and callback [navigateToLogin].
  void start() async =>
      Timer(Duration(seconds: widget.duration), navigateToLogin);

  /// Replaces current screen with [nextScreen].
  void navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(Login.tag);

//    Navigator.push(
//        context, MaterialPageRoute(builder: (context) => Login()));
  }

  // Replaces current screen with [nextScreen].
  void navigateToMain() {
    Navigator.of(context).pushReplacementNamed(MasterDetail.tag);
  }
  void getLocalData() {
    pref.getBool(SharedKey().IS_LOGGED_IN).then((val) {
      if (val != null) {
        if (val) {
          pref.getString(SharedKey().EMAIL_ID).then((eVal) {
            if (eVal != null) {
              FlutterApp.emailId = eVal;
            } else {
              FlutterApp.emailId = "";
            }
            pref.getString(SharedKey().FIRST_NAME).then((nVal) {
              if (nVal != null) {
                FlutterApp.name = nVal;
              } else {
                FlutterApp.name = "";
              }
            });
            pref.getString(SharedKey().USER_ID).then((uVal) {
              if (uVal != null) {
                FlutterApp.id = uVal;
              } else {
                FlutterApp.id = "";
              }
            });
          });
          pref.getString(SharedKey().THEME_VALUE).then((val) {
            if (val != null) {
              setState(() {
                FlutterApp.themeValue = int.parse(val);
              });
            }
          });

          navigateToMain();
        } else {
          start();
        }
      } else {
        start();
      }
    });
  }

  void getDataFromList() {
    print("getDataFromList");
    List<Home> mHomeList = new List();
    List<dynamic> mHomes = new List();
    List<dynamic> mRooms = new List();
    List<dynamic> mDevices = new List();
    pref.getString(SharedKey().CHILD_LIST).then((val) {
      if (val != null) {
   //     print("val::$val");
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
          List<Room> mRoomList = new List();
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
  //      setState(() {     // 28 jully
          Building.getInstance().childList = mHomeList;
 //       });
        print("mHomeList:::${mHomeList.length}");
      }
    });
  }

  void readDataFromFile() {
    List<Home> mHomeList = new List();
    List<dynamic> mHomes = new List();
    List<dynamic> mRooms = new List();
    List<dynamic> mDevices = new List();
    FileUtils.readFromFile().then((contents) {
      //setState(() {
      fileContents = contents;
      print("fileContents:::$fileContents");
      if (contents != null) {
        Map<String, dynamic> mMap = jsonDecode(fileContents);
        print("mMap:::$mMap");
        mHomes = mMap["homes"];
        for (int i = 0; i < mHomes.length; i++) {
          Home home = new Home("", "");
          home.name = mHomes[i]["name"];
          home.iD = mHomes[i]["id"];
          home.iconIndex = mHomes[i]["iconIndex"];
          home.indexChildList = mHomes[i]["indexChildList"];
          mRooms = mHomes[i]["childList"];
          List<Room> mRoomList = new List();
          for (int j = 0; j < mRooms.length; j++) {
            Room room = new Room("", "");
            room.name = mRooms[j]["name"];
            room.iD = mRooms[j]["id"];
            room.iconIndex = mRooms[j]["iconIndex"];
            room.indexChildList = mRooms[j]["indexChildList"];
            mRoomList.add(room);
            print("fileContents:::mRoomList:::${mRoomList.length}");
            mDevices = mRooms[j]["childList"];
            List<Devices> mDeviceList = new List();
            for (int k = 0; k < mDevices.length; k++) {
              Devices device = new Devices("", "", "");
              device.name = mDevices[k]["name"];
              device.ip = mDevices[k]["ip"];
              device.deviceID = mDevices[k]["deviceID"];
              device.iconIndex = mDevices[k]["iconIndex"];
              mDeviceList.add(device);
              print("fileContents:::mDeviceList:::${mDeviceList.length}");
            }
            room.childList = mDeviceList;
          }
          home.childList = mRoomList;
          mHomeList.add(home);
        }
     //   setState(() {   //changes from 29jully
          Building.getInstance().childList = mHomeList;
     //   });
        print("fileContents:::mHomeList:::${mHomeList.length}");
      }
      //   });
    });
  }
}
