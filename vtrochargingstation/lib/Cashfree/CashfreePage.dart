/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:async';
import 'dart:collection';
import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';

/// CashFree Payment gateway integration
/// common class methods added
/// [makePayment] method used
/// accordingly API Integration handled

class CashFreePage{

  String referenceId, paymentMode, paymentStatus, txMsg;
  Map<String, dynamic> map = new HashMap();
  APICall apiCall = APICall();

  MQTTAppState _currentState;

  // Constructor
  CashFreePage({
    @required MQTTAppState state
  }):  _currentState = state ;

  Future makePayment(context, _scaffoldKey, amount, orderID, cfToken, String apiType) async{

    print('-- cash free [make payment] --');

    print(amount);
    print(orderID);
    print(cfToken);

    //Replace with actual values
    String stage = "TEST";
    String orderId = orderID;
    String orderAmount = amount;
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

          referenceId = value['referenceId'];
          paymentMode = value['paymentMode'];
          paymentStatus = value['txStatus'];
          txMsg = value['txMsg'];

          print('.......[ payment status ]......');
          print(referenceId);
          print(paymentMode);
          print(paymentStatus);

          if(paymentStatus == 'FAILED'){
            showDialogSnackBar(context, 'Payment failed', '', AppTheme.red);
            return 'fail';

          }else{
            final MQTTAppState appState = Provider.of<MQTTAppState>(context, listen: false);
            _currentState = appState;

            if(apiType == 'plans'){
              paymentSuccessPlans(context, _scaffoldKey, amount, orderID, cfToken);
            }else if(apiType == 'wallet'){
              addBalanceInWallet(context, _scaffoldKey, amount, orderID, cfToken);
            }else if(apiType == 'booking'){
              paymentSuccessReservation(context, _scaffoldKey, amount, orderID, cfToken);
            }
          }
      }
    }));

    return map;
  }

  /// wallet other payment method
  void addBalanceInWallet(context, _scaffoldKey, amount, orderID, cfToken) {

    print('amount = ' + amount);
    print('orderID = ' + orderID);
    print('' + cfToken);
    print('referenceId = ' + referenceId);
    print('' + paymentMode);
    print('paymentStatus = ' + paymentStatus);
    print('' + txMsg);

    apiCall.addBalanceWallet(orderID, cfToken, amount, referenceId, paymentMode, paymentStatus, txMsg).then((response) {

      if(response['status'] == true){

        _currentState.setWalletAmount(response['wallet_amount']);
        showDialogSnackBar(context, 'Wallet recharge successful ', '', AppTheme.greenShade1);

      }else{
        showDialogSnackBar(context, 'Wallet recharge failed', '', AppTheme.red);
      }
    });
  }

  /// plans api
  void paymentSuccessPlans(context, _scaffoldKey, amount, orderID, cfToken) {

    apiCall.paymentSuccessPlans(referenceId, paymentMode, cfToken, orderID, paymentStatus, txMsg).then((response) {
      ProgressBar.dismiss(context);

      if(response['status'] == true){

        _currentState.setWalletAmount(response['wallet_amount']);
        showDialogSnackBar(context, 'Plan recharged successfully', '', AppTheme.greenShade1);

      }else{
        showDialogSnackBar(context, 'Plan recharged - Failed', '', AppTheme.red);
      }
    });
  }

  /// paymentSuccessReservation API
  void paymentSuccessReservation(context, _scaffoldKey, amount, orderID, cfToken) {

    apiCall.paymentSuccessReservation(referenceId, paymentMode, cfToken, orderID, paymentStatus, txMsg).then((response) {
      if(response['status'] == true){
        splashScreenApi(context);
      }else{
        showDialogSnackBar(context, 'Reservation slot not available!', '', AppTheme.greenShade1);
      }
    });
  }

  /// common snackbar dialog - box
  showDialogSnackBar(context, title, msg, Color color,){
    return showDialog(
      context: context,
        builder: (context) {
          return TrialDialog(
            title: title,
            msg: msg,
            color: color,
          );
        });
  }

  /// splash screen API - to retrieve all data of user
  void splashScreenApi(context) {
    apiCall = APICall(state: _currentState);

    apiCall.getDetailsSplashScreen().then((response) {
      if(response['status'] == true){
        Navigator.of(context).popUntil((route) => route.isFirst);
        showDialogSnackBar(context, 'Reservation successful', '', AppTheme.greenShade1);

      }else{
        FToast.show('something went wrong2');
      }
    });
  }

}