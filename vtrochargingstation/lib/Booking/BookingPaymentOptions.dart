/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:io';
import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrochargingstation/Cashfree/CashfreePage.dart';
import 'package:vtrochargingstation/CommunicationManager.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/GoogleMapData/MapView.dart';
import 'package:vtrochargingstation/InternetConnectivity/network_info.dart';
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

class BookingPaymentOptions extends StatefulWidget {

  double estimatedCost, costOfGst;
  String chargerType, bookDate, timeSlot, stationId;

  BookingPaymentOptions(this.estimatedCost, this.costOfGst, this.chargerType, this.bookDate, this.timeSlot, this.stationId);

  @override
  _BookingPaymentOptionsState createState() => _BookingPaymentOptionsState();
}

class _BookingPaymentOptionsState extends State<BookingPaymentOptions> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  CashFreePage cashFreePage = new CashFreePage();

  AppTheme utils = AppTheme();
  APICall apiCall = APICall();

  int _radioValue = 1;
  String img = 'images/radioUnselected.png';
  String referenceId, paymentMode, paymentStatus, txMsg;

  SharedPreference pref = new SharedPreference();

  bool _loading = false;

  ///mqtt
  MQTTAppState currentAppState;
  CommunicationManager _manager;

  String vtroWalletAmount = '', withWalletAmountWallet = '', withWalletOtherPay = '';
  String witoutWalletAmountWallet = '', withoutWalletOtherPay = '';

  String totalAmountApi = '';

  String wallet = '', other = '';
  String isWallet = '', isOther = '';
  bool _checkbox = true;
  double unselectedDepth = -5;
  double selectedDepth = 5;

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
        color: AppTheme.greenShade1,
        size: h/15,
      ),
      dismissible: false,
      child: Scaffold(
          key: _scaffoldKey,
          /// UI
          body: SafeArea(
              child: Stack(
                children: [

                  Padding(
                    padding:  EdgeInsets.only(bottom:h/6.7),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset('images/line.png', height: 10,)),
                  ),

                  Row(
                    children: [
                      InkWell(
                        onTap: (){
                          currentAppState.setReceivedText('proceed');  // new added
                          currentAppState.setSliderMoveControl(false);  // new added
                          Navigator.pop(context);
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
                        child: Text('Payment', style: utils.textStyleRegular(context,50, AppTheme.text1,FontWeight.normal, 0.0,'')),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SizedBox(height: h/15,),

                        Row(
                          //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Image.asset('images/mapimg.png', height: 50,),
                            Flexible(child: Padding(
                              padding: EdgeInsets.only(left:10.0),
                              child: Text('PowerUp EV Charging Station Laxman Nagar, Baner',
                                  style:utils.textStyleRegular1(context,FontWeight.w400)),
                            )),
                          ],
                        ),

                        ///apply promo code
                        InkWell(
                          onTap: (){
                            ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.upcoming);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top:h/20, ),
                            child: Container(
                              height: h/12,
                              width: w,
                              child: Neumorphic(
                                style: NeumorphicStyle(

                                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                                  color: AppTheme.background,
                                  depth: 5,
                                  intensity: 0.99, //drop shadow
                                  shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                                  shadowLightColor: Colors.white,  // upper top shadow
                                  //    surfaceIntensity: 0.20, // no use

                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Image.asset('images/promocode.png', height: h/30,),

                                      SizedBox(width: 10,),

                                      Text('Apply Promocode',  style:utils.textStyleRegular1(context,FontWeight.w400)),

                                      Padding(
                                          padding: EdgeInsets.only(left:w/3.5),
                                          child: Icon(Icons.arrow_forward_ios, size: h/45,)
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// Bill details
                        Padding(
                          padding: EdgeInsets.only(top:h/30 ),
                          child: Container(
                            height: h/5.6,
                            width: w,
                            child: Neumorphic(
                              style: NeumorphicStyle(

                                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                                color: AppTheme.background,
                                depth: 5,
                                intensity: 0.99, //drop shadow
                                shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                                shadowLightColor: Colors.white,  // upper top shadow
                                //    surfaceIntensity: 0.20, // no use

                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text('Bill Details', style:utils.textStyleRegular1(context,FontWeight.w400)),
                                    ),

                                    Divider(
                                      height: 2.0,
                                      color: Colors.grey[400],
                                    ),

                                    //         SizedBox(height: h/40,),

                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('To Pay : ₹ ' + widget.estimatedCost.toString(), style: utils.textStyleRegular(context,46, AppTheme.greenShade1,FontWeight.w400, 0.0,'')),
                                          Text('',style: utils.textStyleRegular(context,45, AppTheme.text2,FontWeight.normal, 0.0,'')),
                                        ],
                                      ),
                                    ),

                                    Text(' Includes ₹ ' + widget.costOfGst.toString() + ' Taxes', style:utils.textStyleRegular2(context,FontWeight.w400)),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: h/30),

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Debit From', style:utils.textStyleRegular2(context,FontWeight.w400)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Vtro Wallet', style:utils.textStyleRegular1(context,FontWeight.w400)),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('₹ ' + wallet, style:utils.textStyleRegular(context,55, AppTheme.text1,FontWeight.normal, 0.0,'')),
                                      SizedBox(width: 10,),

                                      Checkbox(
                                        value: _checkbox,
                                        onChanged: (value) {
                                          setState(() {

                                            if(vtroWalletAmount == '0'){
                                              _checkbox = false;
                                            }else{
                                              /// when actual amount is greater that wallet

                                              print(value);
                                              _checkbox = !_checkbox;
                                              if(widget.estimatedCost > double.parse(vtroWalletAmount)){
                                                img = 'images/radio.png';
                                                selectedDepth = 5;
                                                unselectedDepth = -5;

                                                if(value == true){
                                                  wallet = withWalletAmountWallet;
                                                  other = withWalletOtherPay;
                                                }else{
                                                  wallet = witoutWalletAmountWallet;
                                                  other = withoutWalletOtherPay;
                                                }
                                              }
                                              else{
                                                if(value == true){
                                                  wallet = withWalletAmountWallet;
                                                  other = withWalletOtherPay;
                                                  img = 'images/radioUnselected.png';
                                                }else{
                                                  wallet = witoutWalletAmountWallet;
                                                  other = withoutWalletOtherPay;
                                                  img = 'images/radio.png';
                                                }
                                              }
                                            }




                                          });
                                        },
                                      ),

                                    ],
                                  ),
                                ],
                              ),

                              Text('Total Balance: ₹ ' + vtroWalletAmount, style:utils.textStyleRegular4(context,FontWeight.w400)),

                              SizedBox(height: 20,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text('Other payment options', style:utils.textStyleRegular1(context,FontWeight.w400)),
                                      Text('BHIM UPI, credit card etc', style:utils.textStyleRegular4(context,FontWeight.w400)),
                                    ],
                                  ),

                                  Row(
                                    children: [

                                      Text('₹ ' + other , style:utils.textStyleRegular(context,55, AppTheme.text1,FontWeight.normal, 0.0,'')),
                                      SizedBox(width: 10,),
                                      Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child:
                                        NeumorphicRadio(
                                          child: Image.asset(img, height: 10,),
                                          groupValue: _radioValue,
                                          onChanged: (int value){
                                            setState(() {

                                              _radioValue = value;
                                              print(_radioValue);

                                              if(widget.estimatedCost > double.parse(vtroWalletAmount)){
                                                img = 'images/radio.png';
                                                selectedDepth = 5;
                                                unselectedDepth = -5;
                                              }
                                              else{
                                                if(value == 1){
                                                  img = 'images/radioUnselected.png';
                                                  wallet = withWalletAmountWallet;
                                                  other = withWalletOtherPay;
                                                  _checkbox = true;
                                                }else{
                                                  img = 'images/radio.png';
                                                  wallet = witoutWalletAmountWallet;
                                                  other = withoutWalletOtherPay;
                                                  _checkbox = false;
                                                }
                                              }
                                            });
                                          },
                                          padding: const EdgeInsets.all(13.0),
                                          value: 1,
                                          style: NeumorphicRadioStyle(
                                            intensity: 0.7,
                                            unselectedDepth: unselectedDepth,
                                            selectedDepth: selectedDepth,
                                            selectedColor: AppTheme.background,
                                            unselectedColor: AppTheme.background,

                                            boxShape: NeumorphicBoxShape.circle(),

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

                        /// secure pay [button]
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: h/14,
                              margin: EdgeInsets.symmetric(horizontal: h/20, ), // horizontal = width, vertical = kiti varun khali

                              child: NeumorphicButton(

                                onPressed: (){
                                  if(wallet != '0.00'){
                                    isWallet = '1';
                                  }else{
                                    isWallet = '0';
                                  }
                                  if(other != '0.00'){
                                    isOther = '1';
                                  }else{
                                    isOther = '0';
                                  }

                                  generateCFToken(isWallet, isOther);
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

                                    Text('SECURE PAY', style:utils.textStyleRegular2(context, FontWeight.w700)),

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
                      ],
                    ),
                  ),
                ],
              )
          )),
    );
  }

  /// booking payment success api Integration
  void paymentSuccessApi(cfToken, orderID, paymentStatus, txMsg) {

    apiCall.paymentSuccess(widget.estimatedCost,referenceId, paymentMode, cfToken, orderID, paymentStatus, txMsg).then((response) {
      ProgressBar.dismiss(context);
      if(response['status'] == true){

        currentAppState.setReceivedText('start');
        currentAppState.setSliderMoveControl(true);

      }else{

        FToast.show('Dear user, your payment failed, please try again!');
      }
    });
  }

  /// estimate cost API Integration
  void estimateCost() async{

    setState(() {
      _loading = true;
    });

    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {

      print('checking...');
      print(widget.estimatedCost);

      if(widget.estimatedCost != 0.0){
        apiCall.estimateCostApi(widget.estimatedCost).then((response) {

          setState(() {
            _loading = false;
          });

          if(response['status'] == true){

            setState(() {
              vtroWalletAmount = response['wallet_amount'];

              withWalletAmountWallet = response['with_wallet'][0]['amt_wallet'];
              withWalletOtherPay = response['with_wallet'][0]['amt_other_pay'];

              wallet = withWalletAmountWallet;
              other = withWalletOtherPay;

              witoutWalletAmountWallet = response['without_wallet'][0]['amt_wallet'];
              withoutWalletOtherPay = response['without_wallet'][0]['amt_other_pay'];

              print('-- Estimate cost [booking]true res::');
              print(response);

              if(vtroWalletAmount == '0'){
                setState(() {
                  _checkbox = false;
                });
              }

              print(widget.estimatedCost);
              if(widget.estimatedCost.toStringAsFixed(0) == response['wallet_amount']){
                setState(() {
                  img = 'images/radioUnselected.png';
                });
              }else if(double.parse(response['wallet_amount']) < widget.estimatedCost){
                setState(() {
                  img = 'images/radio.png';
                });
              }

              else{
                setState(() {
                  img = 'images/radioUnselected.png';
                });
              }
            });

          }else{
            print('-- Estimate cost false --');
            ShowCustomSnack.getCustomSnack(context, _scaffoldKey, '[http] estimate cost - false');
          }
        });
      }
      else{
        setState(() {
          _loading = false;
        });
        FToast.show('app side 1 ');
      }
    }else{
   //   Navigator.pop(context);
      noInternetDialog();
    }
  }

  /// generateCFToken API Integration
  void generateCFToken(isWallet, isOther) {
    ProgressBar.show(context);


    print('testing..');
    print(wallet);
    print(other);
    print(isWallet);
    print(isOther);

    setState(() {
      if(other != '0.00'){
        totalAmountApi = other;
      }else{
        totalAmountApi = wallet;
      }
    });

    print('-- total amount booking --');
    print(totalAmountApi);

      apiCall.getCFTokenReservation(widget.estimatedCost, isWallet, isOther, wallet, other, widget.chargerType,
          widget.bookDate, widget.timeSlot, widget.stationId).then((response) {

        ProgressBar.dismiss(context);

        if(response['status'] == true){
          if(response['is_redirect_gatway'] == false){

            getDetailsApi();

            currentAppState.setWalletAmount(response['wallet_amount']);

          }else if(response['is_redirect_gatway'] == true){

            if(other != '0'){
              totalAmountApi = other;
            }else{
              totalAmountApi = wallet;
            }

            print(widget.estimatedCost);
            print(totalAmountApi);

            cashFreePage.makePayment(context, _scaffoldKey, totalAmountApi.toString(),
                response['order_id'], response['cftoken'], 'booking')
                .then((paymentResponse) async{
              print('payment success [booking]---------');
              print(paymentResponse.toString());

            });
            print('-- CF Token true [booking] --');
            print(response);
          }else{
            ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'http cfToken -- false[booking]');
          }
        }else{
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Reservation slot not available!');
        }


      });
  }

  /// common snackbar dialog - box
  showDialogSnackBar(context, title, msg, Color color,) {
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

  /// common internet dialog - box
  noInternetDialog() {

    setState(() {
      _loading = false;
    });
    return showDialog(
        context: context,
        builder: (context) {
          return NetworkInfo(
            title: Messages.NO_INTERNET,
          );
        });
  }

  /// splash screen API - to retrieve all data of user
  void getDetailsApi() {
    apiCall = APICall(state: currentAppState);

    apiCall.getDetailsSplashScreen().then((response) {

      if(response['status'] == true){
   //     currentAppState.setUpcomingReservationVisibility(true);
   //     Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));
              Navigator.of(context).popUntil((route) => route.isFirst);
        showDialogSnackBar(context, 'Reservation successful', '', AppTheme.greenShade1);

       /* var array = response['current_request'];
        var reservationData = response['reservation_details'];

        if(array.length == 0){

          /// check if user has any current reservation request
          if(reservationData.length != 0){

            setState(() {
              FlutterApp.rStationName = response['reservation_details'][0]['station_name'];
              FlutterApp.rTimeSlot = response['reservation_details'][0]['time_slot'];
              FlutterApp.splashScreenReservationId = response['reservation_details'][0]['reservation_id'];
              FlutterApp.reservationStationImage = response['reservation_details'][0]['station_image'];
              FlutterApp.reservationStationID = response['reservation_details'][0]['station_id'];
            });
          }

          Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));
          showDialogSnackBar(context, 'Reservation success[wallet]', '', AppTheme.greenShade1);

    //      Navigator.of(context).popUntil((route) => route.isFirst);
        }else{
          FToast.show('something went wrong1');
        }*/
      }else{
        FToast.show('something went wrong!');
      }
    });
  }
}
