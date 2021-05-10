
/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itts/Guide/appGuide.dart';
import 'package:itts/Guide/appGuideNew.dart';
import 'package:itts/Guide/videoGuide.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/login/login.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper.dart';
import 'file:///D:/skromanApp/itts/lib/attendance/attendance.dart';
import 'file:///D:/skromanApp/itts/lib/attendance/employeeList.dart';
import 'package:itts/screens/searchTemperature.dart';
import 'package:itts/screens/add_device.dart';
import 'package:itts/utils/FToast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class SideDrawer extends StatefulWidget {

  String firstLetter = "";
  int dbValueLength;

  SideDrawer(this.firstLetter, this.dbValueLength);

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {

  FToast utils=new FToast();
  SharedPreferences _preferences;
  String fName = "",lName='',email='',userId;
  bool checkVisibility = false;


  ///showcase
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;
  var dbHelper = Helper();

  @override
  void initState() {
    super.initState();

    if(widget.dbValueLength > 0){

      setState(() {
        checkVisibility = true;
      });
    }
    getPreferencesValues();
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
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),

            ),
            child:fun_drawer(w/5, 10, 45, 35, 50, h/30),

          ),
        ],
      ),
    );
  }

  fun_drawer(double profileWidth, double topDividerHeight, int text_height_middle, int text_height_top, text_mailId, double iconHeight){

    double h = MediaQuery.of(context).size.height;
    return  Drawer(

      child: ListView(

        padding: EdgeInsets.zero,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(

              splashColor: Colors.grey.withOpacity(0.1),
              highlightColor: Colors.transparent,
              child: DrawerHeader(

                child: Row(

                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:

                      CircleAvatar(
                        radius: 25,

                       // backgroundImage: NetworkImage(_userAvatarUrl),
                        child: Text(widget.firstLetter,style: TextStyle(fontSize: h/30),),  //fName[0]
                      )

                    ),
                    // SizedBox(height: h/15,),

                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(fName+" "+lName, style: utils.textStyle(context,text_height_top,Colors.black,FontWeight.bold,0.0),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(email,
                              overflow: TextOverflow.ellipsis,
                              style: utils.textStyle(context,text_mailId,Colors.black,FontWeight.normal,0.0),),
                          ),

                        ],
                      ),
                    ),

                  ],
                ),

              ),
            ),
          ),

          ListTile(
            leading:
            Icon(Icons.event_note),
            title: Text('Attendance',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Attendance())); //LoginOption
            },
          ),
          Visibility(
            visible: checkVisibility,
            child: ListTile(
              leading:
              Icon(Icons.playlist_add_check),
              title: Text('Check Attendance',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EmployeeList())); //EmployeeList   AttendanceList
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top:topDividerHeight),
            child: Divider(
              height: 2.0,
              color: Colors.grey[400],
            ),
          ),

          Visibility(
            visible: checkVisibility,
            child: ListTile(
              leading:
              Icon(Icons.search),
              title: Text('Export',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DashboardTry())); //LoginOption
              },
            ),
          ),
          ListTile(
            leading:
            Icon(Icons.add_circle_outline),
            title: Text('Add Device',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddDevice())); //LoginOption
            },
          ),

          Padding(
            padding: EdgeInsets.only(top:topDividerHeight),
            child: Divider(
              height: 2.0,
              color: Colors.grey[400],
            ),
          ),

          ListTile(
            leading:
            Icon(Icons.videocam),
            title: Text('Guide',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => YoutubePlayerDemoApp())); // YoutubePlayerDemoApp  AppGuideNew
            },
          ),

          ListTile(
            leading:
            Icon(Icons.add_call),
            title: Text('Support (24 x 7)',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
             // Navigator.pop(context);
              launch("tel:"+"9850014833");
            },
          ),

         /* Padding(
            padding: EdgeInsets.only(top:topDividerHeight),
            child: Divider(
              height: 2.0,
              color: Colors.grey[400],
            ),
          ),*/

          /*ListTile(
            leading:
            Icon(Icons.lock),
            title: Text('Logout',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
               Navigator.pop(context);
               return showDialog(
                 context: context,
                 builder: (context) => new AlertDialog(
                   title: new Text('Confirm Logout?'),
                   content: new Text('Are you sure you want to logout?'),
                   actions: <Widget>[
                     new FlatButton(
                       onPressed: () {
                         Navigator.of(context).pop();
                       },
                       child: new Text('No'),
                     ),
                     new FlatButton(
                       onPressed: () {
                         logout();
                         Navigator.push(context,
                             MaterialPageRoute(builder: (context) => Login()));
                         },
                       child: new Text('Yes'),
                     ),
                   ],
                 ),
               ) ??
                   false;
            },
          ),*/

        ],
      ),
    );
  }


  void getPreferencesValues() async{
    _preferences = await SharedPreferences.getInstance();
    setState(() {

      fName = _preferences.getString("fname");
      lName = _preferences.getString("lname");
      email = _preferences.getString("email");
      userId = _preferences.getString("user_id");

      print(fName[0]);

    });

    print('Adddevice:gotUserId:::$email');
    print('Arti:gotUserId:::$userId');
  }

  void logout() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _authMethods.logoutApi().then((response) {

      print('gotdateresponse:::');
      print(response);

      if (response['success'] == "1") {



        clearPref();
        dbHelper.clearDB();
        dbHelper.clearEmp();
        FToast.show("Logout Successfully");

      } else if (response['success'] == "0") {

        FToast.show("Please try again");
      } else {
        FToast.show("API error");
      }
    });
  }

  void clearPref() async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}


