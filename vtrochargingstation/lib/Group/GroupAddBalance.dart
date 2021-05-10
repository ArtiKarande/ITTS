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
import 'package:vtrochargingstation/charging/paymentOptions.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/Recommended.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class GroupAddBalance extends StatefulWidget {
  @override
  _GroupAddBalanceState createState() => _GroupAddBalanceState();
}

class _GroupAddBalanceState extends State<GroupAddBalance> {
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
    super.initState();
    recommendedBalance();
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
        currentAppState.setMapVisibility(true);
        Navigator.pop(context);
        return;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false, /// keyboard issue handled
        /// UI
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

                       //     currentAppState.setMapVisibility(true);
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
                          padding: EdgeInsets.only(left: w / 4),
                          child: Text('Group Balance',
                              style: utils.textStyleRegular1(context, FontWeight.normal)),
                        ),
                      ],
                    ),

                    /// balance
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //         Image.asset('images/walletBlack.png', height: h / 25,),
                              //          SizedBox(width: w/30,),
                              Text(FlutterApp.groupName + ' Balance', style:utils.textStyleRegular(context,42, AppTheme.text1,FontWeight.w500, 0.0,'')),
                            ],
                          ),

                          Text('₹' + FlutterApp.groupBalance.toString(), style:utils.textStyleRegular(context,42, AppTheme.red,FontWeight.w500, 0.0,'')),
                        ],
                      ),
                    ),

                    Image.asset('images/line.png'),

                    Padding(
                      padding: EdgeInsets.only(top:h/30, left: w/20, bottom: h/90),
                      child: Text('Topup Group Wallet ' , style:utils.textStyleRegular1(context, FontWeight.w400)),
                    ),

                    Neumorphic(
                      margin: EdgeInsets.only(left: w/30, right: w/30, top: 2, bottom: 4),
                      style: NeumorphicStyle(
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
                        //   onChanged: itemTitleChanget,
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
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        decoration: InputDecoration.collapsed(hintText: '₹ Enter Amount',
                            //      hintStyle: TextStyle(color: Color(0xFFB2B2B2), fontSize: h/45)),  // hint text color
                            hintStyle: utils.textStyleRegular(context, 32 , AppTheme.text4,FontWeight.w700, 0.0,'')), // hint text color
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top:h/30, left: w/20, bottom: h/90),
                      child: Text('Recommended', style:utils.textStyleRegular1(context, FontWeight.w400)),
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
                            //  color: Color(0xFFF2F2F2),
                            height: h/14,
                            margin: EdgeInsets.symmetric(horizontal: h/15), // horizontal = width, vertical = kiti varun khali

                            child: AbsorbPointer(
                              absorbing: disabledButton,
                              child: NeumorphicButton(
                                onPressed: () {
                                  if(_amountController.text.isEmpty){
                                    ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter amount');

                                  }else{
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentOptions(
                                        0.0, '0.0', double.parse(_amountController.text), 0.0, 'group', '')));
                                  }
                                },

                                style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                    color: AppTheme.background,
                                    depth: 5,
                                    intensity: disabledButton == true ? 0.50 : 0.95,
                                   // intensity: 0.95,
                                    shadowDarkColor: AppTheme.bottomShadow,  //outer bottom shadow
                                    shadowLightColor: Colors.white  // outer top shadow
                                ),

                                child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    Text('SECURE PAY',
                                        style: utils.textStyleRegular(context, 50, disabledButton == true ? AppTheme.buttonDisabled :
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

  /// UI for horizontal list
  getRecommendedBalance() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      height: h / 11,
    //  width: w,
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: _balanceList.length > 0 ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _balanceList.length,

            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){
                  print('tap');
                  print(_balanceList[index].amount.toString());

                  setState(() {
                    _amountController.text = _balanceList[index].amount.toString();
                    disabledButton = false;
                    _amountController.selection = TextSelection.fromPosition(TextPosition(offset: _amountController.text.length)); // set cursor at end
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

  /// value changes to edit text callback method
  void itemTitleChanget(String title) {
    setState(() {
      this._amountController.text = title;

      print('textval...');
      print(_amountController.text);

    });
  }

  /// API for recommended balance
  void recommendedBalance() {
    apiCall.recommendedBalance().then((response) {

      if(response['status'] == true){
        setState(() {
          for (var amount in response['recommended_list']) {
            _balanceList.add(Recommended(amount['amount']));
          }
        });
      }
      else{
      // todo
      }
    });
  }

  @override
  void dispose() {

    _amountController.dispose();
    super.dispose();
  }

}
