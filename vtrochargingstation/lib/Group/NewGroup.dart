/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/Group/YourGroup.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class NewGroup extends StatefulWidget {
  List<String> checksMobile = new List<String>();
  List<String> checksName = new List<String>();

//  List<String> checksUserImage = new List<String>();

  NewGroup(this.checksMobile, this.checksName);

  @override
  _NewGroupState createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = new AppTheme();

  TextEditingController _groupNameController = new TextEditingController();

  String strImg = 'https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg';
  bool _loading = false;
  APICall apiCall = APICall();

  @override
  void initState() {
    // TODO: implement initState
    print(widget.checksMobile);
    print(widget.checksName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: false, /// keyboard issue handled

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
                      child: Text('New Group',
                          style: utils.textStyleRegular(context, 54, AppTheme.text1,
                              FontWeight.normal, 0.0, '')),
                    ),
                  ],
                ),

                /// 1st card
                Padding(
                  padding:
                      EdgeInsets.only(top: h / 50, left: w / 30, right: w / 30),
                  child: GestureDetector(
                    onTap: () async {},
                    child: Container(
                      height: h / 7.5,
                      width: w,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(25)),
                          color: AppTheme.background,
                          shadowDarkColor: AppTheme.bottomShadow,
                          // upper bottom shadow
                          shadowLightColor: Colors.white, // upper top shadow
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    //     Image.asset('images/profile.png', height: h/6.7,),

                                    Padding(
                                      padding: EdgeInsets.only(left: w / 30),
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          borderRadius: new BorderRadius.all(
                                              new Radius.circular(50.0)),
                                          /*border: new Border.all(
                                            color: Colors.white70,
                                            width: 2.0,
                                          ),*/
                                        ),
                                        child: ClipOval(
                                            child: Image.asset(
                                          'images/profile/editImage.png',
                                          height: h / 12,
                                        )),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.tag_faces_sharp),
                                            hintText: 'Enter Group Name',
                                            hintStyle: utils.textStyleRegular1(
                                                context, FontWeight.w400),
                                          ),
                                          controller: _groupNameController,
                                          onChanged: itemTitleChange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: h / 30),

                Container(
                  color: AppTheme.textBackground,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: w / 20, top: h / 140, bottom: h / 140),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.checksName.length.toString() + ' Members',
                            style:
                                utils.textStyleRegular1(context, FontWeight.w400)),
                      ],
                    ),
                  ),
                ),

                /// grid options
                Flexible(
                  child: Container(
                      color: AppTheme.background,
                      //  height: h/1.5,
                      padding: EdgeInsets.all(5.0),
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior(),

                        //  behavior: new ScrollBehavior()..buildViewportChrome(context, null, AxisDirection.down, ),
                        child: GridView.builder(
                          itemCount: widget.checksName.length,
                          padding: EdgeInsets.all(10),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: MediaQuery.of(context).size.width /
                                (MediaQuery.of(context).size.height / 3.1),
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.0, // middle space
                            mainAxisSpacing: 10.0,  // from top space
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () async {},
                              child: Container(
                                color: AppTheme.background,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      child: Text(widget.checksName[index][0], style: TextStyle(color: AppTheme.greenShade1),),
                                      backgroundColor: AppTheme.greenShade2,
                                      radius: 22,
                                    ),
                                    Text(widget.checksName[index],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: utils.textStyleRegular(context,60, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                ),

              ],
            ),

            ///CREATE GROUPS pay button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: h / 14,
                    margin: EdgeInsets.symmetric(horizontal: h / 22, vertical: w/10),
                    child: NeumorphicButton(
                      onPressed: () {
                        if (_groupNameController.text.isNotEmpty){
                          createGroupApi();
                        }
                        else {
                          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter group name');
                        }
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
                          Text('ADD',
                              style: utils.textStyleRegular(context, 50, AppTheme.text2, FontWeight.w700, 0.0, '')),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF808080),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// value changes to edit text callback method
  void itemTitleChange(String title) {
    setState(() async {
      print('text val...');
      print(_groupNameController.text);
    });
  }

  /// API
  createGroupApi() {
    setState(() {
      _loading = true;
    });
      apiCall.createGroup(_groupNameController.text, '' , widget.checksMobile).then((response) {
        setState(() {
          _loading = false;
        });

        if(response['status'] == true){
          FlutterApp.isGroupUser = true;
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => YourGroup()));
        }
        else if(response['status'] == 'timeout'){
          Navigator.pop(context);

          return showDialog(
            context: context,
            builder: (_) => TrialDialog(
              title: 'Timeout',
              msg: Messages.NO_INTERNET,
              color: AppTheme.red,
            ),
          );
        }
        else{
          print('-- createGroup false --');
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, '[http] - false');
        }
      });
  }
}
