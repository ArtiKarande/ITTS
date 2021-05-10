/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/Admin/statusUpdate.dart';
import 'package:happyfoods/Dashboard/ViewStatus.dart';
import 'package:happyfoods/SideDrawerNavgation.dart';
import 'package:happyfoods/animation/DelayedAimation.dart';
import 'package:happyfoods/dialogBox/successDialog.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/models/UserDevice.dart';
import 'package:happyfoods/models/adminSubscriptionPkg.dart';
import 'package:happyfoods/notification/ViewNoticeboard.dart';
import 'package:happyfoods/productionHouse/statusUpdatePH.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProductionDashboard extends StatefulWidget {

  @override
  _ProductionDashboardState createState() => _ProductionDashboardState();
}

class _ProductionDashboardState extends State<ProductionDashboard> {

  bool isLoading = false;
  FToast utils = new FToast();

  AuthMethods _authMethods = AuthMethods();
  List<AdminSubscriptionPkg> _subscriptionList = new List<AdminSubscriptionPkg>();

  String status,tag='';
  bool _loading = false,shareVisible = false;
  ScrollController _sc = new ScrollController();

  int flag = 0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {

    checkInternet();
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: AppTheme.BUTTON_BG_COLOR,
          size: 50,
        ),
        dismissible: false,
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

          body:
          api_seectedListViewShow(context, h, 44, h/50, 30, 50, 80),
          resizeToAvoidBottomPadding: false,
        ),
      ),
    );
  }

  ///API call - get all approved subscription data
  void getSubscriptionApi() {

    setState(() {
      _loading =true;
    });

     tag = 'approve_data';

    _authMethods.getSubscription(tag).then((response) {

      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if(response['success'] == "1"){

        _subscriptionList.clear();

        for (var subscription in response['list']) {
          _subscriptionList.add(AdminSubscriptionPkg(subscription['Id'],subscription['planType'],subscription['packageType']
            ,subscription['fromDate'],subscription['toDate'],subscription['roleId']
            ,subscription['noofmeals'],subscription['totalcost'],subscription['address'],subscription['creationDate'],
            subscription['status'],subscription['snackType'],subscription['snackTotal'],subscription['customeName'],subscription['age'],subscription['height_cms'],
            subscription['weight'],subscription['medicalCondition'],subscription['deliveryAddress'],subscription['dob'],

          ));//user['cards']
        }
      }
      else if(response['success'] == "0"){

        _subscriptionList.clear();
        //  FToast.show("No data to load");

        showDialog(
          context: context,
          builder: (_) => FunkyOverlay(
            msg: "Order not found! Admin needs to approve customer subscription plan!",
          ),
        );


      }else{
        FToast.show("API error");

      }
    });
  }

  api_seectedListViewShow(
      BuildContext context, double height, titleFontSize, subTitleFontSize, int titleFont, int subTitleFont, double seeMoreFontSize,) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    if(_subscriptionList.length == 0){
      return Center(child: Image.asset('images/nodatafound.png'));
    }else{
      return RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: Container(

          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _subscriptionList.length,
              itemBuilder: (context, index) {

                String status =  _subscriptionList[index].status;

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
                            color: Colors.green[50],
                          ),
                          child: Stack(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[

                                        Padding(
                                          padding: EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            _subscriptionList[index].planType + " [ " +_subscriptionList[index].pkgType + " ] ",
                                            style: utils.textStyle(
                                                context,
                                                titleFontSize,
                                                Colors.black,
                                                FontWeight.bold,
                                                0.0),
                                          ),
                                        ),

                                        ClipOval(
                                          child: Container(
                                            color: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: Text(
                                              _subscriptionList[index].noofmeals,
                                              style: TextStyle(color: Colors.black, fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            _subscriptionList[index].customeName,
                                            style: utils.textStyle(
                                                context,
                                                45,
                                                Colors.black,
                                                FontWeight.bold,
                                                1.0),
                                          ),
                                        ),

                                      ],
                                    ),


                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text('Delivery Address - '+
                                          _subscriptionList[index].deliveryAddress,
                                        style: utils.textStyle(
                                            context,
                                            titleFontSize,
                                            Colors.black,
                                            FontWeight.normal,
                                            0.0),
                                      ),
                                    ),


                                    SizedBox(height: 10,),

                                    //     Text('Time Frame',style: utils.textStyle(context, subTitleFont, Colors.black, FontWeight.normal, 0.0),),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "from: ",
                                              style: utils.textStyle(
                                                  context,
                                                  subTitleFont,
                                                  Colors.black,
                                                  FontWeight.normal,
                                                  0.0),
                                            ),

                                            Text(
                                              _subscriptionList[index].fromDate,
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
                                              "To: ",
                                              style: utils.textStyle(
                                                  context,
                                                  subTitleFont,
                                                  Colors.black,
                                                  FontWeight.normal,
                                                  0.0),
                                            ),
                                            Text(
                                              _subscriptionList[index].toDate,
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
                                      showDialog(
                                        context: context,
                                        builder: (_) => StatusUpdatePH(subId:_subscriptionList[index].id,
                                          msg1: "Please select appropriate option",
                                          msg2: "Meal Delivery Status",
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[

                                        Text(
                                          _subscriptionList[index].totalCost,
                                          style: utils.textStyle(context, 40, Colors.green, FontWeight.normal, 0.0),
                                        ),

                                        Container(
                                          height: 30,
                                          child: OutlineButton(

                                            child: new Text(status.toString(),style: utils.textStyle(context, 58, Colors.black, FontWeight.normal, 0.0),),
                                            onPressed: null,
                                            shape: StadiumBorder(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )*/

                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      )),
                );
              }),
        ),
      );
    }


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
    ) ?? false;
  }

  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";

        getSubscriptionApi();
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

  /// pull refresh request
  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      getSubscriptionApi();
    });

    return null;
  }

}

