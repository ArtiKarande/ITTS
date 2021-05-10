/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/API/api_call.dart';
import 'package:happyfoods/API/api_response.dart';
import 'package:happyfoods/Dashboard/DashboardTab.dart';
import 'package:happyfoods/bloc_pattern.dart';
import 'package:happyfoods/dialogBox/optionDialog.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/models/Plan.dart';
import 'package:happyfoods/models/Snacks.dart';
import 'package:happyfoods/models/plan_package.dart';
import 'package:happyfoods/payment/SubscriptionPayment.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionTab extends StatefulWidget {
  @override
  _SubscriptionTabState createState() => _SubscriptionTabState();
}

class _SubscriptionTabState extends State<SubscriptionTab> {
  bool isLoading = false;
  FToast utils = new FToast();

  AuthMethods _authMethods = AuthMethods();
  List<Plan> planlist = new List<Plan>();
  List<PackagePlan> packageList = new List<PackagePlan>();
  List<Snacks> snackList = new List<Snacks>();

  List<String> snackCheckList = new List<String>();
 // List<String> pkgCheckList = new List<String>();
//  List<String> planCheckList = new List<String>();
 String pkgCheckList ='', planCheckList='';


  String pkgStr = '', pkgId='', pkgCost, pkgDays;
  String planStr = '', planId='';

  String status;
  bool _loading = false, shareVisible = false;

  String category;
  List<String> plans;
  bool dontVisible = false;

  ///drop down meal declaration
  List<Meal> _companies = Meal.getCompanies();
  List<DropdownMenuItem<Meal>> _dropdownMenuItems;
  Meal _selectedCompany;

///date declaration
  DateTime firstDate;
  var firstConvertedDate = 'yyyy-mm-dd'; //     dd-mm-yyyy
  var firstToDate = 'yyyy-mm-dd';
  var _fromDate = "";


  ///pref declaration
  String date, address1 = '', address2 = '', _age = '', _weight = '', _medical= '',  _height = '';
  String fName = "",lName='',email='',userId;
  SharedPreferences _preferences;
  double totalMealCost;

  ///cache declaration
  ApiCall _apiCall = new ApiCall();
  List<UserData> usersList = List<UserData>();


  List<DropdownMenuItem<Meal>> buildDropdownMenuItems(List companies) {
    List<DropdownMenuItem<Meal>> items = List();
    for (Meal company in companies) {
      items.add(
        DropdownMenuItem(
          value: company,
          child: Text(company.name),
        ),
      );
    }
    return items;
  }
  onChangeDropdownItem(Meal selectedCompany) {
    final StateProviderManagement counterBloc = Provider.of<StateProviderManagement>(context);

    setState(() {

      dontVisible = true;
      _selectedCompany = selectedCompany;
      print(_selectedCompany.name);

  //    counterBloc.setMealValue(_selectedCompany.name);

    });
  }

