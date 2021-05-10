/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/GoogleMapData/scanQR.dart';
import 'package:vtrochargingstation/Group/ContactList.dart';
import 'package:vtrochargingstation/Group/GroupDataDetails.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/GroupListModel.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class YourGroup extends StatefulWidget {
  @override
  _YourGroupState createState() => _YourGroupState();
}

class _YourGroupState extends State<YourGroup> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = new AppTheme();
  MQTTAppState currentAppState;

  APICall apiCall = APICall();
  List<GroupListModel> _groupList = new List<GroupListModel>();

  bool _enabled = true;

  @override
  void initState() {
    // TODO: implement initState

   if(FlutterApp.isGroupUser == true){
     userGroupList();

   }else{
     print('Not having any group');
   }
   super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    /// state management - current state maintain [provider]
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      /// UI
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// Appbar
                Row(
                  children: [
                    InkWell(
                      onTap: () async {

                        Navigator.pop(context);
                      },
                      child: CircularSoftButton(
                        radius: 20,
                        icon: Padding(
                          padding: EdgeInsets.only(left: h / 90),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: w / 4),
                      child: Text('Group',
                          style: utils.textStyleRegular(context, 54, AppTheme.text1, FontWeight.normal, 0.0, '')),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Groups', style: utils.textStyleRegular(context, 42, AppTheme.text1, FontWeight.w500, 0.0, '')),

                    ],
                  ),
                ),
                Image.asset('images/line.png'),

                Visibility(
                  visible: FlutterApp.isGroupUser == true ? false : true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Image.asset('images/group/groupEmpty.png', height: h/4,),
                      ),
                      Text('No Groups', style: utils.textStyleRegular(context, 42, AppTheme.text1, FontWeight.w700, 0.0, '')),
                      Text('When you create groups they will ', style: utils.textStyleRegular2(context, FontWeight.w400)),
                      Text('appear here', style: utils.textStyleRegular2(context, FontWeight.w400)),

                    ],
                  ),
                ),

                Visibility(
                  visible: FlutterApp.isGroupUser == true ? true : false,
                  child: Flexible(
                    child: Container(
                      width: w,
                      child: _groupList.length > 0 ?
                      ScrollConfiguration(
                        behavior: ScrollBehavior(),
                        child: ListView.builder(
                            itemCount: _groupList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: (){
                                  createCroup(index);
                                },
                                child: Slidable(

                                  actionPane: SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.25,//0.25

                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 2,
                                            child: Image.asset('images/group/group_no_img.png', height: h/16),
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 6,
                                            child: Container(
                                     //       color: AppTheme.greenShade1,
                                              width: w/3,
                                              height: h/11,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(_groupList[index].groupName, style: utils.textStyleRegular1(context, FontWeight.w400)),
                                                  Text('id: '+_groupList[index].groupId, style: utils.textStyleRegular4(context, FontWeight.w400)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 1,
                                            child: Container(
                                   //         color: AppTheme.red,
                                              height: h/11,
                                              child: Padding(
                                                padding: EdgeInsets.only(top: h/50.0),
                                                child: Text('time', style: utils.textStyleRegular4(context, FontWeight.w400)),
                                              ),
                                            ),
                                          ),

                                          Flexible(
                                         //   fit: FlexFit.tight,
                                            flex: 0,
                                            child: Container(
                                              color: AppTheme.greenShade1,
                                              height: h/11,
                                              width: w/50,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        padding: EdgeInsets.only(left: w/4.5),
                                        child: Divider(
                                          height: 2.0,
                                          color: AppTheme.divider
                                        ),
                                      ),
                                    ],
                                  ),

                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      caption: 'scan',
                                 //     foregroundColor: Colors.white, //icon color
                                      color: AppTheme.greenShade2,
                                      icon: Icons.qr_code_scanner_outlined,
                                        onTap: () {
                                          currentAppState.setPlugAnim(false);
                                          FlutterApp.groupId = _groupList[index].groupId;
                                          if(_groupList[index].groupBalance == ''){
                                            ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Insufficient balance');
                                          }
                                         else if(currentAppState.getReceivedText == 'stop'){
                                            ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Already in charging state, You can not scan now!');
                                          }
                                          else{
                                   //         FlutterApp.splashScreenReservationId = '';
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ScanQR('', 'group', '', '')));
                                          }
                                        }
                                    ),
                                  ],

                                ),
                              );
                            }),
                      ) : Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      enabled: _enabled,
                      child: Stack(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(left:w/20, right: w/20),
                            child: SizedBox(
                              height: h/9.5,
                            ),
                          ),

                          ListView.builder(
                            itemCount: 9,
                            itemBuilder: (context, index){
                              return
                                ListTile(leading: Icon(Icons.image, size: h/10),
                                  title: SizedBox(
                                    height: h/10,
                                    child: Container(color: AppTheme.red),
                                  ),
                                );
                            },
                          ),
                        ],
                      ),
                    )
                    ),
                  ),
                ),
              ],
            ),

            ///CREATE GROUPS pay button
            Hero(
              tag: 'group',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: h / 14,
                      margin: EdgeInsets.symmetric(horizontal: h / 22, vertical: w/10),
                      child: NeumorphicButton(
                        onPressed: () {
                          permissions();
                        },
                        style: NeumorphicStyle(
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(30)),
                            color: AppTheme.background,
                            depth: 5,
                            surfaceIntensity: 0.20,
                            intensity: 0.95,
                            shadowDarkColor: AppTheme.bottomShadow,
                            //outer bottom shadow
                            shadowLightColor:
                            Colors.white // outer top shadow
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('CREATE',
                                style: utils.textStyleRegular(context, 50, AppTheme.text2, FontWeight.w700, 0.0, '')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// before loading contact, contact permission sets here
  void permissions() async{
    if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    }
// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
    Permission.contacts,
 //   Permission.storage,
    ].request();
    print('............');
    print(statuses[Permission.contacts]);

    if(statuses[Permission.contacts].isGranted){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ContactList()));
    }else{

    }

  }

  /// API
  void userGroupList() {
    apiCall.groupList().then((response) {

      if(response['status'] == true){

        /// check empty array condition
        var groupList = response['group_list'];

        if(groupList.length == 0){
          setState(() {
            _enabled = false;
          });

          FToast.show('No group found');
          Navigator.pop(context);
        }

        setState(() {
          for (var group in response['group_list']) {
            _groupList.add(GroupListModel(group['group_id'], group['group_name'], group['profile_pic'],
              group['createdOn'],group['created_by'],group['group_balance']));
          }
        });
      }
      else{
      }
    });
  }

  /// on click of create group button method
  void createCroup(int index) {
    setState(() {
      FlutterApp.groupId = _groupList[index].groupId;
      FlutterApp.groupName = _groupList[index].groupName;

      FlutterApp.groupImage = _groupList[index].groupImage;

      if(_groupList[index].groupBalance.toString().isNotEmpty){
        FlutterApp.groupBalance = double.parse(_groupList[index].groupBalance);
      }else{
        FlutterApp.groupBalance = 0;
      }
    });

    print(FlutterApp.groupId);
    print(FlutterApp.groupName);
    print(FlutterApp.groupBalance.toString());
    print(FlutterApp.groupImage);
    Navigator.push(context, MaterialPageRoute(builder: (context) => GroupDataDetails()));
  }
}
