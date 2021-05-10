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
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/InternetConnectivity/network_info.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/Invoice/Invoice.dart';
import 'package:vtrochargingstation/VtroPlans/PreviousPlanDetails.dart';
import 'package:vtrochargingstation/VtroPlans/RechargePlans.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/MyPlans.dart';
import 'package:vtrochargingstation/models/Plans.dart';
import 'package:vtrochargingstation/models/bikeInformation.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class VTroPlans extends StatefulWidget {
  @override
  _VTroPlansState createState() => _VTroPlansState();
}

class _VTroPlansState extends State<VTroPlans> with SingleTickerProviderStateMixin{

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = AppTheme();
  int index = 0;

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Our Plans'),
    Tab(text: 'Your Plans'),
  ];

  TabController _tabController;

  bool loading = false;
  bool activePlanVisibility = true;
  bool activePlanDetails = true;

  ///drop down declaration

  List<PlansDropdownList> _companies = PlansDropdownList.getCompanies();
  List<DropdownMenuItem<PlansDropdownList>> _dropdownMenuItems;
  PlansDropdownList _selectedCompany;

  bool _enabled = true;
  bool _loading = false;

  int val = 1;

  APICall apiCall = new APICall();
  String pkgCheckList ='', planCheckList='', remainingWatt = '';

  List<PlansModel> _plansList = new List<PlansModel>();
  List<MyPlans> _myPlansList = new List<MyPlans>();
  List<MyPlansDetails> _myPlansDetailList = new List<MyPlansDetails>();

 // List<BikeInformationModel> _bikeList = new List<BikeInformationModel>();
  List _bikeList = new List();
  String _bikeName;

  /// pagination
  ScrollController _sc = new ScrollController();
  static int page = 0;

  List<DropdownMenuItem<PlansDropdownList>> buildDropdownMenuItems(List companies) {
    List<DropdownMenuItem<PlansDropdownList>> items = List();
    for (PlansDropdownList company in companies) {
      items.add(
        DropdownMenuItem(
          value: company,
          child: Text(company.name),
        ),
      );
    }
    return items;
  }
  onChangeDropdownItem(PlansDropdownList selectedCompany) {

      _selectedCompany = selectedCompany;
      print(_selectedCompany.name);

      if(_selectedCompany.id == 1){
        setState(() {
          page = 0;
          activePlanDetails = true;
        });

        getActivePlans();
      }else if(_selectedCompany.id == 2){

        setState(() {
          page = 0;
          activePlanDetails = false;
        });

        getUpcomingPlans();

      }else if(_selectedCompany.id == 3){
        setState(() {
          page = 0;
          activePlanDetails = false;
        });
        getPreviousPlans();
      }
  }

  @override
  void initState() {

    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _dropdownMenuItems = buildDropdownMenuItems(_companies);
    getBikeList();

    getPlans();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        getActivePlans();  //pagination
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Colors.green,
        size: 50,
      ),
      dismissible: false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        key: _scaffoldKey,
        appBar: AppBar(

          automaticallyImplyLeading: false,

          title: Padding(
            padding: EdgeInsets.only(left:w/4),
            child: Text('Vtro Plans', style: utils.textStyleRegular(context,45, AppTheme.text1,FontWeight.normal, 0.0,'')),
          ),

          leading: InkWell(
            onTap: (){
              Navigator.pop(context);
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfile()));
            },
            child: CircularSoftButton(
              radius: 20,
              icon: Padding(
                padding: EdgeInsets.only(left: h/90),
                child: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87,),
              ),
            ),
          ),

          backgroundColor: AppTheme.background,
          bottom: TabBar(
            controller: _tabController,
            indicatorWeight: 5,
            indicatorColor: AppTheme.tabLine,
            labelColor: AppTheme.text1,
            labelStyle: TextStyle(fontSize: h/50,fontFamily: 'Sofia_Pro_Regular'),
            unselectedLabelColor: AppTheme.text4,
            unselectedLabelStyle: TextStyle(fontSize: h/50,fontFamily: 'Sofia_Pro_Regular'),
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ourPlansFirstTab(),
            yourPlanSecondTab(h),
          ],
        ),
      ),
    );
  }

  /// first Tab - Our plans
  ourPlansFirstTab() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: EdgeInsets.only(top:h/50, left: w/20, bottom: h/90),
          child: Text('Guidance', style:utils.textStyleRegular(context,50, AppTheme.text1,FontWeight.w400, 0.0,'')),
        ),
        guidanceList(),
        SizedBox(height: h/70),

        /// bike drop-down widget
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Padding(
              padding: EdgeInsets.only(top:h/50, left: w/20, bottom: h/90),
              child: Text('Plans For You', style:utils.textStyleRegular(context,50, AppTheme.text1,FontWeight.w400, 0.0,'')),
            ),

            Visibility(
              visible: _bikeList.length > 1 ? true : false,
              child: Padding(
                padding: EdgeInsets.only(right: w/30),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -7,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),  // side border
                    shadowDarkColorEmboss: AppTheme.bottomShadow,  //  inner top shadow
                    shadowLightColorEmboss: Colors.white, // inner bottom shadow
                    disableDepth: false,
                    surfaceIntensity: 5,
                    color: AppTheme.background,
                    shape: NeumorphicShape.convex,
                    intensity: 0.99,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            dropdownColor: Colors.deepOrangeAccent[50],
                            value: _bikeName,
                            iconSize: h/30,
                            icon: Icon(Icons.keyboard_arrow_down),
                            style:utils.textStyleRegular4(context, FontWeight.w400),
                            hint: Text('Select Bike',
                                style:utils.textStyleRegular4(context, FontWeight.w400)),
                            onChanged: (String newValue) {
                              setState(() {
                                _bikeName = newValue;
                                print('...');
                                print(_bikeName);
                              });
                            },
                            items: _bikeList?.map((item) {
                              return new DropdownMenuItem(
                                child: new Text(item['bike_name'] + ' ' +item['bike_kw'] + 'KW'),
                                value: item['bike_name'].toString(),
                              );
                            })?.toList() ??
                                [],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        Flexible(
          child: Container(
            width: w,
            child: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: _plansList.length > 0 ? ListView.builder(

                  scrollDirection: Axis.vertical,
                  itemCount: _plansList.length,
                  itemBuilder:(context, index) {

                    return  Padding(
                      padding: EdgeInsets.only(left: w/20, right: w/20, top: h/70, bottom: h/70),
                      child: NeumorphicRadio(
                        onChanged: (index1){
                          print('tap');
                          print(index);

                         if(_bikeList.length > 2){
                           if(_bikeName == null){
                             ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select your bike');
                           }
                           else{
                             Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                 RechargePlans(_plansList[index].planCharges, _plansList[index].planEnergy,
                                     int.parse(_plansList[index].planPrice), _plansList[index].planId)));
                           }
                         }else{
                           Navigator.push(context, MaterialPageRoute(builder: (context) =>
                               RechargePlans(_plansList[index].planCharges, _plansList[index].planEnergy,
                                   int.parse(_plansList[index].planPrice), _plansList[index].planId)));
                         }
                        },
                        style: NeumorphicRadioStyle(

                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                          intensity: 0.70, //drop shadow
                        ),
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

                          child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
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

                                    //    border: Border.all(),
                                  ),


                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      Text(_plansList[index].planCharges, style:utils.textStyleRegular(context,40, AppTheme.text1,FontWeight.w700, 0.0,'')),
                                      Text('Charges', style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),

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
                                      Text(_plansList[index].planEnergy, style:utils.textStyleRegular(context,40, AppTheme.text1,FontWeight.w400, 0.0,'')),
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
                                  height: h/15,
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

                                      Text('₹ ' + _plansList[index].planPrice, style:utils.textStyleRegular(context,40, AppTheme.text1,FontWeight.w400, 0.0,'')),
                                      Text('Pay', style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                    ],
                                  ),
                                ),

                              ),
                            ],
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

                    Padding(
                      padding: EdgeInsets.only(top: h/9),
                      child: ListView.builder(
                        itemCount: 4,
                        itemBuilder: (context, index){
                          return
                            ListTile(leading: Icon(Icons.image, size: h/10),
                              title: SizedBox(
                                height: h/9,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.red[500],
                                      ),
                                      borderRadius: BorderRadius.circular(20) // use instead of BorderRadius.all(Radius.circular(20))
                                  ),
                                ),
                              ),
                              subtitle: SizedBox(height: 5,),


                            );
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// second Tab - Your Plans
  yourPlanSecondTab(double h) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Neumorphic(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
              color: AppTheme.background,
              depth: 5,
              intensity: 0.99, //drop shadow
              shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
              shadowLightColor: Colors.white,  // upper top shadow
              //    surfaceIntensity: 0.20, // no use
            ),

            child: Padding(
              padding: const EdgeInsets.only(left:18.0,),
              child: DropdownButton(
                underline: SizedBox(),// remove underline
                itemHeight: 50,
                focusColor: Colors.green,
                iconEnabledColor: Colors.green,
                iconSize: 30,
                icon: Icon(Icons.keyboard_arrow_down),
                dropdownColor: Colors.deepOrangeAccent[50],

                hint: Text("Active Plans",style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
                value: _selectedCompany,
                //      value: counterBloc.mealValue,
                items: _dropdownMenuItems,
                style: utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,''),

                onChanged: onChangeDropdownItem,
              ),
            ),
          ),
        ),

        /// default active plan
        Visibility(
          visible: activePlanVisibility,
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

              child: Container(
                width: w,
                  height: h/8,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _myPlansList.length,
                      itemBuilder:(context, index) {
                        return Row(
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
                                height: h/15,
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
                        );
                      }),
                )


            ),
          ),
        ),

        Visibility(
          visible: activePlanVisibility,
          child: Container(
            color: AppTheme.textBackground,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Remaining Watt',style:utils.textStyleRegular1(context, FontWeight.w400)),
                  Text(remainingWatt + 'kwh',style:utils.textStyleRegular1(context, FontWeight.w400)),
                ],
              ),
            ),
          ),
        ),

        detailsList(h),

        upcomingPlansDesign(w, h),

      ],
    );
  }

  /// active plan [detailed list] design
  Widget detailsList(double h){

    double w = MediaQuery.of(context).size.width;

    return Visibility(
      visible: activePlanDetails,
      child: Flexible(
        child: Container(
          width: w,
          child: ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: _myPlansList.length > 0 ? ListView.builder(
                controller: _sc,
                scrollDirection: Axis.vertical,
                itemCount: _myPlansDetailList.length,
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

                      child:  GestureDetector(
                        onTap: (){
                          FlutterApp.requestId = _myPlansDetailList[index].requestId;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Invoice('own_plan')));
                        },

                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child:
                          Stack(
                            children: [
                              Row(
                                children: [
                                  //Image.network(_myPlansDetailList[index].stationImage, height: h / 15,),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(_myPlansDetailList[index].stationImage, height: h/15,
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
                                    child: Text(_myPlansDetailList[index].stationName,
                                        maxLines: 3,
                                        style:utils.textStyleRegular(context,56, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                  )),
                                ],
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  children: [
                                    Text(_myPlansDetailList[index].date, style:utils.textStyleRegular(context,55, AppTheme.text4,FontWeight.w400, 0.0,'')),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(_myPlansDetailList[index].perRequest + ' kwt', style:utils.textStyleRegular(context,55, AppTheme.text1,FontWeight.w400, 0.0,'')),
                                    ),
                                    Text(_myPlansDetailList[index].energyConsume.toString(), style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
      ),
    );
  }

  /// API - plans
  void getPlans() async{

    setState(() {
      activePlanVisibility = true;
    });

    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {
      apiCall.getPlans().then((response) {

        if(response['status'] == true){
          if (!mounted) return;
          setState(() {
            for (var plan in response['plan_list']) {
              _plansList.add(PlansModel(plan['plan_id'], plan['plan_energy'], plan['plan_price'], plan['plan_charges']));
            }
          });
          getActivePlansInit();

        }else{
          if (!mounted) return;
          setState(() {
            _enabled = false;
          });
        }
      });
    }else{
      noInternetDialog();
    }
  }

  /// call only for initially - if no plan then it gets issue so new function added
  void getActivePlansInit() async{

    clear();

    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {
      apiCall.getMyPlans('active', page).then((response) {

        if (mounted) {
          setState(() {

            _enabled = false;
          });
        }
        if(response['status'] == true){

          remainingWatt = response['your_plan'][0]['remaining_energy'];

          if (!mounted) return;
          setState(() {
            for (var plan in response['your_plan']) {
              _myPlansList.add(MyPlans(plan['plan_id'], plan['plan_energy'], plan['plan_price'],
                  plan['consume_energy'], plan['remaining_energy'], plan['plan_charges'], plan['recharge_on'], plan['sub_id']));
            }

            /// empty array condition []
            var array = response['your_plan'][0]['request_history'];
            if(array.length == 0){
              print('array 0');
            }else{
              for (var plan in response['your_plan'][0]['request_history']) {
                _myPlansDetailList.add(MyPlansDetails(plan['station_name'], plan['station_image'], plan['date'],
                    plan['percentage_request'], plan['energy_consume'],plan['request_id'] ));
              }
            }
          });
          print('---get [own] plans API - True');

        }else{
          setState(() {
            activePlanVisibility = false;
          });
          print('-- [own] plan API - False');
        }
      });
    }else{
      noInternetDialog();
    }
  }

  ///  --- 1st ActivePlans ---
  void getActivePlans() async{

    clear();

    apiCall.getMyPlans('active', page).then((response) {

      if (!mounted) return;
      setState(() {
        _loading = false;
      });

      if(response['status'] == true){

        remainingWatt = response['your_plan'][0]['remaining_energy'];

        if (!mounted) return;
        setState(() {
          for (var plan in response['your_plan']) {
            _myPlansList.add(MyPlans(plan['plan_id'], plan['plan_energy'], plan['plan_price'],
                plan['consume_energy'], plan['remaining_energy'], plan['plan_charges'], plan['recharge_on'], plan['sub_id']));
          }

         /* for (var plan in response['your_plan'][0]['request_history']) {
            _myPlansDetailList.add(MyPlansDetails(plan['station_name'], plan['station_image'], plan['date'],
                plan['percentage_request'], plan['energy_consume'] ));
          }*/



          /// empty array condition []
          var array = response['your_plan'][0]['request_history'];
          if(array.length == 0){
            ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'No more data found!');
            print('array 0');
          }else{
            for (var plan in response['your_plan'][0]['request_history']) {
              _myPlansDetailList.add(MyPlansDetails(plan['station_name'], plan['station_image'], plan['date'],
                  plan['percentage_request'], plan['energy_consume'], plan['request_id'] ));
            }
          }


        });
        print('---get [own] plans API - True');

      }else{
        if (!mounted) return;
        setState(() {
          _enabled = false;
          activePlanVisibility = false;
        });
        print('-- [own] plan API - False');
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'No data found');
      }
    });
  }

  ///  --- 2nd UpcomingPlans ---
  void getUpcomingPlans() {

    clear();
    _myPlansList.clear();
    setState(() {
      activePlanVisibility = false;
    });

    apiCall.getMyPlans('upcoming', page).then((response) {
      if(response['status'] == true){

        setState(() {

          for (var plan in response['your_plan']) {
            _myPlansList.add(MyPlans(plan['plan_id'], plan['plan_energy'], plan['plan_price'],
                plan['consume_energy'], plan['remaining_energy'], plan['plan_charges'], plan['recharge_on'], plan['sub_id']));
          }
        });
        print('-- [getUpcomingPlans] plans API -> True');

      }else{
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'No data found');
        setState(() {
          _loading = false;
          _enabled = false;
        });
        print('-- [getUpcomingPlans] -> False');
      }
    });
  }

  ///  --- 3rd getPreviousPlans ---
  void getPreviousPlans() {
    clear();
    _myPlansList.clear();
    setState(() {
      activePlanVisibility = false;
    });

    apiCall.getMyPlans('previous', page).then((response) {

      if(response['status'] == true){

        setState(() {
          for (var plan in response['your_plan']) {
            _myPlansList.add(MyPlans(plan['plan_id'], plan['plan_energy'], plan['plan_price'],
                plan['consume_energy'], plan['remaining_energy'], plan['plan_charges'], plan['recharge_on'], plan['sub_id']));
          }
        });
        print('---get previous plans API -> True');
        print(response);

      }else{
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'No data found');
        setState(() {
          _loading = false;
          _enabled = false;
        });
        print('-- previous plans API -> False');
      }
    });
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
            // itemCount: _planList.length,
            itemCount: 5,
            itemBuilder:(context, index) {

              return Padding(
                padding: EdgeInsets.only(left: w/20, right: w/70, top: h/70, bottom: h/70),
                child: Neumorphic(

                  style: NeumorphicStyle(

                    color: AppTheme.blueShade1,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                    depth: 4,
                    intensity: 0.99, //drop shadow
                    shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                    shadowLightColor: Colors.white,  // upper top shadow
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: w/30, right: w/30,),
                        child: Text('Charge until \nenergy consume',style:utils.textStyleRegular1(context, FontWeight.w400)),
                      ),
                    ],
                  ),
                ),
              );

            }),
      ),
    );
  }

  /// upcoming / previous plan UI
  upcomingPlansDesign(double w, double h){
    return Visibility(
      visible: activePlanDetails == true ? false : true,
      child: Flexible(
        child: Container(
          width: w,
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
                        child: Text('Recharged on : ' + _myPlansList[index].date  ,style:utils.textStyleRegular4(context, FontWeight.w400)),
                      ),

                      GestureDetector(
                        onTap: (){
                          if(_selectedCompany.id == 3){
                            print('previous plan tap::');
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PreviousPlanDetails(_myPlansList[index].subId)));
                          }else{
                            print('else');
                          }
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
                                    height: h/15,
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

                : _enabled == true ?  Shimmer.fromColors(
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
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    page = 0;
    _sc.dispose();
    super.dispose();
  }

  /// API - get user bike list
  void getBikeList() async{
    _bikeList.clear();

    apiCall.getProfile().then((response) {

      if(response['status'] == true){

        if (mounted) {
          setState(() {
            _bikeList = response['bike_name'];
          });
        }


      }else{
        print('---edit profile API -> False');
        print('status - false');
      }
    });
  }

  clear(){
    setState(() {
      page++;
    });

    print('page count::::');
    print(page);

    if (page == 1) {
      setState(() {
        _myPlansList.clear();
        _myPlansDetailList.clear();
      });
    }else{
      setState(() {
        _loading = true;
      });
    }
 //   _myPlansList.clear();
    setState(() {
      activePlanVisibility = true;
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

/// static dropdown list of plans option
class PlansDropdownList {
  int id;
  String name;

  PlansDropdownList(this.id, this.name);

  static List<PlansDropdownList> getCompanies() {
    return <PlansDropdownList>[
      PlansDropdownList(1, 'Active Plans'),
      PlansDropdownList(2, 'Upcoming plans'),
      PlansDropdownList(3, 'Previous plans'),
    ];
  }
}