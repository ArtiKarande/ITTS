/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */


import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';  //for asynchronous features
import 'dart:convert';  //for converting the response to desired format. e.g: JSON
import 'package:connectivity/connectivity.dart';  //connectivity package...also see the pubspec.yaml
import 'package:flutter/services.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/screens/account/login/loginModel.dart';
import 'package:ioskitouchnew/screens/account/login/loginViewModel.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart'; //PlatForm Exception


class MyLoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(home: new ButtonOptions());
  }
}

class ButtonOptions extends StatefulWidget {
  static final String tag = 'interLogin';
  @override
  State<StatefulWidget> createState() {
    return new ButtonOptionsState();
  }
}

class ButtonOptionsState extends State<ButtonOptions> {
  String _connectionStatus;
  final Connectivity _connectivity = new Connectivity();

  //For subscription to the ConnectivityResult stream
  StreamSubscription<ConnectivityResult> _connectionSubscription;
  SharedPreference pref = new SharedPreference();
  LoginViewModel model = new LoginViewModel();

  /*
  ConnectivityResult is an enum with the values as { wifi, mobile, none }.
  */
  @override
  void initState() {

    FToast.showGreen('interlogin screen call');
    super.initState();
    // initConnectivity(); before calling on button press
    _connectionSubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            _connectionStatus = result.toString();
          });
        });
    print("Initstate : $_connectionStatus");
  }

  //For cancelling the stream subscription...Good way to release resources
  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }

  //called in initState
  /*
    _connectivity.checkConnectivity() checks the connection state of the device.
    Recommended way is to use onConnectivityChanged stream for listening to connectivity changes.
    It is done in initState function.
  */
  Future<Null> initConnectivity() async {
    String connectionStatus;

    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = "Internet connectivity failed";
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
    print("InitConnectivity : $_connectionStatus");
    if(_connectionStatus == "ConnectivityResult.mobile" || _connectionStatus == "ConnectivityResult.wifi") {
      getData();
    } else {
      print("You are not connected to internet");
    }
  }

  //makes the request
  Future<String> getData() async {
    LoginUser loginUser;
    loginUser.email = "soni@skromanglobal.com";
    loginUser.password = "soni@123";
    ProgressBar.show(context);
    userData(loginUser, (String error) {
      ProgressBar.dismiss(context);
      FToast.show(error);
    },(Map response){
      FToast.show(response['message']);
      FlutterApp.emailId = response['result']['email'];
      FlutterApp.name = response['result']['name'];
      FlutterApp.id = response['result']['_id'];
      pref.putString(SharedKey().USER_ID, response['result']['_id']);
      FlutterApp.userID = response['result']['_id'];
      pref.putBool(SharedKey().IS_LOGGED_IN, true);
      pref.putString(SharedKey().EMAIL_ID, "${response['result']['email']}");
      pref.putString(SharedKey().FIRST_NAME, "${response['result']['name']}");
      restoreData(response['result']['_id']);
      Future.delayed(const Duration(milliseconds: 15000), () async {
        ProgressBar.dismiss(context);
        navigateTo();
      });

      print("response::${response.toString()}");
    });
  }

  void navigateTo() =>
      Navigator.of(context).pushReplacementNamed(MasterDetail.tag);

  void restoreData(String userID) {
    Map<String, dynamic> map = new HashMap();
    map["user_id"] = userID;
    String mMap = jsonEncode(map);
    CommunicationManager.getInstance().connection();
    Future.delayed(const Duration(milliseconds: 15000), () async {
      if (mounted)
        setState(() {
          CommunicationManager.getInstance()
              .syncSubscribe(userID + "/kitouchplus_server_to_app_ack");
          CommunicationManager.getInstance()
              .publishSync("global_in/kitouchplus_server_to_app", mMap);
        });
    });
  }

  userData(LoginUser loginUser,Function completionHander,Function errorHandler) {
    model.loginUser(context, loginUser, (String error) {
      errorHandler(error);
    }, (Map response) {
      completionHander(response);
    });
  }

  final TextEditingController _controller = new TextEditingController();
  String str = "";
  String submitStr = "";

  void _changeText(String val) {
    setState(() {
      submitStr = val;
    });
    print("On RaisedButton : The text is $submitStr");
  }

  void _onSubmit(String val) {
    print("OnSubmit : The text is $val");
    setState(() {
      submitStr = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    void _onChanged(String value) {
      print('"OnChange : " $value');
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('First Screen'),
      ),
      body: new Container(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(
                hintText: "Type something...",
              ),
              onChanged: (String value) {
                _onChanged(value);
              },
              controller: _controller,
              onSubmitted: (String submittedStr) {
                _onSubmit(submittedStr);
                _controller.text = "";
              },
            ),
            new Text('$submitStr'),
            new RaisedButton(
              child: new Text("Click me"),
              onPressed: () {
                //_changeText(_controller.text);
                //getData();
                initConnectivity();
                // countT();
                _controller.text = _connectionStatus;
              },
            )
          ],
        ),
      ),
    );
  }
}