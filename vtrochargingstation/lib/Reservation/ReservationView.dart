/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/InternetConnectivity/network_info.dart';
import 'package:vtrochargingstation/Reservation/Reservation.dart';
import 'package:vtrochargingstation/Reservation/ResevationDetails.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/dialog/FunkeyOverlay.dart';
import 'package:vtrochargingstation/models/Reservation/ReservationModel.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';
import 'dart:collection';

class ReservationView extends ReservationState {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = AppTheme();
  bool _loading = false;
  APICall apiCall = APICall();
  List<ReservationModel> _reservationList = new List<ReservationModel>();
  bool _enabled = true;
  Map<String, dynamic> map = new HashMap();
  String chargerTypeIcon = '';

  @override
  void initState() {
    super.initState();
    getReservationList();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      key: _scaffoldKey,

      /// UI
      body: SafeArea(
        child: Column(
          children: [
            Row(
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
                Padding(
                  padding: EdgeInsets.only(left: w / 7),
                  child: Text('Upcoming Reservation',
                      style:
                          utils.textStyleRegular1(context, FontWeight.normal)),
                ),
              ],
            ),
            getReservation(),
          ],
        ),
      ),
    );
  }

  /// reservation list - design
  getReservation() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Flexible(
      child: Container(
        width: w,
        child: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: _reservationList.length > 0
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _reservationList.length,
                  itemBuilder: (context, index) {
                    if (_reservationList[index].chargerType == 'Normal') {
                      chargerTypeIcon = 'images/normal.png';
                    } else {
                      chargerTypeIcon = 'images/turbo.png';
                    }

                    return InkWell(
                      onTap: () {
                        print('check rid::');
                        print(FlutterApp.reservationID);
                        FlutterApp.reservationID =
                            _reservationList[index].reservation_id;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReservationDetails(
                                      _reservationList[index].reservation_id,
                                      _reservationList[index].stationName,
                                      _reservationList[index].chargerType,
                                      _reservationList[index].timeSlot,
                                      _reservationList[index].amount,
                                      _reservationList[index].station_id,
                                      _reservationList[index].stationImage,
                                      'reservation',
                                      _reservationList[index].rStartTime,
                                    )));
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
                            shadowLightColor: Colors.white, // upper top shadow
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 2,
                                  child: Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Image.network(
                                        _reservationList[index].stationImage,
                                        height: h / 16,
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
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 5,
                                  child: Container(
                                    //          color: Colors.red.shade100,
                                    //   width: w/3,
                                    //   height: h/11,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                          _reservationList[index].stationName,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: utils.textStyleRegular(
                                              context,
                                              60,
                                              AppTheme.text2,
                                              FontWeight.w400,
                                              0.0,
                                              '')),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 0,
                                  child: Container(
                                    //     color: AppTheme.yellow1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Image.asset(chargerTypeIcon,
                                                height: h / 40),
                                            Text(
                                                _reservationList[index]
                                                    .timeSlot,
                                                style: utils.textStyleRegular(
                                                    context,
                                                    58,
                                                    AppTheme.text1,
                                                    FontWeight.w400,
                                                    0.0,
                                                    '')),
                                          ],
                                        ),
                                        Text(_reservationList[index].bookDate,
                                            style: utils.textStyleRegular(
                                                context,
                                                58,
                                                AppTheme.text2,
                                                FontWeight.w400,
                                                0.0,
                                                '')),
                                      ],
                                    ),
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
                              child: Container(
                                color: Colors.green,
                              ),
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
                  : Center(child: Image.asset('images/noDataFound.png', height: h / 3,)),
        ),
      ),
    );
  }

  /// API - reservation list
  void getReservationList() async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true) {
      apiCall.getReservationList().then((response) {
        if (response['status'] == true) {
          setState(() {
            print('--- getReservationList API - True');
            for (var reservation in response['reservation_list']) {
              _reservationList.add(ReservationModel(
                  reservation['reservation_id'],
                  reservation['user_id'],
                  reservation['charger_type'],
                  reservation['book_date'],
                  reservation['time_slot'],
                  reservation['station_id'],
                  reservation['amount'],
                  reservation['station_name'],
                  reservation['station_image'],
                  reservation['is_redirect_scan'],
                  reservation['is_cancel_redirect'],
                  reservation['stime']));
            }
          });
        } else if (response['status'] == 'timeout') {
          Navigator.pop(context);
          showDialog1('Timeout', 'Poor Internet connection please try again!');
        } else {
          setState(() {
            _enabled = false;
          });
        }
      });
    } else {
      setState(() {
        _enabled = false;
      });
      return showDialog(
          context: context,
          builder: (context) {
            return NetworkInfo(
              title: 'Ooops! Something went wrong',
            );
          });
    }
  }

  showDialog1(title, msg) {
    return showDialog(
      context: context,
      builder: (_) => FunkyOverlay(
        title: title,
        msg: msg,
      ),
    );
  }
}
