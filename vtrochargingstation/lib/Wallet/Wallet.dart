/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/Cashfree/CashfreePage.dart';
import 'package:vtrochargingstation/InternetConnectivity/network_info.dart';
import 'package:vtrochargingstation/Profile/MyProfileView.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/Recommended.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';
import 'package:vtrochargingstation/neo/text_field.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils=new AppTheme();

  APICall apiCall = APICall();
  TextEditingController _amountController = new TextEditingController();
  CashFreePage cashFreePage = new CashFreePage();
  List<Recommended> _balanceList = new List<Recommended>();
  bool _enabled = true, disabledButton = true;

  ///mqtt
  MQTTAppState currentAppState;

  @override
  void initState() {

    recommendedBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    /// state management - current state maintain [provider]
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: (){
        Navigator.pop(context);
        return;
      },
      child: Scaffold(

        backgroundColor: AppTheme.background,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false, /// keyboard issue handled
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: h,
                width: w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Appbar
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            _amountController.text = '';
                            FocusScope.of(context).requestFocus(FocusNode());
                       //     ProgressBar.show(context);
                      //      await new Future.delayed(const Duration(seconds: 1));
                      //      currentAppState.setMapVisibility(true);//5apr
                      //      ProgressBar.dismiss(context);
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
                          padding: EdgeInsets.only(left: w / 4),
                          child: Text('Wallet',
                              style: utils.textStyleRegular(context, 54, AppTheme.text1, FontWeight.normal, 0.0, '')),
                        ),
                      ],
                    ),

                    /// balance
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Vtro Balance ',
                              style: utils.textStyleRegular(context, 42,
                                  AppTheme.text1, FontWeight.w500, 0.0, '')),
                          Text('₹' + currentAppState.getWalletAmount.toString(),
                              style: utils.textStyleRegular(context, 42, double.parse(currentAppState.getWalletAmount) < 50 ?
                                  AppTheme.red : AppTheme.greenShade1, FontWeight.w500, 0.0, '')),
                        ],
                      ),
                    ),

                    Image.asset('images/line.png'),

                    Padding(
                      padding: EdgeInsets.only(top: h / 30, left: w / 20, bottom: h / 90),
                      child: Text('Topup Wallet',
                          style: utils.textStyleRegular1(context, FontWeight.w400)),
                    ),

                    Neumorphic(
                      margin: EdgeInsets.only(left: w/30, right: w/30, top: 2, bottom: 4),
                      style: NeumorphicStyle(
                        //  depth: NeumorphicTheme.embossDepth(context),
                        depth: -7,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),  // side border
                        shadowDarkColorEmboss: AppTheme.bottomShadow,  //  inner top shadow
                        shadowLightColorEmboss: Colors.white, // inner bottom shadow
                        disableDepth: false,
                        surfaceIntensity: 5,
                        color: AppTheme.background,
                        shape: NeumorphicShape.convex,
                        intensity: 0.99,// inner shadow effect
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 14),
                      child: TextField(style: utils.textStyleRegular(context,32, AppTheme.text1,FontWeight.w700, 0.0,''), // writing text color
                        cursorColor: AppTheme.greenShade1,

                        controller: _amountController,
                        onChanged: (text) {
                        if(text.length >= 1){
                          setState(() {
                            disabledButton = false;
                          });
                        }else{
                          setState(() {
                            disabledButton = true;
                          });
                        }
                   },
                        keyboardType: TextInputType.number,
                        maxLines: 1,

                        decoration: InputDecoration(hintText: 'Enter Amount',

                            prefix: Text('₹ ', style: TextStyle(color: Colors.black),),
                         //   disabledBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintStyle: utils.textStyleRegular(context, 32 , AppTheme.text4,FontWeight.w700, 0.0,'')),
                        // hint text color
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                          top: h / 30, left: w / 20, bottom: h / 90),
                      child: Text('Recommended',
                          style: utils.textStyleRegular1(context, FontWeight.w400)),
                    ),

                    getRecommendedBalance(),

                    SizedBox(height: h / 7,),

                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/bell.png',
                                height: h / 35,
                              ),
                              SizedBox(width: w / 40),
                              Flexible(
                                child: Text('We’ll remind you to keep your wallet loaded.',
                                    style: utils.textStyleRegular(context,60, AppTheme.text2,FontWeight.w400, 0.0,'')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Image.asset('images/line.png'),

                    ///SECURE pay button
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: h / 25),
                          child: Container(
                            height: h / 14,
                            margin: EdgeInsets.symmetric(horizontal: h / 15),
                            child: AbsorbPointer(
                              absorbing: disabledButton, //changed
                              child: NeumorphicButton(
                                onPressed: () {
                                  if(_amountController.text.isEmpty){
                                    ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter amount');
                                  }else{
                                    generateCFTokenApi();
                                  }
                                },
                                style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(30)),
                                    color: AppTheme.background,
                                    depth: 5,
                                    surfaceIntensity: 0.20,
                                    intensity: disabledButton == true ? 0.50 : 0.95, //changed
                                    shadowDarkColor: AppTheme.bottomShadow,
                                    //outer bottom shadow
                                    shadowLightColor: Colors.white // outer top shadow
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('SECURE PAY',
                                        style: utils.textStyleRegular(context, 50, disabledButton == true ? AppTheme.buttonDisabled :
                                        AppTheme.text2, FontWeight.w700, 0.0, '')),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
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

  /// value changes to edit text callback method
  void itemTitleChange(String amount) {
    setState(() {
      this._amountController.text = amount;
      print(_amountController.text);
    });
  }

  /// design of recommended balance
  getRecommendedBalance() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      height: h / 11,
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: _balanceList.length > 0 ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _balanceList.length,

            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){

                  print(_balanceList[index].amount.toString());

                  setState(() {
                    _amountController.text = _balanceList[index].amount.toString();
                    disabledButton = false;

                    _amountController.selection = TextSelection.fromPosition(TextPosition(offset: _amountController.text.length)); // set cursor at end

                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
                child: Container(
                  width: w/3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                        color: AppTheme.background,
                        depth: 4,
                        intensity: 0.99,
                        shadowDarkColor: AppTheme.bottomShadow,
                        shadowLightColor: Colors.white, // upper top shadow
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: Text(_balanceList[index].amount,
                              style: utils.textStyleRegular(context, 45, AppTheme.greenShade1, FontWeight.w400, 0.0, '')),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }) : Shimmer.fromColors(
      baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        enabled: _enabled,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left:w/20, right: w/20),
              child: SizedBox(
                height: h/9.5,
                child: Container(color: AppTheme.background),
              ),
            ),
          ],
        ),
      ) ,
      ),
    );
  }

  /// API - get cftoken
  void generateCFTokenApi() async {
    cashFreePage = CashFreePage(state: currentAppState);
    ProgressBar.show(context);

    apiCall.generateCFToken(_amountController.text).then((response) {

      ProgressBar.dismiss(context);
      if (response['status'] == true) {

        cashFreePage.makePayment(context, _scaffoldKey, _amountController.text,
            response['order_id'], response['cftoken'], 'wallet')
            .then((paymentResponse) {

          print(paymentResponse.toString());

        });
      } else {
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.WENT_WRONG);
      }

      setState(() {
        _amountController.clear();
      });
    });
  }

  /// API - get recommended balance
  void recommendedBalance() {
    apiCall.recommendedBalance().then((response) {

      if(response['status'] == true){
        setState(() {
          for (var amount in response['recommended_list']) {
            _balanceList.add(Recommended(amount['amount']));
          }
        });
      }

      else if(response['status'] == 'timeout'){
  //      Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return NetworkInfo(
                title: 'Ooops! Something went wrong',
              );
            });
      }
      else{

      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _amountController.dispose();
    super.dispose();
  }

}
