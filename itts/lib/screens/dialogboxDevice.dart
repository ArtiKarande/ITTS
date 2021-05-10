/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

/*


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/models/User.dart';
import 'package:itts/screens/AddEmployee.dart';
import 'package:itts/screens/dialog_addEmployee.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../Helper.dart';
import 'DashboardGrid.dart';
import 'attendanceList.dart';

class DialogboxDevice extends StatefulWidget {
  String deviceId = "", date, time, password, userId, deviceName;
  int id;

  DialogboxDevice(
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
  State<StatefulWidget> createState() => DialogboxDeviceState();
}

class DialogboxDeviceState extends State<DialogboxDevice>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  final renameController = TextEditingController();
  FToast utils = new FToast();
  bool _loading = false;
  AuthMethods _authMethods = AuthMethods();

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
          child: Center(
            child: Container(
              width: w / 1.2,
              height: h / 1.6,
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
                        child: Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 30,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                //    crossAxisAlignment: CrossAxisAlignment.center,

                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'Edit Device ',
                            style: utils.textStyle(
                                context, 40, Colors.black, FontWeight.bold, 0.0),
                          ),

                          Text(
                            widget.deviceName,
                            style: utils.textStyle(
                                context, 50, Colors.black, FontWeight.normal, 0.0),
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 15),

                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: renameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                                hintText: "Enter Device Name ",
                                contentPadding: const EdgeInsets.only(left: 8.0),
                              ),
                            ),
                          ),
                        ],
                      ),

                      FlatButton(
                        child: Text(
                          'Rename',
                        ),
                        onPressed: () {

                          Navigator.pop(context);

                          dialogBoxRename();

                        },
                      ),
                      FlatButton(
                        child: Text(
                          'Delete',
                        ),
                        onPressed: () {
                          dialogBoxDelete();

                          //   deleteDevice((widget.deviceId));
                        },
                      ),
                      FlatButton(
                        child: Text('Deactivate',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          dialogBoxDeactivate();

                          */
/*setState(() {
                            _loading = true;
                            deactivateDevice((widget.deviceId));
                          });*//*

                        },
                      ),
                      FlatButton(
                        child: Text(
                          'Add Employee',
                        ),
                        onPressed: () {
                          Navigator.pop(context);

//                          Navigator.push(context,
//                              MaterialPageRoute(builder: (context) => DialogboxEmployee(widget.deviceId)));   //AddEmployee

                          showDialog(
                            context: context,
                            builder: (_) => DialogboxEmployee(
                              widget.deviceId,
                            ),
                          );
                        },
                      ),
                      FlatButton(
                        child: Text(
                          'Cancel',
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
    );
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

  void deleteDevice(String deviceId) {
    setState(() {
      _loading = true;
    });

    _authMethods.deactivateDevice(deviceId, "removedevice").then((response) {
      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if (response['success'] == "1") {
        FToast.show("Device deleted");
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
      } else if (response['success'] == "0") {
        FToast.show("Device not deactivate please try again");
      } else {
        FToast.show("API error");
      }
    });
  }

  void deactivateDevice(String deviceId) {
    setState(() {
      _loading = true;
    });

    _authMethods
        .deactivateDevice(deviceId, "softDeviceRemove")
        .then((response) {
      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if (response['success'] == "1") {
        FToast.show("Device deactivated");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
      } else if (response['success'] == "0") {
        FToast.show("Device not deactivate please try again");
      } else {
        FToast.show("API error");
      }
    });
  }

  Future<bool> dialogBoxDeactivate() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: Container(
              height: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                      'All data for this device will be stored on server.'),
                  Text('You can add this device again at later stage.'),
                  Text(''),
                  Text('To delete data permantly use'),
                  Row(
                    children: <Widget>[
                      Text(
                        'Delete ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('option'),
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    deactivateDevice((widget.deviceId));
                  });
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> dialogBoxDelete() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: Container(
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('All data for this device '),
                      Text(
                        'will be ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text('permantly deleted.',style: TextStyle(fontWeight: FontWeight.bold),),
                  Text('This action can not be handle.'),
                  Text(''),
                  Text(
                      'In case, if you want to add this device again with existing data '),
                  Row(
                    children: <Widget>[
                      Text('then try '),
                      Text(
                        'Deactivate ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('option'),
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () {
                  deleteDevice((widget.deviceId));
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> dialogBoxRename() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Row(
          children: <Widget>[
            Text('Edit Device - ' +widget.deviceName),

          */
/*  Text(
              widget.deviceName,
              style: utils.textStyle(
                  context, 50, Colors.black, FontWeight.normal, 0.0),
            ),*//*

          ],
        ),
        content:   Container(
          height: 80,
          margin: const EdgeInsets.symmetric(
              vertical: 14.0, horizontal: 15),
          //height: h/18.0,

          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: renameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.0)),
              hintText: "Enter Device Name ",
              contentPadding: const EdgeInsets.only(left: 8.0),
            ),
          ),
        ),

        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              if (renameController.text.isNotEmpty) {
                renameApi(
                    widget.deviceId,
                    renameController.text,
                    widget.id,
                    widget.date,
                    widget.time,
                    widget.password,
                    widget.userId);
              } else {
                FToast.showCenter("Add Device name");
              }
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }
}
*/

