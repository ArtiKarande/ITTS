/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slider_button/slider_button.dart';
import 'package:vtrochargingstation/CommunicationManager.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/GoogleMapData/MapView.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/Invoice/Invoice.dart';
import 'package:vtrochargingstation/charging/paymentOptions.dart';
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
import 'package:flutter/scheduler.dart';

class StartCharging extends StatefulWidget{

  double refernceSliderVal;
  String reservationId;
  StartCharging(this.refernceSliderVal, this.reservationId);

  @override
  _StartChargingState createState() => _StartChargingState();
}

class _StartChargingState extends State<StartCharging> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<FlutterSliderHatchMarkLabel> effects = [];
  List<Map<dynamic, dynamic>> mEffects = [];
  double ellv = 0;
  double euuv = 20;
  int segmentedControlValue = 1;

  AnimationController _animationController;
  Animation _animation;
  AppTheme utils = new AppTheme();
  APICall apiCall = new APICall();

  SharedPreferences _preferences;

  ///slider
  double sliderVal = 0.0;

  bool visibilityStopCharging = true;

  int index = 0;
  SharedPreference pref = new SharedPreference();

  double energyUnits = 0.0;
  String chargerType = '';
  double costOfGst = 0;

  ///mqtt
  MQTTAppState currentAppState;
  CommunicationManager _manager;

  void initState() {
    super.initState();

  /// remember that - euuv is imp param to modify for live charging percentage
    euuv = widget.refernceSliderVal;
    sliderVal = widget.refernceSliderVal;

    var rnga = 20;

    for (double i = 0; i < 100; i++) {
      mEffects.add({"percent": i, "size": 5 + rnga.toDouble()});
    }
    effects = updateEffects(ellv * 100 / mEffects.length, euuv * 100 / mEffects.length);

    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1),);
    _animation = IntTween(begin: 100, end: 0).animate(_animationController);
    _animation.addListener(() => setState(() {}));

    ///
    print('check values::');
    print(FlutterApp.remainingEnergy.toString());
    print(FlutterApp.subID.toString());
    print(FlutterApp.userBikeKw.toString());
  }

  @override
  Widget build(BuildContext context) {

    /// state management - current state maintain [provider]
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    /// when mqtt receives charging stop partially then callback to [Invoice]
    if(appState.getReceivedText.contains('partial')){
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Invoice('map')));
      });
    }

    /// when mqtt receives charging not started within time then callback to [MapView]
    else if(appState.getReceivedText.contains('notStarted')){

      SchedulerBinding.instance.addPostFrameCallback((_) async {
        Navigator.of(context).popUntil((route) => route.isFirst);

      });
    }

    /// calculate screen width and height
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        key: _scaffoldKey,
        /// UI part
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Neumorphic(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(0)),
                  color: AppTheme.white,
                  depth: 5,
                  intensity: 0.99,
                  //drop shadow
                  shadowDarkColor: AppTheme.bottomShadow,
                  shadowLightColor: Colors.white, // upper top shadow
                ),
                child: Container(

                  color: Color(0xFFF5F5F8),
                  height: h / 3.0, //200
                  child: Column(
                    children: [

                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              /// when state has value [start]
                              if(currentAppState.getReceivedText.contains('start')){
                                _onWillPop();
                              }
                              /// when state has value [stop]
                              else if(currentAppState.getReceivedText.contains('stop')){
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }else{
                                Navigator.of(context).popUntil((route) => route.isFirst);
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
                            padding: EdgeInsets.only(left: w / 5),
                            child: Text('Charging Plan',
                                style: utils.textStyleRegular1(context, FontWeight.normal)),
                          ),
                        ],
                      ),

                      Image.asset('images/evehicle.png', height: h / 7,),

                      /// healthy / normal
                      Padding(
                        padding: EdgeInsets.only(top: h / 20), // h / 5.5
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: h / 10),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'images/healthy_battery.png', height: h / 30,),
                                  Text(' Healthy',style:utils.textStyleRegular3(context,FontWeight.w400)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Image.asset(FlutterApp.chargerType == 'Normal' ? 'images/normal.png' : 'images/turbo.png', height: h / 30,),
                                Text(FlutterApp.chargerType,style:utils.textStyleRegular3(context,FontWeight.w400)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: h / 3.6), //160
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Avatar(
                        image: AssetImage('images/chargerPlug.png',),
                        radius: h/15,
                        backgroundColor: Colors.transparent,
                        borderColor: AppTheme.background,
                        borderWidth: 4.0,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(currentAppState.getEstimatedTime.toStringAsFixed(0) +
                            ' [hrs]', style: utils.textStyleRegular(
                            context, 40, AppTheme.text1, FontWeight.normal,
                            0.0, '')),
                        Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Row(
                            children: [
                              Text(
                                  currentAppState.getRequestedPercentage.toStringAsFixed(0),
                                  style: utils.textStyleRegular(
                                      context, 18, AppTheme.text1, FontWeight.normal,
                                      0.0, '')),
                              Padding(
                                padding: const EdgeInsets.only(top:8.0),
                                child: Text(
                                    '%', style: utils.textStyleRegular(context, 25, AppTheme.text1, FontWeight.normal, 0.0, '')),
                              ),
                            ],
                          ),
                        ),
                        Text(' ₹' + currentAppState.getEstimatedCost.toStringAsFixed(2),
                            style: utils.textStyleRegular(context, 40, AppTheme.text1, FontWeight.normal, 0.0, '')),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estimated Time', style: utils.textStyleRegular4(context,  FontWeight.normal,)),
                          Text(currentAppState.getReceivedText.contains('proceed') ? 'Current battery' : 'Charging',

                              style: utils.textStyleRegular4(context,  FontWeight.normal,)),
                          Text('Cost (incl. GST)', style: utils.textStyleRegular4(context,  FontWeight.normal,)),
                        ],
                      ),
                    ),

                    SizedBox(height: h/40),

                    /// custom percentage slider
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: FlutterSlider(

                     //     disabled: true,           /// so that slider will not move
                          disabled: currentAppState.getSliderMoveControl,           /// so that slider will not move
                          min: 0,
                          max: effects.length.toDouble(),
                          values: [ellv, euuv],
                   //       values: [ellv, currentAppState.getRequestedPercentage],  // live data useful this temp commented
                          handler: FlutterSliderHandler(
                          disabled: true,
                            /// change this param to disable range parameter - [true]
                            opacity: 0.0,
                          ),

                          step: FlutterSliderStep(step: 5), /// ui steps of 5
                          handlerAnimation: FlutterSliderHandlerAnimation(
                            curve: Curves.elasticOut,
                            reverseCurve: Curves.bounceIn,
                            duration: Duration(milliseconds: 500),
                            scale: 1.0,    /// size of slider scroll - height
                          ),
                          rangeSlider: true,

                          rightHandler: FlutterSliderHandler(
                              decoration: BoxDecoration(),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.green,
                                    border: Border.all(color: Colors.green.withOpacity(0.65), width: 1)),

                                child: Icon(Icons.arrow_right, size: 15,
                                  color: Colors.white,),
                              )),
                          handlerWidth: 15,
                          handlerHeight: 50,
                          touchSize: 20,
                          tooltip: FlutterSliderTooltip(
                            disabled: true,
                          ),

                          hatchMark: FlutterSliderHatchMark(
                            labels: effects,
                            linesAlignment: FlutterSliderHatchMarkAlignment.right,
                            density: 0.5,
                          ),
                          trackBar: FlutterSliderTrackBar(
                              inactiveTrackBar: BoxDecoration(borderRadius: BorderRadius.circular(30),),
                              activeTrackBarHeight: 0.2,
                              inactiveTrackBarHeight: 0.5, // middle line height
                              activeTrackBar: BoxDecoration(color: Colors.transparent,)),
                          onDragging: (a, b, c) {

                            print('...............values................');
                            print(a);   //1
                            print(b);   //0
                            print(c);   // percentage
                            print(widget.refernceSliderVal);

                            /// formula - to calculate cost and time
                            /// you refer formula from vaidehi - I have provided to her
                            /// formula for normal type
                            if(FlutterApp.userChargerSelectionType == 1){

                              double cost = ((double.parse(FlutterApp.userBikeKw) * (c - widget.refernceSliderVal)) / 100) * FlutterApp.normalBikeCost;
                              double time = ((double.parse(FlutterApp.userBikeKw) * c) / 100) / FlutterApp.normalBikeTime;

                              costOfGst = (cost * FlutterApp.gstFormula) / 100;

                              setState(() {
                                energyUnits = ((double.parse(FlutterApp.userBikeKw) * (c - widget.refernceSliderVal)) / 100);
                              });

                              currentAppState.setRequestPercentage(c);
                              currentAppState.setEstimatedCost(cost + costOfGst);
                              currentAppState.setEstimatedTime(time);

                            }else{

                              /// formula for turbo/fast type
                              double cost = ((double.parse(FlutterApp.userBikeKw) * (c - widget.refernceSliderVal)) / 100) * FlutterApp.fastBikeCost;
                              double time = ((double.parse(FlutterApp.userBikeKw) * c) / 100) / FlutterApp.fastBikeTime;

                              costOfGst = (cost * FlutterApp.gstFormula) / 100;

                              setState(() {
                                energyUnits = ((double.parse(FlutterApp.userBikeKw) * (c - widget.refernceSliderVal)) / 100);
                              });

                              currentAppState.setRequestPercentage(c);
                              currentAppState.setEstimatedCost(cost + costOfGst);
                              currentAppState.setEstimatedTime(time);
                            }

                            ellv = b;
                            euuv = c;
                            effects = updateEffects(b * 100 / mEffects.length, c * 100 / mEffects.length);
                            setState(() {
                              sliderVal = c;
                            });
                          }
                      ),
                    ),

                    SizedBox(height: h/9),

                    /// final evaluation text - UI
                    Visibility(
                      visible: currentAppState.getReceivedText.contains('proceed') ? true : false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: w/40,),
                          Container(

                            child: NeumorphicButton(
                              onPressed: (){
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
                                'images/iIcon.png',
                                height: h/50,
                                width: h/50,
                              ),
                            ),
                          ),
                          SizedBox(width: w/90,),
                          Text('final evaluation of bill will depend on kw/hr',
                              style:utils.textStyleRegular(context, 60, AppTheme.text2,FontWeight.w400, 0.0,'')),
                        ],
                      ),
                    ),

                    Visibility(
                        visible: FlutterApp.subID.isNotEmpty ? true : false,
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppTheme.greenShade2,
                            ),
                            width: w/1.5,
                            height: h/30,

                            child: Center(child: Text('Existing Plan Remaining : ' + FlutterApp.remainingEnergy.toString() + 'khw',
                                style:utils.textStyleRegular(context,60, AppTheme.text2,FontWeight.w700, 0.0,''))))),

                    SizedBox(height: h/80),
                    Image.asset('images/line.png'),

                    /// button - proceed to pay
                    Visibility(
                      visible: currentAppState.getReceivedText.contains('proceed') ? true : false,
                      child: Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Container(
                              height: h/14,
                              margin: EdgeInsets.symmetric(horizontal: h/15, ), // horizontal = width, vertical = kiti varun khali

                              child: NeumorphicButton(
                                onPressed: (){

                                  if(currentAppState.getRequestedPercentage == 0.0){
                                    ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Dear user, Please select slider!');
                                  }
                                  else if(widget.refernceSliderVal == currentAppState.getRequestedPercentage){
                                    ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Battery percentage should not same as requested %');
                                  }
                                  else{

                                    /// [qr_flow] when user go through qr then call api accordingly
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                        PaymentOptions(currentAppState.getRequestedPercentage,
                                        energyUnits.toStringAsFixed(2), currentAppState.estimatedCost, costOfGst, 'charging', widget.reservationId)));
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

                                    Text('PROCEED TO PAY', style:utils.textStyleRegular2(context,FontWeight.w700)),

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
                          ),
                        ),
                      ),
                    ),

                    /// waiting text - connect vehicle to plug
                    Visibility(
                      visible: currentAppState.getReceivedText.contains('wait') ? true : false,
                      child: Expanded(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SliderButton(
                                width: w,
                                buttonSize: 0,
                                icon: Icon(Icons.check_circle_outline,
                                  color: Colors.green.shade100,),

                                radius: 0,
                                backgroundColor: Colors.green.shade100,
                                boxShadow: BoxShadow(
                                  color: Colors.black, blurRadius: 4,),
                                alignLabel: Alignment(0.0, 0),
                                buttonColor: Colors.green,
                                vibrationFlag: true,
                                highlightedColor: Colors.greenAccent,
                                baseColor: Colors.green,
                                // text color

                                action: () {},
                                label: Text("Waiting..",
                                  style: TextStyle(
                                      letterSpacing: 1.0,
                                      fontSize: h / 25,
                                      fontFamily: 'SofiaProRegular'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// start charging button
                    Visibility(
                      visible: currentAppState.getReceivedText.contains('start') ? true : false,
                      child: Expanded(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,

                              child: SliderButton(
                                  radius: 0,
                                  width: w,
                                  backgroundColor: Colors.green.shade100,
                                  boxShadow: BoxShadow(color: Colors.white, blurRadius: 4,),
                                  alignLabel: Alignment(0.2, 0),

                                  buttonColor: Colors.transparent,
                                  vibrationFlag: true,
                                  highlightedColor: Colors.white,
                                  //    baseColor: Colors.black87,
                                  label: Text(
                                    "Slide to Start Charging",
                                    style: TextStyle(
                                        color: Colors.green.shade50,
                                        fontSize: h / 50,
                                        fontFamily: 'SofiaProRegular'),
                                  ),
                                  buttonSize: 60,
                                  baseColor: Colors.black87,

                                  icon: Image.asset('images/gif/start.gif',
                                  alignment: Alignment.center, height: h/10),
                                  action: () async{
                                    if(currentAppState.getRequestedPercentage == 0.0){
                                      print('if');
                                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select slider');
                                   //   currentAppState.setReceivedText('start');
                                    }
                                    else{
                                      currentAppState.setSliderStatus(true);
                                      currentAppState.setSliderMoveControl(true);   /// slider moving disabled
                                      startChargingAPI();
                                    }
                                  },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    ///stop charging button
                    Visibility(
                      visible: currentAppState.getReceivedText.contains('stop') ? true : false,
                      child: Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,

                          child: SliderButton(
                              radius: 0,
                              width: w,

                              backgroundColor: Colors.green.shade100,
                              boxShadow: BoxShadow(color: Colors.white,
                              blurRadius: 4,),
                              alignLabel: Alignment(0.2, 0),
                              buttonColor: Colors.transparent,
                              vibrationFlag: true,
                              highlightedColor: Colors.white,
                              baseColor: Colors.black87,

                              action: () {

                                if(FlutterApp.requestId != null || FlutterApp.scanQR != null || FlutterApp.plugPoint != null){
                                  stopChargingAPI();
                                }else{
                                  ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.appError);
                                }
                              },
                              label: Text(
                                  "Slide to Stop Charging",
                                  style: utils.textStyleRegular(context, 50, AppTheme.text4, FontWeight.normal, 0.0, '')
                              ),
                              icon: Image.asset('images/gif/start.gif',
                                alignment: Alignment.center, height: h/10,)
                          ),
                        ),
                      ),
                    ),

                    /// charging text
                    Visibility(
                      visible: currentAppState.getSliderStatus,
                      child: Expanded(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SliderButton(
                                width: w,
                                buttonSize: 0,
                                icon: Icon(Icons.check_circle_outline,
                                  color: Colors.green.shade100,),

                                radius: 0,
                                backgroundColor: Colors.green.shade100,
                                boxShadow: BoxShadow(
                                  color: Colors.black, blurRadius: 4,),
                                alignLabel: Alignment(0.0, 0),
                                buttonColor: Colors.green,
                                vibrationFlag: true,
                                highlightedColor: Colors.greenAccent,
                                baseColor: Colors.green,
                                // text color

                                action: () {},
                                label: Text("Charging",
                                  style: TextStyle(
                                      letterSpacing: 1.0,
                                      fontSize: h / 25,
                                      fontFamily: 'SofiaProRegular'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// slider moving function
  List<FlutterSliderHatchMarkLabel> updateEffects(double leftPercent,
      double rightPercent) {

    List<FlutterSliderHatchMarkLabel> newLabels = [];
    for (Map<dynamic, dynamic> label in mEffects) {

      /// green field area logic
      if (label['percent'] >= leftPercent && label['percent'] <= rightPercent &&
          label['percent'] % 5 == 0) {
        newLabels.add(FlutterSliderHatchMarkLabel(
            percent: label['percent'],
            label: Container(
              decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(30))
              ),
              height: label['size'],
              width: 5.5,
            )));
      }
      else if (label['percent'] % 5 != 0) {
        newLabels.add(FlutterSliderHatchMarkLabel(
            percent: label['percent'],
            label: Container(
              height: label['size'],
              width: 2.5,
              color: AppTheme.background,
            )));
      }
      else {
        newLabels.add(FlutterSliderHatchMarkLabel(
            percent: label['percent'],
            label: Container(
              decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.all(Radius.circular(30))
              ),

              height: label['size'],
              width: 2.5,
              //   color: AppTheme.white,
            )));
      }
    }
    return newLabels;
  }

  /// Start charging http api
  void startChargingAPI() async{
    _preferences = await SharedPreferences.getInstance();

    print('check units::');
    print(energyUnits.toStringAsFixed(2));

    apiCall.startChargingAPI(sliderVal, energyUnits.toStringAsFixed(2)).then((response) {

      currentAppState.setSliderStatus(false);
      if (response['status'] == true) {

        _preferences.setString('time', currentAppState.getEstimatedTime.toStringAsFixed(2));
        currentAppState.setReceivedText('wait');
        /// store this value for initially check charging is started or not
        pref.putString(SharedKey().chargingStatus, "stop");
      }
      else {
        currentAppState.setSliderMoveControl(false);   /// slider moving enabled
        /// reset values
        pref.putString(SharedKey().chargingStatus, "start");
        currentAppState.setReceivedText('start');

        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please try again -> [http response]');
      }
    });

    /// new mqtt flow 10 sec added
  /*  print('in start charging [62 sec] before:: ');
    await new Future.delayed(const Duration(seconds: 62));
    if(currentAppState.getReceivedText != 'stop'){
      apiCall.getInvoiceAPI(FlutterApp.requestId).then((response) {
        if (response['status'] == true) {
          String status = response['current_status'][0]['active_status'];

          print('in start charging [62 sec] after:: ');
          FToast.show(status);
          print(status);

          if(status == 'P'){
            currentAppState.setReceivedText('start');
          }
        }else{}
      });
    }*/


  }

  /// stop charging http api
  void stopChargingAPI() async{

    apiCall.stopChargingAPI().then((response) {
      if (response['status'] == true) {
        currentAppState.setReceivedText('wait');

        Navigator.push(context, MaterialPageRoute(builder: (context) => Invoice('map')));
      } else {
    //    currentAppState.setReceivedText('stop');  //start
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Dear user something went wrong, please stop charging again!');
      }
    });

    /// new mqtt flow 10 sec added
 /*   print('in stop charging [10 sec] before::');

    await new Future.delayed(const Duration(seconds: 10));
    if(currentAppState.getReceivedText != 'stopped'){
      apiCall.getInvoiceAPI(FlutterApp.requestId).then((response) {
        if (response['status'] == true) {
          String status = response['current_status'][0]['active_status'];
          print('in stop charging [10 sec] after::');
          print(status);
          FToast.show(status);

          if(status == 'S'){
            currentAppState.setReceivedText('stop');
            Navigator.pop(context);
          }

        }else{}
      });
    }*/
  }

  /// on press of android back button action
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(

        content: new Text('Dear user, do not exit App! Processing...'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
       //     onPressed: () => exit(0),
            onPressed: (){
              SystemNavigator.pop();
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  /// app background method
  void didChangeDependencies() {

    print('in didChangeDependencies');

    /// state management - current state maintain [provider]
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    if(currentAppState.getReceivedText.contains('stop')){
      euuv = currentAppState.getLivePercentage;
      effects = updateEffects(ellv * 100 / mEffects.length, euuv * 100 / mEffects.length);
    }

    super.didChangeDependencies();
  }

}

class Avatar extends StatelessWidget {
  final ImageProvider<dynamic> image;
  final Color borderColor;
  final Color backgroundColor;
  final double radius;
  final double borderWidth;

  const Avatar(
      {Key key,
        @required this.image,
        this.borderColor = Colors.grey,
        this.backgroundColor,
        this.radius = 30,
        this.borderWidth = 5})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      foregroundColor: Colors.red,
      radius: radius + borderWidth,
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor != null
            ? backgroundColor
            : Theme.of(context).primaryColor,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: radius - borderWidth,
          backgroundImage: image,
        ),
      ),
    );
  }
}
