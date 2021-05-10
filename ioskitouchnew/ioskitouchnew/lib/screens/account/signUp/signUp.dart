/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/screens/account/signUp/SignUpView.dart';

class SignUp extends StatefulWidget{
  static final String tag = 'Sign';
  @override
  SignUpView createState()=> new SignUpView();
}

abstract class SignUpState extends State<SignUp>{

  Connectivity connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> connectionSubscription;

  String status;


  ///when this screen is called, this block will execute first
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      connectionSubscription =
          connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
            setState(() {
              status = result.toString();
              print("Initstate : $status");
              if (status == "ConnectivityResult.mobile" ||
                  status == "ConnectivityResult.wifi") {
                FToast.show("Internet available now.");
              }
            });
          });
    });
  }
}