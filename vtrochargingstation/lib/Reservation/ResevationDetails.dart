/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vtrochargingstation/GoogleMapData/scanQR.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/GoogleMapData/ChargerTypeNeu.dart';
import 'package:vtrochargingstation/Reservation/RefundDetails.dart';
import 'package:vtrochargingstation/Reservation/cancelReservation.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedKeys.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedPreferneces.dart';
import 'package:vtrochargingstation/dialog/FunkeyOverlay.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class ReservationDetails extends StatefulWidget {

  String reservationId, stationName, chargerType, timeSlot, amount, stationId, stationImage, navigationType, reservationStartTime;

  ReservationDetails(this.reservationId, this.stationName, this.chargerType,
      this.timeSlot, this.amount, this.stationId, this.stationImage,  this.navigationType, this.reservationStartTime);

  @override
  _ReservationDetailsState createState() => _ReservationDetailsState();
}

class _ReservationDetailsState extends State<ReservationDetails> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = new AppTheme();
  APICall apiCall = APICall();
  bool _enabled = true;

  SharedPreference pref = new SharedPreference();
  String _scanBarcode = 'Unknown', stationID = '';
  bool _loading = false;

  MQTTAppState currentAppState;

  @override
  void initState() {

    if(widget.navigationType == 'map'){
      getReservationDetails();
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

    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: AppTheme.greenShade1,
        size: h/15,
      ),
      dismissible: false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        key: _scaffoldKey,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Appbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text('Reservation Details',
                      style: utils.textStyleRegular1(context, FontWeight.normal)),

                  NeumorphicButton(
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
                ],
              ),

             /// Station details
              Padding(
                padding: EdgeInsets.only(left: w/30, right: w/30, top: h/40),
                child: Container(
                  height: h/2.9,
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
                            padding: EdgeInsets.only(left: w/20, top: h/110),
                            child: Text('Station Details: ' + widget.stationId
                                + ' [ Rid: ' +widget.reservationId + ' ]'
                                , style:utils.textStyleRegular1(context, FontWeight.normal)),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top:10),
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

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(widget.stationImage.isEmpty ? FlutterApp.strImage : widget.stationImage, height: h/13,
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
                                  child: Text(widget.stationName,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style:utils.textStyleRegular3(context, FontWeight.w400)),
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
                                        child: Text('Charger Type', style:utils.textStyleRegular4(context, FontWeight.normal)),
                                      ),

                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      flex: 0,
                                      child: Text(widget.chargerType,style:utils.textStyleRegular4(context, FontWeight.normal)),
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
                                        child: Text('Time Slot', style:utils.textStyleRegular4(context, FontWeight.normal)),

                                      ),

                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      flex: 0,
                                      child: Text(widget.timeSlot, style:utils.textStyleRegular4(context, FontWeight.normal)),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                          SizedBox(height: h/80,),

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
                                  flex: 3,
                                  child:  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text('Total Bill', style: utils.textStyleRegular1(context, FontWeight.w400)),
                                  ),

                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 0,
                                  child: Text('₹'+ widget.amount, style: utils.textStyleRegular1(context, FontWeight.w400)),
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

              SizedBox(height: w/60,),

              Container(
                height: h/13,
                margin: EdgeInsets.symmetric(horizontal: h/50, vertical: h/30),

                child: NeumorphicButton(
                  onPressed: (){
                    calculateTime();

              //      clearData(); //temp commented
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

                      Image.asset('images/scanner.png',),
                      SizedBox(width: w/40,),
                      Text('Scan QR', style:utils.textStyleRegular1(context, FontWeight.normal)),

                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: w/14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          FlutterApp.reservationID = widget.reservationId;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CancelReservation()));
                      },
                      child: Row(
                        children: [
                          Text('Cancel Reservation', style: utils.textStyleRegular(context,55, AppTheme.greenShade1, FontWeight.normal, 0.0,'')),
                          SizedBox(width: w/40),
                          Icon(Icons.arrow_forward_ios, size: h/60,color: AppTheme.greenShade1)
                        ],
                      ),
                    ),
           //         SizedBox(height: w/50),
         //           Text('you can cancel reservation upto 1hr before time slot', style: utils.textStyleRegular(context,60, AppTheme.text4,FontWeight.normal, 0.0,'')),

                  //
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// API - reservation details
  void getReservationDetails() {
    setState(() {
      _loading = true;
    });

    apiCall.getReservationDetails().then((response) {
      setState(() {
        _loading = false;
      });

      if(response['status'] == true){
        setState(() {
          print('--- reservation_details API - True');
      //    widget.is_redirect_scan = response['reservation_list'][0]['is_redirect_scan'];
          widget.chargerType = response['reservation_list'][0]['charger_type'];
          widget.amount = response['reservation_list'][0]['amount'];
     //     widget.isCancelRedirect = response['reservation_list'][0]['is_redirect_scan'];
          widget.stationId = response['reservation_list'][0]['station_id'];

        });
      }
      else if(response['status'] == 'timeout'){
        Navigator.pop(context);
        showDialog1('Timeout', 'Poor Internet connection please try again!');
      }
      else{
        setState(() {
          _enabled = false;
        });
      }
    });
  }

  showDialog1(title, msg){
    return showDialog(
      context: context,
      builder: (_) => FunkyOverlay(
        title: title,
        msg: msg,
      ),
    );
  }

  /// reservation time check with current time and apply condition accordingly
  void calculateTime() {
    final now = new DateTime.now();
    print(widget.reservationStartTime);

    var parsedDate = DateTime.parse(widget.reservationStartTime);

    /// failed condition
    if(parsedDate.compareTo(now) > 0){
      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'You can not scan now');
    }else{
      /// my logic part
      clearData(); //temp commented
    }
  }

  /// clear data before scan and navigate to scan QR
  void clearData() {
    if(currentAppState.getReceivedText == 'stop'){
      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Already in charging state, You can not scan now!');
    }
   else{
      currentAppState.setPlugAnim(false);
      currentAppState.setRequestPercentage(0.0);
      currentAppState.setSliderMoveControl(false);
      currentAppState.setEstimatedCost(0.0);
      currentAppState.setEstimatedTime(0);
      FlutterApp.groupId = '';
      FlutterApp.plugPoint = '0';
      FlutterApp.activeStatus = '';

      currentAppState.setReceivedText('proceed');
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          ScanQR(widget.stationId, 'reservation', widget.reservationId, widget.chargerType)));
    }
  }
}
