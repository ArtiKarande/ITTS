/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itts/login/RegisterNewUser.dart';
import 'package:itts/models/message.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'auth_methods.dart';
import 'forgetPassword.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  GlobalKey<ScaffoldState> _scaffoldKey =GlobalKey <ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;

  TextEditingController _emailIDController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String status;
  bool passwordVisible = true;

  final List<Message> messages = [];
  String fcmToken = "";


  @override
  void dispose() {
    _emailIDController?.dispose();
    _passwordController?.dispose();
    fcmToken = "";
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 0.5,
          progressIndicator: SpinKitFadingCircle(
            color: AppTheme.BUTTON_BG_COLOR,
            size: 50,
          ),
          dismissible: false,
          child: Scaffold(
            key: _scaffoldKey,
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.only(top:5.0,right: 10.0),
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          child: Text(' Forgot Password? ' ,
                            style: TextStyle(
                                fontSize: h/40,
                            ),),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) => ForgetPassword()));
                          },
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(vertical:  h/4, horizontal: w/11),
                      child: Column(

                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          Text(
                            'Welcome to ITTS',
                            style: TextStyle(
                              fontSize: h / 30,
                            ),
                          ),
                          SizedBox(
                            height: h / 40,
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 14.0),
                            //height: h/18.0,

                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              validator: (value){

                                setState(() {
                                  _loading = false;
                                });

                                /*Pattern pattern =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                                RegExp regex = new RegExp(pattern);*/


                                if (value.isEmpty) {
                                  return "Please enter mobile/email id";
                                }
                               /* else if (!value.contains("@")) {
                                  return "Incorrect email id";
                                }*/
                                else if(value.contains(" ")){
                                  return 'please remove extra space';
                                }

                               /* else if(!regex.hasMatch(value)){
                                  return 'Invalid email address';
                                }*/

                                else{
                                  return null;
                                }
                              },
                              controller: _emailIDController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(7.0)),
                                hintText: "mobile / Email ID",
                                contentPadding: const EdgeInsets.only(left: 8.0 ),

                              ),
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            alignment: Alignment.bottomCenter,
                            //height: h/18.0,
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: passwordVisible,
                              validator: (value){

                                setState(() {
                                  _loading = false;
                                });

                                if(value.isEmpty){
                                  return 'Enter password';
                                }
                                else if(value.contains(" ")){
                                  return 'please remove extra space';
                                }
                                else if(value.length<6){
                                  return 'please enter 6 digit password';
                                }
                                else{
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(7.0)),
                                contentPadding: const EdgeInsets.only(left: 8.0),
                                hintText: "Enter Password",

                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: h / 40,
                          ),

                          Container(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              child: Text('You dont have an account? Sign Up' ,
                                style: TextStyle(
                                    fontSize: h/55
                                ),),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterNewUser()));
                              },
                            ),
                          ),

                          SizedBox(
                            height: h / 20.0,
                          ),
                          GestureDetector(
                            onTap: (){

                              if(_formKey.currentState.validate()){

                                checkInternet();

                              }
                            },

                            child: Container(
                              alignment: Alignment.center,
                              //height: h / 20,
                              width: w / 2.5,
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  AppTheme.BUTTON_BG_COLOR,
                                  AppTheme.BUTTON_BG_COLOR
                                ]),
                                borderRadius: BorderRadius.circular(10),

                              ),
                              child: Text(
                                "Login",
                                style:
                                TextStyle(fontSize: h / 45, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => exit(0),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }


  void animateButton() async{

    setState(() {
      _loading = true;
    });

    if(fcmToken.isNotEmpty){
      String result = await _authMethods.loginUser(context,_emailIDController.text.replaceAll(" ", "") , _passwordController.text, fcmToken, _scaffoldKey);

      print(result.toString());

    }else{
      FToast.show("Token empty");
    }

    setState(() {
      _loading = false;
    });
  }

  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }

      animateButton();

    } on SocketException catch (_) {
      print('not connected');
      
      FToast.show("You are not connected to internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }
}
