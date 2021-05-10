/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/Booking/BookingPaymentOptions.dart';
import 'package:vtrochargingstation/InternetConnectivity/network_info.dart';
import 'package:vtrochargingstation/charging/paymentOptions.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/Reservation/BookReservationList.dart';
import 'package:vtrochargingstation/models/Reservation/TimeSlot.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:shimmer/shimmer.dart';

class BookSlot extends StatefulWidget {

  String stationId;

  BookSlot(this.stationId);

  @override
  _BookSlotState createState() => _BookSlotState();
}

class _BookSlotState extends State<BookSlot> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Book> _dateList = new List<Book>();
  List<TimeSlot> _timeList = new List<TimeSlot>();

  APICall apiCall = APICall();
  AppTheme utils = AppTheme();
  bool _enabled = true, disabledButton = true;

  Color greenShade1 = Color(0xFFE8E8EA);
  List<bool> isHighlightedDate = [];       /// used in [select date] for list selection purpose
  List<bool> isHighlightedTimeSlot = [];  /// used in [select date] for list selection purpose

  /// radio
  TextEditingController nameController = TextEditingController();
  int _radioValue1 = 0;
  String img = 'images/radioUnselected.png';
  double unselectedDepth = -5;
  double selectedDepth = 5;

  String chargerType = 'Normal';
  String bookingDate = '', timeSlot = '', statusOfStation='';

  /// radio button callback method
  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue1 = value;

      if(_radioValue1 == 0){
        chargerType = 'Normal';
      }else{
        chargerType = 'Fast';
      }

      switch (_radioValue1) {
        case 0:
          print(_radioValue1);
          isHighlightedDate = [];
          getByDate();
          break;
        case 1:
          print(_radioValue1);
          isHighlightedDate = [];
          getByDate();
          break;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    getByDate();
    super.initState();
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
                      padding: EdgeInsets.only(left: w / 3.5),
                      child: Text('Book',
                          style: utils.textStyleRegular1(context, FontWeight.normal)),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.only(left:w/15.0, right: w/20, bottom: h/50, top: h/60),
                  child: Text('Select Charger Type', style:utils.textStyleRegular1(context ,FontWeight.w400)),
                ),

                Padding(
                  padding: EdgeInsets.only(left:w/15.0, right: w/20),
                  child: Row(
                    children: [
                      NeumorphicRadio(
                        child: Image.asset(img, height: 10),
                        groupValue: _radioValue1,  //0
                        onChanged: (int value){
                          print(value);
                          setState(() {
                            _radioValue1 = value;
                            print(_radioValue1);
                            _handleRadioValueChange(value);
                          });
                        },
                        padding: const EdgeInsets.all(10.0), // size of radio button
                        value: 0,
                        style: NeumorphicRadioStyle(
                          intensity: 0.7,
                          unselectedDepth: unselectedDepth,
                          selectedDepth: selectedDepth,
                          selectedColor: AppTheme.greenShade1,
                          unselectedColor: AppTheme.background,

                          boxShape: NeumorphicBoxShape.circle(),

                        ),
                      ),
                      SizedBox(width: w/40),
                      Image.asset('images/normal.png', height: h/45,),
                      SizedBox(width: w/40),
                      Text('Normal', style: utils.textStyleRegular3(context, FontWeight.w300)),

                      SizedBox(width: w/10),

                      NeumorphicRadio(
                        child: Image.asset(img, height: 10,),
                        groupValue: _radioValue1,  //1
                        onChanged: (int value){
                          setState(() {
                            _radioValue1 = value;
                            print(_radioValue1);

                          });
                          _handleRadioValueChange(value);
                        },
                        padding: const EdgeInsets.all(10.0),
                        value: 1,
                        style: NeumorphicRadioStyle(
                          intensity: 0.7,
                          unselectedDepth: unselectedDepth,
                          selectedDepth: selectedDepth,
                          selectedColor: AppTheme.greenShade1,
                          unselectedColor: AppTheme.background,
                          boxShape: NeumorphicBoxShape.circle(),
                        ),
                      ),

                      SizedBox(width: w/40),
                      Image.asset('images/turbo.png', height: h/40,),
                      SizedBox(width: w/40),
                      Text('Fast', style: utils.textStyleRegular3(context, FontWeight.w300)),
                    ],
                  ),
                ),

                SizedBox(height: h/70,),

                Padding(
                  padding: EdgeInsets.only(left:w/20.0, right: w/20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(left:w/30.0),
                        child: Text('Select Date', style:utils.textStyleRegular1(context ,FontWeight.w400)),
                      ),

                      SizedBox(height: h/50,),

                      getDateCalender(),

                      SizedBox(height: h/50,),
                      Padding(
                        padding:  EdgeInsets.only(left:w/30.0),
                        child: Text('Select Time Slot', style:utils.textStyleRegular1(context ,FontWeight.w400)),
                      ),

                      SizedBox(height: h/50,),
                      getTimeSlot(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                   //       Image.asset('images/infoIcon.png', height: h/15,), //infoIcon

                          Container(

                            child: NeumorphicButton(
                              onPressed: (){
                              },
                              style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.circle(),
                                color: AppTheme.background,
                                depth: 5,
                                surfaceIntensity: 0.20,
                                intensity: 0.99, //drop shadow
                                shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                                shadowLightColor: Colors.white,  // upper top shadow

                              ),

                              child: Image.asset(
                                'images/iIcon.png',
                                height: h/50,
                                width: h/50,
                              ),
                            ),
                          ),
                     //     SizedBox(width: w/80),
                          Flexible(
                              child:
                               Text('To book a time slot will cost ₹500, but it’ll be adjusted against final invoice',
                                   style:utils.textStyleRegular4(context,FontWeight.w400))),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h/30),

                Image.asset('images/line.png'),

                ///RESERVE button
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: h/80),
                      child: Container(
                        height: h/14,
                        margin: EdgeInsets.symmetric(horizontal: h/15),

                        child: AbsorbPointer(
                          absorbing: disabledButton,
                          child: NeumorphicButton(
                            onPressed: (){
                              reserveBooking();
                            },

                            style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                color: AppTheme.background,
                                depth: 5,
                                surfaceIntensity: 0.20,
                                intensity: disabledButton == true ? 0.50 : 0.95,
                                shadowDarkColor: AppTheme.bottomShadow,  //outer bottom shadow
                                shadowLightColor: Colors.white  // outer top shadow
                            ),

                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Text('RESERVE', style: utils.textStyleRegular(context, 50, disabledButton == true ? AppTheme.buttonDisabled :
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
          ],
        ),
      ),
    );
  }

  /// 7 days date - design
  getDateCalender() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      height: h/7,
      width: w,
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: _dateList.length > 0 ? ListView.builder(

            scrollDirection: Axis.horizontal,
            itemCount: _dateList.length,
            itemBuilder:(context, index) {

              print('Checking akshay');
              print(_dateList[index].time);

              return GestureDetector(
                onTap: (){
                  setState(() {
                    isHighlightedTimeSlot = [];
                  });

                  for(int i = 0; i < isHighlightedDate.length; i++){
                    setState(() {
                      if (index == i) {
                        isHighlightedDate[index] = true;
                      } else {                               //the condition to change the highlighted item
                        isHighlightedDate[i] = false;
                      }
                    });
                  }
                  setState(() {
                    bookingDate = _dateList[index].currentDate;
                  });

                  print('Date:::' + bookingDate);
                  getTimeSlotApi(_dateList[index].currentDate);

                },
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Neumorphic(

                    style: NeumorphicStyle(

                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                      color: isHighlightedDate[index] ? AppTheme.greenShade2 : AppTheme.background,
                      depth: isHighlightedDate[index] ? -5 : 5,
                      intensity: 0.89, //drop shadow
                      shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                      shadowLightColor: Colors.white,  // upper top shadow
                    ),

                    child: Container(
                      width: w/4.5,
                      //color: greenShade1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_dateList[index].date,
                                overflow: TextOverflow.ellipsis, maxLines: 1,
                                style:utils.textStyleRegular(context,55, AppTheme.text1,FontWeight.w700, 0.0,'')),
                            Text(_dateList[index].day,
                                style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
                          ],
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

  /// UI time - design widget
  getTimeSlot() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      height: h/4,
      width: w,
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: GridView.builder(

          itemCount: _timeList.length,
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / 5),
            crossAxisCount: 3,
            crossAxisSpacing: 15.0, // middle space
            mainAxisSpacing: 15.0,
          ),
          itemBuilder: (BuildContext context, int index){

            return GestureDetector(
              onTap: () {
                print(_timeList.length);

                setState(() {
                  timeSlot = _timeList[index].timeSlot;
                  statusOfStation = _timeList[index].status;
                });

                for(int i = 0; i < isHighlightedTimeSlot.length; i++){
                  setState(() {
                    if (index == i) {
                      disabledButton = false;
                      isHighlightedTimeSlot[index] = true;
                    } else {                               //the condition to change the highlighted item
                      isHighlightedTimeSlot[i] = false;
                    }
                  });
                }
              },
              child: Neumorphic(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                  color: isHighlightedTimeSlot[index] ? AppTheme.greenShade2 : AppTheme.background,
                  depth: isHighlightedTimeSlot[index] ? -5 : 5,
                  intensity: 0.89, //drop shadow
                  shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                  shadowLightColor: Colors.white,  // upper top shadow
                ),
                child: Container(
            //      color: AppTheme.background,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_timeList[index].timeSlot,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style:utils.textStyleRegular(context, 54 , _timeList[index].status == 'busy' ? AppTheme.text2 : AppTheme.text1,FontWeight.w700, 0.0,'')),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );


  }

  /// init state [book date] API
  void getByDate() async{
    _dateList.clear();

    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {
      apiCall.getBooking(widget.stationId, chargerType).then((response) {

        print('date_check');
        print(response);

        if(response != null){
          if(response['status'] == true){
            getTimeSlotApi(response['schedule_list'][0]['current_date']);

            setState(() {
              print('---by date API - True');

              for (var book in response['schedule_list']) {
                _dateList.add(Book(book['date'], book['day'], book['current_date'], book['time_slot']));
                isHighlightedDate.addAll([false]);
              }
              setState(() {
                isHighlightedDate.insert(0, true);
              });

            });

          }

          else{
            ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'http response - false');
            print('---by date API - false');
          }
        }else{
          Navigator.pop(context);
          FToast.show('backend date issue!');
        }
      });
    }else{
      Navigator.pop(context);
      noInternetDialog();
    }
  }

  /// API - getTimeSlot
  void getTimeSlotApi(currentDate) async{
    _timeList.clear();

    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {
      apiCall.getTimeSlot(widget.stationId, currentDate, chargerType).then((response) {

        if(response['status'] == true){
          setState(() {
            print('---getTimeSlot API - True');

            for (var time in response['schedule_list'][0]['time_slot']) {
              _timeList.add(TimeSlot(time['time_slot'], time['status']));
              isHighlightedTimeSlot.addAll([false]);
            }
            setState(() {
              isHighlightedTimeSlot.addAll([false]);
            });
          });
        }else{
          print('---by date API - false');
        }
      });
    }else{
      noInternetDialog();
    }
  }

  /// on click of reserve button
  void reserveBooking() {

    if(bookingDate.isEmpty){
      bookingDate = _dateList[0].currentDate;
    }
    if(timeSlot.isEmpty){

      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select time slot');
    }else if(statusOfStation == 'busy'){
      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Dear user, station is already booked');
    }
    else{
      Navigator.pop(context);
      if(chargerType == 'Normal'){

        print('FlutterApp.reservationNormalCoast');
        print(FlutterApp.reservationNormalCoast);

        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            BookingPaymentOptions(FlutterApp.reservationNormalCoast, 0.0, chargerType, bookingDate, timeSlot, widget.stationId)));
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            BookingPaymentOptions(FlutterApp.reservationFastCoast, 0.0, chargerType, bookingDate, timeSlot, widget.stationId)));
      }
    }

    print('params..' + bookingDate);
    print(timeSlot);
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
