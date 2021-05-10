/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/InternetUtil.dart';
import 'package:ioskitouchnew/common/Messages.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/screens/account/SignUpView.dart';
import 'package:ioskitouchnew/screens/account/signUpModel.dart';
import 'package:ioskitouchnew/screens/account/signUpViewModel.dart';
import 'package:ioskitouchnew/screens/account/verifyOtp.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';

String inStatus;

class SignUp extends StatefulWidget {
  static final String tag = 'SignUp';

  SignUp(String status) {
    inStatus = status;
    print("inStatus::$inStatus");
  }

  @override
  SignUpView createState() => new SignUpView();
}

abstract class SignUpState extends State<SignUp> {
  @protected
  var formKey = new GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController confirmPassController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();
  bool obscurePasswordText = true;
  bool obscurePasswordText1 = true;
  @protected
  String username = '', password = '', emailId = '', mobileNumber = '';
  SignUpViewModel signUpViewModel = new SignUpViewModel();
  UserModel userModel = new UserModel();
  SharedPreference pref = new SharedPreference();
  Connectivity connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> connectionSubscription;
//  StreamSubscription<ConnectivityResult> connectivitySubscription;  //arti commented

  String status;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      print("initSt::$inStatus");
      status = inStatus;
      print("Initstate : $status");
      if (status == "ConnectivityResult.mobile" ||
          status == "ConnectivityResult.wifi") {
  //      FToast.show("Internet available now.");
        print("Internet available now.");
      } else {
        FToast.show("You are not connected to internet");
        setState(() {
          connectionSubscription = connectivity.onConnectivityChanged
              .listen((ConnectivityResult result) {
            setState(() {
              status = result.toString();
              print("Initstate : $status");
              if (status == "ConnectivityResult.mobile" ||
                  status == "ConnectivityResult.wifi") {
     //           FToast.show("Internet available now.");
                print("Internet available now.");
              }
            });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    connectionSubscription.cancel();
    super.dispose();
  }

  signUpApi() {

    userModel.name = nameController.text;
    userModel.email = emailController.text;
    userModel.password = confirmPassController.text;
    userModel.mobile = mobileController.text;
    signUpViewModel.signUpUser(context, userModel, (Map response) {

      print(response['message']);

      Future.delayed(const Duration(seconds: 1), () async {
        ProgressBar.dismiss(context);
       // navigateTo();

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VerifyOtp(emailController.text)));
      });


      FToast.show(Messages.SIGN_UP__MESSAGE);
      FlutterApp.id = response['result']['_id'];
      FlutterApp.emailId = response['result']['email'];
      FlutterApp.name = response['result']['name'];
      FlutterApp.isSignUp = "Yes";
      pref.putString(SharedKey().USER_ID, response['result']['_id']);
      pref.putBool(SharedKey().IS_LOGGED_IN, true);
      pref.putString(SharedKey().EMAIL_ID, "${response['result']['email']}");
      pref.putString(SharedKey().FIRST_NAME, "${response['result']['name']}");

      ///set value to 1
      pref.putString(SharedKey().setAuthValue, "1");

    }, (String error) {
      ProgressBar.dismiss(context);
      FToast.show(error);
    });
  }

  submit() async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      ProgressBar.show(context);
      if ((passController.text.toString()) ==
          confirmPassController.text.toString()) {
        signUpApi();
      } else {
        ProgressBar.dismiss(context);
        FToast.show(Messages.INVALID_PASSWORD);
      }
    } else {
      print("else");
    }
  }

  /// Replaces current screen with [nextScreen].
  void navigateTo() =>
      Navigator.of(context).pushReplacementNamed(MasterDetail.tag);

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  String validateMobile(String value) {
    if (value.length < 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  String validatePassword(String val) {
    if (val.length < 8 || val.length > 32) {
      return 'password length should be greater than 8 digits';
    }
    else {
      return null;
    }
  }

  Future<void> initConnectivity() async {
    String connectionStatus;
    try {
      connectionStatus = (await connectivity.checkConnectivity()).toString();
    } on Exception catch (e) {
      print(e.toString());
      connectionStatus = "Internet connectivity failed";
    }
    if (!mounted) {
      return Future.value(null);
    }

    if (status == "ConnectivityResult.wifi") {
    } else {
      setState(() {
        status = connectionStatus;
      });
    }
    print("InitConnectivity : $status");
    if (status == "ConnectivityResult.mobile" ||
        status == "ConnectivityResult.wifi") {
      submit();
    } else {
      print("You are not connected to internet");
      FToast.show("You are not connected to internet");
    }
    return status;
  }
}
