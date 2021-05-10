/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/models/tile.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/shareQRScreen.dart';

/// [ShareQRPrefScreen] is a preference screen which is used to share qr code of the elements available in the system.
class ShareQRPrefScreen extends StatefulWidget {
  static final tag = 'ShareQRPreferenceScreen';

  /// Creating state class to manage states of [ShareQRPrefScreen].
  @override
  State<StatefulWidget> createState() => _ShareQRPrefScreenState();
}

/// [_ShareQRPrefScreenState] is a state class of [ShareQRPrefScreen].
/// It creates and maintains UI, also its different states for [ShareQRPrefScreen].
class _ShareQRPrefScreenState extends State<ShareQRPrefScreen> {

  /// List of element types, user can select type of element he wants to share.
  List<Tile> preferenceList = [
    Tile(Icons.home, 'Home'),
    Tile(Icons.room_service, 'Room'),
    Tile(Icons.live_tv, 'Device'),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      //   appBar: new AppBar(title: new Text("Settings"),),
      body:new Column(
        children: <Widget>[
          new Container(
            child:itemsListView(context) ,
          )
        ],
      ) ,
    );
  }

  /// Builds screen with cards for each type in [preferenceList].
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(centerTitle: true, title: Text('Share')),
//      body: GridView.count(
//        crossAxisCount: 1,
//        padding: const EdgeInsets.all(10.0),
//        mainAxisSpacing: 20.0,
//        childAspectRatio: 2.0,
//        children: [makeCard(0), makeCard(1), makeCard(2)],
//      ),
//    );
//  }

  /// Returns a card view for specified type, using icon and name data from [preferenceList].
  /// On tap of these cards, user is navigated to the [ShareQRPrefScreen] with selected type.
  Material makeCard(int type) {
    return Material(
      shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.0))),
      elevation: 10.0,
      shadowColor: Colors.black,
      child: InkWell(
        onTap: () {
          ShareQRScreen.type = type;
          Navigator.of(context).pushNamed(ShareQRScreen.tag);
        },
        splashColor: Colors.blueGrey,
        child: LayoutBuilder(builder: (ct, cr) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Icon(preferenceList[type].icon, size: cr.biggest.height - 40),
              Center(child: Text(preferenceList[type].name)),
            ],
          );
        }),
      ),
    );
  }


  Widget itemsListView(BuildContext context) {
    return new Container(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[

          ///temperarory we are not going to provide this feature
//          ListTile(
//            title: Text('Room'),
//            leading: Icon(Icons.room_service),
//            onTap: (){
//              ShareQRScreen.type = 1;
//              Navigator.of(context).pushNamed(ShareQRScreen.tag);
//            },
//          ),


          new Divider(color: Colors.grey,height: 1.0,),
          ListTile(
            title: Text('Device'),
            leading: Icon(Icons.live_tv),
            onTap: (){
              ShareQRScreen.type = 2;
              Navigator.of(context).pushNamed(ShareQRScreen.tag);
            },
          ),
          new Divider(color: Colors.grey,height: 1.0,),

        ],
      ),
      margin: const EdgeInsets.all(5.0),
    );
  }
}
