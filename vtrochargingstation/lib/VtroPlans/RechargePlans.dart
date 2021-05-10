/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vtrochargingstation/Cashfree/CashfreePage.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/VtroPlans/plans.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/dialog/FunkeyOverlay.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class RechargePlans extends StatefulWidget {

  String charges, energy, planId;
  int estimatedCost;

  RechargePlans(this.charges, this.energy,  this.estimatedCost, this.planId,);

  @override
  _RechargePlansState createState() => _RechargePlansState();
}

class _RechargePlansState extends State<RechargePlans> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  APICall apiCall = APICall();
  AppTheme utils = AppTheme();
  CashFreePage cashFreePage = new CashFreePage();

  bool _loading = false;

  /// wallet needed params
  String wallet = '', other = '';
  String isWallet = '', isOther = '';
  bool _checkbox = true;
  String vtroWalletAmount = '', withWalletAmountWallet = '', withWalletOtherPay = '';
  String witoutWalletAmountWallet = '', withoutWalletOtherPay = '';
  double unselectedDepth = -5;
  double selectedDepth = 5;
  String img = 'images/radioUnselected.png';
  int _radioValue = 1;

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
        color: AppTheme.greenShade1,
        size: h/15,
      ),
      dismissible: false,
      child: Scaffold(
          backgroundColor: AppTheme.background,
        key: _scaffoldKey,
        body: SafeArea(
          child: Stack(
            children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Appbar
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                    //      Navigator.push(context, MaterialPageRoute(builder: (context) => Plans()));
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
                        padding: EdgeInsets.only(left: w / 4),
                        child: Text('Plan Recharge',
                            style: utils.textStyleRegular1(context, FontWeight.normal,)),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.only(top:h/50, left: w/20, bottom: h/90),
                    child: Text('Guidance', style:utils.textStyleRegular1(context, FontWeight.w400)),
                  ),

                  guidanceList(),

                  Padding(
                    padding: EdgeInsets.only(top:h/50, left: w/20, bottom: h/90),
                    child: Text('Selected Plan', style:utils.textStyleRegular1(context, FontWeight.w400)),
                  ),

                  /// selected plan
                  selectedPlan(),

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
                                SizedBox(width: w/50),

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

                        Text('Total Balance: ₹ ' + currentAppState.getWalletAmount.toString(), style:utils.textStyleRegular4(context,FontWeight.w400)),

                        SizedBox(height: h/50),

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
                                SizedBox(width: w/50),
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

                  /// secure pay button
                  securePayButton(h),

                ],
              )
            ],
          ),
        )
      ),
    );
  }

  /// static guidance list
  guidanceList() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      height: h/7,
      width: w,

      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: ListView.builder(

            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder:(context, index) {

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                    color: AppTheme.blueShade1,
                    depth: 4,
                    intensity: 0.99, //drop shadow
                    shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                    shadowLightColor: Colors.white,  // upper top shadow
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(child: Text('Charge until \nenergy consume',style:utils.textStyleRegular1(context, FontWeight.w400)),
                  ),
                ),
              ),);
            }),
      ),
    );
  }

  selectedPlan(){
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(left:w/30.0, right: w/30, bottom: h/30),
      child: Neumorphic(
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
          color: AppTheme.background,
          depth: 5,
          intensity: 0.99, //drop shadow
          shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
          shadowLightColor: Colors.white,  // upper top shadow
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Container(
                    //  width: 50,
                    height: h/8,
                    decoration: BoxDecoration(
                      color: AppTheme.greenShade2,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.charges, style:utils.textStyleRegular(context,40, AppTheme.text1,FontWeight.w700, 0.0,'')),
                        Text('Charges', style:utils.textStyleRegular4(context, FontWeight.w400)),
                      ],
                    ),
                  ),

                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Container(
                    //  width: 50,
                    height: h/8,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.energy, style:utils.textStyleRegular(context,40, AppTheme.text1,FontWeight.w400, 0.0,'')),
                        Text('Energy', style:utils.textStyleRegular4(context, FontWeight.w400)),
                      ],
                    ),
                  ),

                ),

                Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: Container(
                    width: 1,
                    height: 30,
                    color: Color(0xFFd0d0d0),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Container(
                    //  width: 50,
                    height: h/8,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text('₹'+ widget.estimatedCost.toString(), style:utils.textStyleRegular(context,40, AppTheme.text1,FontWeight.w400, 0.0,'')),
                        Text('Pay', style:utils.textStyleRegular4(context, FontWeight.w400)),
                      ],
                    ),
                  ),

                ),
              ],
            ),

            Container(
              width: w,
              height: 1,
              color: Color(0xFFd0d0d0),
            ),

            GestureDetector(
              onTap: (){
                Navigator.pop(context);
          //      Navigator.push(context, MaterialPageRoute(builder: (context) => Plans()));
              },
              child: Padding(
                padding: EdgeInsets.all(w/30),
                child: Text('Change plan', style:utils.textStyleRegular(context, 54, AppTheme.greenShade1,FontWeight.w400, 0.0,'')),
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// API - estimate cost
  void estimateCost() async{

    setState(() {
      _loading = true;
    });

    if(widget.estimatedCost != 0.0){
      apiCall.estimateCostPlans(widget.planId).then((response) {

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
              print('here2');
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
      FToast.show(Messages.appError);
    }
  }

  /// API - cftoken
  void generateCFToken(isWallet, isOther) {
    cashFreePage = CashFreePage(state: currentAppState);

    ProgressBar.show(context);

    if(other != '0.00'){
      totalAmountApi = other;
    }else{
      totalAmountApi = wallet;
    }

    print('--- total amount send to API ---');
    print(totalAmountApi);

      apiCall.getCFTokenPlans(totalAmountApi, isWallet, isOther,  wallet, other, widget.planId).then((response) {

        ProgressBar.dismiss(context);

        if(response['is_redirect_gatway'] == false){
          currentAppState.setWalletAmount(response['wallet_amount']);

          showDialog(context: context,

              builder: (context) {
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(context).pop(true);
                });
                return TrialDialog(
                  title: 'Plan payment - success',
                  msg: '',
                  color: AppTheme.greenShade1,
                );
              });

        }else if(response['is_redirect_gatway'] == true){

          print('-- CF Token true [plans] --');
          cashFreePage.makePayment(context, _scaffoldKey, totalAmountApi, response['order_id'], response['cftoken'], 'plans').then((paymentResponse){
            print('-- payment success [plans] --');
            print(paymentResponse.toString());
          });
        }else{
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'http cfToken -- false');
        }
      });
  }

  /// button secure pay
  securePayButton(double h) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: h/14,
          margin: EdgeInsets.symmetric(horizontal: h/20, vertical: h/40),

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

                Text('SECURE PAY', style:utils.textStyleRegular(context,50, AppTheme.text2,FontWeight.w700, 0.0,'')),

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
    );
  }
}
