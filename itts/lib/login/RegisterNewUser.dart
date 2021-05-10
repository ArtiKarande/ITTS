/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itts/constants.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/login/login.dart';
import 'package:itts/login/verifyOtp.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:itts/utils/toast_snack.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterNewUser extends StatefulWidget {
  @override
  _RegisterNewUserState createState() => _RegisterNewUserState();
}

class _RegisterNewUserState extends State<RegisterNewUser> {
  GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;
  bool isConfirmed = false, passwordVisible = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailIDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String status;
  SharedPreferences _preferences;
  String fName = '',lName='',email='',userId;

  @override
  void initState() {
      passwordVisible = true;
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
          key: _scafoldKey,
          body: Form(
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
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: w/11, vertical: h/7),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Register',
                          style: TextStyle(
                              fontSize: h / 25, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: h / 20.0,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: getTextField("First Name",
                                  "Enter First Name", _firstNameController),
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Expanded(
                              child: getTextField("Last Name",
                                  "Enter Last Name", _lastNameController),
                            ),
                          ],
                        ),
                        //  getTextField("Email ID", 'Invalid email address' , _emailIDController),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            controller: _emailIDController,
                            keyboardType: TextInputType.emailAddress,
                           /* validator: (value) {
                              setState(() {
                                _loading = false;
                              });

                              Pattern pattern =
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                              RegExp regex = new RegExp(pattern);

                              if (!_emailIDController.text.contains("@")) {
                                return 'missing @ symbol';
                              } else if (_emailIDController.text
                                  .contains(" ")) {
                                return 'please remove extra space';
                              } else if (!regex
                                  .hasMatch(_emailIDController.text)) {
                                return 'Invalid email address';
                              } else {
                                return null;
                              }
                            },*/

                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                hintText: 'Send OTP on mobile / email',
                                border: OutlineInputBorder( borderRadius: BorderRadius.circular(10)),
                                contentPadding:
                                const EdgeInsets.only(left: 14.0)),
                          ),
                        ),
                        //       getTextField("Password", "Password must be at least 8 characters long" , _passwordController),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: passwordVisible,

                            validator: (value) {
                              setState(() {
                                _loading = false;
                              });

                              if (value.isEmpty) {
                                return 'Password must be at least 6 digits';
                              } else if (value.contains(" ")) {
                                return 'please remove extra space';
                              } else if (value.length < 6) {
                                return 'Password must be at least 6 digits';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                                counterText: '',  //optional
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                hintText: 'Password',
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
                                border: OutlineInputBorder( borderRadius: BorderRadius.circular(10)),
                                contentPadding:
                                const EdgeInsets.only(left: 14.0)),
                          ),
                        ),

                       /* getTextField("Location", "Please Enter Location",
                            _countryController),*/

                        SizedBox(
                          height: h / 20.0,
                        ),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  _loading = true;
                                });

                                checkInternet();

                              }
                            });
                          },
                          child: Container(
                            height: h / 20,
                            width: w / 2.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                AppTheme.BUTTON_BG_COLOR,
                                AppTheme.BUTTON_BG_COLOR,
                              ]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Register",
                                style: TextStyle(
                                    fontSize: h / 45, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getTextField(hintText, errorText, TextEditingController _controller) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    setState(() {
      _loading = false;
    });
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controller,
        validator: (_controller) {
          if (_controller.isEmpty) {
            return errorText;
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            hintText: hintText,
            border: OutlineInputBorder( borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.only(left: 14.0)),
      ),
    );
  }
  /*void registerUser() async {

    String result,type;



    print(_firstNameController.text + " " + _lastNameController.text + " " +
        _emailIDController.text + " " + _passwordController.text);

    if(_emailIDController.text.contains('@')){
      type = "1";    //email sathi

      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

      RegExp regex = new RegExp(pattern);

      if (!_emailIDController.text.contains("@")) {
        FToast.show("missing @ symbol");
      } else if (_emailIDController.text
          .contains(" ")) {
        FToast.show("please remove extra space");
      } else if (!regex
          .hasMatch(_emailIDController.text)) {
        FToast.show("Invalid email address");
      } else {

        setState(() {
          _loading = true;
        });
        result = await  _authMethods.registerUser(_firstNameController.text,_lastNameController.text,_emailIDController.text,
            _passwordController.text,_scafoldKey,context,type);

        print("check::a::");
        print(result);

      }


    }else{
      type = "2";  //mobile sathi

      if(_emailIDController.text.length <10 || _emailIDController.text.length > 10){
        FToast.show("Please enter valid mobile number");
      }else{

        setState(() {
          _loading = true;
        });
        result = await  _authMethods.registerUser(_firstNameController.text,_lastNameController.text,_emailIDController.text,
            _passwordController.text,_scafoldKey,context,type);

        print("check::a::");
        print(result);
      }

    }

      setState(() {
        _loading = false;
      });

      if(result == "1"){

        print(_emailIDController.text);

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VerifyOtp(_emailIDController.text)));

      }
      else if(result == "0"){
          ShowCustomSnack.getCustomSnack(
              context, _scafoldKey, "error");
      }
      else if(result == "2"){

        ShowCustomSnack.getCustomSnack(
            context, _scafoldKey, "User already exist");
      }
      else if(result == "3"){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VerifyOtp(_emailIDController.text)));
      }


  }*/

  void registerUser() async {

    String type;

    if(_emailIDController.text.contains("@")){
      type = "1";    //email sathi
    }else{
      type = "2";    //phone sathi
    }


    print(_firstNameController.text + " " + _lastNameController.text + " " +
        _emailIDController.text + " " + _passwordController.text);

    _authMethods.registerUser(_firstNameController.text,_lastNameController.text,_emailIDController.text,
        _passwordController.text,_scafoldKey,context,type).then((response) {

      setState(() {
        _loading = false;
      });

      if(response['success'] == "1"){

        print(_emailIDController.text);
        print("-------");
        print(response);

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VerifyOtp(_emailIDController.text,response["VerificationSessionId"],response["type"])));

      }
      else if(response['success'] == "0"){
        ShowCustomSnack.getCustomSnack(
            context, _scafoldKey, "error");
      }
      else if(response['success'] == "2"){

        ShowCustomSnack.getCustomSnack(
            context, _scafoldKey, "User already exist");
      }
      else if(response['success'] == "3"){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VerifyOtp(_emailIDController.text,response["VerificationSessionId"],response["type"])));
      }

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
      registerUser();


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
