
/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

/*

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:itts/Helper.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/models/User.dart';
import 'package:itts/screens/AddEmployee.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'attendance_dialog.dart';

class RenameDevice extends StatefulWidget {
  String deviceId = "", date, time, password, userId, deviceName;
  int id;

  RenameDevice(
      {Key key,
        this.deviceId,
        this.id,
        this.date,
        this.time,
        this.password,
        this.userId,
        this.deviceName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => RenameDeviceState();
}

class RenameDeviceState extends State<RenameDevice>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  final TextEditingController renameController = TextEditingController();
  FToast utils=new FToast();
  bool _loading = false;
  AuthMethods _authMethods = AuthMethods();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String status="";

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 0.5,
          progressIndicator: SpinKitFadingCircle(
            color: AppTheme.BUTTON_BG_COLOR,
            size: 50,
          ),
          dismissible: false,
          child: Form(
            key: _formKey,
            child: Center(
              child: Container(
                width: w / 1.2,
                height: h / 2.5,
                decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0))),
                child: Stack(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                          child: Icon(Icons.cancel, color: Colors.red, size: 30,

                          ),onTap: (){
                          Navigator.pop(context);
                        },),
                      ],
                    ),
                    Column(
                      children: <Widget>[

                        SizedBox(height: 10,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Edit - ",style: utils.textStyle(context,45,Colors.black,FontWeight.bold,0.0),),

                            Text(
                              widget.deviceId,
                              style: utils.textStyle(
                                  context, 50, Colors.black, FontWeight.normal, 0.0),
                            ),
                          ],
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 20),
                          child: TextFormField(
                            controller: renameController,
                            keyboardType: TextInputType.emailAddress,

                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                hintText: 'Enter Device Name',
                                border: OutlineInputBorder( borderRadius: BorderRadius.circular(10)),
                                contentPadding:
                                const EdgeInsets.only(left: 14.0)),
                          ),
                        ),
                        FlatButton(
                          child: Text('Add',),
                          onPressed: () {

                            if(renameController.text.isNotEmpty){
                              setState(() {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  checkInternet();
                                }
                              });

                            }else{
                              FToast.showCenter("Add Device name");
                            }
                          },
                        ),

                        FlatButton(
                          child: Text('Cancel',
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }
      renameApi(widget.deviceId,
          renameController.text,
          widget.id,
          widget.date,
          widget.time,
          widget.password,
          widget.userId);

    } on SocketException catch (_) {
      print('not connected');

      FToast.show("You are not connected to internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }

  void renameApi(String deviceId, String deviceName, uid, date, time, password,
      userID) async {
    setState(() {
      _loading = true;
    });

    _authMethods.editDeviceDetails(deviceId, deviceName).then((response) {
      var user = User("", "", "", "", "", "","");
      user.id = uid;
      user.name = deviceId;
      user.password = password;
      user.userId = userID;
      user.date = date;
      user.time = time;
      user.deviceName = deviceName;
      user.datenew =

      var dbHelper = Helper();
      dbHelper.update(user).then((update) {
        renameController.text = "";

        Navigator.of(context).pop();
        print("Data Saved successfully");
      });

      setState(() {
        _loading = false;
      });

      print('gototpRess:::');
      print(response);

      if (response['success'] == "1") {
        FToast.show("Device name changed successfully");
      } else if (response['success'] == "0") {
        print("something went wrong please try again");
      } else {
        FToast.show("API error");
      }
    });
  }
}

*/
