/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/Animation/DelayedAimation.dart';
import 'package:vtrochargingstation/GoldCard/AddBalance.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/Invoice/Invoice.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/GoldCardModel.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';
import 'GoldCard.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image/image.dart' as Img;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vtrochargingstation/common/FToast.dart';

class GoldCardView extends ApplyGoldCardState {
  ///mqtt
  MQTTAppState currentAppState;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = AppTheme();
  bool _loading = false;
  APICall apiCall = APICall();
  List<GoldCardModel> _goldList = new List<GoldCardModel>();
  bool _enabled = true;

  /// month picker
  DateTime selectedDate;

  /// pagination
  ScrollController _sc = new ScrollController();
  static int page = 0;

  @override
  void initState() {
    // TODO: implement initState

    selectedDate = DateTime.now();
    getGoldCardList();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        getGoldCardList(); //pagination
      }
    });
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
        size: h / 15,
      ),
      dismissible: false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.background,

        /// UI
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Appbar
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      page = 0;
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
                    child: Text('Gold card',
                        style:
                            utils.textStyleRegular1(context, FontWeight.w400)),
                  ),
                ],
              ),

              /// balance
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //     Image.asset('images/walletBlack.png', height: h / 25,),
                    //     SizedBox(width: 10,),
                    Text('Card Balance',
                        style: utils.textStyleRegular(context, 38,
                            AppTheme.text1, FontWeight.w500, 0.0, '')),
                    Text('₹' + currentAppState.getGoldCardAmount.toString(),
                        style: utils.textStyleRegular(
                            context,
                            38,
                            double.parse(currentAppState.getGoldCardAmount) < 50
                                ? AppTheme.red
                                : AppTheme.greenShade1,
                            FontWeight.w500,
                            0.0,
                            '')),
                  ],
                ),
              ),

              Image.asset('images/line.png'),

              Row(
                children: [
                  Container(
                    //  color: Color(0xFFF2F2F2),
                    height: h / 17,
                    width: w / 3.3,
                    margin:
                        EdgeInsets.symmetric(horizontal: 10, vertical: h / 27),
                    // horizontal = width, vertical = kiti varun khali

                    child: NeumorphicButton(
                      onPressed: () {
                        showMonthPicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 1, 5),
                          lastDate: DateTime(
                              DateTime.now().year, DateTime.now().month + 1, 0),
                          initialDate: selectedDate,
                          locale: Locale("en"),
                        ).then((date) {
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                              print(selectedDate.month);
                              print(selectedDate.year);
                              print(selectedDate);

                              page = 0;
                              monthFilterApi(selectedDate.year.toString() +
                                  '-' +
                                  selectedDate.month.toString());
                            });
                          } else {
                            //    FToast.show("message");
                          }
                        });
                      },
                      style: NeumorphicStyle(
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(30)),
                          color: AppTheme.background,
                          depth: 5,
                          surfaceIntensity: 0.20,
                          intensity: 0.95,
                          shadowDarkColor: AppTheme.bottomShadow,
                          //outer bottom shadow
                          shadowLightColor: Colors.white // outer top shadow
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Month',
                              style: utils.textStyleRegular4(
                                  context, FontWeight.w400)),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF808080),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    //  color: Color(0xFFF2F2F2),
                    height: h / 17,
                    width: w / 2.9,
                    margin:
                        EdgeInsets.symmetric(horizontal: 10, vertical: h / 30),
                    // horizontal = width, vertical = kiti varun khali

                    child: NeumorphicButton(
                      onPressed: () {
                        currentAppState.setMapVisibility(false);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddBalance()));
                      },
                      style: NeumorphicStyle(
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(30)),
                          color: AppTheme.background,
                          depth: 5,
                          surfaceIntensity: 0.20,
                          intensity: 0.95,
                          shadowDarkColor: AppTheme.bottomShadow,
                          //outer bottom shadow
                          shadowLightColor: Colors.white // outer top shadow
                          ),
                      child: Center(
                          child: Text('Add Balance',
                              style: utils.textStyleRegular4(
                                  context, FontWeight.w400))),
                    ),
                  ),
                ],
              ),

              getHistory(),
            ],
          ),
        ),
      ),
    );
  }

  /// history - API
  getHistory() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Flexible(
      child: DelayedAimation(
        child: Container(
          width: w,
          child: ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: _goldList.length > 0
                ? ListView.builder(
                    controller: _sc,
                    scrollDirection: Axis.vertical,
                    itemCount: _goldList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          print('gold card req ID::');
                          FlutterApp.requestId = _goldList[index].requestId;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Invoice('gold')));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(10)),
                              color: AppTheme.background,
                              depth: 5,
                              intensity: 0.99,
                              //drop shadow
                              shadowDarkColor: AppTheme.bottomShadow,
                              // upper bottom shadow
                              shadowLightColor:
                                  Colors.white, // upper top shadow
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          _goldList[index].stationImage,
                                          height: h / 13,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1,
                                                backgroundColor: Colors.green,
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: w / 20),
                                      Flexible(
                                          child: Padding(
                                        padding: EdgeInsets.only(right: h / 6),
                                        child: Text(
                                            _goldList[index].stationName,
                                            maxLines: 3,
                                            style: utils.textStyleRegular(
                                                context,
                                                60,
                                                AppTheme.text2,
                                                FontWeight.normal,
                                                0.0,
                                                '')),
                                      )),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Column(
                                      children: [
                                        Text('₹' + _goldList[index].amount,
                                            style: utils.textStyleRegular4(
                                                context, FontWeight.w400)),
                                        Text(_goldList[index].energyConsume,
                                            style: utils.textStyleRegular3(
                                                context, FontWeight.w400)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                : _enabled == true
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        enabled: _enabled,
                        child: Stack(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(left: w / 20, right: w / 20),
                              child: SizedBox(
                                height: h / 9.5,
                                //      child: Container(color: Colors.green,),
                              ),
                            ),
                            ListView.builder(
                              itemCount: 9,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(Icons.image, size: h / 10),
                                  title: SizedBox(
                                    height: h / 10,
                                    child: Container(
                                      color: Colors.green,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Image.asset(
                        'images/noDataFound.png',
                        height: h / 3,
                      )),
          ),
        ),
      ),
    );
  }

  /// gold card - API
  void getGoldCardList() {
    setState(() {
      page++;
    });

    print('page count::::');
    print(page);

    if (page == 1) {
      _goldList.clear();
    } else {
      setState(() {
        _loading = true;
      });
    }
    apiCall.getGoldCardDetails(page).then((response) {
      setState(() {
        _loading = false;
      });

      if (response['status'] == true) {
        setState(() {
          for (var gold in response['request_list']) {
            _goldList.add(GoldCardModel(
                gold['request_id'],
                gold['station_image'],
                gold['station_id'],
                gold['station_name'],
                gold['energy_consume'],
                gold['amount'],
                gold['start_date'],
                gold['start_time']));
          }
        });
      } else {
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'No more data');
        setState(() {
          _enabled = false;
        });
      }
    });
  }

  /// month - API
  void monthFilterApi(String monthYear) async {
    setState(() {
      page++;
    });

    print('page count::::');
    print(page);

    if (page == 1) {
      _goldList.clear();
    } else {
      setState(() {
        _loading = true;
      });
    }

    apiCall.filterHistoryGoldCard(page, monthYear).then((response) {
      setState(() {
        _loading = false;
      });

      if (response['status'] == true) {
        setState(() {
          for (var gold in response['request_list']) {
            _goldList.add(GoldCardModel(
                gold['request_id'],
                gold['station_image'],
                gold['station_id'],
                gold['station_name'],
                gold['energy_consume'],
                gold['amount'],
                gold['start_date'],
                gold['start_time']));
          }
        });
      } else {
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'No more data');
        setState(() {
          _enabled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    page = 0;
    _sc.dispose();
    super.dispose();
  }
}
