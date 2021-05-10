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
import 'package:happyfoods/CheckInternetConnection.dart';
import 'package:happyfoods/Dashboard/DashboardTab.dart';
import 'package:happyfoods/dialogBox/successDialog.dart';
import 'package:happyfoods/models/message.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:happyfoods/utils/message.dart';
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

  NetworkCheck networkCheck = new NetworkCheck();

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;

  String status;

  TextEditingController _otpController = TextEditingController();

  bool valueVisible = false;
  String fcmToken = "";
  bool recent = false,dontVisible = true;

  final List<MessageNfication> messages = [];


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
        size: 50,
      ),
      dismissible: false,
      child: Scaffold(
        key: _scaffoldKey,
        body:

        Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              height: h,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
                  image: new AssetImage('images/doodle.jpg'),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: <Widget>[

                  SizedBox(height: 20,),

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
                    margin: EdgeInsets.symmetric(vertical:  h/8, horizontal: w/11),
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

                        SizedBox(height: 10,),

                        Text(
                          'We\'ll send an SMS message to verify your identity, please enter your OTP right below!',
                          style: TextStyle(
                            fontSize: h / 50,
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
                              prefixIcon: Icon(Icons.lock_open, color: Colors.orange,),
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
           _prefs.setString("roleId", response['roleId']);

           Navigator.pop(context);

           Navigator.push(context,
               MaterialPageRoute(builder: (context) => DashboardTab(0)));


           showDialog(
             context: context,
             builder: (_) => FunkyOverlay(
               msg: "Thanks for registering with Hashtag Happy Foods",
             ),
           );

         }
         else if(response['success'] == "0"){

           print("OTP not match");
         }
         else{

           FToast.show("API error");
         }
       });
     }else{
       FToast.show("Token empty! Please try again");
     }


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

    return Text(
      "$timerText",
      style: TextStyle(
        fontSize: 50,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}