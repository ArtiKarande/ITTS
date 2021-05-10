/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itts/login/RegisterNewUser.dart';
import 'package:itts/login/login.dart';
import 'package:itts/models/message.dart';
import 'package:itts/screens/DashboardGrid.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:itts/utils/toast_snack.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_methods.dart';


class VerifyOtp extends StatefulWidget {

  String email,VerificationSessionId,type;

  VerifyOtp(this.email,this.VerificationSessionId,this.type);

  @override
  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> with TickerProviderStateMixin {

  GlobalKey<ScaffoldState> _scaffoldKey =GlobalKey <ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;

  String status;

  TextEditingController _otpController = TextEditingController();

  bool valueVisible = false;
  final List<Message> messages = [];
  String fcmToken = "";
  bool recent = false,dontVisible = true;


  ////////////
  int _counter = 0;
  AnimationController _controller;
  int levelClock = 70;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }


  @override
  void dispose() {
    _otpController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 70), () {
      setState(() {
        recent = true;
        dontVisible = false;
      });
    });

    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
            levelClock) // gameData.levelClock is a user entered number elsewhere in the applciation
    );

    _controller.forward();




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

    return SafeArea(
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
          body:

          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(fontSize: h / 40),
                        )),
                  ),

                  Visibility(
                    visible: dontVisible,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Countdown(
                          animation: StepTween(
                            begin: levelClock, // THIS IS A USER ENTERED NUMBER
                            end: 0,
                          ).animate(_controller),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Visibility(
                          visible: recent,

                          child: InkWell(
                              onTap: (){
                                resendOtp();

                                Countdown(
                                  animation: StepTween(
                                    begin: levelClock, // THIS IS A USER ENTERED NUMBER
                                    end: 0,
                                  ).animate(_controller),
                                );

                              },

                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text("resend OTP",style: TextStyle(color: Colors.green,fontSize: 20),),
                              ))),
                    ],
                  ),




                  Container(
                    margin: EdgeInsets.symmetric(vertical:  h/7, horizontal: w/11),
                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[


                        Text(
                          'OTP verification',
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
                            maxLength: 6,
                            validator: (value){

                              setState(() {
                                _loading = false;
                              });

                              if (value.isEmpty) {
                                return "Please enter otp";
                              } else if (value.length<6) {
                                return "otp should be 6 digits";
                              }
                              else if(value.contains(" ")){
                                return 'please remove extra space';
                              }

                              else{
                                return null;
                              }
                            },
                            controller: _otpController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(7.0)),
                              hintText: "Enter OTP",
                              contentPadding: const EdgeInsets.only(left: 8.0 ),

                            ),
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
                              "Submit",
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

     SharedPreferences _prefs = await SharedPreferences.getInstance();

     setState(() {
       _loading = true;
     });

     if(fcmToken.isNotEmpty){
       _authMethods.otpVerification(context,widget.email,_otpController.text,fcmToken,widget.type,widget.VerificationSessionId, _scaffoldKey).then((response) {

         setState(() {
           _loading = false;
         });

         print('gototpRess:::');
         print(response);

         if(response['success'] == "1"){

           _prefs.setString("fname", response['fname']);
           _prefs.setString("lname", response['lname']);
           _prefs.setString("email", response['email']);
           _prefs.setString("user_id", response['user_Id']);

           Navigator.push(context,
               MaterialPageRoute(builder: (context) => Dashboard()));

         }
         else if(response['success'] == "0"){

           print("OTP not match");
         }
         else{

           FToast.show("API error");
         }

       });
     }else{
       FToast.show("Token empty");

       setState(() {
         _loading = false;
       });

     }
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

  void resendOtp() async{

    setState(() {
      _loading = true;
    });

    _authMethods.sendOtp(context,widget.email , widget.type, _scaffoldKey).then((response){

      if(response['success'] == "1"){
        setState(() {
          _loading = false;
        });
        widget.VerificationSessionId = response['otpsession'];

      }else{
        FToast.show("OTP not sent");
      }
    });

  }
}


class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';



   /* print('animation.value  ${animation.value} ');
    print('inMinutes ${clockTimer.inMinutes.toString()}');
    print('inSeconds ${clockTimer.inSeconds.toString()}');
    print('inSeconds.remainder ${clockTimer.inSeconds.remainder(60).toString()}');
*/

    return Text(
      "$timerText",
      style: TextStyle(
        fontSize: 50,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}