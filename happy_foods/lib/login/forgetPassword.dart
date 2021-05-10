/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:happyfoods/utils/message.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../CheckInternetConnection.dart';
import 'auth_methods.dart';
import 'forgetPassword.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  GlobalKey<ScaffoldState> _scaffoldKey =GlobalKey <ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  NetworkCheck networkCheck = new NetworkCheck();


  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;
  var flag=0;

  String status,otpSession="";

  TextEditingController _emailIDController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController _newPasswordIDController = TextEditingController();

  bool valueVisible = false;
  bool passwordVisible = true;

  @override
  void dispose() {
    _emailIDController?.dispose();
    _otpController?.dispose();
    _newPasswordIDController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
        body: Form(
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

                  Container(
                    margin: EdgeInsets.symmetric(vertical:  h/7, horizontal: w/11),
                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        Text(
                          'Forgot Password ',
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
                            enabled: shouldEnable(), //arti
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

                        Visibility(
                          visible: valueVisible,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            alignment: Alignment.bottomCenter,
                            //height: h/18.0,
                            child: TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              obscureText: passwordVisible,
                              maxLength: 6,
                              validator: (value){

                                setState(() {
                                  _loading = false;
                                });

                                if(value.isEmpty){
                                  return 'Enter otp';
                                }
                                else if(value.contains(" ")){
                                  return 'please remove extra space';
                                }
                                else if(value.length<6){
                                  return 'please enter 6 digit otp';
                                }
                                else{
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(7.0)),
                                contentPadding: const EdgeInsets.only(left: 8.0),
                                hintText: "Enter OTP",

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
                        ),
                        Visibility(
                          visible: valueVisible,

                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            alignment: Alignment.bottomCenter,
                            //height: h/18.0,
                            child: TextFormField(
                              controller: _newPasswordIDController,
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
                                  return 'please enter at least 6 digit password';
                                }
                                else{
                                  return null;
                                }
                              },

                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(7.0)),
                                contentPadding: const EdgeInsets.only(left: 8.0),
                                hintText: "Enter New Password",

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

    String result,type;

    if(_emailIDController.text.contains("@")){
      type = "1";    //email sathi
    }else{
      type = "2";    //phone sathi
    }

    setState(() {
      _loading = true;
    });

    if(_otpController.text.isEmpty || _newPasswordIDController.text.isEmpty){
      _authMethods.sendOtp(context,_emailIDController.text ,type, _scaffoldKey).then((response){

        setState(() {
          _loading = false;
        });

        if(response['success'] == "1"){
          setState(() {
            valueVisible = true;
            otpSession = response['otpsession'];

          });
        }else if(response['success'] == "2"){
          FToast.show("Given data does not exist please try again");
        }
        else if(response['success'] == "0"){
          FToast.show("otp/Email not sent");
        }

      });

    }else{
      result = await  _authMethods.forgetPasswordWithOTP(context,_emailIDController.text,_otpController.text,_newPasswordIDController.text,otpSession,type,
          _scaffoldKey);


      print("result:::else::");
      print(result.toString());

      if(result == "1"){

        Navigator.pop(context);
        FToast.show("Password change successfully");

      }
      setState(() {
        _loading = false;
      });
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

  shouldEnable() {
    bool shouldEnable = true;

    if(valueVisible == true){
      shouldEnable = false;
    }
    else{
      shouldEnable = true;
    }
    return shouldEnable;


  }
}
