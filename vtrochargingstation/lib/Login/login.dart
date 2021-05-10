/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *  
 */

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:vtrochargingstation/BikeInformation/AddBikeInfoId.dart';
import 'package:vtrochargingstation/BikeInformation/BikeInformation.dart';
import 'package:vtrochargingstation/GoogleMapData/MapView.dart';
import 'package:vtrochargingstation/Login/PinCodeVerification.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/Login/SocialLogin/sign_in.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedKeys.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedPreferneces.dart';
import 'package:vtrochargingstation/models/message.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import '../CommunicationManager.dart';
import '../InternetConnectivity/network_info.dart';
import 'LoginNeoView.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'SocialLogin/sign_in.dart';
import 'dart:convert' as JSON;

class Login extends StatefulWidget{
  @override
  LoginView createState() => LoginView();
}

abstract class LoginState extends State<Login> {

  @protected
  var formKey = new GlobalKey<FormState>();
  bool loginButtonVisibility = true;
  String status;
  bool passwordVisible = true;
  TextEditingController _emailIDController = new TextEditingController();

  String fcmToken = "";
  APICall apiCall = APICall();

  ///mqtt
  MQTTAppState currentAppState;
  CommunicationManager _manager;

  /// fb initialize
//  static final FacebookLogin facebookSignIn = new FacebookLogin();

  String _message = 'Log in/out by pressing the buttons below.';
  SharedPreference pref = new SharedPreference();

  ///fb params
  bool _isLoggedIn = false;
  Map userProfile;
//  final facebookLogin = FacebookLogin();
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  final List<Message> messages = [];

  @override
  void dispose() {

    fcmToken = "";
    super.dispose();
  }

  /// mobile login
  void normalLogin(String _emailIDController) async{

    if (_emailIDController.contains('@',)) {
      apiCall.login(_emailIDController, 'email_address', '1', 'gmail').then((response) {  //normal
        ProgressBar.dismiss(context);

        if(response['status'] == true){
          print('---Login API -> True');
          print(response);
          navigateTo(_emailIDController);
        }else if(response['status'] == false){

          setState(() {
            loginButtonVisibility = true;
          });
          FToast.show(Messages.otpError);

        }else{
          setState(() {
            loginButtonVisibility = true;
          });
          FToast.show(Messages.elseMethod);
        }

      });
    }
    else {
      apiCall.login(_emailIDController, 'mobile_no', '1', '').then((response) {  //1

        print(response);
        ProgressBar.dismiss(context);

        if(response['status'] == true){
          print('---Login mobile API -> True');
          print(response);
          navigateTo(_emailIDController);
        }else if(response['status'] == false){

          setState(() {
            loginButtonVisibility = true;
          });
          FToast.show(Messages.WENT_WRONG);

        }else{
          setState(() {
            loginButtonVisibility = true;
          });
          FToast.show(Messages.elseMethod);
        }


      });
    }
  }

  ///facebook login

  /*Future<Null> _logOut() async {
    await facebookLogin.logOut();
  //  _showMessage('Logged out.');
  }*/

  _logout(){
    facebookSignIn.logOut();
    setState(() {
      _isLoggedIn = false;
    });
  }

  /// facebook login
 loginWithFB() async{

//    final result = await facebookLogin.logInWithReadPermissions(['email']);
   final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

   print('aaa');
   print(result.status);
   print(result);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,email&access_token=${token}');
        final profile = JSON.jsonDecode(graphResponse.body);
        print(profile);
        setState(() {
          userProfile = profile;
          _isLoggedIn = true;
        });

        /// if we get fb details then store email and update [IS_LOGGED_IN] = true for splash screen validations

          print('fb details::');
          print(profile['email']);
          if(profile['email'] != null){
            pref.putBool(SharedKey().IS_LOGGED_IN, true);
            ProgressBar.dismiss(context);
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));
         //   FToast.show(Messages.LOGIN_MESSAGE);
          }else{
            ProgressBar.dismiss(context);
            FToast.show(Messages.WENT_WRONG);
          }
        break;
      case FacebookLoginStatus.cancelledByUser:
        ProgressBar.dismiss(context);
        setState(() => _isLoggedIn = false );
        FToast.show('facebook login cancelled by user!');
        break;

      case FacebookLoginStatus.error:
        setState(() => _isLoggedIn = false );
        FToast.show('The user has not authorized application');
        break;
    }
  }

  navigateTo(String emailIDController) async{

    Navigator.push(context, MaterialPageRoute(builder: (context) => PinCodeVerification(emailIDController, 'login')));

    setState(() {
      loginButtonVisibility = true;
    });
  }

  /// google login
  signInGoogle(GlobalKey<ScaffoldState> scaffoldKey){
    signInWithGoogle().then((result) {
      print('google result...');
      print(result);
      if (result != null) {

        ///google api
        if (email != null) {
          googleLogin(email, 'gmail', '2', scaffoldKey);
        } else {
          FToast.show(Messages.WENT_WRONG);
        }
      }else{
        ProgressBar.dismiss(context);
      }
    });
  }

  /// API - google login
  void googleLogin(String userEmail, String platform, loginType, GlobalKey<ScaffoldState> scaffoldKey) {
    apiCall.login(userEmail, 'email_address', loginType, platform).then((response) {  ///google
      ProgressBar.dismiss(context);

      if(response['status'] == true){

        pref.putString(SharedKey().email_or_mobile, userEmail);

        if(response['is_bike_details'] == true){
          getDetailsApi(); ///splash api google
          pref.putBool(SharedKey().IS_LOGGED_IN, true);
          fcm();

        }else{

         getDetailsApi(); ///splash screen api
         Navigator.push(context, MaterialPageRoute(builder: (context) => AddBikeInfoId('login'))); //BikeInformation
         FToast.show(Messages.LOGIN_MESSAGE);

        }

      }else{
        FToast.show(Messages.apiStatus);
      }

    });
  }

  /// splash screen API - to retrieve all data of user
  void getDetailsApi() {
    apiCall = APICall(state: currentAppState);//new

    apiCall.getDetailsSplashScreen().then((response) {

      if(response['status'] == true){
        currentAppState.setWalletAmount(response['wallet_amount']);
        currentAppState.setGoldCardAmount(response['vtro_gold_card_balance']);

     //   print('-- [splash] true --');
     //   print(response);

      }else{
        print('-- splash screen api - false --');
      }
    });
  }

  /// after login - update fcm token
  void fcm() {

    FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) async{
      },
      onResume: (Map<String, dynamic> msg) async{
      },
      onMessage: (Map<String, dynamic> msg) async{

        final notification = msg['notification'];
        setState(() {
          messages.add(Message(title: notification['title'], body: notification['body']));
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

        print('check FCM gmail login...');
        print(fcmToken);

        pref.putString(SharedKey().fcmValue, fcmToken);

        if(fcmToken.isNotEmpty){
          pref.putString(SharedKey().fcmValue, fcmToken);

          apiCall.fcmUpdate(fcmToken, FlutterApp.token).then((response){

            if(response['status'] == true){

              Navigator.pop(context);

              Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));

              print('--- fcm API Success ----');
              print(response);

            }else if(response['status'] == false){
              FToast.show('Token expired, please login again');

            }else{
              FToast.show(Messages.elseMethod);
            }
          });
        }

      });
    });
  }

}
