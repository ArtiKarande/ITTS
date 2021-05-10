/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/Group/ContactList.dart';
import 'package:vtrochargingstation/Group/GroupAddBalance.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/Group/GroupInfoModel.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class GroupInformation extends StatefulWidget {
  @override
  _GroupInformationState createState() => _GroupInformationState();
}

class _GroupInformationState extends State<GroupInformation> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = new AppTheme();
  String strImg = 'https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg';

  APICall apiCall = APICall();
  List<GroupInfoModel> _groupList = new List<GroupInfoModel>();
  bool _enabled = true;
  String createdBy = '', createdOn = '';

  @override
  void initState() {
    // TODO: implement initState
    userGroupList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      /// UI
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                      child: Text('Group info',
                          style: utils.textStyleRegular(context, 54, AppTheme.text1, FontWeight.normal, 0.0, '')),
                    ),
                  ],
                ),

                /// 1st card
                Padding(
                  padding: EdgeInsets.only(top:h/50, left: w/30, right: w/30),
                  child: GestureDetector(
                    onTap: () async{

                    },

                    child: Container(
                      height: h/9,
                      width: w,
                      child:Column(
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
                                      Text(FlutterApp.groupName.toString(), style: utils.textStyleRegular1(context, FontWeight.w400)),
                                      Text('Created by ' + createdBy + ',' + createdOn,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: utils.textStyleRegular(context, 65, AppTheme.text2, FontWeight.normal, 0.0, '')),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 1,
                                child: Container(
                                  //color: AppTheme.red,
                            //      height: h/11,

                                  child: Padding(
                                    padding: EdgeInsets.only(top: h/50.0),
                                    child: Image.asset('images/edit.png', height: h/30),
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

                Container(
                  color: AppTheme.greenShade2,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [

                        Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: Container(
                         //   color: AppTheme.greenShade1,
                            width: w/3,
                            height: h/15,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Text('Mute Notification', style: utils.textStyleRegular1(context, FontWeight.w400)),
                                Text('On', style: utils.textStyleRegular4(context, FontWeight.w400)),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 0,
                          child: Container(
                       //     color: AppTheme.red,
                        //    height: h/15,

                            child: Padding(
                              padding: EdgeInsets.only(top: h/40.0),
                              child: NeumorphicSwitch(height: h/25, isEnabled: true,value: false,
                                style: NeumorphicSwitchStyle(
                                    activeThumbColor: AppTheme.greenShade1,
                                  activeTrackColor: AppTheme.background,

                                ),)
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  height: h/13,
                  margin: EdgeInsets.symmetric(horizontal: h/50, vertical: h/30),

                  child: NeumorphicButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GroupAddBalance()));
                    },

                    style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                        color: AppTheme.background,
                        depth: 5,
                        surfaceIntensity: 0.20,
                        intensity: 0.95,
                        shadowDarkColor: AppTheme.bottomShadow,  //outer bottom shadow
                        shadowLightColor: Colors.white  // outer top shadow
                    ),

                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                //        Image.asset('images/scanner.png',),

                      SvgPicture.asset(
                      'images/group/wallet_svg.svg',
                      width: w/10,
                    //  color: Colors.green,
                      semanticsLabel: 'Acme Logo'),

                        SizedBox(width: w/40,),
                        Text('Add Group Balance', style:utils.textStyleRegular1(context, FontWeight.normal)),

                      ],
                    ),
                  ),
                ),

                Container(
                  height: h/13,
                  margin: EdgeInsets.symmetric(horizontal: h/50),

                  child: NeumorphicButton(
                    onPressed: (){
                      permissions();
                    },
                    style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                        color: AppTheme.background,
                        depth: 5,
                        surfaceIntensity: 0.20,
                        intensity: 0.95,
                        shadowDarkColor: AppTheme.bottomShadow,  //outer bottom shadow
                        shadowLightColor: Colors.white  // outer top shadow
                    ),

                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Image.asset('images/group/addMember.png',),
                        SizedBox(width: w/40,),
                        Text('Add Member', style:utils.textStyleRegular1(context, FontWeight.normal)),

                      ],
                    ),
                  ),
                ),

                SizedBox(height: h/30,),


                /// group member
                Container(
                    height: h/3.5,
                    child: _groupList.length > 0 ?
                    ListView.builder(
                        itemCount: _groupList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Row(
                                children: [

                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 3,
                                    child: //Image.asset('images/group/group_no_img.png', height: h/16),

                                    CircleAvatar(
                                      //widget.checksName[index][0],
                                    //  child: Text(_groupList[index].memberName, style: TextStyle(color: AppTheme.greenShade1),),
                                      child: Text(_groupList[index].nameInitial, style: TextStyle(color: AppTheme.greenShade1),),
                                      backgroundColor: AppTheme.greenShade2,
                                      radius: 22,
                                    ),

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

                                          Text(_groupList[index].memberName, style: utils.textStyleRegular1(context, FontWeight.w400)),
                                          Text(_groupList[index].memberContactNo, style: utils.textStyleRegular4(context, FontWeight.w400)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 2,
                                    child: Container(
                                      //         color: AppTheme.red,

                                      height: h/11,

                                      child: Padding(
                                        padding: EdgeInsets.only(top: h/50.0),
                                        child: Text(_groupList[index].type, style: utils.textStyleRegular4(context, FontWeight.w400)),
                                      ),
                                    ),

                                  ),
                                ],
                              ),
                            ],
                          );
                        }) : Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      enabled: _enabled,
                      child: Stack(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(left:w/20, right: w/20),
                            child: SizedBox(
                              height: h/9.5,
                      //        child: Container(color: Colors.green,),
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


                /// exit group
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: h / 50),
                      child: Container(
                        height: h/13,
                        margin: EdgeInsets.symmetric(horizontal: h/50),

                        child: NeumorphicButton(
                          onPressed: (){
                          },

                          style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                              color: AppTheme.background,
                              depth: 5,
                              surfaceIntensity: 0.20,
                              intensity: 0.95,
                              shadowDarkColor: AppTheme.bottomShadow,  //outer bottom shadow
                              shadowLightColor: Colors.white  // outer top shadow
                          ),

                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              Image.asset('images/group/exitGroup.png',),
                              SizedBox(width: w/40,),
                              Text('Exit Group', style:utils.textStyleRegular1(context, FontWeight.normal)),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// UI
  void userGroupList() {
    apiCall.groupInformation().then((response) {

      if(response['status'] == true){
        setState(() {

          createdBy = response['group_info'][0]['created_by'];
          createdOn = response['group_info'][0]['created_on'];

          for (var group in response['group_info']) {

            print(group['member'][0]['member_name']);
            print(response['group_info'][0]['member'][0]['member_name']);

                    for(var groupIn in response['group_info'][0]['member']){
                      _groupList.add(GroupInfoModel(groupIn['member_name'], groupIn['member_name'], groupIn['type'],
                          groupIn['member_name'],groupIn['member_contact_no'], groupIn['first_name']));

                    }



          }
        });
      }
      else{

      }
    });
  }

  /// before loading contacts, contact permission set here
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

}
