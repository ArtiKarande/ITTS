/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:io';
import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrochargingstation/CommunicationManager.dart';
import 'package:vtrochargingstation/GoldCard/GoldCard.dart';
import 'package:vtrochargingstation/GoogleMapData/MapView.dart';
import 'package:vtrochargingstation/Group/YourGroup.dart';
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
import 'StartCharging.dart';

/// UI - Payment screen widgets
/// wallet / other payment option provided
///


class PaymentOptions extends StatefulWidget {

  double sliderVal, estimatedCost, costOfGst;
  String type, energyUnit, reservationId;

  PaymentOptions(this.sliderVal, this.energyUnit, this.estimatedCost, this.costOfGst, this.type, this.reservationId);  //type i.e. gold card/

  @override
  _PaymentOptionsState createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

    /// when mqtt receives charging not started within time then callback to [MapView]
    if(appState.getReceivedText.contains('notStarted')){

      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }

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
        backgroundColor: AppTheme.background,
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
                      child: Text('Payment', style: utils.textStyleRegular(context,45, AppTheme.text1,FontWeight.normal, 0.0,'')),
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
                                        Text('To Pay : ₹ ' + widget.estimatedCost.toStringAsFixed(2), style: utils.textStyleRegular(context,46, AppTheme.greenShade1,FontWeight.w400, 0.0,'')),
                                        Text('',style: utils.textStyleRegular(context,45, AppTheme.text2,FontWeight.normal, 0.0,'')),
                                      ],
                                    ),
                                  ),

                                  Text(' Includes ₹ ' + widget.costOfGst.toStringAsFixed(2) + ' Taxes', style:utils.textStyleRegular2(context,FontWeight.w400)),

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
                                    Text('₹ ' + wallet, style:utils.textStyleRegular(context,45, AppTheme.text1,FontWeight.normal, 0.0,'')),
                                    SizedBox(width: 10),
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

                                    Text('₹ ' + other , style:utils.textStyleRegular(context,45, AppTheme.text1,FontWeight.normal, 0.0,'')),
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
                                if(widget.type == 'goldCard'){
                                  generateCFTokenGoldCard(isWallet, isOther);
                                }else if(widget.type == 'group'){
                                  generateCFTokenGroup(isWallet, isOther);
                                }

                                /// normal flow of QR payment method
                                else{
                                  generateCFToken(isWallet, isOther);
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

                                  Text('SECURE PAY', style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w700, 0.0,'')),

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

  /// email,order id, amount,notifyUrl, customerPhone - get all details
  /// static values has been provided for testing purpose only - later on remove it

  makePayment(orderID, cfToken) {

    print('-- in make payment --');
    print(orderID);
    print(cfToken);
    print(wallet);
    print(orderID);

    if(other != '0'){
      totalAmountApi = other;
    }else{
      totalAmountApi = wallet;
    }

    print('totalAmountApi::: ');
    print(totalAmountApi);

    //Replace with actual values
    String stage = "TEST";
    String orderId = orderID;
    String orderAmount = totalAmountApi.toString();
    String tokenData = cfToken;
    String customerName = "Arti Karande";
    String orderNote = "Order Note";
    String orderCurrency = "INR";
    String appId = "169473694bfbd37eb8b24c65874961";
    String customerPhone = "8329015378";
    String customerEmail = "arti.karande@vtro.in";
    String notifyUrl = "https://test.gocashfree.com/notify";

    Map<String, dynamic> inputParams = {
      "orderId": orderId,
      "orderAmount": orderAmount,
      "customerName": customerName,
      "orderNote": orderNote,
      "orderCurrency": orderCurrency,
      "appId": appId,
      "customerPhone": customerPhone,
      "customerEmail": customerEmail,
      "stage": stage,
      "tokenData": tokenData,
      "notifyUrl": notifyUrl,
    };

    CashfreePGSDK.doPayment(inputParams)
        .then((value) => value?.forEach((key, value1) {
      print('-- cash free response --');

      print("$key : $value1");

      if(key == 'referenceId'){

        setState(() {
          referenceId = value['referenceId'];
          paymentMode = value['paymentMode'];
          paymentStatus = value['txStatus'];
          txMsg = value['txMsg'];

          print('.............');
          print(referenceId);
          print(paymentMode);

          if(paymentStatus == 'FAILED'){
            if(widget.type == 'goldCard'){
              paymentSuccessApi(cfToken, orderID, paymentStatus, txMsg); // fail call
       //       paymentSuccessGoldCard(cfToken, orderID, paymentStatus, txMsg); // success
            }
            else if(widget.type == 'group'){
              paymentSuccessApi(cfToken, orderID, paymentStatus, txMsg); // fail call group
            }

            /// normal flow of QR payment method
            else{
              paymentSuccessApi(cfToken, orderID, paymentStatus, txMsg); // fail call

              print('payment failed   ---------');
              pref.putString(SharedKey().chargingStatus, "");
              pref.putString(SharedKey().REQUESTID, '0');
              currentAppState.setReceivedText('start');
            }

          }else{
            if(widget.type == 'goldCard'){
              paymentSuccessGoldCard(cfToken, orderID, paymentStatus, txMsg); // success gold card
            }else if(widget.type == 'group'){
              paymentSuccessGroup(cfToken, orderID, paymentStatus, txMsg); // success group
            }

            /// normal flow of QR payment method
            else{
              print('payment success ---------');
              paymentSuccessApi(cfToken, orderID, paymentStatus, txMsg); // success
            }

          }

        });
      }
      //Do something with the result
    }));
  }

  void paymentSuccessApi(cfToken, orderID, paymentStatus, txMsg) {

    apiCall.paymentSuccess(widget.estimatedCost.toStringAsFixed(2),referenceId, paymentMode, cfToken, orderID, paymentStatus, txMsg).then((response) {
      ProgressBar.dismiss(context);
      if(response['status'] == true){

          currentAppState.setReceivedText('start');
          currentAppState.setSliderMoveControl(true);
          pref.putString(SharedKey().REQUESTID, response['request_id']);

          pref.putString(SharedKey().reqPercentage, widget.sliderVal.toString());
          pref.putString(SharedKey().assignedPlug, response['plug_point']);

          Navigator.push(context, MaterialPageRoute(builder: (context) => StartCharging(widget.sliderVal, widget.reservationId)));

      }else{

        if(widget.type == 'goldCard'){
          Navigator.pop(context);
          showDialogSnackBar(context, 'Recharge Failed [other]', '', AppTheme.red);
    //      showDialog1(context, 'Gold Card - Failed', 'Dear user your Gold Card balance is not added');

        }else if(widget.type == 'group'){
          Navigator.pop(context);
          showDialogSnackBar(context, 'Group Recharge Failed [other]', '', AppTheme.red);
        }
        /// normal flow of QR payment method
        else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));
          FToast.show('Dear user, your payment failed, please try again!');
        }
      }
    });
  }

  void estimateCost() async{

    setState(() {
      _loading = true;
    });

    if(widget.estimatedCost != 0.0){
      apiCall.estimateCostApi(widget.estimatedCost.toStringAsFixed(2)).then((response) {

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

            print('-- Estimate cost true --');
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
    }else{
      setState(() {
        _loading = false;
      });
      FToast.show('App side error 2');
      Navigator.pop(context);
    }
  }

  void generateCFToken(isWallet, isOther) {
    ProgressBar.show(context);
    setPref();
    print(wallet);
    print(other);

    if(other != '0.00'){
      totalAmountApi = other;
    }else{
      totalAmountApi = wallet;
    }

    print('--- total amount send to API ---');
    print(totalAmountApi.toString());

    if(widget.sliderVal != null || widget.sliderVal.toString().isNotEmpty || widget.estimatedCost != null || widget.energyUnit != null){

      apiCall.getCFToken(widget.sliderVal, widget.estimatedCost.toStringAsFixed(2),  widget.energyUnit, isWallet, isOther, wallet, other, widget.reservationId).then((response) {
        currentAppState.setReceivedText('start');
        currentAppState.setSliderMoveControl(true);
        ProgressBar.dismiss(context);

        if(response['is_redirect_gatway'] == false){
          currentAppState.setWalletAmount(response['wallet_amount'].toString());
          Navigator.push(context, MaterialPageRoute(builder: (context) => StartCharging(currentAppState.reqPercentage, widget.reservationId)));

        }else if(response['is_redirect_gatway'] == true){

          makePayment(response['order_id'], response['cftoken']);

          print('-- CF Token true --');
          print(response);
        }else{
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'http cfToken -- false');
        }
      });
    }else{
      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'App error 1');
    }
  }

  void setPref() async{

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("time", currentAppState.getEstimatedTime.toStringAsFixed(2));
    _prefs.setString("cost", currentAppState.getEstimatedCost.toString());
    _prefs.setString("percentage", currentAppState.getRequestedPercentage.toString());
  }

  ///------- gold card API --------///
  void generateCFTokenGoldCard(isWallet, isOther) {
    print('in gold card1');
    ProgressBar.show(context);

    if(other != '0.00'){
      totalAmountApi = other;
    }else{
      totalAmountApi = wallet;
    }

    apiCall.generateCFTokenGoldCard(widget.estimatedCost.toStringAsFixed(2), isWallet, isOther, wallet, other).then((response) {

      ProgressBar.dismiss(context);

      /// gold card wallet payment
      if(response['is_redirect_gatway'] == false){
        currentAppState.setGoldCardAmount(response['vtro_gold_card_balance']);
        currentAppState.setWalletAmount(response['wallet_amount']);
        Navigator.pop(context);

        showDialogSnackBar(context, 'Recharge Successful [wallet]', '', AppTheme.greenShade1);

      }
      /// gold card other payment
      else if(response['is_redirect_gatway'] == true){
        print('-- gold card other payment --');
        print(response);
        makePayment(response['order_id'], response['cftoken']);
      }else{
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'http cfToken -- false');
      }
    });
  }

  void paymentSuccessGoldCard(cfToken, orderID, paymentStatus, txMsg) {

    apiCall.addBalanceGoldCard(orderID, cfToken, widget.estimatedCost.toStringAsFixed(2), referenceId, paymentMode, paymentStatus, txMsg).then((response) {
      ProgressBar.dismiss(context);
      if(response['status'] == true){
        print('in gold card success::');

        currentAppState.setGoldCardAmount(response['vtro_gold_card_balance']);
        currentAppState.setWalletAmount(response['wallet_amount']);
        Navigator.pop(context);
        showDialogSnackBar(context, 'Recharge Successful [other]', '', AppTheme.greenShade1);
     //   showDialog1(context, 'Gold Card Balance Added - [other]', 'Dear user your Gold Card balance is successfully added');

      }else{
        print('gold card failed::');
        Navigator.pop(context);
        showDialogSnackBar(context, 'Recharge Failed [other]', '', AppTheme.red);
     //   showDialog1(context, 'Gold Card - Failed [other]', 'Dear user your Gold Card balance is not added');

      }
    });
  }

  showDialog1(context, title, msg){
    return showDialog(
      context: context,
      builder: (_) => FunkyOverlay(
        title: title,
        msg: msg,
      ),
    );
  }

  showDialogSnackBar(context, title, msg, Color color,){
    return showDialog(
      context: context,
      builder: (_) => TrialDialog(
        title: title,
        msg: msg,
        color: color,
      ),
    );
  }

  ///------- group -------///

  void generateCFTokenGroup(isWallet, isOther) {
    print('in gold card1');
    ProgressBar.show(context);

    if(other != '0.00'){
      totalAmountApi = other;
    }else{
      totalAmountApi = wallet;
    }

    apiCall.generateCFTokenGroup(widget.estimatedCost.toStringAsFixed(2), isWallet, isOther, wallet, other).then((response) {

      ProgressBar.dismiss(context);

      /// gold card wallet payment
      if(response['is_redirect_gatway'] == false){
     //   currentAppState.setGoldCardAmount(response['vtro_gold_card_balance']);
        currentAppState.setWalletAmount(response['wallet_amount']);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => YourGroup()));

        showDialogSnackBar(context, 'Recharge Successful [wallet]', '', AppTheme.greenShade1);

      } else if(response['status'] == 'timeout'){
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

      /// gold card other payment
      else if(response['is_redirect_gatway'] == true){
        print('-- gold card other payment --');
        print(response);
        makePayment(response['order_id'], response['cftoken']); //gold
      }else{
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'http cfToken -- false');
      }
    });
  }

  void paymentSuccessGroup(cfToken, orderID, paymentStatus, txMsg) {

    apiCall.addBalanceGroupPayment(orderID, cfToken, referenceId, paymentMode, paymentStatus, txMsg).then((response) {
      ProgressBar.dismiss(context);
      if(response['status'] == true){
        print('in group payment success::');

        currentAppState.setGoldCardAmount(response['vtro_gold_card_balance']);
        currentAppState.setWalletAmount(response['wallet_amount']);
        setState(() {
          FlutterApp.groupBalance = (double.parse(response['group_balance']));
        });


        Navigator.pop(context);
        Navigator.pop(context);

        /*Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => YourGroup()));*/
        showDialogSnackBar(context, 'Group Recharge Successful', '', AppTheme.greenShade1);

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
      } else{
        print('group failed::');
        Navigator.pop(context);
        showDialogSnackBar(context, 'Recharge Failed [other]', '', AppTheme.red);
        //   showDialog1(context, 'Gold Card - Failed [other]', 'Dear user your Gold Card balance is not added');

      }
    });
  }

}
