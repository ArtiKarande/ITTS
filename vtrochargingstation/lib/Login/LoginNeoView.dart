/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:io';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:vtrochargingstation/CommunicationManager.dart';

import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/message.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/text_field.dart';
import '../InternetConnectivity/network_info.dart';
import 'login.dart';

class LoginView extends LoginState{

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _emailIDController = new TextEditingController();

  String status;
  bool passwordVisible = true;

  String fcmToken = "";
  AppTheme utils = new AppTheme();

  @override
  void initState() {
    loginButtonVisibility = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    /// state management - current state maintain [provider]
    final MQTTAppState appState =Provider.of<MQTTAppState>(context, listen: true);
    currentAppState = appState;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomPadding:false,
        key: _scaffoldKey,
          backgroundColor: AppTheme.background,

          /// UI
          body: SafeArea(
            child: SingleChildScrollView(
              child: Stack(
                children: [

                  Center(child: Container(
                      height: h/1.3,
                      child: Padding(
                        padding: EdgeInsets.only(right:h/5),
                        child: Image.asset("images/loginCircle.png",fit: BoxFit.cover,),
                      ))),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                   //      SizedBox(height: h/20,),
                          Image.asset('images/vtrologo.png', height: h/7 ),

                          Text('LOGIN HERE', style:utils.textStyleRegular2(context,FontWeight.w400)),

                          SizedBox(height: h/10,),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: NeumorphicTextField(
                              textSize: 48,
                              height: 15.0,
                              text: _emailIDController.text,
                              hint: ' Mobile Number / Email Address',
                              onChanged: itemTitleChanget,
                            ),
                          ),

                          SizedBox(height: h/10,),

                          /// login button
                          Visibility(
                            visible: loginButtonVisibility,
                            child: Container(

                              height: h/13,
                              margin: EdgeInsets.symmetric( horizontal: h/15), // horizontal = width, vertical = height

                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius:
                                const BorderRadius.all(Radius.circular(35)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      offset: const Offset(4, 4),
                                      blurRadius: 8.0),
                                ],
                              ),

                              child: NeumorphicButton(
                                onPressed: () async {

                                  FocusScope.of(context).requestFocus(FocusNode());

                                  Pattern pattern =
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                                  RegExp regex = new RegExp(pattern);

                                  bool result = await DataConnectionChecker().hasConnection;
                                  if(result == true) {

                                    if(_emailIDController.text.isEmpty){
                                //      FToast.show('Please enter mobile/email id');
                                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter valid mobile number/email address');
                                      //   FToast.show('Internet connection available');
                                    }

                                    else if(_emailIDController.text.contains('@')){

                                    if(!regex.hasMatch(_emailIDController.text)){

                                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter valid email address');

                                    }else{

                                      setState(() {
                                        loginButtonVisibility = false;
                                      });

                                      ProgressBar.show(context);
                                      normalLogin(_emailIDController.text);
                                    }

                                    }

                                    else{
                                      if(_emailIDController.text.length < 10){
                                        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter valid mobile number/email address');
                                      }else{
                                        String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                                        RegExp regExp = new RegExp(pattern);
                                        if (!regExp.hasMatch(_emailIDController.text)) {
                                          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter valid mobile number/email address');
                                        }else{

                                          setState(() {
                                            loginButtonVisibility = false;
                                          });

                                          ProgressBar.show(context);
                                          normalLogin(_emailIDController.text);
                                        }
                                      }
                                    }
                                  } else {
                                //    FToast.show('no internet connection');

                                    ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.NO_INTERNET);
                                    print(DataConnectionChecker().lastTryResults);
                                  }
                                },

                                style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                    color: AppTheme.background,
                                    depth: 10,
                                    surfaceIntensity: 0.20,
                                    intensity: 15,
                                    shadowDarkColor: Color(0xFFe2e2e2),  //outer bottom shadow
                                    shadowLightColor: Colors.white  // outer top shadow
                                ),

                                child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    Text('LOGIN', style:utils.textStyleRegular2(context,FontWeight.w700)),

                                    Padding(
                                      padding: const EdgeInsets.only(left:10.0),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Color(0xFF808080),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: h/15,),

                          /// or login using
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [

                              Text('Or',style:utils.textStyleRegular2(context,FontWeight.w400)),
                              Text('Login Using',style:utils.textStyleRegular2(context,FontWeight.w400)),
                            ],
                          ),

                          SizedBox(height: h/20,),

                          /// 3 icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /// temporary hide this
                              /*Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(35)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.6),
                                          offset: const Offset(4, 4),
                                          blurRadius: 8.0),
                                    ],
                                  ),

                                  child: NeumorphicButton(

                                    onPressed: (){
                                    },

                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      //  shape: NeumorphicShape.concave,

                                      color: AppTheme.background,
                                      depth: 10,
                                      surfaceIntensity: 0.20,
                                      intensity: 15, //drop shadow
                                      shadowDarkColor: Color(0xFFe2e2e2), // upper bottom shadow
                                      shadowLightColor: Colors.white,  // upper top shadow

                                    ),

                                    child: Image.asset(
                                      'images/twitter.png',
                                      fit: BoxFit.contain,
                                    ),

                                  ),
                                ),
                              ),*/
                              /*Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(35)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.6),
                                          offset: const Offset(4, 4),
                                          blurRadius: 8.0),
                                    ],
                                  ),

                                  child: NeumorphicButton(
                                    onPressed: (){
                                      ProgressBar.show(context);

                                      signInGoogle(_scaffoldKey);
                                    },

                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      color: AppTheme.background,
                                      depth: 10,
                                      surfaceIntensity: 0.20,
                                      intensity: 15, //drop shadow
                                      shadowDarkColor: Color(0xFFe2e2e2), // upper bottom shadow
                                      shadowLightColor: Colors.white,  // upper top shadow

                                    ),

                                    child: Image.asset(
                                      'images/google.png',
                                      fit: BoxFit.contain,

                                      //  height: 250,
                                      //  width: 250,
                                    ),

                                  ),
                                ),
                              ),


                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(35)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.6),
                                          offset: const Offset(4, 4),
                                          blurRadius: 8.0),
                                    ],
                                  ),

                                  child: NeumorphicButton(
                                    onPressed: (){
                                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.upcoming);
                                    },

                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      color: AppTheme.background,
                                      depth: 10,
                                      surfaceIntensity: 0.20,
                                      intensity: 15, //drop shadow
                                      shadowDarkColor: Color(0xFFe2e2e2), // upper bottom shadow
                                      shadowLightColor: Colors.white,  // upper top shadow

                                    ),

                                    child: Image.asset(
                                      'images/fb.png',
                                      fit: BoxFit.contain,
                                      // height: 100,
                                    ),

                                  ),
                                ),
                              ),
                              */


                              Container(

                                child: NeumorphicButton(
                                  onPressed: (){
                                    ProgressBar.show(context);
                                    signInGoogle(_scaffoldKey);
                                  },
                                  style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.circle(),
                                    color: AppTheme.background,
                                    depth: 5,
                                    surfaceIntensity: 0.20,
                                    intensity: 0.99, //drop shadow
                                    shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                                    shadowLightColor: Colors.white,  // upper top shadow

                                  ),

                                  child: Image.asset(
                                    'images/google.png',
                                    height: 35,
                                    width: 35,
                                  ),

                                ),
                              ),

                              SizedBox(width: w/15),

                              Container(

                                child: NeumorphicButton(
                                  onPressed: (){

                                //    loginWithFB();
                                    ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.upcoming);
                                  },
                                  style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.circle(),
                                    color: AppTheme.background,
                                    depth: 5,
                                    surfaceIntensity: 0.20,
                                    intensity: 0.99, //drop shadow
                                    shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                                    shadowLightColor: Colors.white,  // upper top shadow

                                  ),

                                  child: Image.asset(
                                    'images/fb.png',
                                    height: 35,
                                    width: 35,
                                  ),

                                ),
                              ),

                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  /// value changes to edittext callback method
  void itemTitleChanget(String title) {
    setState(() {
      this._emailIDController.text = title;

      print('textval...');
      print(_emailIDController.text);

    });
  }

  /// on press of android back button action
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(

        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
         //   onPressed: () => exit(0),
            onPressed: (){
              SystemNavigator.pop();
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

}
