/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/CheckInternetConnection.dart';
import 'package:happyfoods/Dashboard/DashboardTab.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:happyfoods/utils/message.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChangePassword extends StatefulWidget {

  String loginWith = '';

  ChangePassword(this.loginWith);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  GlobalKey<ScaffoldState> _scaffoldKey =GlobalKey <ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;

  TextEditingController _emailIDController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String status;
  bool passwordVisible = true;
  FToast utils = new FToast();

  NetworkCheck networkCheck = new NetworkCheck();

  @override
  void initState() {
    // TODO: implement initState

    _emailIDController.text = widget.loginWith;
    super.initState();
  }

  @override
  void dispose() {
    _emailIDController?.dispose();
    _passwordController?.dispose();
    super.dispose();
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
        appBar: AppBar(
          backgroundColor: Color(0xFFFAFAFA),
          iconTheme: IconThemeData(
            color: Colors.deepOrange, //change your color here
          ),
          title: Text('Change Password',style: TextStyle(
            color: Colors.deepOrange,
          )),),

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
              //  mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: w/11),
                    child: Column(

                  //    mainAxisAlignment: MainAxisAlignment.center,
               //       crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        SizedBox(height: 20,),
                        Image.asset("images/fresh.jpg",height: 100,),

                        SizedBox(height: 20,),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0,),
                          //height: h/18.0,

                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (value){

                              setState(() {
                                _loading = false;
                              });


                              if (value.isEmpty) {
                                return "Please enter mobile/email id";
                              }

                              else if(value.contains(" ")){
                                return 'please remove extra space';
                              }

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
                                return 'Enter new password';
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
                                return 'Enter new password';
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
                              hintText: "Confirm Password",

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

                        SizedBox(
                          height: h / 20.0,
                        ),
                        GestureDetector(
                          onTap: (){

                            if(_formKey.currentState.validate()){
                          //    networkCheck.checkInternet(fetchPrefrence);
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

  void changePasswordButton() async{

    setState(() {
      _loading = true;
    });

    String result = await _authMethods.loginUser(context,_emailIDController.text.replaceAll(" ", "") , _passwordController.text, "fcmToken", _scaffoldKey);

    print(result.toString());

    setState(() {
      _loading = false;
    });
  }

  fetchPrefrence(bool isNetworkPresent) {
    if(isNetworkPresent){
      changePasswordButton();

    }else{
      setState(() {
        _loading = false;
      });
      FToast.show(Message.noInternet);
    }
  }
}
