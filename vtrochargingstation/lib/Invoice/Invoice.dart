/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:collection';
import 'dart:io';
import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/CommunicationManager.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedKeys.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedPreferneces.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class Invoice extends StatefulWidget {

  String _page;
  Invoice(this._page);

  @override
  _InvoiceState createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  APICall apiCall = new APICall();
  SharedPreference pref = new SharedPreference();
  FToast utils=new FToast();

  MQTTAppState currentAppState;

  String plugPoint = '' , reqPercentage = '', units = '', startTime = '',endTime = '', totalCharges = '', remainingBalance = '', startDate = '';
  String stationImage = '',stationName = '', gst = '', totalBill = '', batteryChargeStatus = '';
  bool status = false;
  double convertedPercentage = 0.0;
  bool _enabled = true;

  SharedPreferences _prefs;
  Map<dynamic, dynamic> map;

  @override
  void initState() {

    if(FlutterApp.requestId != null){
      getInvoiceApi();
    }else{
      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.appError);
    }

    splashScreenApi();
    clearDataFew();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    /// state management - current state maintain [provider]
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    AppTheme utils = new AppTheme();

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
       key: _scaffoldKey,
       backgroundColor: AppTheme.background,

        body: SafeArea(
          child: startDate.isNotEmpty ?  Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 0,vertical: h/12,), // horizontal = width, vertical = kiti varun khali,

                    child: NeumorphicButton(
                      onPressed: (){
                        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.upcoming);
                      },
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.circle(),
                        color: AppTheme.background,
                        depth: 5,
                        surfaceIntensity: 0.20,
                        intensity: 0.99, //drop shadow
                        shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                        shadowLightColor: Colors.white,  // upper top shadow
                      ),
                      child: Image.asset(
                        'images/download.png',
                       height: 20,
                       width: 20,

                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5,vertical: h/10), // horizontal = width, vertical = kiti varun khali,
                    child: NeumorphicButton(
                      onPressed: (){
                        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.upcoming);
                      },
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.circle(),
                        color: AppTheme.background,
                        depth: 5,
                        surfaceIntensity: 0.20,
                        intensity: 0.99, //drop shadow
                        shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                        shadowLightColor: Colors.white,  // upper top shadow
                      ),

                      child: Image.asset(
                        'images/share.png',
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        /// if [page ] contains map then goto map page, else pop screen
                        onTap: () async {

                          if(widget._page == 'map'){
                            ///clear all data when u finish with charging

                            clearData();

                            Navigator.of(context).popUntil((route) => route.isFirst);

                            showDialog(
                                context: context,
                                builder: (context) {
                                  Future.delayed(Duration(seconds: 1), () {
                                    Navigator.of(context).pop(true);
                                  });
                                  return TrialDialog(
                                    title: 'Thank You!',
                                    msg: '',
                                    color: AppTheme.greenShade1,
                                  );
                                });

                          }else{
                            Navigator.pop(context);
                          }
                        },
                        child: CircularSoftButton(
                          radius: 20,
                          icon: Padding(
                            padding: EdgeInsets.only(left:h/90),
                            child: Icon(Icons.arrow_back_ios, size: 20,),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left:w/4),
                        child: Text('Invoice', style: utils.textStyleRegular1(context, FontWeight.w400)),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.only(left:w/15.0, top: h/50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invoice Number : '+FlutterApp.requestId.toString(),
                            style: utils.textStyleRegular1(context, FontWeight.w400)),
                        Text(startDate + ', ' +startTime, style: utils.textStyleRegular1(context, FontWeight.w400)),
                      ],
                    ),
                  ),
                  SizedBox(height: h/30),

                  SizedBox(height: h/70),

                  /// Station details
                  Padding(
                    padding:  EdgeInsets.only(left: w/30, right: w/30),
                    child: Container(
                      height: h/3.1,
                      width: w,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                          color: AppTheme.background,
                          depth: 5,
                          intensity: 0.99, //drop shadow
                          shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                          shadowLightColor: Colors.white,  // upper top shadow
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top:h/60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Padding(
                                padding: EdgeInsets.only(top:h/70, left: 20, right: 20),
                                child: Row(
                                  //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                     ClipRRect(
                                         borderRadius: BorderRadius.circular(10.0),
                                         child: Image.asset('images/mapimg.png', height: h/15)),

                                    /*ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(stationImage.isEmpty ?
                                      FlutterApp.strImage : stationImage, fit: BoxFit.fill, height: h/15,width: h/15),
                                    ),*/

                                    Flexible(child: Padding(
                                      padding: EdgeInsets.only(left:w/20.0),
                                      child: Text(stationName,
                                          maxLines: 2,
                                          style:utils.textStyleRegular1(context, FontWeight.w400)),
                                    )),
                                  ],
                                ),
                              ),

                              SizedBox(height: h/70,),

                              Padding(
                                padding: EdgeInsets.only(left: w/30, right: w/30),
                                child: Column(
                                  children: [
                                    Row(
                                      //     mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 3,
                                          child:  Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text('Plug point',
                                               style: utils.textStyleRegular2(context, FontWeight.w400)),
                                          ),

                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 0,
                                          child: Text(plugPoint, style: utils.textStyleRegular2(context, FontWeight.w400)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      //     mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 3,
                                          child:  Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text('Requested percentage',  style: utils.textStyleRegular2(context, FontWeight.w400)),
                                          ),

                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 0,
                                          child: Text(convertedPercentage.toStringAsFixed(0) + ' %',  style: utils.textStyleRegular2(context, FontWeight.w400)),

                                        ),
                                      ],
                                    ),
                                    Row(
                                      //     mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 3,
                                          child:  Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text('Battery Status', style: utils.textStyleRegular(context,48, AppTheme.greenShade1,FontWeight.normal, 0.0,'')),

                                          ),

                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 0,
                                          child: Text(batteryChargeStatus.toString(), style: utils.textStyleRegular(context,48, AppTheme.greenShade1,FontWeight.normal, 0.0,'')),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      //     mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 3,
                                          child:  Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text('Charging Started',  style: utils.textStyleRegular2(context, FontWeight.w400)),
                                          ),

                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 0,
                                          child: Text(startTime,  style: utils.textStyleRegular2(context, FontWeight.w400)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      //     mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 3,
                                          child:  Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text('Charging Finished',  style: utils.textStyleRegular2(context, FontWeight.w400)),
                                          ),

                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 0,
                                          child: Text(endTime, style: utils.textStyleRegular2(context, FontWeight.w400)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Bill details
                  Container(
                    height: h/3,
                    width: w,
                    //    margin: EdgeInsets.symmetric(horizontal: 0,), // horizontal = width, vertical = kiti varun khali
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/bgg.png"), fit: BoxFit.fill)),

                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SizedBox(height:h/90),
                        Padding(
                          padding: EdgeInsets.only(top: h/25, left: w/11),
                          child: Text('Bill Details', style: utils.textStyleRegular1(context, FontWeight.w400)),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top:h/60, left: w/25, right: w/25),
                          child: Divider(
                            height: 2.0,
                            color: AppTheme.divider,

                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: h/80, left: w/12, right: 30),
                          child: Column(
                            children: [
                              Row(
                                children: [

                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 3,
                                    child:  Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text('Units',  style: utils.textStyleRegular2(context, FontWeight.w400)),
                                    ),

                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 0,
                                    child: Text(units,  style: utils.textStyleRegular2(context, FontWeight.w400)),
                                  ),
                                ],
                              ),
                              Row(
                                children: [

                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 3,
                                    child:  Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text('Charges',  style: utils.textStyleRegular2(context, FontWeight.w400)),
                                    ),

                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 0,
                                    child: Text('₹ ' + totalCharges, style: utils.textStyleRegular2(context, FontWeight.w400)),
                                  ),
                                ],
                              ),
                              Row(
                                children: [

                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 3,
                                    child:  Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text('GST',  style: utils.textStyleRegular2(context, FontWeight.w400)),
                                    ),

                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 0,
                                    child: Text('₹' + gst, style: utils.textStyleRegular2(context, FontWeight.w400)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top:8.0, left: w/25, right: w/25),
                          child: FDottedLine(
                            color: AppTheme.divider,
                            width: w,
                            strokeWidth: 1.5,
                            dottedLength: 7.0,
                            space: 4.0,
                          ),
                        ),
                        SizedBox(height: h/90,),

                        /* Padding(
                      padding: EdgeInsets.only(left: w/11, right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Total Bill', style: utils.textStyleRegular(context,48, AppTheme.text1,FontWeight.normal, 0.0,'')),
                          Text('₹ '+totalAmount, style: utils.textStyleRegular(context,48, AppTheme.text1,FontWeight.normal, 0.0,'')),
                    //      Text('₹ '+'20'),
                        ],
                      ),
                    ),*/

                        Padding(
                          padding: EdgeInsets.only(left: w/11, right: 30),
                          child: Row(
                            children: [

                              Flexible(
                                fit: FlexFit.tight,
                                flex: 3,
                                child:  Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text('Total Bill',  style: utils.textStyleRegular2(context, FontWeight.w400)),
                                ),

                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 0,
                                child: Text('₹ '+ totalBill,  style: utils.textStyleRegular2(context, FontWeight.w400)),
                              ),
                            ],
                          ),
                        ),

                        /* Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(' Includes Rs.10.99 Taxes', style: utils.textStyleRegular(context,48, AppTheme.text2,FontWeight.normal, 0.0,'')),

                      ],
                    ),*/
                      ],
                    ),

                  ),

                  SizedBox(height: 25,),

                ],
              )
            ],
          ) : Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            enabled: _enabled,
            child: Stack(
              children: [

                Padding(
                  padding: EdgeInsets.only(left:w/20, right: w/20, top: h/20),
                  child: SizedBox(
                    height: h/9.5,
                    child: Container(color: Colors.green,),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: h/5.0),
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index){
                      return
                        ListTile(leading: Icon(Icons.image, size: h/10),
                          title: SizedBox(
                            height: h/9,
                            child: Container(color: AppTheme.red),
                          ),


                        );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// clear data when navigate to map screen
  void clearData() {
      pref.putString(SharedKey().chargingStatus, "");
      pref.putString(SharedKey().REQUESTID, '0');
      pref.putString(SharedKey().reqPercentage, '');
      FlutterApp.chargingStatus = '';
      FlutterApp.balance = '';
      FlutterApp.requestId = '0';
      FlutterApp.typeOfAll = '';
      FlutterApp.subID = '';
  }

  void clearDataFew() {
    setState(() {
      pref.putString(SharedKey().chargingStatus, "");
      pref.putString(SharedKey().REQUESTID, '0');
      pref.putString(SharedKey().reqPercentage, '');
    });
  }

  /// on press of android back button action
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(

        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              clearData();
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: (){

              clearData();  ///yes option
              exit(0);
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  /// API - invoice
  void getInvoiceApi() async{

    _prefs = await SharedPreferences.getInstance();

    await SharedPreferences.getInstance();
    if(currentAppState.getReceivedText.contains('partial')){
      print('Invoice:: partial');

      apiCall.getInvoiceAPI(FlutterApp.requestId).then((response) {
        setState(() {
          _enabled = false;
        });

        if(response['status'] == true){
          print('wallet_amount--- ' + response['current_status'][0]['wallet_amount'].toString());


          setState(() {
            plugPoint = response['current_status'][0]['plug_point'];
            reqPercentage = response['current_status'][0]['requested_percentage'];
            startTime = response['current_status'][0]['start_time'];
            endTime = response['current_status'][0]['end_time'];
            startDate = response['current_status'][0]['start_date'];

            units = response['current_status'][0]['unit_consume'];
            totalCharges = response['current_status'][0]['charges'];
            totalBill = response['current_status'][0]['unit_consume_cost'];
            gst = response['current_status'][0]['gst'];
            remainingBalance = response['current_status'][0]['remaining_balance'];
            stationImage = response['current_status'][0]['station_image'];
            stationName = response['current_status'][0]['station_name'];
            batteryChargeStatus = response['current_status'][0]['battery_charge_status'];
            currentAppState.setWalletAmount(response['current_status'][0]['wallet_amount'].toString());

            _prefs.setString("time", '0.0');
            _prefs.setString("cost", '0.0');
            _prefs.setString("percentage", '0.0');
            _prefs.setString("plug", '');
            currentAppState.setReceivedText('proceed');
            currentAppState.setPlugAnim(false);
            convertedPercentage = double.parse(reqPercentage);
          });
        }else{
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.apiStatus);
        }
      });
    }

    if(widget._page == 'history' || widget._page == 'gold' || widget._page == 'own_plan'){

      print('Invoice:: history/gold/own_plan');
      apiCall.getInvoiceAPI(FlutterApp.requestId).then((response) {

        setState(() {
          _enabled = false;
        });

        if(response['status'] == true){

          setState(() {
            plugPoint = response['current_status'][0]['plug_point'];
            reqPercentage = response['current_status'][0]['requested_percentage'];
            units = response['current_status'][0]['unit_consume'];
            startTime = response['current_status'][0]['start_time'];
            endTime = response['current_status'][0]['end_time'];
            totalCharges = response['current_status'][0]['charges'];
            gst = response['current_status'][0]['gst'];
            totalBill = response['current_status'][0]['unit_consume_cost'];
            startDate = response['current_status'][0]['start_date'];
            remainingBalance = response['current_status'][0]['remaining_balance'];
            stationImage = response['current_status'][0]['station_image'];
            stationName = response['current_status'][0]['station_name'];
            batteryChargeStatus = response['current_status'][0]['battery_charge_status'];

            _prefs.setString("time", '0.0');
            _prefs.setString("cost", '0.0');
            _prefs.setString("percentage", '0.0');
            _prefs.setString("plug", '');
            currentAppState.setReceivedText('proceed');
            currentAppState.setPlugAnim(false);

            if(widget._page == 'history'){
              convertedPercentage = double.parse(reqPercentage);
            }

          });
        }
        else if(response['status'] == 'timeout'){
          Navigator.pop(context);

          showDialog(
              context: context,

              builder: (context) {
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(context).pop(true);
                });
                return TrialDialog(
                  title: 'You’re offline, Please check your internet connection ',
                  msg: '',
                  color: AppTheme.red,
                );
              });
        }

        else{
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.apiStatus);
        }
      });
    }else{
      await new Future.delayed(const Duration(seconds: 3));
    }

    if(currentAppState.getReceivedText.contains('stopped')){
      print('Invoice:: stopped');

      apiCall.getInvoiceAPI(FlutterApp.requestId).then((response) {
        setState(() {
          _enabled = false;
        });

        if(response['status'] == true){


          print('wallet_amount-- ' + response['current_status'][0]['wallet_amount'].toString());

          setState(() {
            plugPoint = response['current_status'][0]['plug_point'];
            reqPercentage = response['current_status'][0]['requested_percentage'];
            startTime = response['current_status'][0]['start_time'];
            endTime = response['current_status'][0]['end_time'];
            startDate = response['current_status'][0]['start_date'];

            units = response['current_status'][0]['unit_consume'];
            totalCharges = response['current_status'][0]['charges'];
            totalBill = response['current_status'][0]['unit_consume_cost'];
            gst = response['current_status'][0]['gst'];
            remainingBalance = response['current_status'][0]['remaining_balance'];
            stationImage = response['current_status'][0]['station_image'];
            stationName = response['current_status'][0]['station_name'];
            batteryChargeStatus = response['current_status'][0]['battery_charge_status'];

            _prefs.setString("time", '0.0');
            _prefs.setString("cost", '0.0');
            _prefs.setString("percentage", '0.0');
            _prefs.setString("plug", '');
            currentAppState.setReceivedText('proceed');
            currentAppState.setWalletAmount(response['current_status'][0]['wallet_amount'].toString());
            currentAppState.setPlugAnim(false);
            convertedPercentage = double.parse(reqPercentage);
          });

        }else{
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.apiStatus);
        }
      });
    }

    else{
      print('Invoice else::--');

    }
  }

  /// splash screen API - to retrieve all data of user
  void splashScreenApi() async{
    await new Future.delayed(const Duration(seconds: 2));
    apiCall = APICall(state: currentAppState);//new

    apiCall.getDetailsSplashScreen().then((response) {

      if(response['status'] == true){

        currentAppState.setWalletAmount(response['wallet_amount']);
        currentAppState.setGoldCardAmount(response['vtro_gold_card_balance']);

        print('-- splash screen api Invoice --');

      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    clearData();
    super.dispose();
  }
}
