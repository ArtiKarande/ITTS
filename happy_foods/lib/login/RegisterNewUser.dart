/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/CheckInternetConnection.dart';
import 'file:///D:/skromanApp/happy_foods/lib/dialogBox/successDialog.dart';
import 'package:happyfoods/login/verifyOtp.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:happyfoods/utils/message.dart';
import 'package:happyfoods/utils/toast_snack.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_methods.dart';

class RegisterNewUser extends StatefulWidget {
  @override
  _RegisterNewUserState createState() => _RegisterNewUserState();
}

class _RegisterNewUserState extends State<RegisterNewUser> {
  GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  NetworkCheck networkCheck = new NetworkCheck();

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;
  bool isConfirmed = false, passwordVisible = true;

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
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

    return ModalProgressHUD(
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
            child: Container(
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

                  SizedBox(height: 15,),

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
                        horizontal: w/11, vertical: h/9),
                    child: Column(
                      children: <Widget>[

                        Image.asset("images/pic.png",height: h/9,fit: BoxFit.fill,),

                        SizedBox(
                          height: h / 20.0,
                        ),

                        Row(
                          children: <Widget>[
                            Expanded(
                              child: getTextField("First Name",
                                  "First Name", _firstNameController),
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Expanded(
                              child: getTextField("Last Name",
                                  "Last Name", _lastNameController),
                            ),
                          ],
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            controller: _emailIDController,
                            keyboardType: TextInputType.number,
                             maxLength: 10,
                             validator: (value) {

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

                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                hintText: 'Send OTP on mobile number',
                                border: OutlineInputBorder( borderRadius: BorderRadius.circular(10)),
                                contentPadding:
                                const EdgeInsets.only(left: 14.0)),
                          ),
                        ),

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
                       /* Row(
                          children: <Widget>[
                            Expanded(
                              child: getTextField("Height",
                                  "Enter height", _heightController),
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Expanded(
                              child: getTextField("weight",
                                  "Enter weight", _weightController),
                            ),
                          ],
                        ),

                        getTextField("Medical condition", "should not empty" , _fullNameController),
                        getTextField("Delivery Address 1 ", "should not empty" , _fullNameController),
                        getTextField("Delivery Address 2 ", "should not empty" , _fullNameController),*/


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

                                networkCheck.checkInternet(fetchPrefrence);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              height: h / 18,
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
        textCapitalization: TextCapitalization.sentences,
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

  void registerUser() async {

    String type;

    if(_emailIDController.text.contains("@")){
      type = "1";    //email sathi
    }else{
      type = "2";    //phone sathi
    }

    print(_heightController.text + " " + _weightController.text + " " +
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

        showDialog(
          context: context,
          builder: (_) => FunkyOverlay(
            msg: "User already exist",
          ),
        );

        ShowCustomSnack.getCustomSnack(
            context, _scafoldKey, "User already exist");
      }
      else if(response['success'] == "3"){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VerifyOtp(_emailIDController.text,response["VerificationSessionId"],response["type"])));
      }

    });
  }


  fetchPrefrence(bool isNetworkPresent) {
    if(isNetworkPresent){
      registerUser();
    }else{
      setState(() {
        _loading = false;
      });
      FToast.show(Message.noInternet);
    }
  }
}
