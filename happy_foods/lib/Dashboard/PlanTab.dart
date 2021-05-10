/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/Dashboard/ViewStatus.dart';
import 'package:happyfoods/animation/DelayedAimation.dart';
import 'package:happyfoods/dialogBox/successDialog.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/models/UserDevice.dart';
import 'package:happyfoods/models/adminSubscriptionPkg.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class PlanTab extends StatefulWidget {

  @override
  _PlanTabState createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {

  bool isLoading = false;
  FToast utils = new FToast();

  AuthMethods _authMethods = AuthMethods();
  List<AdminSubscriptionPkg> _planList = new List<AdminSubscriptionPkg>();

  String status,greenZone,orangeZone,redZone,totalZoneCount;
  bool _loading = false,shareVisible = false;
  ScrollController _sc = new ScrollController();

  int flag = 0;

  @override
  void initState() {
    super.initState();
       checkInternet();
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
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: AppTheme.BUTTON_BG_COLOR,
          size: 50,
        ),
        dismissible: false,
        child: Scaffold(

          body:
          api_seectedListViewShow(context, h, 44, h/50, 30, 50, 80),
          resizeToAvoidBottomPadding: false,
        ),
      ),
    );
  }

  ///API call
  void getSearchDataByDate() {

    setState(() {
      _loading =true;
    });

    _planList.clear();
    _authMethods.customerPlan().then((response) {

      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if(response['success'] == "1"){

        for (var subscription in response['list']) {
          _planList.add(AdminSubscriptionPkg(subscription['Id'],subscription['planType'],subscription['packageType']
            ,subscription['fromDate'],subscription['toDate'],subscription['roleId']
            ,subscription['noofmeals'],subscription['totalcost'],subscription['address'],subscription['creationDate'],
            subscription['status'],subscription['snackType'],subscription['snackTotal'],subscription['customeName'],subscription['age'],subscription['height_cms'],
            subscription['weight'],subscription['medicalCondition'],subscription['deliveryAddress'],subscription['dob'],

          ));//user['cards']
        }
      }
      else if(response['success'] == "0"){

        print(_planList.length);
        showDialog(
          context: context,
          builder: (_) => FunkyOverlay(
            msg: "No data found! To activate plan, please select subscription plan",
          ),
        );

      }else{
        FToast.show("API error");

      }
    });
  }

  api_seectedListViewShow(
      BuildContext context,
      double height,
      titleFontSize,
      subTitleFontSize,
      int titleFont,
      int subTitleFont,
      double seeMoreFontSize,
      ) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    if(_planList.length == 0){
      return Center(child: Image.asset('images/nodatafound.png'));
    }else{
      return Container(
        child: ListView.builder(

            scrollDirection: Axis.vertical,
            itemCount: _planList.length,
            itemBuilder:(context, index) {

              String status =  _planList[index].status;

              if(status == 'P'){
                status = 'Pending';
              }else if(status == 'A'){
                status = 'Approved';
              }else{
                status = 'Rejected';
              }
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[200],
                        ),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      _planList[index].planType,
                                      style: utils.textStyle(
                                          context,
                                          titleFontSize,
                                          Colors.black,
                                          FontWeight.bold,
                                          1.0),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text("Number of meals [ " +
                                      _planList[index].noofmeals + " per Day ]",
                                      style: utils.textStyle(
                                          context,
                                          titleFontSize,
                                          Colors.black,
                                          FontWeight.bold,
                                          0.0),
                                    ),
                                  ),


                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "You have subscribed ",
                                        style: utils.textStyle(context, subTitleFont, Colors.black, FontWeight.normal, 0.0),
                                      ),

                                      Text(
                                        _planList[index].pkgType ,
                                        style: utils.textStyle(context, subTitleFont, Colors.black, FontWeight.bold, 0.0),
                                      ),

                                      Text(
                                        ' subscription', style: utils.textStyle(context, subTitleFont, Colors.black, FontWeight.normal, 0.0),
                                      ),

                                    ],
                                  ),

                                  SizedBox(height: 10,),

                               //   Text('Time Frame',style: utils.textStyle(context, subTitleFont, Colors.black, FontWeight.normal, 0.0),),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            "Start Date: ", style: utils.textStyle(context, subTitleFont, Colors.black, FontWeight.normal, 0.0),
                                          ),

                                          Text(
                                            _planList[index].fromDate,
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
                                            "End Date: ",
                                            style: utils.textStyle(
                                                context,
                                                subTitleFont,
                                                Colors.black,
                                                FontWeight.normal,
                                                0.0),
                                          ),
                                          Text(
                                            _planList[index].toDate,
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

                                  SizedBox(height: 20,),

                                  /*  InkWell(

                                  onTap: (){
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => ViewStatus()));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        height: 30,
                                        child: OutlineButton(

                                            child: new Text("View Status",style: utils.textStyle(
                                                context,
                                                60,
                                                Colors.black,
                                                FontWeight.normal,
                                                0.0),),
                                            onPressed: null,
                                          shape: StadiumBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                )*/

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text('₹ ',  style: utils.textStyle(context, 40, Colors.green, FontWeight.normal, 0.0)),

                                          Text(
                                            _planList[index].totalCost,
                                            style: utils.textStyle(context, 40, Colors.green, FontWeight.normal, 0.0),
                                          ),

                                        ],
                                      ),


                                      Text(status,style: utils.textStyle(
                                          context,
                                          titleFontSize,
                                          Colors.black,
                                          FontWeight.bold,
                                          1.0),),
                                    ],
                                  )


                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    )),
              );

            }),
      );
    }


  }

  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";

        getSearchDataByDate();
      }


    } on SocketException catch (_) {
      print('not connected');

      FToast.show("You are not connected to internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }

}

