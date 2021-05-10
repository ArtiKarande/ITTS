/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/CheckInternetConnection.dart';
import 'package:happyfoods/Dashboard/DashboardTab.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/models/message.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:happyfoods/utils/message.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'RegisterNewUser.dart';
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

  String fcmToken = "";
  final List<MessageNfication> messages = [];

  NetworkCheck networkCheck = new NetworkCheck();

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
          messages.add(MessageNfication(
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

    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: AppTheme.BUTTON_BG_COLOR,
        size: 40,
      ),
      dismissible: false,
      child: Scaffold(
        key: _scaffoldKey,

        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(

              decoration: new BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
                  image: new AssetImage('images/doodle.jpg'),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.only(top:35.0,right: 10.0),
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

//             /     Image.asset('images/happyfoodlogo.png', height: 150,),

                  Container(
                    margin: EdgeInsets.symmetric(vertical:  h/5, horizontal: w/11),
                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        Text(
                          'Welcome to Happy Foods',
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
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            validator: (value){

                              setState(() {
                                _loading = false;
                              });

                              if (_emailIDController.text.length < 10) {
                                return 'enter 10 digit number';
                              } else if (_emailIDController.text
                                  .contains(" ")) {
                                return 'please remove extra space';
                              } else {
                                return null;
                              }
                            },
                            controller: _emailIDController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(7.0)),
                              hintText: "Enter registered mobile no.",
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

                              networkCheck.checkInternet(fetchPrefrence);

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
    );
  }

  void animateButton() async{

    String result;

    print('gotToken::: $fcmToken');

    setState(() {
      _loading = true;
    });

    if(fcmToken.isNotEmpty){
      result = await _authMethods.loginUser(context,_emailIDController.text.replaceAll(" ", "") , _passwordController.text, fcmToken, _scaffoldKey);

    }else{
      FToast.show("Token empty! Please try again");
    }


    print(result.toString());

    setState(() {
      _loading = false;
    });

  }

  fetchPrefrence(bool isNetworkPresent) {
    if(isNetworkPresent){
      animateButton();

    }else{
      setState(() {
        _loading = false;
      });
      FToast.show(Message.noInternet);
    }
  }
}