  @override
  void initState() {

  //  final StateProviderManagement counterBloc = Provider.of<StateProviderManagement>(context);

    _dropdownMenuItems = buildDropdownMenuItems(_companies);
    getPlan();
    getPreferencesValues();

   /* if(counterBloc.fromDate.toString() == 'yyyy-mm-dd'){

    }else{
      setState(() {
        dontVisible = true;
      });
    }
*/

  //  getSnack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    final StateProviderManagement counterBloc = Provider.of<StateProviderManagement>(context);

    if(counterBloc.fromDate.toString() == 'yyyy-mm-dd'){
      dontVisible = false;
    }else{
      setState(() {
        dontVisible = true;
      });
    }


    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: AppTheme.BUTTON_BG_COLOR,
          size: 50,
        ),
        dismissible: false,
        child: Scaffold(

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[

                SizedBox(height: 10,),

               /* FutureBuilder<ApiResponse>(
                  future: _apiCall.getUserDataResponse(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {

                      usersList = snapshot.data.plans;

                      print('my cache');
                      print(usersList.length);
                      print(usersList);

                      return ListView.builder(
                          itemCount: usersList.length,
                          itemBuilder: (context, index) {
                            UserData userData = usersList[index];

                            print(userData.type);

                            return ListTile(
                              title: Text(userData.type + " " + userData.cost),
                              subtitle: Text(userData.plan),
                            );
                          });

                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),*/

                  Container(
                      height: 25,
                      width: w,
                      color: Colors.red[50],
                      child: Center(
                        child: Text(
                            'Please select appropriate options to enjoy our food '),
                      )),

                  Padding(
                    padding: EdgeInsets.only(top:h/30),
                    child: GestureDetector(
                      onTap: () {
                        _displayDialogPlan();
                      },
                      child: Center(
                        child: Container(
                          height: h/13,
                          width: w/1.23,

                          decoration: BoxDecoration(
                            border: Border.all(width: 0.2),
                          ),
                          child: Center(
                            child: Text(
                             // "SELECT PLAN",
                              counterBloc.planValue.toString(),
                              style: TextStyle(fontSize: h/40, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top:h/30),
                    child: GestureDetector(
                      onTap: () {


                        if(planStr.isEmpty){                            //counterBloc.planValue.toString() == 'SELECT PLAN'
                          FToast.showCenter('Please select Plan first');
                        }else{
                          _displayDialogPkg();
                        }
                      },
                      child: Center(
                        child: Container(
                          height: h/13,
                          width: w/1.23,

                          decoration: BoxDecoration(
                            border: Border.all(width: 0.2),
                          ),
                          child: Center(
                            child: Text(
                              counterBloc.packageValue.toString() + "  " + counterBloc.packageCost.toString(),
                          //    "SELECT PACKAGE",
                              //  pkgStr,
                              style: TextStyle(fontSize: h/40, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                 /*
                  Material(
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      splashColor: Color(0xFF765d94),
                      onTap: () {
                        _displayDialogPlan();
                      },
                      child: Container(
                        color: Colors.red[50],
                        height: h / 9,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Image.asset("images/bag.png"),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Select Plan",
                                  style: TextStyle(fontSize: h / 30),
                                ),
                              ),
                              flex: 4,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Material(
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      splashColor: Color(0xFF765d94),
                      onTap: () {
                        _displayDialogPkg();
                      },
                      child: Container(
                        color: Colors.green[50],
                        height: h / 9,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Image.asset("images/caltwo.png"),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Select Package",
                                  style: TextStyle(fontSize: h / 30),
                                ),
                              ),
                              flex: 4,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Material(
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      splashColor: Color(0xFF765d94),
                      onTap: () {
                        _displayDialogSnacks();
                      },
                      child: Container(
                        color: Colors.green[50],
                        height: h / 9,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Image.asset("images/pic.png"),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Select Snacks",
                                  style: TextStyle(fontSize: h / 30),
                                ),
                              ),
                              flex: 4,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  */

                 /*
                  Container(
                    height: h / 6.5,
                    width: w/1.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("images/Dashboard/attendance.png")),
                      borderRadius: BorderRadius.circular(10),

                    ),

                    child: Material(
                      type: MaterialType.transparency,
                      elevation: 8.0,
                      color: Colors.transparent,
                      shadowColor: Colors.grey[50],
                      child: InkWell(
                        splashColor: Colors.white30,
                        onTap: () {
                          _displayDialogPkg();
                        },
                        child: Container(
                          //   padding: EdgeInsets.all(16.0),
                          child: Padding(
                            padding: EdgeInsets.only(left:w/5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Select Package',
                                      style: utils.textStyle(
                                          context, 35, Colors.white, FontWeight.bold, 1.0),
                                    ),
                                    Text(
                                      pkgStr.toString(),
                                      style: utils.textStyle(context, 65, Colors.white,
                                          FontWeight.normal, 1.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: h / 6.5,
                    width: w/1.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("images/Dashboard/explore_more.png")),
                      borderRadius: BorderRadius.circular(10),

                    ),

                    child: Material(
                      type: MaterialType.transparency,
                      elevation: 8.0,
                      color: Colors.transparent,
                      shadowColor: Colors.grey[50],
                      child: InkWell(
                        splashColor: Colors.white30,
                        onTap: () {
                          _displayDialogPlan();
                        },
                        child: Container(
                          //   padding: EdgeInsets.all(16.0),
                          child: Padding(
                            padding: EdgeInsets.only(left:w/10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Select Plan',
                                      style: utils.textStyle(
                                          context, 35, Colors.white, FontWeight.bold, 1.0),
                                    ),
                                    Text(
                                      'it has multiple plans',
                                      style: utils.textStyle(context, 65, Colors.white,
                                          FontWeight.normal, 1.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
*/

                  DropdownButton(
                    itemHeight: 80,
                    focusColor: Colors.green,
                    iconEnabledColor: Colors.green,
                    iconSize: 50,

                    dropdownColor: Colors.deepOrangeAccent[50],

                    hint: Text("Number of meals every day"),
                    value: _selectedCompany,
              //      value: counterBloc.mealValue,
                    items: _dropdownMenuItems,
                    style: TextStyle(fontSize: 15,color: Colors.black, ),

                    onChanged: onChangeDropdownItem,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'From : ',
                              style: utils.textStyle(context, 50, Colors.black,
                                  FontWeight.normal, 1.0),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _selectStartDate();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                               // '$firstConvertedDate',
                                counterBloc.fromDate.toString(),
                                style: utils.textStyle(context, 50, Colors.black54,
                                    FontWeight.normal, 1.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          height: h / 20,
                          width: 1,
                          color: Colors.grey[400],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'To : ',
                            style: utils.textStyle(context, 50, Colors.black,
                                FontWeight.normal, 1.0),
                          ),
                          Text(
                         //   '$firstToDate',
                            counterBloc.toDate.toString(),
                            style: utils.textStyle(context, 50, Colors.black54,
                                FontWeight.normal, 1.0),
                          ),
                        ],
                      ),


                    ],
                  ),

                  SizedBox(height: 150,),

                  GestureDetector(
                    onTap: (){

                      if(address1 == null || address1.isEmpty   || address2 == null || address2.isEmpty ||
                      _age.isEmpty || _age == null || _height.isEmpty || _height == null ||  _weight.isEmpty || _weight == null ||
                      _medical.isEmpty || _medical == null){

                        showDialog(
                          context: context,
                          builder: (_) => OtionDialog(
                            msg1: "To order food, you need to update profile details",
                            msg2: "Update profile",
                          ),
                        );
                      }else if(counterBloc.planValue.toString() == 'SELECT PLAN'){
                        FToast.showCenter('Please select plan');
                      }else if(counterBloc.packageValue.toString() == 'SELECT PACKAGE'){
                        FToast.showCenter('Please select package');
                      }else if(_selectedCompany == null){
                        FToast.showCenter('Please select Number of Meals');
                      }else if(counterBloc.fromDate.toString().contains('yyyy-mm-dd')){
                        FToast.showCenter('Please select start date');
                      }

                      else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>
                                SubscriptionPayment(counterBloc.planValue.toString(), counterBloc.packageValue.toString(), _selectedCompany.name,
                                  counterBloc.fromDate.toString(), counterBloc.toDate.toString(),
                                  counterBloc.packageCost.toString(),pkgDays,

                                )));
                      }

                    },

                    child: Visibility(
                      visible: dontVisible,
                      child: Container(
                        alignment: Alignment.center,
                        //height: h / 20,
                        width: w / 1,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppTheme.BUTTON_BG_COLOR,
                            AppTheme.BUTTON_BG_COLOR
                          ]),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Text(
                          "GO TO PAYMENT",
                          style:
                          TextStyle(fontSize: h / 45, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  /*Container(
                    height: h / 6.5,
                    width: w,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("images/Dashboard/homework.png")),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Material(
                      type: MaterialType.transparency,
                      elevation: 8.0,
                      color: Colors.transparent,
                      shadowColor: Colors.grey[50],
                      child: InkWell(
                        splashColor: Colors.white30,
                        onTap: () {
                          _displayDialogSnacks();
                        },
                        child: Container(
                          //   padding: EdgeInsets.all(16.0),
                          child: Padding(
                            padding: EdgeInsets.only(left:w/6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Select Snacks',
                                      style: utils.textStyle(
                                          context, 35, Colors.white, FontWeight.bold, 1.0),
                                    ),
                                    Text(
                                      'Better snacks are available',
                                      style: utils.textStyle(context, 65, Colors.white,
                                          FontWeight.normal, 1.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),*/

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getPlan() {

    setState(() {
      _loading = true;
    });

    planlist.clear();
    _authMethods.planList().then((response) {
      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if (response['success'] == "1") {
     //   FToast.show("success 1");

        setState(() {
          for (var plan in response['plans']) {
            planlist.add(Plan(plan['id'], plan['plan'], plan['cost'])); //user['cards']
          }
        });
      } else if (response['success'] == "0") {
        FToast.show("success 0");
      } else {
        FToast.show("API error");
      }
    });
  }

  void getPackage(String planId) {
    setState(() {
      _loading = true;
    });

    packageList.clear();
    _authMethods.packageList(planId).then((response) {
      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if (response['success'] == "1") {

        setState(() {
          for (var package in response['package']) {
            packageList.add(
                PackagePlan(package['id'], package['package'], package['cost'], package['day'])); //user['cards']
          }
        });
      } else if (response['success'] == "0") {
        FToast.show("success 0");
      } else {
        FToast.show("API error");
      }
    });
  }

  void getSnack() {
    setState(() {
      _loading = true;
    });

    snackList.clear();
    _authMethods.snackList().then((response) {
      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if (response['success'] == "1") {
        FToast.show("success 3");

        setState(() {
          for (var snacks in response['snacks']) {
            snackList
                .add(Snacks(snacks['id'], snacks['snacks'])); //user['cards']
          }
        });
      } else if (response['success'] == "0") {
        FToast.show("success 0");
      } else {
        FToast.show("API error");
      }
    });
  }

  _displayDialogPlan() {

    final StateProviderManagement counterBloc = Provider.of<StateProviderManagement>(context);

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Center(
                  child: Text(
                "Please select plan from given list",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 40),
              )),
              content: Container(
                width: double.maxFinite,
                height: 200.0,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: planlist.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: planCheckList.contains(planlist[index].id),
                        onChanged: (bool value) {
                          setState(() {
                            planCheckList = planlist[index].id;
                            planStr = planlist[index].plan;

                            counterBloc.setTagValue(planStr);

                            ///provider concept uses here reset values
                            counterBloc.setFromDate('yyyy-mm-dd');
                            counterBloc.setToDate('yyyy-mm-dd');
                            counterBloc.setPkgValue('SELECT PACKAGE');
                            counterBloc.setPackageCost('');

                          });

                          print(planCheckList);
                          print(planStr);
                        },

                        title: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                           // mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                planlist[index].plan,
                                style: utils.textStyle(context, 50, Colors.black, FontWeight.bold, 0.0),
                              ),

                              Text(
                                planlist[index].cost,
                                style: utils.textStyle(context, 50, Colors.black, FontWeight.bold, 0.0),
                              ),
                            ],
                          ),
                        ),

                      );
                    }),
              ),

              actions: <Widget>[

                new FlatButton(
                  child: new Text(
                    'OK',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 36),
                  ),
                  onPressed: () {
                    print('here::');

                    setState(() {
                      firstConvertedDate = 'yyyy-mm-dd';      ///  reset to yyyy-mm-dd
                      firstToDate = 'yyyy-mm-dd';             ///  reset to yyyy-mm-dd

                    });


                    Navigator.of(context).pop();

                    ///if user select mixed or other plan then send empty value to api
                    if(planCheckList == '3' || planCheckList == '4'){
                      getPackage('');
                    }else{
                      getPackage(planCheckList);
                    }

                    setState(() {
                      category = '';
                      print(category);
                    });
                  },
                ),
                new FlatButton(
                  child: new Text(
                    'CANCEL',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 40,
                        color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }


 /* _displayDialogPlan() {

    final StateProviderManagement counterBloc = Provider.of<StateProviderManagement>(context);

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Center(
                  child: Text(
                    "Please Select plan From Given List",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 40),
                  )),
              content: Container(
                width: double.maxFinite,
                height: 300.0,
                child:
                FutureBuilder<ApiResponse>(
                  future: _apiCall.getUserDataResponse(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {

                      usersList = snapshot.data.plans;

                      print('my cache');
                      print(usersList.length);
                      print(usersList);

                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: usersList.length,
                          itemBuilder: (context, index) {

                            UserData userData = usersList[index];

                            return CheckboxListTile(
                              value: planCheckList.contains(planlist[index].id),
                              onChanged: (bool value) {
                                setState(() {
                                  planCheckList = planlist[index].id;
                                  planStr = planlist[index].plan;

                                  counterBloc.setTagValue(planStr);

                                });
                                print(planCheckList);
                                print(planStr);
                              },

                              title: Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      userData.plan,
                                      style: utils.textStyle(context, 50, Colors.black, FontWeight.bold, 0.0),
                                    ),

                                    Text(
                                      userData.cost,
                                      style: utils.textStyle(context, 50, Colors.black, FontWeight.bold, 0.0),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });

                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),






              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    'OK',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 36),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                    ///if user select mixed or other plan then send empty value to api
                    if(planCheckList == '3' || planCheckList == '4'){
                      getPackage('');
                    }else{
                      getPackage(planCheckList);
                    }

                    setState(() {
                      category = '';
                      print(category);
                    });
                  },
                ),
                new FlatButton(
                  child: new Text(
                    'CANCEL',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 40,
                        color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }*/

  _displayDialogPkg() {

    final StateProviderManagement counterBloc = Provider.of<StateProviderManagement>(context);

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: FDottedLine(
                color: Colors.green[200],
                corner: FDottedLineCorner.all(6.0),
                child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                  "Prices for 1 Meal",
                  style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 40, color: Colors.green),
                ),
                    )),
              ),
              content: Container(
                width: double.maxFinite,
                height: 150.0,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: packageList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: pkgCheckList.contains(packageList[index].id),
                        onChanged: (bool value) {
                          setState(() {

                           /* if (pkgCheckList.contains(packageList[index].id)) {
                              pkgCheckList.remove(packageList[index].id);

                            } else {
                              pkgCheckList.add(packageList[index].id);
                            }*/
                           pkgCheckList = packageList[index].id;
                           pkgStr = packageList[index].package;
                           pkgCost = packageList[index].cost;
                           pkgDays = packageList[index].days;

                           counterBloc.setPkgValue(pkgStr);
                           counterBloc.setPackageCost(pkgCost);

                             firstConvertedDate = 'yyyy-mm-dd';      ///  reset to yyyy-mm-dd
                             firstToDate = 'yyyy-mm-dd';             ///  reset to yyyy-mm-dd

                           ///provider concept uses here
                            counterBloc.setFromDate('yyyy-mm-dd');
                            counterBloc.setToDate('yyyy-mm-dd');

                          });
                          print(pkgStr);
                        },

                        title: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                packageList[index].package + "  ",
                                style: utils.textStyle(context, 45, Colors.black, FontWeight.bold, 0.0),
                              ),

                              Text("₹ " +
                                packageList[index].cost,
                                style: utils.textStyle(context, 50, Colors.black, FontWeight.bold, 0.0),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    'OK',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 36),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                  },
                ),
                new FlatButton(
                  child: new Text(
                    'CANCEL',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 40,
                        color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }

  _displayDialogSnacks() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Center(
                  child: Row(
                children: <Widget>[
                  Image.asset(
                    "images/fresh.jpg",
                    height: 50,
                  ),
                  Text(
                    "Select snacks From List",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 40),
                  ),
                ],
              )),
              content: Container(
                width: double.maxFinite,
                height: 120.0,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: snackList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                       value: snackCheckList.contains(snackList[index].id),
                       onChanged: (bool value) {
                         setState(() {
                           if (snackCheckList.contains(snackList[index].id)) {
                             snackCheckList.remove(snackList[index].id);

                           } else {
                             snackCheckList.add(snackList[index].id);
                           }
                         });
                         print(snackCheckList);
                       },

                       title: Padding(
                         padding: EdgeInsets.only(bottom: 8.0),
                         child: Text(
                           snackList[index].snacks,
                           style: utils.textStyle(context, 50, Colors.black, FontWeight.bold, 0.0),
                         ),
                       ),
                          );
                    }),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    'OK',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 36),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                    setState(() {
                      category = '';
                      print(category);
                    });
                  },
                ),
                new FlatButton(
                  child: new Text(
                    'CANCEL',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 40,
                        color: Colors.red),
                  ),
                  onPressed: () {
                    snackCheckList.clear();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }

  Future _selectStartDate() async {

    final StateProviderManagement counterBloc = Provider.of<StateProviderManagement>(context);

    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),

       // firstDate: new DateTime(2019),
        firstDate: DateTime.now().subtract(Duration(days: 0)),  ///hide previous days
        lastDate: new DateTime(2022));

    if (picked != null) {
      setState(() {

        firstDate = picked;
        firstConvertedDate =
        "${firstDate.year}-${firstDate.month}-${firstDate.day}";

        firstToDate = "-${firstDate.year}";
        _fromDate = firstConvertedDate;
        dontVisible = true;
        counterBloc.setFromDate(firstConvertedDate);


        if(pkgStr == 'Daily'){

          firstToDate = _fromDate;
          counterBloc.setToDate(firstToDate);

        }else if(pkgStr == 'Weekly'){
          var weekly = firstDate.add(Duration(days: 7)).toIso8601String();
          print('weekly.....');
          print(weekly);

          firstToDate = weekly.substring(0,10);


          counterBloc.setToDate(firstToDate);

        }else{
          var monthly1 = new DateTime(firstDate.year, firstDate.month + 1, firstDate.day);
          print(monthly1);
          print('checkdate.....');
          firstToDate = monthly1.toIso8601String().substring(0,10);


          counterBloc.setToDate(firstToDate);

        }

        counterBloc.setFromDate(firstConvertedDate);
        counterBloc.setToDate(firstToDate);

      });
    }
    print(_fromDate);
    return firstConvertedDate;
  }

  void getPreferencesValues() async{
    _preferences = await SharedPreferences.getInstance();
    setState(() {

      address1 = _preferences.getString("address1");
      address2 = _preferences.getString("address2");
      fName = _preferences.getString("fname");
      lName = _preferences.getString("lname");
      email = _preferences.getString("email");

      _age = _preferences.getString("age");
      _height = _preferences.getString("height_cms");
      _weight = _preferences.getString("weight");
      _medical = _preferences.getString("medicalCondition");

    });

    print('address1:::$address1');
    print('address2::$address2');
  }

}

class Meal {
  int id;
  String name;

  Meal(this.id, this.name);

  static List<Meal> getCompanies() {
    return <Meal>[
      Meal(1, '1'),
      Meal(2, '2'),
      Meal(3, '3'),
      Meal(4, '4'),
      Meal(5, '5'),
    ];
  }
}