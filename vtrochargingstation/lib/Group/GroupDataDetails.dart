/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/Animation/DelayedAimation.dart';
import 'package:vtrochargingstation/GoogleMapData/scanQR.dart';
import 'package:vtrochargingstation/Group/GroupAddBalance.dart';
import 'package:vtrochargingstation/Group/GroupInformation.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/Invoice/Invoice.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/Group/GroupHistoryModel.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class GroupDataDetails extends StatefulWidget {
  @override
  _GroupDataDetailsState createState() => _GroupDataDetailsState();
}

class _GroupDataDetailsState extends State<GroupDataDetails> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = new AppTheme();
  APICall apiCall = APICall();

  List<GroupHistoryModel> _groupList = new List<GroupHistoryModel>();
  bool _enabled = true;

  /// month picker
  DateTime selectedDate ;
  static int page = 0;

  String strImage = '', selectedMonth = '';

  /// pagination
  ScrollController _sc = new ScrollController();

  ///drop down declaration

  List<FilterList> _companies = FilterList.getCompanies();
  List<DropdownMenuItem<FilterList>> _dropdownMenuItems;
  FilterList _selectedCompany;

  List<DropdownMenuItem<FilterList>> buildDropdownMenuItems(List companies) {
    List<DropdownMenuItem<FilterList>> items = List();
    for (FilterList company in companies) {
      items.add(
        DropdownMenuItem(
          value: company,
          child: Text(company.name),
        ),
      );
    }
    return items;
  }
  onChangeDropdownItem(FilterList selectedCompany) {

    _selectedCompany = selectedCompany;
    print(_selectedCompany.name);

    if(_selectedCompany.id == 1){
      FToast.show('by name');
      setState(() {
        _groupList.sort((a, b) => a.userName.compareTo(b.userName));
      });
      getHistory();
    }else if(_selectedCompany.id == 2){

      FToast.show('low to high [2. amount]');
      setState(() {
        _groupList.sort((a, b) => a.amount.compareTo(b.amount));
      });
      getHistory();

    }else if(_selectedCompany.id == 3) {
      FToast.show('high to low [3. energy]');
      setState(() {
        _groupList.sort((a, b) => b.amount.compareTo(a.amount));
      });
      getHistory();


    }
  }

  @override
  void initState() {
    super.initState();

    selectedDate = DateTime.now();
    _dropdownMenuItems = buildDropdownMenuItems(_companies);

    userGroupHistory();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        userGroupHistory(); //pagination
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      ///UI
      body: Stack(
        children: [
          SafeArea(
            child: Column(
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
                      child: Text(FlutterApp.groupName,
                          style: utils.textStyleRegular(context, 54, AppTheme.text1, FontWeight.normal, 0.0, '')),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Group Balance', style: utils.textStyleRegular(context, 42, AppTheme.text1, FontWeight.w500, 0.0, '')),
                      Text(FlutterApp.groupBalance == 0 ? '₹0' : '₹' +
                          FlutterApp.groupBalance.toStringAsFixed(0),
                          style: utils.textStyleRegular(context, 42,FlutterApp.groupBalance == 0 || FlutterApp.groupBalance < 50 ?
                          AppTheme.red : AppTheme.text1, FontWeight.w500, 0.0, '')),
                    ],
                  ),
                ),
                Image.asset('images/line.png'),

                Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: h/17,
                          width: w/3.2,
                          margin: EdgeInsets.symmetric(horizontal: h/40), // horizontal = width, vertical = kiti varun khali

                          child: NeumorphicButton(
                            onPressed: (){
                              showMonthPicker(
                                context: context,
                                firstDate: DateTime(DateTime.now().year - 1, 5),
                                lastDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
                                initialDate: selectedDate,
                                locale: Locale("en"),
                              ).then((date) {
                                if (date != null) {
                                  setState(() {
                                    selectedDate = date;
                                    page = 0;
                                    selectedMonth = selectedDate.month.toString();
                                    print(selectedDate.month);
                                  });
                                }else{
                                  //    FToast.show("message");
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

                                Text('Month', style:utils.textStyleRegular4(context, FontWeight.w400)),

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
                            hint: Text("Filter",style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,'')),
                            value: _selectedCompany,
                            //      value: counterBloc.mealValue,
                            items: _dropdownMenuItems,
                            style: utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w400, 0.0,''),
                            onChanged: onChangeDropdownItem,
                          ),
                        ),
                      ),
                    ),

                    PopupMenuButton(
                      itemBuilder: (BuildContext bc) => [
                        PopupMenuItem(child: Text("Scan QR"), value: "1"),
                        PopupMenuItem(child: Text("Group info"), value: "2"),
                        PopupMenuItem(child: Text("Add Balance"), value: '3'),
                        PopupMenuItem(child: Text("Mute Notifications"), value: "4"),
                      ],
                      onSelected: (route) {
                        print(route);
                        if(route == '1'){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ScanQR('', 'group', '', '')));
                        }else if(route == '2'){
                          // Note You must create respective pages for navigation
                          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupInformation()));
                        }
                        else if(route == '3'){
                          // Note You must create respective pages for navigation
                          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupAddBalance()));
                        }
                        else{
                          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.upcoming);
                        }
                      },
                    ),
                  ],
                ),
                getHistory(),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// API
  void userGroupHistory() {
    apiCall.groupHistory().then((response) {

      if(response['status'] == true){
        setState(() {
          for (var group in response['group_list']) {
            _groupList.add(GroupHistoryModel(group['id'], group['user_id'], group['type'],
              group['request_id'],group['user_name'],group['amount'], group['created_on'],
                group['station_image'], group['station_name'], group['start_date'], group['energy_consume']));
          }
        });
      }
      else{
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'No more data');
        setState(() {
          _enabled = false;
        });
      }
    });
  }

  /// group history - UI
  getHistory() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Flexible(
      child: DelayedAimation(
        child: Container(
     //     height: h/3,
          width: w,
          child: ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: _groupList.length > 0 ? ListView.builder(
                controller: _sc,
                scrollDirection: Axis.vertical,
                itemCount: _groupList.length,
                itemBuilder:(context, index) {

                  return GestureDetector(
                    onTap: (){

                      FlutterApp.requestId = _groupList[index].requestId;
                      print(_groupList[index].type);
                      if(_groupList[index].type == 'Credit'){

                      }else{
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Invoice('history')));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: _groupList[index].type == 'Debit' ? Neumorphic(

                        style: NeumorphicStyle(
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                          color: AppTheme.background,
                          depth: 5,
                          intensity: 0.99, //drop shadow
                          shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                          shadowLightColor: Colors.white,  // upper top shadow
                          //    surfaceIntensity: 0.20, // no use

                        ),

                        child:  Padding(
                          padding: const EdgeInsets.all(15.0),
                          child:

                          Stack(
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(_groupList[index].stationImage, height: h/13,
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
                                    child: Text(_groupList[index].stationName,
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
                                    Text(_groupList[index].userName,
                                        style:utils.textStyleRegular4(context, FontWeight.w400)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [

                                        Text(_groupList[index].amount,
                                            style:utils.textStyleRegular4(context, FontWeight.w400)),
                                      ],
                                    ),
                                    Text(_groupList[index].energyConsume + 'kwh',
                                        style:utils.textStyleRegular4(context, FontWeight.w400)),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ) :

                      Container(
                          color: AppTheme.greenShade2,
                          child: Center(child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(_groupList[index].userName + ' added ₹' + _groupList[index].amount + ' in group',
                                style:utils.textStyleRegular4(context, FontWeight.w400)),
                          ))),
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
               //       child: Container(color: Colors.green,),
                    ),
                  ),

                  ListView.builder(
                    itemCount: 5,
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
}

/// static list class
class FilterList {
  int id;
  String name;

  FilterList(this.id, this.name);

  static List<FilterList> getCompanies() {
    return <FilterList>[
      FilterList(1, 'By Name'),
      FilterList(2, 'Low to high'),
      FilterList(3, 'High to Low'),
    ];
  }
}