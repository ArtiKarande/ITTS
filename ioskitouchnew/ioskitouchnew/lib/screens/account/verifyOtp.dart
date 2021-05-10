/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 * Skroman Switches pvt ltd.
 */

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/screens/auth_methods.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtp extends StatefulWidget {

  String email;
  VerifyOtp(this.email);

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
  bool recent = false,dontVisible = true;
  SharedPreference pref = new SharedPreference();

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

    print('initstatte');
    print(widget.email);

    Future.delayed(Duration(minutes: 2), () {
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
          color: Colors.blue,
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
                             //   resendOtp();

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
                                Colors.blue,
                                Colors.blue,
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

  /// to verify user is register or not
  void verifyOtpButton() async{

    setState(() {
      _loading = true;
    });
    _authMethods.verifyOtp(widget.email,_otpController.text).then((response){

      setState(() {
        _loading = false;
      });

      if(response['message'] == "Verification successfull"){
        pref.putString(SharedKey().Status, '1');
        pref.putString(SharedKey().setAuthValue, '0');    //reset value to 0 if user verify his otp



        Navigator.of(context).pushReplacementNamed(MasterDetail.tag);

        FToast.show("OTP verification successfull");
      }
      else if(response['message'] == "Incorrect OTP"){
        pref.putString(SharedKey().Status, '0');
        FToast.show("Incorrect OTP");
      }
    });
  }

  ///to check internet connection this method is used
  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }
      verifyOtpButton();

    } on SocketException catch (_) {
      print('not connected');

      FToast.show("You are not connected to internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }

 /* void resendOtp() async{

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

  }*/

  void navigateTo() =>
      Navigator.of(context).pushReplacementNamed(MasterDetail.tag);
}

///to show countdown timer this class is used
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
        color: Colors.white,
      ),
    );
  }
}