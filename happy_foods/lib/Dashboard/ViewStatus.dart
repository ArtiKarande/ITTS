/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/animation/DelayedAimation.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/models/UserDevice.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:happyfoods/utils/message.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../CheckInternetConnection.dart';

class ViewStatus extends StatefulWidget {

  @override
  _ViewStatusState createState() => _ViewStatusState();
}

class _ViewStatusState extends State<ViewStatus> {

  bool isLoading = false;
  FToast utils = new FToast();
  AuthMethods _authMethods = AuthMethods();
  List<UserDevice> _userDeviceList = new List<UserDevice>();

  String status,icon,deliveryStatus = "";
  bool _loading = false,shareVisible = false;
  ScrollController _sc = new ScrollController();

  @override
  void initState() {

    fetchPrefrence(bool isNetworkPresent) {
      if(isNetworkPresent){
        getSearchDataByDate();

      }else{
        FToast.show(Message.noInternet);
      }
    }
    NetworkCheck networkCheck = new NetworkCheck();
    networkCheck.checkInternet(fetchPrefrence);
    super.initState();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: Colors.deepOrange, //change your color here
          ),
          backgroundColor: Color(0xFFFAFAFA),
          title: Text('Plan Status', style: TextStyle(
            color: Colors.deepOrange,
          )),),

        body: ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 0.5,
          progressIndicator: SpinKitFadingCircle(
            color: AppTheme.BUTTON_BG_COLOR,
            size: 50,
          ),
          dismissible: false,
          child: api_seectedListViewShow(context, h, 44, h/50, 30, 50, 80),
        ),
      ),
    );
  }

  ///API call
  void getSearchDataByDate() {

    setState(() {
      _loading =true;
    });

    _userDeviceList.clear();
    _authMethods.attendanceList('10000156').then((response) {

      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if(response['success'] == "1"){
        //       FToast.show("msg");
        for (var user in response['data']['data']) {
          _userDeviceList.add(UserDevice(user['deviceId'],user['temperature'], user['date'],user['time'],user['devicename']
          ));//user['cards']
        }
      }
      else if(response['success'] == "0"){
        //  FToast.show("No data to load");

        Navigator.pop(context);


      }else{
        FToast.show("API error");

      }
    });
  }

  api_seectedListViewShow(BuildContext context, double height, titleFontSize, subTitleFontSize, int titleFont, int subTitleFont, double seeMoreFontSize,) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      child: _userDeviceList.length > 0 ? ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _userDeviceList.length,

          itemBuilder: (context, index) {

            var tempValue =
            double.parse(_userDeviceList[index].temperature);

            if (tempValue >= 33.00 && tempValue < 37.00) {
              icon = "images/green.png";
              deliveryStatus = 'Delivered';
            } else if (tempValue > 37.00 && tempValue <= 38.00) {
              icon = "images/orange.png";
              deliveryStatus = 'Pending';
            } else if (tempValue > 38.00) {
              icon = "images/red.png";
              deliveryStatus = 'Canceled';
            }

            return Card(

                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                     // color: Colors.grey[200],
                      color: deliveryStatus == 'Delivered' ? AppTheme.green : AppTheme.red,
                    ),
                    child: Stack(
                      children: <Widget>[

                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 15,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Status",
                                    style: utils.textStyle(
                                        context,
                                        40,
                                        Colors.black,
                                        FontWeight.normal,
                                        0.0),
                                  ),

                                  Image.asset(
                                    icon,
                                    height: h / 17,
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[

                                      Icon(Icons.date_range, color: Colors.black54,size: h/40),
                                      Text(
                                        _userDeviceList[index].date + "   ",
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.black,
                                            FontWeight.normal,
                                            0.0),
                                      ),

                                      Icon(Icons.access_time,color: Colors.black54,size: h/40,),
                                      Text(
                                        _userDeviceList[index].time,
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.black,
                                            FontWeight.normal,
                                            0.0),
                                      ),

                                    ],
                                  ),


                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[

                                      Text(
                                        deliveryStatus,
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.black,
                                            FontWeight.normal,
                                            0.0),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ));
          }) : Container(

        child: Center(child: Image.asset("images/nodatafound.png")),

      ),
    );
  }

}

