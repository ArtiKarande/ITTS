/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/PreviousPlanModel.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class PreviousPlanDetails extends StatefulWidget {

  String subId;
  PreviousPlanDetails(this.subId);

  @override
  _PreviousPlanDetailsState createState() => _PreviousPlanDetailsState();
}

class _PreviousPlanDetailsState extends State<PreviousPlanDetails> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = AppTheme();
  APICall apiCall = new APICall();
  List<PreviousPlanModel> _myPlansList = new List<PreviousPlanModel>();
  bool _enabled = true;

  /// pagination
  ScrollController _sc = new ScrollController();
  static int page = 0;

  @override
  void initState() {
    // TODO: implement initState

    getPreviousPlan();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        getPreviousPlan();  //pagination
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [

                /// Appbar
                Row(
                  children: [
                    InkWell(
                      onTap: () async {

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
                      child: Text('Plan History',
                          style: utils.textStyleRegular(context, 54, AppTheme.text1, FontWeight.normal, 0.0, '')),
                    ),
                  ],
                ),

                previousPlanDesign(w, h),

                Container(
                  width: w,
                  color: AppTheme.textBackground,
                  child: Padding(
                    padding: EdgeInsets.only(left: w/ 20.0, top: h/90, bottom: h/90),
                    child: Text('Details',style:utils.textStyleRegular1(context, FontWeight.w400)),
                  ),
                ),

                detailsList(h),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// UI of previous plans
  previousPlanDesign(double w, double h){
    return Flexible(
      child: Container(
        width: w,
        height: h/5,
        child: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: _myPlansList.length > 0 ? ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _myPlansList.length,
              itemBuilder:(context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: w/20.0, bottom: h/70),
                      child: Text('Recharged on : ' + _myPlansList[index].date, style:utils.textStyleRegular4(context, FontWeight.w400)),
                    ),
                    GestureDetector(
                      onTap: (){
                      },
                      child: Padding(
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
                          child: Row(
                            children: [
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 1,
                                child: Container(
                                  height: h/8,
                                  decoration: BoxDecoration(
                                    color: AppTheme.greenShade2,
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_myPlansList[index].planCharges, style:utils.textStyleRegular(context,40, AppTheme.text1,FontWeight.w700, 0.0,'')),
                                      Text('Charges', style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 1,
                                child: Container(
                                  height: h/8,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_myPlansList[index].planEnergy + ' kwt', style:utils.textStyleRegular(context,40, AppTheme.text1,FontWeight.w400, 0.0,'')),
                                      Text('Energy', style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
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
                                  height: h/8,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('₹' +_myPlansList[index].planPrice, style:utils.textStyleRegular(context,40, AppTheme.text1,FontWeight.w400, 0.0,'')),
                                      Text('Pay', style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              })
              :  Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            enabled: _enabled,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left:w/20, right: w/20),
                  child: SizedBox(
                    height: h/9.5,
                    child: Container(color: Colors.green,),
                  ),
                ),

                ListView.builder(
                  itemCount: 9,
                  itemBuilder: (context, index){
                    return
                      ListTile(leading: Icon(Icons.image, size: h/10),
                        title: SizedBox(
                          height: h/10,
                          child: Container(color: Colors.green,),
                        ),
                      );
                  },
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  /// UI of detailed list
  Widget detailsList(double h){

    double w = MediaQuery.of(context).size.width;

    return Flexible(
      child: Container(
        width: w,
        child: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: _myPlansList.length > 0 ? ListView.builder(
              controller: _sc,
              scrollDirection: Axis.vertical,
              itemCount: _myPlansList.length,
              itemBuilder:(context, index) {

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                      color: AppTheme.background,
                      depth: 5,
                      intensity: 0.99, //drop shadow
                      shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                      shadowLightColor: Colors.white,  // upper top shadow
                    ),
                    child:  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child:
                      Stack(
                        children: [
                          Row(
                            children: [
                              Image.network(_myPlansList[index].stationImage, height: h / 15,),
                              SizedBox(width: w/20),
                              Flexible(child: Padding(
                                padding: EdgeInsets.only(right: h/6),
                                child: Text(_myPlansList[index].stationName,
                                    maxLines: 3,
                                    style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
                              )),
                            ],
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                Text(_myPlansList[index].date, style:utils.textStyleRegular(context,55, AppTheme.text4,FontWeight.w400, 0.0,'')),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(_myPlansList[index].percentageRequest + ' kwh', style:utils.textStyleRegular(context,55, AppTheme.text1,FontWeight.w400, 0.0,'')),
                                ),
                                Text(_myPlansList[index].energyConsume.toString(), style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

              }) :  _enabled == true ?  Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            enabled: _enabled,
            child: Stack(
              children: [

                Padding(
                  padding: EdgeInsets.only(left:w/20, right: w/20),
                  child: SizedBox(
                    height: h/9.5,
                    child: Container(color: Colors.green,),
                  ),
                ),

                ListView.builder(
                  itemCount: 9,
                  itemBuilder: (context, index){
                    return
                      ListTile(leading: Icon(Icons.image, size: h/10),
                        title: SizedBox(
                          height: h/10,
                          child: Container(color: Colors.green,),
                        ),
                      );
                  },
                ),
              ],
            ),
          ) : Center(child: Image.asset('images/noDataFound.png', height: h/3,)),
        ),
      ),
    );
  }

  /// API - PreviousPlan
  void getPreviousPlan() {
    setState(() {
      page++;
    });

    apiCall.getPreviousPlan(widget.subId, page).then((response) {
      if(response['status'] == true){
        setState(() {
          for (var plan in response['previous_plan']) {
            _myPlansList.add(PreviousPlanModel(plan['plan_energy'], plan['plan_price'], plan['plan_charges'], plan['consume_energy'],
              plan['recharge_on'], plan['request_history'][0]['station_name'], plan['request_history'][0]['landmark'], plan['request_history'][0]['station_image'],
              plan['request_history'][0]['date'], plan['request_history'][0]['percentage_request'], plan['request_history'][0]['energy_consume']
            ));
          }
        });
        print('---previous plan API - True');

      }else{
        setState(() {
          _enabled = false;
        });
        print('--previous plan API - False');
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
