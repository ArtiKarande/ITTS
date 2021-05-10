/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrochargingstation/GoogleMapData/MapView.dart';
import 'package:vtrochargingstation/Login/login.dart';
import 'package:vtrochargingstation/Settings/ChangeUrl.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/Invoice/Invoice.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/message.dart';
import 'dart:ui';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/InternetConnectivity/network_info.dart';
import 'CommunicationManager.dart';
import 'GoldCard/Trial.dart';
import 'IntroSlider/Introduction.dart';
import 'charging/StartCharging.dart';
import 'common/ApiCall.dart';
import 'common/Messages.dart';
import 'common/sharedPreferece/SharedKeys.dart';
import 'common/sharedPreferece/SharedPreferneces.dart';
import 'dialog/FunkeyOverlay.dart';
import 'mqtt/MQTTAppState.dart';
import 'mqttConnectionManager.dart';
import 'package:location/location.dart' as loc;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  /// local storage
  SharedPreference pref = new SharedPreference();
  String userId = '';

  /// notification params
  final List<Message> messages = [];
  String fcmToken = "", userToken = '', prefFcm = '', time = '';

  APICall apiCall = APICall();

  ///mqtt variable declaration
  MQTTAppState currentAppState;
  CommunicationManager _manager;

  SharedPreferences _preferences;

  /// map parameters
  final Geolocator _geolocator = Geolocator();
  double currentLat, currentLong;
  loc.Location location = new loc.Location();

  @override
  void initState(){

    /// to get current location [ latitude, longitude ]
    _getCurrentLocation();

  //  WidgetsFlutterBinding.ensureInitialized();
//    setCrashAnalytics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    final MQTTAppState appState = Provider.of<MQTTAppState>(context, listen: true);
    currentAppState = appState;

    return Scaffold(
        backgroundColor: AppTheme.background,
        body:
        Stack(

          /// UI
          children: <Widget>[
            Center(child: Container(
              height: h,
                child: Image.asset("images/splashscreen.png",fit: BoxFit.fill,))),

          ],
        ));
  }

  /// when IS_LOGGED_IN is true then call dio API or else go the [login] page
  checkLogin(){

    pref.getBool(SharedKey().IS_LOGGED_IN).then((val) {
      print(val);
      if(val != null){

        if (val) {
          getDetailsApi(); ///splash screen api

        }else{
          start();
        }
      }else{
        start();
      }
    });
  }

  ///login naviagtion
  void start() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Introduction()));  //prev Login
  }

  /// firebase push notification update [fcm] token method
  void fcm() {

    FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) async{
        print("onLaunch called");
      },
      onResume: (Map<String, dynamic> msg) async{
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) async{
        print(" onMessage called ${(msg)}");
        final notification = msg['notification'];
        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });
      },
    );

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    firebaseMessaging.getToken().then((token) {
      setState(() {
        fcmToken = token;

        pref.putString(SharedKey().fcmValue, fcmToken);

        if(userToken == null){
          checkLogin();
        }

        else if(fcmToken.isNotEmpty){
          pref.putString(SharedKey().fcmValue, fcmToken);

          apiCall.fcmUpdate(fcmToken, userToken).then((response){

            print(response);
            print(token);

            if(response['status'] == true){
              print('--- fcm API Success ----');
              print(response);

              checkLogin();

            }else if(response['status'] == false){

              start();
              FToast.show('Token expired, please login again');

            }else{
              FToast.show(Messages.elseMethod);
            }
          });
        }else{
          checkLogin();
        }
      });
    });
  }

  /// firebase crash report submit using crash analytics plugin
  void setCrashAnalytics() async {

    await Firebase.initializeApp();
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };

    // FirebaseCrashlytics.instance.crash(); //forcefully crash app trial only
  }

  /// splash screen API - to retrieve all data of user
  void getDetailsApi() {

    /// reference of current widget state
    apiCall = APICall(state: currentAppState);

    apiCall.getDetailsSplashScreen().then((response) {

      if(response['status'] == true){

       currentAppState.setWalletAmount(response['wallet_amount']);
       currentAppState.setGoldCardAmount(response['vtro_gold_card_balance']);

        /// empty array condition []
        var array = response['current_request'];

        /// when charging status is start / stop
        if(array.length == 0){
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));
        }else{
          subscribeTopic1();
          currentAppState.setRequestPercentage(double.parse(response['current_request'][0]['remaning_battery_percentage']));

          ///if user has already plan
          if(response['is_plan_purchase'] == false){
            currentAppState.setEstimatedCost(double.parse(response['current_request'][0]['amount']));
          }

          FlutterApp.requestId = response['current_request'][0]['request_id'];
          FlutterApp.chargerType = response['current_request'][0]['charger_type'];
          FlutterApp.percentage = response['current_request'][0]['percentage_request'];
          FlutterApp.plugPoint = response['current_request'][0]['plug_point'];
          FlutterApp.scanQR = response['current_request'][0]['station_id'];

          /// if charging already started
          /// S = already started
          /// P = Payment done
          /// else other upcoming state

          if(response['current_request'][0]['active_status'] == 'S'){
            getPref();
            currentAppState.setSliderMoveControl(true);
            currentAppState.setReceivedText('stop');
            currentAppState.setLivePercentage(double.parse(response['current_request'][0]['remaning_battery_percentage'])); //checking per filled
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));//MapView  ChangeUrl
          }

          /// user payment done then show start charging option P = payment done
          else if(response['current_request'][0]['active_status'] == 'P'){
            getPref();
            currentAppState.setSliderMoveControl(false);
            currentAppState.setReceivedText('start');
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                StartCharging(double.parse(response['current_request'][0]['remaning_battery_percentage']), '')));
          }
          else{
            //todo
          }
        }
      }else{
        start();
        FToast.show('Token expired, please login again');
      }
    });
  }

  /// mqtt subscribe topic method
  void subscribeTopic1() {
    _manager = CommunicationManager(state: currentAppState);
    _manager.connection();

    Future.delayed(const Duration(seconds: 2), () async {
        _manager.syncSubscribe('percentage');
        _manager.syncSubscribe('vtro/' + FlutterApp.requestId.toString() + '/chargingstation/out/app');

        /*
        use when trying to fetch live percentage
 {
          "tag":"percentage",
          "percentage":"100"
}
        */
   //   });
    });
  }

  /// to get user current location [latitude, longitude] method
  _getCurrentLocation() async {
    bool isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    print('location status::');
    print(isLocationEnabled);

    if (isLocationEnabled) {
    } else {
      /// enable user current location
      await location.requestService();
    }

    await _geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {

      currentLat = position.latitude;
      currentLong = position.longitude;

      FlutterApp.currentLatitude = currentLat;
      FlutterApp.currentLongitude = currentLong;

      getPreferencesValues();

    }).catchError((e) {
      print('current loc--exception---');
      print(e);
    });
  }

  /// fetch value which is stored locally e.g., user token value
  void getPreferencesValues() async{

    pref.getString(SharedKey().token).then((value) {
      setState(() {
        userToken = value;
        FlutterApp.token = userToken;
      });
      print('user token splash:: $userToken');
      checkInternet();
    });
  }

  /// fetch value of time which is stored locally,
  /// this method useful when user has started his charging then only
  void getPref() async{
    _preferences = await SharedPreferences.getInstance();
    setState(() {

      time = _preferences.getString("time");
      print('time:: ' + time);
      if(time != null){
        currentAppState.setEstimatedTime(double.parse(time));
      }
    });
  }

/// to check internet connection
  checkInternet() async {
    bool result1 = await DataConnectionChecker().hasConnection;
    if(result1 == true) {
      checkLogin();
    }else{
      return showDialog(
          context: context,
          builder: (context) {
            return NetworkInfo(
              title: 'Ooops! Something went wrong',
            );
          });
    }
  }
}
