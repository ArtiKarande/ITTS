
/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:happyfoods/AboutUs/AboutUs.dart';
import 'package:happyfoods/Dashboard/DashboardTab.dart';
import 'package:happyfoods/changePassword/ChangePassword.dart';
import 'package:happyfoods/login/LoginOption.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'feedback/addFeedback.dart';

class SideDrawer extends StatefulWidget {

  SideDrawer();

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {

  FToast utils=new FToast();
  SharedPreferences _preferences;
  String fName = "",lName='',email='',userId='',roleId='';
  bool optionVisibility = true;

  @override
  void initState() {
    super.initState();
    getPreferencesValues();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),

          ),
          child:fun_drawer(w/5, 10, 45, 35, 50, h/30),

        ),
      ],
    );
  }

  fun_drawer(double profileWidth, double topDividerHeight, int text_height_middle, int text_height_top, text_mailId, double iconHeight){
    double w = MediaQuery.of(context).size.width;
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

                      Container(
                          width: w / 5,
                          height: w / 5, //changes
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 0.2,color: Colors.orangeAccent),
                             image: new DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: new AssetImage("images/food.png")),
                          )),

                    ),
                    // SizedBox(height: h/15,),

                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(fName + ' ' + lName, style: utils.textStyle(context,text_height_top,Colors.black,FontWeight.bold,0.0),),
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

          Visibility(
            visible: optionVisibility,
            child: ListTile(
              leading:
              Icon(Icons.restaurant_menu,color: Colors.orange[200],),
              title: Text('Menu',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DashboardTab(0)));
              },
            ),
          ),

         /* Visibility(
            visible: optionVisibility,
            child: ListTile(
              leading:
              Icon(Icons.search,color: Colors.green[200]),
              title: Text('Subscription plans',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),*/

          Visibility(
            visible: optionVisibility,
            child: Padding(
              padding: EdgeInsets.only(top:topDividerHeight),
              child: Divider(
                height: 2.0,
                color: Colors.grey[400],
              ),
            ),
          ),

          ListTile(
            leading:
            Icon(Icons.event_note, color: Colors.lightBlue[100]),
            title: Text('Feedback',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddFeedback())); //LoginOption
            },
          ),

        /*  ListTile(
            leading:
            Icon(Icons.lock_open, color: Colors.brown[200]),
            title: Text('Change Password',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChangePassword(email))); //LoginOption
            },
          ),*/

          ListTile(
            leading:
            Icon(Icons.info_outline, color: Colors.orange[200]),
            title: Text('About Us',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutUs()));
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
            Icon(Icons.add_call, color: Colors.green[200]),
            title: Text('Support (24 x 7)',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
              Navigator.pop(context);
              launch("tel:"+"8600190140");
            },
          ),
          ListTile(
            leading:
            Icon(Icons.lock, color: Colors.brown[200]),
            title: Text('Logout',style: utils.textStyle(context,text_height_middle,Colors.black,FontWeight.normal,0.0),),
            onTap: () {
           //   Navigator.pop(context);
              logoutOption();
            },
          ),
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
      roleId = _preferences.getString("roleId");

      if(roleId == '1' || roleId == '3'){
        setState(() {
          optionVisibility = false;
        });
      }

      print(fName[0]);

    });

    print('Adddevice:roleId:::$roleId');
    print('Arti:gotUserId:::$userId');
  }

  void clear() async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<bool> logoutOption() {

    return AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.WARNING,
      //customHeader: Text("hello"),

      body: Center(child: Text(
        'Do you want to logout?',
        style: TextStyle(fontStyle: FontStyle.normal),
      ),),
      title: 'This is Ignored',
      desc:   'This is also Ignored',

      btnOkOnPress: () {

        Navigator.of(context, rootNavigator: true).pop();

        clear();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => LoginOption()));
      },

      btnCancelOnPress: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    ).show();

  }

}


