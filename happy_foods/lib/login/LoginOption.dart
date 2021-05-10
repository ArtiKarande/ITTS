/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/utils/StyleColor.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'Login.dart';
import 'RegisterNewUser.dart';
import 'dart:convert' show json;
import 'auth_methods.dart';

class LoginOption extends StatefulWidget {
  @override
  _LoginOptionState createState() => _LoginOptionState();
}

class _LoginOptionState extends State<LoginOption> {

  String _contactText,idToken='',userGoogleEmail='',fbTocken='',userFacebookEmail='';

  GlobalKey<ScaffoldState> _scaffoldKey =GlobalKey <ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;

  //////////////// Facebook ////////////////////////
  bool _isLoggedIn = false;
  Map userProfile;


  _logout(){

    setState(() {
      _isLoggedIn = false;
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
        color: AppTheme.BLACK_COLOR,
        size: 50,
      ),
      dismissible: false,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('images/bg.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Column(
              //  crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: h / 4,
                  ),
                  Text(
                    'Happy Foods',
                    style: TextStyle(
                      fontSize: h / 15,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  SizedBox(
                    height: h / 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterNewUser()));
                    },
                    child: Container(
                      height: h / 18,
                      width: w / 2.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppTheme.BUTTON_TEXT_COLOR,
                          AppTheme.BUTTON_TEXT_COLOR
//                          Color(0xFFEE0000),
//                          Color(0xFFD41A1F),
                        ]),
                        borderRadius: BorderRadius.circular(10),

                      ),
                      child: Center(
                        child: Text(
                          'Register',
                          style:
                              TextStyle(fontSize: h / 45, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: h / 20,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            //MaterialPageRoute(builder: (context) => DropDownExpantion()));
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Already a member? ',
                              style: TextStyle(
                                fontSize: h / 50,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: h / 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
