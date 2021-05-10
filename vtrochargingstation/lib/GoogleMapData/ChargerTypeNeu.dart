/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:async';
import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vtrochargingstation/CommunicationManager.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/charging/StartCharging.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/dialog/FunkeyOverlay.dart';
import 'package:vtrochargingstation/models/ChargerList.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';

class ChargerTypeNeu extends StatefulWidget {

  /// reservation id and charger type req only when u go through reservation process
  String qrCode, reservationId, chargerType;
  ChargerTypeNeu(this.qrCode, this.reservationId, this.chargerType);

  @override
  _ChargerTypeNeuState createState() => _ChargerTypeNeuState();
}

class _ChargerTypeNeuState extends State<ChargerTypeNeu> with TickerProviderStateMixin{

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  APICall apiCall = APICall();
  AppTheme utils = AppTheme();
  MQTTAppState currentAppState;
  CommunicationManager _manager;
  List<ChargerList> _chargerList = new List<ChargerList>();

  List<bool> isHighlighted = [false, false, false, false];

  bool flag = false, disabledButton = true;  /// to set animation

  ///Anim
  AnimationController _controller;
  int levelClock = 63; //63
  String img = 'images/normal.png';

  bool _loading = false;
  String subId = '', activeStatus = '';       // if no plan/subscription then send [subid] blank param to assign plug api

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 0));

    super.initState();
    print('reservationID:::');
    print(widget.reservationId);
    getChargerList();

  }

  @override
  Widget build(BuildContext context) {

    /// state management - current state maintain [provider]
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    /// when mqtt receives [false] for charger connection
    ///     - then callback to [MapView]
    if(appState.getReceivedText.contains('map')) {
      SchedulerBinding.instance.addPostFrameCallback((_) {

        Navigator.of(context).popUntil((route) => route.isFirst);
        showDialogSnackBar(context, 'Charger not connected', '', AppTheme.red);

      });
    }
    else if(appState.getReceivedText.contains('per')){
      SchedulerBinding.instance.addPostFrameCallback((_) {

        /// when mqtt res is true, sub id is present then start charging
        if(FlutterApp.typeOfAll == '3'){            /// when user has plan directly start charging
          currentAppState.setSliderMoveControl(false);
          currentAppState.setReceivedText('start');
        }
        else if(FlutterApp.typeOfAll == 'RP'){
          currentAppState.setSliderMoveControl(false);
          currentAppState.setReceivedText('start');  /// when reservation and plans both then directly start charging
        }else if(FlutterApp.typeOfAll == 'RN'){
          currentAppState.setReceivedText('proceed');  /// when reservation and normal flow both then straight all flow
        }
        else if(FlutterApp.typeOfAll == '1'){
          currentAppState.setReceivedText('proceed');  /// when user no any plans or anything then straight all flow
        }
        else if(FlutterApp.typeOfAll == '6'){          /// group charging condition flow
          print('group charging flow');
          currentAppState.setSliderMoveControl(false);
          currentAppState.setReceivedText('start');
        }else  if(appState.getReceivedText.contains('notStarted')){  /// when mqtt success false

          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        }
        else{
          currentAppState.setReceivedText('proceed');   /// payment needed
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => StartCharging(currentAppState.getRequestedPercentage, widget.reservationId)));
      });
    }

    return ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: AppTheme.greenShade1,
          size: h/15,
        ),
        dismissible: false,
      child: WillPopScope(
        onWillPop: (){

          if(currentAppState.getPlugAnim == true){
            _onWillPop();
          }else{
            _controller.dispose();
            Navigator.pop(context);
            Navigator.pop(context);
          }
          return;
        },
        child: Scaffold(
          key: _scaffoldKey,

          /// UI
          body: Stack(
            children: <Widget>[

              Visibility(
                visible: currentAppState.getPlugAnim,
                child: Container(
                    color: Color(0xFF80C38F),
                    height: h,
                    width: w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Padding(
                          padding: EdgeInsets.only(left:h/35, right: h/35),
                          child: Column(
                            children: [
                              Text('Please Connect Your Charger to ', style:utils.textStyleRegular(context,40, AppTheme.white,FontWeight.w700, 0.0,'')),
                              Text('Selected Plug-Point', style:utils.textStyleRegular(context,38, AppTheme.white,FontWeight.w700, 0.0,'')),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(h/15),
                          child: ClipOval(child: Image.asset('images/gif/plugAnim.gif')),
                        ),

                        Countdown(
                          animation: StepTween(
                            begin: levelClock, // THIS IS A USER ENTERED NUMBER
                            end: 0,
                          ).animate(_controller),
                        ),
                      ],
                    )),
              ),

              Visibility(
                visible: currentAppState.getPlugAnim == true ? false : true,
                child: Center(child: Container(
                    height: h,
                    child: Image.asset("images/qrBackground.png",fit: BoxFit.fill,))),
              ),

            ],
          ),
          bottomSheet: Visibility(
            visible: currentAppState.getPlugAnim == true ? false : true,
            child: Container(
              decoration: ShapeDecoration(
                  color: AppTheme.background,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),)),
                height: h/1.78,
                width: MediaQuery.of(context).size.width,
                child: getBottomSheetOptions()
            ),
          ),
        ),
      ),
    );
  }

  /// API
  void getChargerList() async{

    setState(() {
      _loading = true;
    });

    _chargerList.clear();
    apiCall.scanQR(widget.qrCode, widget.reservationId).then((response) {

      print('reservationID:::');
      print(widget.reservationId);

      if (mounted) {
        setState(() {
          _loading = false;

        });
      }

      if(response['status'] == true){

        if(mounted){
          setState(() {

            List list = response['current_plan'];

            if(list.length != 0){
              print('[in sub ID]::');
              subId = response['current_plan'][0]['sub_id'];
              FlutterApp.subID = subId;
              FlutterApp.remainingEnergy = response['current_plan'][0]['remaining_energy'];   /// if plan, show energy on start charging page
            }else{
              print('[not in sub ID]');
            }

            /// store all list
            if(widget.chargerType.isEmpty){

              for (var chargerType in response['available_point']) {
                _chargerList.add(ChargerList(chargerType['plug_point'], chargerType['charger_type'], chargerType['active_status']));

              }
              isHighlighted = [false, false, false, false];


            }else{
              print('charger type of booking');
              print(widget.chargerType);

              /// store only normal or only fast charging list
              for (var chargerType in response['available_point']) {

                if(chargerType['charger_type'] == widget.chargerType){
                  _chargerList.add(ChargerList(chargerType['plug_point'], chargerType['charger_type'], chargerType['active_status']));
                }else if(chargerType['charger_type'] == widget.chargerType){
                  _chargerList.add(ChargerList(chargerType['plug_point'], chargerType['charger_type'], chargerType['active_status']));
                }
              }
            }
          });
        }
      }
      else{
         Navigator.pop(context);
         Navigator.pop(context);
      if(response['failure_status'] == '1'){
        showDialogSnackBar(context, 'Station is offline - Please reset hardware!', '', AppTheme.red);
      }
      else if(response['failure_status'] == '2'){
        showDialogSnackBar(context, 'Dear user, Station not found!', '', AppTheme.red);
      }else if(response['failure_status'] == '3'){
        showDialogSnackBar(context, 'Station empty found', '', AppTheme.red);
      }
      else if(response['failure_status'] == '4'){
        showDialogSnackBar(context, 'station is temporary busy please wait!', '', AppTheme.red);
      }
 //     Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  /// UI - charger list in [horizontal]
  getChargerDetailsApi() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      height: h/5.4,
      width: w,
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: ListView.builder(

            scrollDirection: Axis.horizontal,
            itemCount: _chargerList.length,
            itemBuilder:(context, index) {

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Neumorphic(

                  style: NeumorphicStyle(

                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),

                    color: isHighlighted[index] ? AppTheme.greenShade2 : AppTheme.background,
                    depth: isHighlighted[index] ? -5 : 5,
                    intensity: 0.99, //drop shadow
                    shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                    shadowLightColor: Colors.white,  // upper top shadow
                    //    surfaceIntensity: 0.20, // no use

                  ),
                  child: InkWell(
                    onTap: (){

                      for(int i = 0; i < isHighlighted.length; i++){
                        setState(() {
                          if (index == i) {
                            disabledButton = false;
                            isHighlighted[index] = true;
                          }
                         /* else if(_chargerList[index].activeStatus == 'occupied'){ //working on 8 april
                            isHighlighted = [false, false, false, false];
                          }*/

                          else {                               //the condition to change the highlighted item
                            isHighlighted[i] = false;
                          }
                        });
                      }
                      setState(() {
                        FlutterApp.plugPoint = _chargerList[index].plugPoint;
                        FlutterApp.scanQR = widget.qrCode;
                        FlutterApp.activeStatus =  _chargerList[index].activeStatus;
                        activeStatus =  _chargerList[index].activeStatus;
                        FlutterApp.chargerType =  _chargerList[index].chargerType;
                      });

                      if(_chargerList[index].chargerType == 'Normal'){
                        FlutterApp.userChargerSelectionType = 1;  // set to normal

                        setState(() {
                          img = 'images/normal.png';
                        });

                      }else{
                        FlutterApp.userChargerSelectionType = 2; // set to fast

                        setState(() {
                          img = 'images/turbo.png';
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(11.0),
                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Image.asset(_chargerList[index].chargerType == 'Normal' ? 'images/normal.png' : 'images/turbo.png', height: h/30),
                              Text(_chargerList[index].plugPoint,style:utils.textStyleRegular(context,52,
                                  _chargerList[index].activeStatus == 'Available' ? AppTheme.text1 : AppTheme.text2,FontWeight.w700, 0.0,'')),
                            ],
                          ),
                          Text('Plug-in',style:utils.textStyleRegular(context,52,
                              _chargerList[index].activeStatus == 'Available' ? AppTheme.text1 : AppTheme.text2,FontWeight.w400, 0.0,'')),
                          Text(_chargerList[index].activeStatus,style:utils.textStyleRegular(context,52,
                              _chargerList[index].activeStatus == 'Available' ? AppTheme.greenShade1 : AppTheme.red1,FontWeight.w400, 0.0,'')),
                        ],
                      ),
                    ),
                  ),
                ),
              );

            }),
      ),
    );
  }

  /// design of bottom sheet
  Widget getBottomSheetOptions() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: EdgeInsets.only(top:h/30, left: w/20, right: w/20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Scanned Station:  ', style:utils.textStyleRegular2(context,FontWeight.w400)),
                  Text(widget.qrCode, style:utils.textStyleRegular1(context,FontWeight.w400)),
                ],
              ),

              Padding(
                  padding: EdgeInsets.only(top:h/40, bottom: h/40),
                  child: FDottedLine(
                    color: Colors.grey.shade400,
                    width: w,
                    strokeWidth: 0.5,
                    dottedLength: 6.0,
                    space: 2.0,
                  )
              ),

              Row(
                children: [

                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Container(
                      //  width: 50,
                      height: h/11,

                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('images/normal.png', height: h/30,),

                            Text('₹ ' + FlutterApp.normalBikeCost.toString() + '/Unit', style:utils.textStyleRegular4(context,FontWeight.w400)),

                          ],
                        ),
                      ),
                    ),

                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 0,
                    child: Container(
                      width: w/3,
                      height: h/11,
                      child: Padding(
                        padding: const EdgeInsets.only(top:8.0, left: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('images/turbo.png', height: h/30),

                            Text('₹ ' + FlutterApp.fastBikeCost.toString() + '/Unit', style:utils.textStyleRegular4(context,FontWeight.w400)),

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

        Padding(
          padding: EdgeInsets.only(left: w/28,),
          child: Text('Select Plug-Point: ', style:utils.textStyleRegular2(context,FontWeight.w400)),
        ),

        SizedBox(height: h/50,),

        getChargerDetailsApi(),

        SizedBox(height: h/50,),

        /// ok button
        Container(
          height: h/15,
          margin: EdgeInsets.symmetric(horizontal: h/8.2), // horizontal = width, vertical = height

          child: AbsorbPointer(
            absorbing: disabledButton, //changed
            child: NeumorphicButton(
              onPressed: (){
                if(FlutterApp.activeStatus == 'occupied'){
                 print(FlutterApp.plugPoint);
                  FToast.show('Dear user this plug is already occupied!');
                }
                else if(FlutterApp.plugPoint == '0') {
                  FToast.show('Please select plug point');
                }else{

                  print('status: ' + FlutterApp.activeStatus);
                   currentAppState.setPlugAnim(true);
                  _controller = AnimationController(vsync: this, duration: Duration(seconds: levelClock));
                  _controller.forward();

                  if(FlutterApp.plugPoint.isEmpty){
                    FlutterApp.plugPoint = _chargerList[0].plugPoint;
                  }
                  assignPlugPointApi();
                }
              },

              style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                  color: AppTheme.background,
                  depth: 5,
                  surfaceIntensity: 0.20,
                  intensity: disabledButton == true ? 0.50 : 0.95, //changed
                  shadowDarkColor: AppTheme.bottomShadow,  //outer bottom shadow
                  shadowLightColor: Colors.white  // outer top shadow
              ),

              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('OK', style: utils.textStyleRegular(context, 50, disabledButton == true ? AppTheme.buttonDisabled :
                  AppTheme.text2, FontWeight.w700, 0.0, '')),

                  Padding(
                    padding: const EdgeInsets.only(left:10.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: disabledButton == true ? AppTheme.buttonDisabled : AppTheme.text2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],);
  }

  /// API - assign plug point
  void assignPlugPointApi() async{

    if(FlutterApp.groupId.isNotEmpty){
      subId = '';
    }

    apiCall.assignPlugPoint(widget.reservationId, subId).then((response) {


      if(response['status'] == true){
        print('assign plug point http - true');
        FlutterApp.requestId = response['request_id'];
        FlutterApp.typeOfAll = response['type'];
        if(FlutterApp.requestId != '0'){
          subscribeTopic1();  /// here i get req id, then only i can subscribe topic here
        }
      }else if(response['mqtt_status'] == '0'){
        Navigator.of(context).popUntil((route) => route.isFirst);

        currentAppState.setPlugAnim(false);
        FToast.show('MQTT server is not responding');
      }
      else{
        Navigator.of(context).popUntil((route) => route.isFirst);

        currentAppState.setPlugAnim(false);
        FToast.show('[http] Dear user, plug Point Not Available');
      }
    });

    /// if mqtt doesn't respond in 10 second then app needs to decide to discard all and navigate to main page
 //   await new Future.delayed(const Duration(seconds: 59));//59
   /* if(currentAppState.getReceivedText == 'proceed' || currentAppState.getReceivedText == 'map'){
      apiCall.getInvoiceAPI(FlutterApp.requestId).then((response) {
        if (response['status'] == true) {
          String status = response['current_status'][0]['active_status'];
          print('in assign plug [20 sec] after::');
          print(status);

          FToast.show(status);

          /// only request generated
          if(status == '1' || status == '2' || status == 'D'){
            Navigator.pop(context);
            Navigator.pop(context);
        //    Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));
          }

        }else{}
      });
    }else{
      print('[chargerTypeNeu] else::');
    }*/
  }

  /// subscribe [mqtt] topic when assign plug is [true]
  void subscribeTopic1() {
    _manager = CommunicationManager(state: currentAppState);
    _manager.connection();

    Future.delayed(const Duration(seconds: 2), () async {

      _manager.syncSubscribe('vtro/' + FlutterApp.requestId.toString() + '/chargingstation/out/app');
      _manager.syncSubscribe('percentage');
 //     _manager.syncSubscribe('vtro/chargingstation/lastwill');
       print('calling...................');

    });
  }

  showDialogPopup(title, msg){
    return showDialog(
      context: context,
      builder: (_) => FunkyOverlay(
        title: title,
        msg: msg,
      ),
    );
  }

  /// common snackbar dialog - box
  showDialogSnackBar(context, title, msg, Color color,){
    return  showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop(true);
          });
          return TrialDialog(
            title: title,
            msg: msg,
            color: color,
          );
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _controller.dispose();
    _chargerList.clear();
    super.dispose();
  }

  /// on press of android back button action
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(

        content: new Text('Dear user, please wait! Processing...'),
        actions: <Widget>[

          new FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: new Text('OK'),
          ),
        ],
      ),
    ) ??
        false;
  }
}

/// [Countdown] timer class set for - 1 min only
class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText = '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    if(timerText == '0:00'){
      Navigator.pop(context);

  //  Navigator.of(context).popUntil((route) => route.isFirst);
    }

    return Text(
      "$timerText",
      style: TextStyle(
        fontSize: 70,
        color: AppTheme.white,
      ),
    );
  }

}
