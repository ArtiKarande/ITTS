/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/Animation/DelayedAimation.dart';
import 'package:vtrochargingstation/History/history.dart';
import 'package:vtrochargingstation/InternetConnectivity/network_info.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/Invoice/Invoice.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/dialog/FunkeyOverlay.dart';
import 'package:vtrochargingstation/models/HistoryModel.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class HistoryView extends HistoryState{

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = AppTheme();
  bool _loading = false;
  APICall apiCall = APICall();
  List<HistoryModel> _historyList = new List<HistoryModel>();
  bool _enabled = true;
  String plugPoint = '' , reqPercentage = '', units = '', startTime = '',endtime = '', totalAmount = '', remainingBalance = '', startDate = '', strImage = '';

  String status = '', selectedMonth = 'Month';

  /// pagination
  ScrollController _sc = new ScrollController();
  static int page = 0;

  /// month picker
  DateTime selectedDate ;
  bool filter = false;
  String filterDate = '';

  @override
  void initState() {

    super.initState();

    selectedDate = DateTime.now();
    getHistoryApi();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        if(filter){
          monthFilterApi(filterDate);
        }else{
          getHistoryApi(); //pagination
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.0,
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
          child: Column(
            children: [

              ///Appbar
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      page = 0;
                      Navigator.pop(context);
                    },
                    child:CircularSoftButton(
                      radius: 20,
                      icon: Padding(
                        padding: EdgeInsets.only(left:h/90),
                        child: Icon(Icons.arrow_back_ios, size: 20,),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: w / 4),
                    child: Text('Your History', style: utils.textStyleRegular1(context, FontWeight.normal)),
                  ),
                ],
              ),

              Row(
                children: [
                  Container(
                    //  color: Color(0xFFF2F2F2),
                    height: h/17,
                    width: w/3.2,
                    margin: EdgeInsets.symmetric(horizontal: h/40), // horizontal = width, vertical = kiti varun khali

                    child: NeumorphicButton(
                      onPressed: (){

                        filter = true;

                        showMonthPicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 1, 5),
                          lastDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
                          initialDate: selectedDate,
                          locale: Locale("en"),

                        ).then((date) {
                          if (date != null) {

                            setState(() {
                              String formattedMonth = DateFormat('MMM').format(date);
                              print(formattedMonth);
                              selectedDate = date;
                              selectedMonth = formattedMonth;

                              page = 0;
                              filterDate = selectedDate.year.toString() + '-' + selectedDate.month.toString();
                              monthFilterApi(filterDate);

                            });
                          }else{
                          }
                        });
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

                          Text(selectedMonth, style:utils.textStyleRegular4(context, FontWeight.w400)),

                          Padding(
                            padding: const EdgeInsets.only(left:3.0),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF808080),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),

              SizedBox(height: h/40,),

              getHistory(),
          ],),
        ),
      ),
    );
  }

  /// list of list - design
  getHistory() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Flexible(
      child: DelayedAimation(
        child: Container(
          width: w,
          child: ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: _historyList.length > 0 ? ListView.builder(
                controller: _sc,
                scrollDirection: Axis.vertical,
                itemCount: _historyList.length,
                itemBuilder:(context, index) {

                  if(_historyList[index].type == '3'){
                    strImage = 'images/profile/plansIcon.png';
                    status = 'Plan';
                  }else if(_historyList[index].type == '5'){
                    strImage = 'images/profile/goldcard.png';
                    status = 'Gold';
                  }
                  else if(_historyList[index].type == '1'){
                    strImage = 'images/backgroundCircle.png';
                    status = 'N';
                  }else if(_historyList[index].type == '6'){
                    strImage = 'images/group/addMember.png';
                    status = 'Group';
                  }else if(_historyList[index].type == 'RN'){
                    strImage = 'images/bell.png';
                    status = 'RN';
                  }else if(_historyList[index].type == 'RP'){
                    strImage = 'images/radio.png';
                    status = 'RP';
                  }
                  else{
                    strImage = 'images/profile/plansIcon.png';
                  }

                  return GestureDetector(
                    onTap: (){
                      print('tap history::');
                      FlutterApp.requestId = _historyList[index].requestId;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Invoice('history')));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
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

                        child:  /*Padding(
                          padding: const EdgeInsets.all(15.0),
                          child:

                          Stack(
                            children: [
                              Row(
                                children: [

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(_historyList[index].stationImage, height: h/13,
                                      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            backgroundColor: Colors.green,
                                            value: loadingProgress.expectedTotalBytes != null ?
                                            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),


                                  SizedBox(width: w/20),

                                  Flexible(child: Padding(
                                    padding: EdgeInsets.only(right: h/6),
                                    child: Text(_historyList[index].stationId,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: utils.textStyleRegular(context, 60,
                                            AppTheme.text2, FontWeight.w400, 0.0, '')),
                                  )),
                                ],
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(_historyList[index].startdate,
                                        style:utils.textStyleRegular4(context, FontWeight.w400)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(strImage, height: h/40),
                                        SizedBox(width: w/50),
                                        Text(_historyList[index].amount,
                                            style:utils.textStyleRegular4(context, FontWeight.w400)),
                                      ],
                                    ),
                                    Text(_historyList[index].energyConsume,
                                        style:utils.textStyleRegular4(context, FontWeight.w400)),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),*/

                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 2,
                                child: Container(
                                  //  width: w/3,
                                  //  height: h/11,
                                  //   color: Colors.black26,
                                  child:  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.network(_historyList[index].stationImage, height: h/16,
                                      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            backgroundColor: Colors.green,
                                            value: loadingProgress.expectedTotalBytes != null ?
                                            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
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
                                  //            color: Colors.red.shade100,
                           //       width: w/3,
                             //     height: h/11,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(_historyList[index].stationId,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style:utils.textStyleRegular(context,60, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                    ),
                                  ),
                                ),
                              ),


                              Flexible(
                                fit: FlexFit.tight,
                                flex: 0,
                                child: Container(

                                  //      color: AppTheme.yellow1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(_historyList[index].startdate,
                                          style:utils.textStyleRegular(context,58, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                       //   Image.asset(strImage, height: h/40),
                                          SizedBox(width: w/50),
                                          Text(_historyList[index].amount,
                                              style:utils.textStyleRegular(context,58, AppTheme.text1,FontWeight.w400, 0.0,'')),
                                        ],
                                      ),
                                      Text(_historyList[index].energyConsume + 'kwh'
                                          + ' [' + status + ']',
                                          style:utils.textStyleRegular(context,58, AppTheme.text2,FontWeight.w400, 0.0,'')),

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

                }) : _enabled == true ?  Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
              enabled: _enabled,
              child: Stack(
                children: [

                  Padding(
                    padding: EdgeInsets.only(left:w/20, right: w/20),
                    child: SizedBox(
                      height: h/9.5,
                  //    child: Container(color: Colors.green,),
                     ),
                  ),

                  ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index){
                      return
                        ListTile(leading: Icon(Icons.image, size: h/10),
                          title: SizedBox(
                            height: h/10,
                            child: Container(color: AppTheme.red),
                          ),
                        );
                    },
                  ),
                ],
              ),
            ) : Center(child: Image.asset('images/noDataFound.png', height: h/3,)),
          ),
        ),
      ),
    );
  }

  /// get profile and bike list
  void getHistoryApi() async{

    setState(() {
      page++;
    });

    if (page == 1) {
      _historyList.clear();
    }else{
      setState(() {
        _loading = true;
      });
    }

    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {
      apiCall.getHistory(page).then((response) {
        setState(() {
          _loading = false;
        });

        if(response['status'] == true){
          setState(() {
            print('--- history API - True');
            for (var history in response['request_list']) {
              _historyList.add(HistoryModel(history['request_id'], history['station_image'],
                  history['station_name'], history['energy_consume'],
                  history['amount'], history['start_date'], history['start_time'], history['type']));
            }
          });
        }
        else if(response['status'] == 'timeout'){
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (_) => FunkyOverlay(
              title: 'Timeout',
              msg: 'Poor Internet connection please try again!',
            ),
          );
        }
        else{
          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'No more data');
          setState(() {
            _enabled = false;
          });
        }
      });
    }else{
      Navigator.pop(context);
      noInternetDialog();
    }

  }

  showDialog1(title, msg){
    return showDialog(
      context: context,
      builder: (_) => FunkyOverlay(
        title: title,
        msg: msg,
      ),
    );
  }

  @override
  void dispose() {

    page = 0;
    _sc.dispose();
    super.dispose();
  }

  /// filter API - month wise
  void monthFilterApi(String monthYear) async{

    setState(() {
      page++;
    });

    if (page == 1) {
      _historyList.clear();
    }else{
      setState(() {
        _loading = true;
      });
    }

    apiCall.filterHistory(page, monthYear).then((response) {
      setState(() {
        _loading = false;
      });

      if(response['status'] == true){
        setState(() {
          print('--- history API - True');
          for (var history in response['request_list']) {
            _historyList.add(HistoryModel(history['request_id'], history['station_image'], history['station_name'], history['energy_consume'],
                history['amount'], history['start_date'], history['start_time'], history['type']));
          }
        });
      }
      else if(response['status'] == 'timeout'){
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => FunkyOverlay(
            title: 'Timeout',
            msg: 'Poor Internet connection please try again!',
          ),
        );
      }
      else{
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'No more data');
        setState(() {
          _enabled = false;
        });
      }
    });
  }

  /// common internet dialog - box
  noInternetDialog() {
    setState(() {
      _enabled = false;
    });
    return showDialog(
        context: context,
        builder: (context) {
          return NetworkInfo(
            title: Messages.NO_INTERNET,
          );
        });
  }
}