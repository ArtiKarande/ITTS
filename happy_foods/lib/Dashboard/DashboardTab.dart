/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:happyfoods/Dashboard/PlanTab.dart';
import 'package:happyfoods/SideDrawerNavgation.dart';
import 'package:happyfoods/dialogBox/successDialog.dart';
import 'package:happyfoods/notification/ViewNoticeboard.dart';
import 'package:happyfoods/payment/payment.dart';
import 'HomeTab.dart';
import 'SubscriptionTab.dart';
import 'MyProfile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DashboardTab extends StatefulWidget {

  int indexRefer;
  DashboardTab(this.indexRefer);

  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int currentTabIndex = 0;
  List<Widget> tabs = [HomeTab(), SubscriptionTab(), PlanTab(),Payment(), MyProfile()];
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  /*if(widget.indexRefer == 0){

  }else{
  currentTabIndex = widget.indexRefer;
  }*/




  onTapped(int index) {
    setState(() {
      if(widget.indexRefer == 0){
        print(widget.indexRefer);
        currentTabIndex = index;
      }else{
        widget.indexRefer = index;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    print('tabindex::');
    print(widget.indexRefer);
    print(currentTabIndex);

    firebasePushNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: SideDrawer(),

        appBar: AppBar(
          backgroundColor: Color(0xFFFAFAFA),
          iconTheme: new IconThemeData(color: Colors.green),
          elevation: 0,
          title: Text(
            "Happy Food",
            style: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          brightness: Brightness.light,
          /*actions: <Widget>[

            IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Color(0xFF3a3737),
               //   color: Colors.green,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ViewNoticeboard()));
                }
                )
          ],*/
        ),
     //   body: tabs[currentTabIndex],
        body: tabs[widget.indexRefer == 0 ? currentTabIndex : widget.indexRefer],
        bottomNavigationBar: BottomNavigationBar(
      //    currentIndex: currentTabIndex,
          currentIndex: widget.indexRefer == 0 ? currentTabIndex : widget.indexRefer,

          onTap: onTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
            BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu), title: Text("Subscription")),
            BottomNavigationBarItem(
                icon: Icon(Icons.format_indent_decrease), title: Text("Plan")),
            BottomNavigationBarItem(
                icon: Icon(Icons.payment), title: Text("Payment")),

            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), title: Text("Account")),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => exit(0),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void firebasePushNotification() {
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) async {
        //when app is fully closed
        print("msg::: onLaunch called ${(msg)}");
        print("onLaunch called");

        if (msg != null) {
          final notification = msg['data'];
          setState(() {
            showDialog(
              context: context,
              builder: (_) => FunkyOverlay(
                title: notification['title'],
                msg: notification['body'],
              ),
            );
          });
        }
      },
      onResume: (Map<String, dynamic> msg) async {
        print(
            "msg222::: onResume called ${(msg)}"); //when we click on notification

        final notification = msg['data'];
        setState(() {
          showDialog(
            context: context,
            builder: (_) => FunkyOverlay(
              title: notification['title'],
              msg: notification['body'],
            ),
          );
        });
      },
      onMessage: (Map<String, dynamic> msg) async {
        print("msg222::: onMessage called ${(msg)}");
        final notification = msg['notification'];
        setState(() {
          showDialog(
            context: context,
            builder: (_) => FunkyOverlay(
              title: notification['title'],
              msg: notification['body'],
            ),
          );

        });
      },
    );
  }
}