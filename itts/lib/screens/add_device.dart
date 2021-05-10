/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:avatar_glow/avatar_glow.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/models/User.dart';
import 'package:itts/screens/DashboardGrid.dart';
import 'file:///D:/skromanApp/itts/lib/attendance/attendance_dialog.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:itts/utils/toast_snack.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';


/*class AddDeviceOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
            builder: (context) => AddDevice()
        ),
      ),
    );
  }
}*/

class AddDevice extends StatefulWidget {
  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  TextEditingController ssidController = TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  int newIcon = 0;
  TextEditingController passwordController = TextEditingController();
  TextEditingController deviceNameController = TextEditingController();
  String desc, title;
  String result = "Hey there !";
  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SharedPreferences _preferences;
  String userId = '', formatted;
  var formatter_date, time;

  String status;
  FToast utils = new FToast();

  ///showcase
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();

  @override
  void initState() {
    preferencesUserId();

    var now = new DateTime.now();
    formatter_date = new DateFormat('yyyy-MM-dd');
    formatted = formatter_date.format(now);
    print(formatted + "dateprint");

    print("-----");
    time = new DateFormat("H:m:s").format(now);
    print(new DateFormat("H:m:s").format(now));

    /*WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context).startShowCase([_two,_three]));*/
    super.initState();
  }

  @override
  void dispose() {
    ssidController?.dispose();
    passwordController?.dispose();
    deviceNameController?.dispose();

    print("in dispose::");
    super.dispose();
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
            //    resizeToAvoidBottomPadding:false,
            appBar: AppBar(
              title: Text('Scan QR : '+ssidController.text),
              //          actions: <Widget>[qrScanButton],
            ),
            body: Form(
              key: _formKey,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: h,
                    width: w,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 35,
                              width: w,
                              color: Colors.red[50],
                              child: Center(
                                child: Text(
                                    'Please find the QR code located on device and scan it.'),
                              )),

                        /*  key: _two,
                          description: 'add device name eg: Main entrance / Lobby',*/
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: TextFormField(
                              controller: deviceNameController,
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                  labelText: 'Device Name',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (deviceNameController.text.isNotEmpty) {
                                _scanQR(deviceNameController.text);
                              } else {
                                FToast.showCenter(
                                    "Before scan, please enter device name");
                              }
                            },
                            child: AvatarGlow(
                              startDelay: Duration(milliseconds: 500),
                              glowColor: AppTheme.BUTTON_TEXT_COLOR,
                              endRadius: 100.0,
                              duration: Duration(milliseconds: 2000),
                              repeat: true,
                              showTwoGlows: true,
                              repeatPauseDuration: Duration(milliseconds: 100),
                              child: Material(
                                elevation: 8.0,
                                shape: CircleBorder(),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 4.5,
                                  height:
                                      MediaQuery.of(context).size.width / 4.5,
                                  //     color: AppTheme.SUB_TITLE_COLOR,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red[50],

                                    /* image: new DecorationImage(
                                          fit: BoxFit.fill,
                                          image:  NetworkImage("https://i.ya-webdesign.com/images/vector-scan-barcode-2.png",))*/
                                  ),

                                  child: Center(
                                      child: Text(
                                    "Scan",
                                    style: utils.textStyle(context, 30,
                                        Colors.black, FontWeight.bold, 0.0),
                                  )),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),


                          /* Padding(
                            padding: EdgeInsets.all(15.0),
                            child: TextFormField(
                              controller: ssidController,
                              enabled: false,

                              onChanged: (value) {
                                debugPrint('Something changed in Title Text Field');
                              },
                              decoration: InputDecoration(
                                  labelText: 'ssid',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0))),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15.0),
                            child: TextFormField(
                              controller: passwordController,
                              enabled: false,
                              validator: (value) {

                                if (value.isEmpty) {
                                  return 'Scan device first';
                                } else {
                                  return null;
                                }
                              },

                              onChanged: (value) {
                                debugPrint('Something changed in Title Text Field');
                              },
                              decoration: InputDecoration(
                                  labelText: 'password',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0))),
                            ),
                          ),
                          */

                          /*
                          new RaisedButton(
                              child: new Text(
                                'Scan | Add Device',
                                style: new TextStyle(color: Colors.white),
                              ),
                              color: AppTheme.BUTTON_BG_COLOR,
                              onPressed: () {

                                _scanQR();

                           //     checkInternet();
                          */ /*      if(ssidController.text.isEmpty){
                                  FToast.showCenter("Scan device first");
                                }else if(passwordController.text.isEmpty){
                                  FToast.showCenter("Scan device first");
                                }else{
                                  checkInternet();
                                  addUser();
                                }*/ /*
                              }),
                          */
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  addUser(String deviceName) async {
    print(deviceName);

    setState(() {
      _loading = true;
    });

    String result = await _authMethods.addDeviceData(
        context,
        ssidController.text,
        passwordController.text,
        formatted,
        time,
        deviceName,
        _scaffoldKey);

    print('----add device result----');
    print(result);
    if (result == 'error') {
      print("API error 0 issue");

      setState(() {
        _loading = false;
      });
    } else if (result == 'exist') {
      //temp hide

      setState(() {
        _loading = false;
      });
    } else if (result == "false") {
      setState(() {
        _loading = false;
      });
    } else if (result == "true") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard())); //Demo

      /* showDialog(
        context: context,
        builder: (_) => AttendanceDialog(msg1: "Device added successfully!",),
      );*/

      FToast.show("Device added successfully!");
    } else {
      FToast.show("API error");
    }
  }

  Future _scanQR(String deviceName) async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
        print("result:::$result");
      });
      //   FToast.showCenter(result);
      ssidController.text = result;
      if (result.startsWith('D?') && result.endsWith('?D')) {
        final List<String> _qrSP = result.split('?');
        if (_qrSP.length > 3) {
          result = _qrSP[1] +
              '-' +
              _qrSP[1] +
              '-Today-' +
              _qrSP[2] +
              '-' +
              result +
              '-' +
              _qrSP[1];

          ssidController.text = 'KI-' + _qrSP[1].substring(4);
          passwordController.text = _qrSP[2];
          deviceNameController.text = deviceName; //recenty added arti

          print("---------");
          print(_qrSP[1].substring(4));
          print('QRS: $result');

          final List<String> qrStringParts = result.split('-');
          print('111: $qrStringParts');

          checkInternet(deviceName);
        }
      } else {
        FToast.show("QR code does not match with our pattern");
      }
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  void preferencesUserId() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      userId = _preferences.getString("user_id");

      print('Adddevice:gotUserId:::$userId');
    });
  }

  checkInternet(String deviceName) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }

      addUser(deviceName);
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
