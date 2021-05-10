/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/Reservation/Reservation.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class RefundDetails extends StatefulWidget {

  String _reasonName;

  RefundDetails(this._reasonName);

  @override
  _RefundDetailsState createState() => _RefundDetailsState();
}

class _RefundDetailsState extends State<RefundDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = new AppTheme();
  String stationImage = '', chargerType = '', timeSlot = '', totalAmount = '', refundAmount = '', stationName = '';

  String one = '', three = '',  four = '', two = '';

  int _radioValue = 1;

  bool _loading = false;
  APICall apiCall = APICall();
  String totalAmountApi = '';

  ///mqtt
  MQTTAppState currentAppState;

  @override
  void initState() {
    estimateCost();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    /// state management - current state maintain [provider]
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Colors.green,
        size: 50,
      ),
      dismissible: false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.background,
        /// UI
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// appbar
                Row(
                  children: [
                    InkWell(
                      onTap: () {
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
                      padding: EdgeInsets.only(left: w / 5),
                      child: Text('Refund Details'
                          + ' [Rid: ' + FlutterApp.reservationID + ']',
                          style: utils.textStyleRegular1(context, FontWeight.normal)),
                    ),
                  ],
                ),

                SizedBox(height: 10,),

                Padding(
                  padding: const EdgeInsets.only(left:20.0, right: 20),
                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Refundable Amount', style: utils.textStyleRegular(context, 48, AppTheme.text1, FontWeight.w400, 0.0, '')),
                      Text('₹' + refundAmount, style: utils.textStyleRegular(context, 48, AppTheme.greenShade1, FontWeight.w700, 0.0, '')),
                    ],
                  ),
                ),

                SizedBox(
            //      width: 250.0,
                  height: h/30,
                  child: Padding(
                    padding: EdgeInsets.only(left:w/20.0),
               //     child: Text('WHY THIS  AMOUNT?', style: utils.textStyleRegular(context, 52, AppTheme.greenShade1, FontWeight.w400, 0.0, '')),
                    child: AnimatedTextKit(
                      isRepeatingAnimation: true,
                      repeatForever: true,
                      animatedTexts: [
                        FadeAnimatedText('WHY THIS  AMOUNT?',
                            textStyle: utils.textStyleRegular(context, 52, AppTheme.greenShade1, FontWeight.bold, 0.0, '')),],

                      onTap: () {
                        bottomS();
                        print("Tap Event");
                      },
                    ),
                  ),
                ),

                /// Station details
                Padding(
                  padding: EdgeInsets.only(left: w/30, right: w/30, top: h/40),
                  child: Container(
                    height: h/3.5,
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
                              padding: EdgeInsets.only(left: w/20),
                              child: Text('Station Details', style: utils.textStyleRegular1(context, FontWeight.normal)),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top:h/80),
                              child: Divider(
                                height: 2.0,
                                color: AppTheme.divider,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top:h/70, left: 20, right: 20),
                              child: Row(
                                //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  // Image.network(stationImage.isEmpty ?
                                  // FlutterApp.strImage : stationImage, fit: BoxFit.fill, height: h/15,width: h/15),


                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(stationImage.isEmpty ? FlutterApp.strImage : stationImage, height: h/13,
                                      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            backgroundColor: Colors.green,
                                            value: loadingProgress.expectedTotalBytes != null ?
                                            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  Flexible(child: Padding(
                                    padding: EdgeInsets.only(left:w/20.0),
                                    child: Text(stationName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text('Charger Type', style: utils.textStyleRegular4(context, FontWeight.normal)),
                                      ),
                                      Text(chargerType, style: utils.textStyleRegular4(context, FontWeight.normal)),
                                    ],
                                  ),
                                  Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text('Time Slot', style: utils.textStyleRegular4(context, FontWeight.normal)),
                                      ),
                                      Text(timeSlot, style: utils.textStyleRegular4(context, FontWeight.normal)),
                                    ],
                                  ),
                                  Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text('Total Paid', style: utils.textStyleRegular4(context, FontWeight.normal)),

                                      ),
                                      Text('₹' + totalAmount, style: utils.textStyleRegular4(context, FontWeight.normal)),
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

                SizedBox(height: h/40),

                Container(
                  color: AppTheme.greenShade3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(w/30),
                        child: Column(
                          children: [
                            Row(
                       //            mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 3,
                                  child:  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text('Amount Paid', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                  ),

                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 0,
                                  child: Text('₹' + totalAmount,style: utils.textStyleRegular2(context, FontWeight.w400)),
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
                                    child: Text('Refundable Amount', style: utils.textStyleRegular1(context, FontWeight.w400)),

                                  ),

                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 0,
                                  child:  Text('₹' + refundAmount, style: utils.textStyleRegular1(context, FontWeight.w400)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      /// line
                      Padding(
                        padding: EdgeInsets.only(left:0),
                        child: Divider(
                          height: 2.0,
                          color: Colors.grey[400],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(w/30),
                        child: Column(
                          children: [
                            Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 4,
                                  child:  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text('Fare Breakup',style: utils.textStyleRegular1(context, FontWeight.normal)),
                                  ),

                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 2,
                                  child: Text('Paid',style: utils.textStyleRegular1(context, FontWeight.normal)),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 0,
                                  child: Text('Refund',style: utils.textStyleRegular1(context, FontWeight.normal)),
                                ),
                              ],
                            ),

                            Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 4,
                                  child:  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text('Base fare ',style: utils.textStyleRegular(context,52, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                  ),

                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 2,
                                  child: Text('-',style: utils.textStyleRegular(context,52, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 0,
                                  child: Text('-',style: utils.textStyleRegular(context,52, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                ),
                              ],
                            ),
                            Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 4,
                                  child:  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text('Discount',style: utils.textStyleRegular(context,52, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                  ),

                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 2,
                                  child: Text('-',style: utils.textStyleRegular(context,52, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 0,
                                  child: Text('-',style: utils.textStyleRegular(context,52, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                ),
                              ],
                            ),



                          ],
                        ),
                      ),
                      FDottedLine(
                        color: AppTheme.divider,
                        width: w,
                        strokeWidth: 1.5,
                        dottedLength: 7.0,
                        space: 4.0,
                      ),
                      SizedBox(height: h/90,),

                      Padding(
                        padding: EdgeInsets.only(left: w/30, right: w/30),
                        child: Row(
                          children: [

                            Flexible(
                              fit: FlexFit.tight,
                              flex: 4,
                              child:  Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text('Total', style: utils.textStyleRegular1(context, FontWeight.w400)),
                              ),

                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 2,
                              child: Text('₹'+ totalAmount, style: utils.textStyleRegular1(context, FontWeight.w400)),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 0,
                              child: Text('₹'+ refundAmount, style: utils.textStyleRegular1(context, FontWeight.w400)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(w/30),
                  child: Text('Refund amount will be credited to original mode of payment',
                      style: utils.textStyleRegular(context,60, AppTheme.text2,FontWeight.w400, 0.0,'')),
                ),

                Image.asset('images/line.png'),
                Container(
                  //  color: Color(0xFFF2F2F2),
                  height: h/14,
                  margin: EdgeInsets.symmetric(horizontal: h/15, vertical: h/40), // horizontal = width, vertical = kiti varun khali

                  child: NeumorphicButton(
                    onPressed: (){

                      if(refundAmount == '0.00'){
                        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Dear user, Refund amount will not reflect to original payment');
                      }else{
                        cancelReservationApi();
                      }
                    },

                    style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                        color: AppTheme.background,
                        depth: 5,
                        surfaceIntensity: 0.20,
                        intensity: 0.95,
                        shadowDarkColor: AppTheme.bottomShadow,  //outer bottom shadow
                        shadowLightColor: Colors.white  // outer top shadow
                    ),

                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text('CONFIRM CANCELLATION', style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w700, 0.0,'')),

                        Padding(
                          padding: const EdgeInsets.only(left:10.0),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF808080),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// API - estimate cost
  void estimateCost() async{

    setState(() {
      _loading = true;
    });

    if(FlutterApp.reservationID.isNotEmpty){
 //   if(FlutterApp.splashScreenReservationId.isNotEmpty){
      apiCall.estimateCostReservation().then((response) {

        setState(() {
          _loading = false;
        });

        if(response['status'] == true){

          setState(() {
            stationImage = response['station_image'];
            stationName = response['station_name'];
            timeSlot = response['time_slot'];
            totalAmount = response['paid_amt'];
            refundAmount = response['refund_amt'];
            chargerType = response['charger_type'];

            one = response['before_24'];
            two = response['within_24_but_before_1hr'];
            three = response['within_last_1hr'];
            four = response['within_time_slot'];

          });
        }else{
          print('-- Estimate cost false --');
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, '[http] estimate cost - false');
        }
      });
    }else{
      setState(() {
        _loading = false;
      });
      FToast.show(Messages.appError);
    }
  }

  /// API - cancel reservation
  void cancelReservationApi()async {
    setState(() {
      _loading = true;
    });

    if(FlutterApp.reservationID.isNotEmpty){

      apiCall.cancelReservation(refundAmount, widget._reasonName).then((response) {

        if(response['status'] == true){
          currentAppState.setWalletAmount(response['wallet_amount']);
          splashScreenApi();

        }else{
          setState(() {
            _loading = false;
          });
          print('-- cancelReservationApi false --');
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, '[http] cancel reservation - false');
        }
      });
    }else{
      setState(() {
        _loading = false;
      });
      FToast.show(Messages.appError);
    }
  }

  /// common snackbar dialog - box
  showDialogSnackBar(context, title, msg, Color color,){
    return showDialog(
        context: context,

        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
          });
          return TrialDialog(
            title: title,
            msg: msg,
            color: color,
          );
        });
  }

  /// when user click on [why this amount?] bottom sheet - UI
  Widget getBottomSheet() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: h/45, left: w/15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text('Reservation', style: utils.textStyleRegular1(context, FontWeight.normal)),
              Text('Your current cancellation charges according to cancellation policy is highlighted below.',
                    style: utils.textStyleRegular4(context, FontWeight.normal)),

              SizedBox(height: h/40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Time of cancellation', style:utils.textStyleRegular(context,60, AppTheme.text1,FontWeight.w400, 0.0,'')),
                  Text('Cancellation charges', style:utils.textStyleRegular(context,60, AppTheme.text1,FontWeight.w400, 0.0,'')),
                ],
              ),

              SizedBox(height: h/40),


              Table(
                  columnWidths: {0: FractionColumnWidth(.5), 1: FractionColumnWidth(.4)},
                  border: TableBorder.all(color: AppTheme.text4, ), // Allows to add a border decoration around your table

                  children: [
                    TableRow(children :[
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text('Before 24 hrs', style: utils.textStyleRegular3(context, FontWeight.w400),),
                      ),
                      Row(
                        children: [
                          Text(' ₹' + one, style: utils.textStyleRegular3(context, FontWeight.w400),),
                          Text(' (0%)', style: utils.textStyleRegular4(context, FontWeight.w400),),
                        ],
                      ),

                    ]),
                    TableRow(children :[
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text('Before 16 hrs', style: utils.textStyleRegular3(context, FontWeight.w400),),
                      ),
                      Row(
                        children: [
                          Text(' ₹' + two, style: utils.textStyleRegular3(context, FontWeight.w400),),
                          Text(' (10%)', style: utils.textStyleRegular4(context, FontWeight.w400),),
                        ],
                      ),

                    ]),
                    TableRow(children :[
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text('Before 1 hr from reservation time', style: utils.textStyleRegular3(context, FontWeight.w400),),
                      ),
                      Row(
                        children: [
                          Text(' ₹' + three, style: utils.textStyleRegular3(context, FontWeight.w400),),
                          Text(' (25%)', style: utils.textStyleRegular4(context, FontWeight.w400),),
                        ],
                      ),

                    ]),

                    TableRow(children :[
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text('Within the reservation time and later', style: utils.textStyleRegular3(context, FontWeight.w400),),
                      ),
                      Row(
                        children: [
                          Text(' ₹' + four, style: utils.textStyleRegular3(context, FontWeight.w400),),
                          Text(' (30%)', style: utils.textStyleRegular4(context, FontWeight.w400),),
                        ],
                      ),

                    ]),
                  ]
              ),



            ],
          ),
        ),
      ],
    );
  }

  /// when user click on [why this amount?] bottom sheet - UI
  bottomS() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius:
              const BorderRadius.all(Radius.circular(10)),
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.grey.withOpacity(0.6), offset: const Offset(4, 4), blurRadius: 8.0),
              ],
            ),

            child: getBottomSheet(),
            height: h / 2.5,
            //    color: Colors.red,
          ),
        );
      },
    );
  }

  /// splash screen API - to retrieve all data of user
  void splashScreenApi() async{
    apiCall = APICall(state: currentAppState);

    apiCall.getDetailsSplashScreen().then((response) {

      if(response['status'] == true){

        setState(() {
          _loading = false;
        });

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Reservation()));
        showDialogSnackBar(context, 'Reservation canceled successfully', '', AppTheme.greenShade1);

      }
    });
  }
}
