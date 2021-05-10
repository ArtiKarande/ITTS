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
import 'package:flutter/services.dart';
import 'package:ioskitouchnew/CheckInternetConnection.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/InternetUtil.dart';
import 'package:ioskitouchnew/common/Messages.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/screens/account/login/loginModel.dart';
import 'package:ioskitouchnew/screens/account/login/loginView.dart';
import 'package:ioskitouchnew/screens/account/login/loginViewModel.dart';
import 'package:ioskitouchnew/screens/account/signUp.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';
import 'package:ioskitouchnew/screens/settings/backupSuccessAnim.dart';

class Login extends StatefulWidget {
  static final String tag = 'Login';

  @override
  LoginView createState() => new LoginView();
}

abstract class LoginState extends State<Login> {
  @protected
  var formKey = new GlobalKey<FormState>();
  bool obscurePasswordText = true;
  @protected
  String username = '', password = '', emailId = '', mobileNumber = '';
  TextEditingController nameController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  LoginViewModel model = new LoginViewModel();
  LoginUser loginUser = new LoginUser();
  SharedPreference pref = new SharedPreference();
  static const platform = const MethodChannel('wifi');
  Connectivity connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult>  connectionSubscription;
  NetworkCheck networkCheck = new NetworkCheck();


  String status, authCheckVal = '';

  int flag = 0;


  ///this function is for wifi connection permssion
  getWifiPermission() async {
    await platform.invokeMethod("getPermission");
    const MethodChannel('wifi').setMethodCallHandler((MethodCall call) async {
      if (call.method == 'getPermission') {
        return;
      }
    });
  }


  ///to check internet connection
  Future<Null> initConnectivity() async {
    String connectionStatus;
    try {
      connectionStatus = (await connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = "Internet connectivity failed";
    }
    if (!mounted) {
      return;
    }

    if(status=="ConnectivityResult.wifi"|| status=="ConnectivityResult.mobile"){

    }else {
      setState(() {
        status = connectionStatus;
      });
    }

    print("InitConnectivity : $status");

    if (status == "ConnectivityResult.mobile" ||
        status == "ConnectivityResult.wifi") {
      if(authCheckVal == '1'){
        FToast.show('User not verified');
      }else{
        submit();
      }
    } else {
      print("You are not connected to internet");
      FToast.show("You are not connected to internet");
    }
  }


  ///if connection is present then call this method to submit user emailid, password data
  submit() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      loginUser.email = nameController.text;
      loginUser.password = passController.text;
      ProgressBar.show(context);

      setState(() {
        flag = 1;    //used for progres bar arti added
      });

      print('val submit::: $flag');

      model.loginUser(context, loginUser, (String error) {

        setState(() {
          flag = 0;    //used for progres bar arti added
        });

        print('val error::: $flag');

        ProgressBar.dismiss(context);
        FToast.show(error);
      }, (Map response) {

        FlutterApp.emailId = response['result']['email'];
        FlutterApp.name = response['result']['name'];
        FlutterApp.id = response['result']['_id'];
        pref.putString(SharedKey().USER_ID, response['result']['_id']);
        FlutterApp.userID = response['result']['_id'];
        FlutterApp.isSignUp = "No";
        pref.putBool(SharedKey().IS_LOGGED_IN, true);
        pref.putString(SharedKey().EMAIL_ID, "${response['result']['email']}");
        pref.putString(SharedKey().FIRST_NAME, "${response['result']['name']}");

        ///auto backup after user login commented by arti
        /*restoreData(response['result']['_id']);
        Future.delayed(const Duration(milliseconds: 15000), () async {

          setState(() {
            flag = 0;    //arti added
          });

          print('val delayed::: $flag');
          ProgressBar.dismiss(context);
          FToast.show(Messages.LOGIN_MESSAGE);

          navigateTo();
        });*/

        print('val delayed::: $flag');
        ProgressBar.dismiss(context);
        FToast.show(Messages.LOGIN_MESSAGE);


        restoreData();

        ///restore code add here

      });
    }
  }

  userData(LoginUser loginUser, Function completionHander, Function errorHandler) {}


  ///when this screen is called, this block will execute first
  @override
  Future initState() {
    // TODO: implement initState
    super.initState();
    checkInternet();

    pref.getString(SharedKey().setAuthValue).then((val) {

      print('preflogin');
      print(val);
      setState(() {
        authCheckVal = val;
      });
    });


    setState(() {
      connectionSubscription = connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        setState(() {
          status = result.toString();
          print("Initstate : $status");
          if (status == "ConnectivityResult.mobile" || status == "ConnectivityResult.wifi") {
            print('Internet available now.');
          }
          else{

            if(flag == 1){
              ProgressBar.dismiss(context);
              print('Internet not available now.');

              setState(() {
                flag = 0;
              });
            }

          }
        });
      });
    });
//     getWifiPermission();
//    nameController.text="megha@skromanglobal.com";
//    passController.text="megha@44";
    const MethodChannel('plugins.flutter.io/connectivity')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{}; // set initial values here if desired
      }
      return null;
    });

  }


  ///to check internet connection
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

      if(flag == 1){
        ProgressBar.dismiss(context);
        setState(() {
          flag = 0;
        });
      }
      print('val exception::: $flag');
      showDialog(
        context: context,
        builder: (_) => FunkyOverlay(msg: "please check wifi connection",),
      );
     // FToast.show("please check wifi connection");
    }
  }

  /// Replaces current screen with [nextScreen].
  void navigateTo() =>
      Navigator.of(context).pushReplacementNamed(MasterDetail.tag);

  void navigateToSignUp() {
    //Navigator.of(context).pushNamed(SignUp.tag);
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new SignUp(status)));
  }

 /* void restoreData(String userID) {
    print('in login restore data');
    Map<String, dynamic> map = new HashMap();
    map["user_id"] = userID;
    String mMap = jsonEncode(map);
    CommunicationManager.getInstance().connection();
    Future.delayed(const Duration(milliseconds: 15000), () async {
      if (mounted)
        setState(() {
          CommunicationManager.getInstance().syncSubscribe(userID + "/kitouchplus_server_to_app_ack");
          CommunicationManager.getInstance().publishSync("global_in/kitouchplus_server_to_app", mMap);
        });
    });
  }*/

  void restoreData() {
    ProgressBar.show(context);

    FToast.showGreen('Please wait! Data loading...');

    Map<String, dynamic> map = new HashMap();
    map["user_id"] = FlutterApp.userID;
    String mMap = jsonEncode(map);
    CommunicationManager.getInstance().connection();
    Future.delayed(const Duration(seconds: 5), () async {
      setState(() {

        CommunicationManager.getInstance().syncSubscribe(FlutterApp.userID + "/kitouchplus_server_to_app_ack");
        CommunicationManager.getInstance().publishSync("global_in/kitouchplus_server_to_app", mMap);

      });
      ProgressBar.dismiss(context);
      navigateTo();

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

    });
  }


  ///to free used variables
  @override
  void dispose() {
    connectionSubscription.cancel();
    super.dispose();
  }
}
