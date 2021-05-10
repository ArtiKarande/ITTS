/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/Messages.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';
import 'package:ioskitouchnew/screens/settings/settings.dart';

class SettingView extends SettingState{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new WillPopScope(child: new Scaffold(
//         appBar: new AppBar(title: new Text("Settings"),
//           automaticallyImplyLeading: false,
//           actions: <Widget>[Container()],),
      body:new Column(
        children: <Widget>[
          new Container(
            child:itemsListView(context) ,
          )
        ],
      ) ,
    ), onWillPop: (){
      //onBackPressed();
      //showSyncPopup();
      print("hi");
      Navigator.of(context)
          .pushNamedAndRemoveUntil(MasterDetail.tag, (Route<dynamic> route) => false);
    });

  }

  Widget itemsListView(BuildContext context) {
    return new Container(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ListTile(
            title: Text('App Version'),
            onTap: (){
              navigateToAppDetails();
            },
          ),
          new Divider(color: Colors.grey,height: 1.0,),
          ListTile(
            title: Text('Add Home'),
            onTap: (){
              navigateToAddHome();
            },
          ),
          new Divider(color: Colors.grey,height: 1.0,),
          ListTile(
            title: Text('BackUp'),
            onTap: (){
              if(MasterDetail.isCommunicationOverInternet.value){
                onSynchClick();
              }
              else{
                FToast.show('Please enable cloud symbol [on top right corner]');
              }
            },
          ),
          new Divider(color: Colors.grey,height: 1.0,),
          ListTile(
            title: Text('Restore'),
            onTap: (){
              //todo request MQTT to restore data

              if(MasterDetail.isCommunicationOverInternet.value){
                networkCheck.check().then((intenet) {
                  if (intenet != null && intenet) {
                    getRestoreData();
                  }else{
                    FToast.showRed(Messages.NO_INTERNET);
                  }
                });

              }
              else{
                FToast.showGreen('Please enable cloud symbol [on top right corner]');
              }
            },
          ),
          new Divider(color: Colors.grey,height: 1.0,),
          ListTile(
            title: Text('Themes'),
            onTap: (){
              navigateToThemes();
            },
          ),
          new Divider(color: Colors.grey,height: 1.0,),
        ],
      ),
      margin: const EdgeInsets.all(5.0),
    );
  }


}

//Tile(Icons.add_to_photos, 'Add Homes'),