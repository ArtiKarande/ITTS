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
import 'file:///D:/skromanApp/itts/lib/attendance/attendance_dialog.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:itts/utils/toast_snack.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEmployee extends StatefulWidget {

  String deviceId;
  AddEmployee(this.deviceId);

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;
  bool isConfirmed = false, passwordVisible = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailIDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                hintText: 'mobile / email',
                                border: OutlineInputBorder( borderRadius: BorderRadius.circular(10)),
                                contentPadding:
                                const EdgeInsets.only(left: 14.0)),
                          ),
                        ),

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
                                "Add",
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

  void registerUser() async {

    String type;

    if(_emailIDController.text.contains("@")){
      type = "1";    //email sathi
    }else{
      type = "2";    //phone sathi
    }

    _authMethods.addEmployee(_firstNameController.text,_lastNameController.text,_emailIDController.text,
        _scafoldKey,context,type,widget.deviceId).then((response) {

      setState(() {
        _loading = false;
      });

      if(response['success'] == "1"){

        print("-------");
        print(response);

        String name = _firstNameController.text + " " + _lastNameController.text;

        showDialog(
          context: context,
          builder: (_) => AttendanceDialog(msg1: " $name added successfully!",),
        );

        _firstNameController.text = "";
        _lastNameController.text = "";
        _emailIDController.text = "";
      }
      else if(response['success'] == "0"){
        ShowCustomSnack.getCustomSnack(
            context, _scafoldKey, "User Not Exist !");

      } else if(response['success'] == "2"){

        String name = _firstNameController.text + " " + _lastNameController.text;
        showDialog(
          context: context,
          builder: (_) => AttendanceDialog(msg1: " $name already exist !",),
        );

        _firstNameController.text = "";
        _lastNameController.text = "";
        _emailIDController.text = "";
      }
      else{
        FToast.showCenter("API error");
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
