/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/models/User.dart';
import 'package:itts/screens/AddEmployee.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../Helper.dart';
import 'DashboardGrid.dart';
import '../attendance/attendanceList.dart';
import '../attendance/attendance_dialog.dart';

class DialogboxEmployee extends StatefulWidget {
  String deviceId = "";

  DialogboxEmployee(this.deviceId);

  @override
  State<StatefulWidget> createState() => DialogboxEmployeeState();
}

class DialogboxEmployeeState extends State<DialogboxEmployee>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  final TextEditingController _emailIDController = TextEditingController();
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

                        Text("Add Employee Details",style: utils.textStyle(context,45,Colors.black,FontWeight.bold,0.0),),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 20),
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
                        FlatButton(
                          child: Text('Add',),
                          onPressed: () {

                            if(_emailIDController.text.isNotEmpty){

                              setState(() {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  checkInternet();
                                }
                              });

                            }else{
                              FToast.showCenter("Add mobile/email");
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

  void registerUser() async {

    String type;

    if(_emailIDController.text.contains("@")){
      type = "1";    //email sathi
    }else{
      type = "2";    //phone sathi
    }

    _authMethods.addEmployee("","",_emailIDController.text,
        "",context,type,widget.deviceId).then((response) {

      setState(() {
        _loading = false;
      });

      if(response['success'] == "1"){

        print("-------");
        print(response);

        showDialog(
          context: context,
          builder: (_) => AttendanceDialog(msg1: "user added successfully!",),
        );

        _emailIDController.text = "";
      }
      else if(response['success'] == "0"){
        FToast.showCenter("User Not Exist !");

      } else if(response['success'] == "2"){

        String name = _emailIDController.text;
        showDialog(
          context: context,
          builder: (_) => AttendanceDialog(msg1: " $name already exist !",),
        );

        _emailIDController.text = "";
      }
      else{
        FToast.showCenter("API error");
      }

    });
  }

}
