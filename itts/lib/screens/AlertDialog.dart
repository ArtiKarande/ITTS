/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itts/screens/DashboardGrid.dart';
import 'file:///D:/skromanApp/itts/lib/attendance/SelfAttendance.dart';
import 'file:///D:/skromanApp/itts/lib/attendance/attendanceList.dart';
import 'package:itts/screens/searchTemperature.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FunkyOverlay extends StatefulWidget {
  String msg = "",title;

  FunkyOverlay({Key key, this.msg,this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;
  SharedPreferences _preferences;
  String userId;

  @override
  void initState() {
    super.initState();

    getPreferencesValues();

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

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            width: w / 1.2,
            height: h / 3.5,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    BlinkWidget(children: <Widget>[

                      Icon(Icons.notifications_active,color: AppTheme.BUTTON_TEXT_COLOR,),
                      Icon(Icons.notifications_active, color: Colors.transparent),

                    ],),


                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        widget.title,
                        style: TextStyle(fontSize: h / 40,fontWeight: FontWeight.bold),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        widget.msg,
                        style: TextStyle(fontSize: h / 50,),
                      ),
                    ),

                    GestureDetector(
                      onTap: (){
                        FToast.show("message");
                      },

                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Center(
                          child: MaterialButton(
                            splashColor: AppTheme.BUTTON_BG_COLOR,
                            height: h / 18,
                            elevation: 2.0,
                            child: Text("Noted",style: TextStyle(color: Colors.white),),

                            color: AppTheme.BUTTON_BG_COLOR,
                            shape: StadiumBorder(), onPressed: () {

                              if(widget.msg == "Attendence Added"){

                                print(widget.msg);
                                Navigator.pop(context);

                                print("gotIDDD::");
                                print(userId);

                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => SelfAttendance(userId,"")));

                              }else{
                                Navigator.pop(context);
                          //      FToast.show("else");
                              }
                          },
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getPreferencesValues() async{
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      userId = _preferences.getString("user_id");

    });

    print('userId:gotUserId:::$userId');

  }
}

class BlinkWidget extends StatefulWidget {
  final List<Widget> children;
  final int interval;

  BlinkWidget({@required this.children, this.interval = 500, Key key}) : super(key: key);

  @override
  _BlinkWidgetState createState() => _BlinkWidgetState();
}

class _BlinkWidgetState extends State<BlinkWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  int _currentWidget = 0;

  initState() {
    super.initState();

    _controller = new AnimationController(
        duration: Duration(milliseconds: widget.interval),
        vsync: this
    );

    _controller.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        setState(() {
          if(++_currentWidget == widget.children.length) {
            _currentWidget = 0;
          }
        });

        _controller.forward(from: 0.0);
      }
    });

    _controller.forward();
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.children[_currentWidget],
    );
  }
}