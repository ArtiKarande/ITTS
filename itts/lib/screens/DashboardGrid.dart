
/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itts/GenerateBarcode/GererateBarcode.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/models/User.dart';
import 'package:itts/models/message.dart';
import 'package:itts/models/userDetails.dart';
import 'package:itts/screens/AlertDialog.dart';
import 'package:itts/screens/EnquiryDetails.dart';
import 'package:itts/screens/SideDrawerNavgation.dart';
import 'package:itts/screens/add_device.dart';
import 'file:///D:/skromanApp/itts/lib/attendance/attendance_dialog.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper.dart';
import 'dart:async';

import 'dialogboxDevice.dart';

/*class MyAppNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
            builder: (context) => Dashboard()
        ),
      ),
    );
  }
}*/

class Dashboard extends StatefulWidget {

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  List<User> items = new List();
  List<User> values;
  bool flag = false;
  bool insertItem = false;
  int dbValueLength = 0;
  int count = 0, pageloaderror = 0, colorFlag = 0;

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SharedPreferences _preferences;
  String userId, firstRecordDb, fName,showcaseValue;

  FToast utils = new FToast();

//  var _feedData,_userData;
  List<UserDetails> _userModelList = new List<UserDetails>();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel:"navigator");

  var dbHelper = Helper();

  int index = 0;
  TabController _controller;

  String status,
      greenZone = "",
      orangeZone = "",
      redZone = "",
      totalZoneCount = "",
      _deviceName = "";
  ScrollController _sc = new ScrollController();
  bool isLoading = false;

  static int page = 0;

  List<User> syncData = new List();
  List<UserDetails> syncData2 = new List();

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var refreshKey1 = GlobalKey<RefreshIndicatorState>();

  String icon = "", schoolID = "";
  final List<Message> messages = [];
  String fcmToken = "";

  String _deviceid = "", _strDate = "";
  final renameController = TextEditingController();
  final TextEditingController _emailIDController = TextEditingController();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  String getLatestDataType = "";

  ///showcase
  GlobalKey _one = GlobalKey();

  @override
  void initState() {

//    dbHelper.getAllDevicesDemo();//temperatry


    _controller = new TabController(length: 2, vsync: this);

    setState(() {
      _getLen();

      ///commented bcoz it shows list tab when user swipe tab
//      checkInternetInitState();

      getPreferencesValues();
      getApiUserDeviceData();
    });

    firebasePushNotification();

    _sc.addListener(() {
      if (_sc.position.pixels ==
          _sc.position.maxScrollExtent) {
        //  getApiDevicesDetailsTry(_deviceid, _strDate); //pagination
        getApiDevicesDetailsTry(); //pagination
      }
    });

   /* if(showcaseValue == "enableDashboard"){
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ShowCaseWidget.of(context).startShowCase([_one,]));
    }else{}
*/
    super.initState();

  }

  @override
  void dispose() {
    _controller.dispose();
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: MaterialApp(

        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        navigatorKey: navigatorKey,
        home: SafeArea(

          child: ModalProgressHUD(
            inAsyncCall: _loading,
            opacity: 0.5,
            progressIndicator: SpinKitFadingCircle(
              color: AppTheme.BUTTON_BG_COLOR,
              size: 50,
            ),
            dismissible: false,
            child: DefaultTabController(
              length: 2,
              child: new Scaffold(

                resizeToAvoidBottomPadding: false,
                endDrawer: SideDrawer(fName[0], dbValueLength),
                appBar: AppBar(

                 /* actions: [
                    Builder(
                      builder: (context) => Showcase(
                        key: _one,
                        description: 'Tap to see menu options',
                        child: IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                        ),
                      ),
                    ),
                  ],
*/
               //   iconTheme: new IconThemeData(color: Colors.green),
                  automaticallyImplyLeading: false,

                  title: Text("ITTS"),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(h / 12),
                    child: Column(
                      children: <Widget>[
                        Card(
                          shape: Border.all(color: AppTheme.BUTTON_TEXT_COLOR),
                          color: Colors.white,
                          child: fun_tabBar(h / 40),
                        ),
                      ],
                    ),
                  ),
                ),
                body: fun_tabbarView(h / 45, h / 50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  getAllUser() {
    return FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return createGridView(context, snapshot);
        });
  }

  Future<List<User>> _getData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    await dbHelper.getAllUsers().then((value) {
      items = value;
      if (insertItem) {
        insertItem = false;
      }
    });

    firstRecordDb = items[0].name;

    _prefs.setString("firstRecord", items[0].name);

    return items;
  }

  ///click on device
  Widget createGridView(BuildContext context, AsyncSnapshot snapshot) {
    values = snapshot.data;
    if (values != null) {
      return RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: GridView.builder(
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (BuildContext context, int index) {

             return myFun(context, values[index], index);

            }),
      );
    } else
      return Container();
  }



  _getLen() async {
    await dbHelper.getAllUsers().then((value) {
      print(value.length);
      setState(() {
        dbValueLength = value.length;
        print('db:::data length');
      });
    });
  }

  void navigateToDetail() async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddDevice();
    }));

    if (result == true) {
      print("dbhelperexecute::");
      //    updateListView();
    }
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void getPreferencesValues() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      userId = _preferences.getString("user_id");
      fName = _preferences.getString("fname");
      firstRecordDb = _preferences.getString("firstRecord");
 //     showcaseValue = _preferences.getString("enableDashboard");
    });

    print('Arti:gotUserId:::$userId');
  }

  //////////////////tab part/////////////////////

  //devices and list tabs
  fun_tabBar(double fontSize) {
    return TabBar(
      controller: _controller,

      //indicatorWeight: 20,
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: EdgeInsets.only(left: 0, right: 0),
      dragStartBehavior: DragStartBehavior.start,
      unselectedLabelColor: Colors.black,

      indicatorColor: Colors.red,
      indicator: new BubbleTabIndicator(
        indicatorHeight: 40.0,
        indicatorColor: AppTheme.BUTTON_TEXT_COLOR,
        //padding: EdgeInsets.all(20),
        tabBarIndicatorSize: TabBarIndicatorSize.tab,
        indicatorRadius: .0,
      ),

      tabs: <Widget>[
        Tab(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "Devices",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: fontSize,
              ),
            ),
          ),
        ),
        Tab(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "List",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///tab declaration - devices and list
  fun_tabbarView(double text_fontSize, double btn_fontSize) {
    return TabBarView(
      physics: NeverScrollableScrollPhysics(), // disable tab swipe
      controller: _controller,
      children: <Widget>[
        home(),
        deviceDetailList(),
      ],
    );
  }

  ///1st tab
  home() {
    if (dbValueLength < 1) {
      return Container(
        height: 500,
        /*child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () {
                navigateToDetail();
              },
              child: Column(
                //      crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 90,
                    width: 90,
                    decoration: ShapeDecoration(
                        shape: Border.all(color: AppTheme.SUB_TITLE_COLOR)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add,
                          size: h / 12,
                          color: AppTheme.BUTTON_TEXT_COLOR,
                        ),
                        Text(' Add Device ')
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),*/

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("You are not an Admin on any of the ITTS device"),
       //     Text("You do not have ITTS device "),

            GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("For enquiries Contact", style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EnquiryDetails()));


                }
            )
          ],
        ),


      );
    } else {
      return Container(
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () {
                //          navigateToDetail(Note('', '', 2), 'Add Note');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height / 1.3, //1.2
                    child: getAllUser(),
                  )
                ],
              ),
            )
          ],
        ),
      );
    }
  }

  ///2nd tab
  deviceDetailList() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    if (_userModelList.length == 0) {
      return Center(
          child: Text(
        "Select Device ",
        style:
            utils.textStyle(context, 40, Colors.black, FontWeight.normal, 1.0),
      ));
      // getLocalData();
    }
    else {
      return RefreshIndicator(
        key: refreshKey1,
        onRefresh: refreshListTwo,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  _deviceName,
                  style: utils.textStyle(
                      context, 40, Colors.black, FontWeight.bold, 0.0),
                ),
                InkWell(
                    onTap: () {
                      if (status == "ConnectivityResult.none") {
                        FToast.showCenter("You are not connected to internet");
                      } else {
                        refreshIcon();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.red,
                      ),
                    )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Material(
                    color: colorFlag == 1 ? Colors.black12:Colors.white,
                    child: InkWell(

                      onTap: (){
                        setState(() {
                          page = 0;
                          colorFlag = 1;
                          getLatestDataType = "";
                        });

                        getApiDevicesDetailsTry();  //first
                      },

                      child: Card(
                        child: Container(
                          height: w / 6,
                          width: w / 6,
                          color: AppTheme.BLACK_COLOR,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Total",
                                      style: utils.textStyle(context, 75,
                                          Colors.white, FontWeight.normal, 0.0)),
                                  Text(
                                    totalZoneCount,
                                    style: utils.textStyle(context, 34,
                                        Colors.white, FontWeight.bold, 0.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        elevation: 5.0,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: colorFlag == 2? Colors.green[200]:Colors.white,

                    child: InkWell(

                      onTap: (){

                        if(greenZone == "0"){
                          FToast.showCenter("No records");
                        }else{
                          setState(() {
                            page = 0;
                            colorFlag = 2;
                            getLatestDataType = "green";
                          });
                          getApiDevicesDetailsTry();  //green
                        }
                      },
                      child: Card(
                        child: Container(
                          height: w / 6,
                          width: w / 6,
                          color: AppTheme.GreenZone,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                greenZone,
                                style: utils.textStyle(context, 34, Colors.white,
                                    FontWeight.bold, 0.0),
                              ),
                            ],
                          ),
                        ),
                        elevation: 5.0,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                  ),

                  Material(
                    color: colorFlag == 3 ? Colors.orangeAccent[100]:Colors.white,
                    child: InkWell(
                      onTap: (){

                        if(orangeZone == "0"){
                          FToast.showCenter("No records");

                        }else{
                          setState(() {
                            page = 0;
                            colorFlag = 3;
                            getLatestDataType = "orange";
                            getApiDevicesDetailsTry();
                          });
                        }
                      },
                      child: Card(
                        child: Container(
                          height: w / 6,
                          width: w / 6,
                          color: AppTheme.OrangeZone,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                orangeZone,
                                style: utils.textStyle(context, 34, Colors.white,
                                    FontWeight.bold, 0.0),
                              ),
                            ],
                          ),
                        ),
                        elevation: 5.0,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: colorFlag == 4 ? Colors.red[200]:Colors.white,
                    child: InkWell(

                      onTap: (){
                        if(redZone == "0"){
                          FToast.showCenter("High temperature records not found !");
                        }else{
                          setState(() {
                            page = 0;
                            colorFlag = 4;
                            getLatestDataType = "red";
                          });
                          getApiDevicesDetailsTry();
                        }

                      },
                      child: Card(
                        child: Container(
                          height: w / 6,
                          width: w / 6,
                          color: AppTheme.RedZone,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                redZone,
                                style: utils.textStyle(context, 34, Colors.white,
                                    FontWeight.bold, 0.0),
                              ),
                            ],
                          ),
                        ),
                        elevation: 5.0,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: h / 1.7,
              child: ListView.builder(
                  controller: _sc,
                  itemCount: _userModelList.length,
                  itemBuilder: (context, index) {
                    var tempValue =
                        double.parse(_userModelList[index].temperature);

                    if (tempValue >= 33.00 && tempValue < 37.00) {
                      icon = "images/green.png";
                    } else if (tempValue > 37.00 && tempValue <= 38.00) {
                      icon = "images/orange.png";
                    } else if (tempValue > 38.00) {
                      icon = "images/red.png";
                    }

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: AppTheme.background,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, top: 5, bottom: 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.WHITE_COLOR,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0)), //68 hote
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: AppTheme.grey.withOpacity(0.2),
                                      offset: Offset(1.1, 1.1),
                                      blurRadius: 10.0),
                                ],
                              ),
                              child: Padding(
                                //left right changes
                                padding: const EdgeInsets.only(
                                    top: 5, left: 10, right: 5, bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                            //    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              //  crossAxisAlignment: CrossAxisAlignment.end,

                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(left: 4, bottom: 1),
                                                    child: Text(_userModelList[index].empName.toString().trim(), //ful name
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontFamily: AppTheme.fontName,
                                                        fontStyle: _userModelList[index].empName == " Guest" ? FontStyle.italic : FontStyle.normal,
                                                        fontSize: 17,
                                                        letterSpacing: 0.0, color: AppTheme.darkText,
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                // line
                                                left: 5,
                                                right: 48,
                                                top: 12,
                                                bottom: 0),
                                            child: Container(
                                              height: 2,
                                              decoration: BoxDecoration(
                                                color: AppTheme.background1,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4.0)),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[

                                                    Text(" "+_userModelList[index].timeType.toString().trim() + " ", style: utils.textStyle(
                                                        context,
                                                        40,
                                                        Colors.deepOrange,
                                                        FontWeight.bold,
                                                        0.0),),

                                                    Text(
                                                      _userModelList[index].date,
                                                      style: TextStyle(
                                                        fontFamily: AppTheme.fontName,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 14,
                                                        letterSpacing: 0.0,
                                                        color: AppTheme.lightText,
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      width: 10,
                                                    ),

                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 4.0),
                                                      child: Text(
                                                        _userModelList[index].time,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontFamily: AppTheme.fontName,
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 14, letterSpacing: 0.0,
                                                          color: AppTheme.lightText,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          _userModelList[index].temperature,
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontWeight: FontWeight.w400,
                                            fontSize: h / 35,
                                            letterSpacing: 0.0,
                                            color: AppTheme.darkText,
                                          ),
                                        ),

                                        Text(
                                          "  C",
                                          style: TextStyle(fontSize: h / 40),
                                        ),

                                        Image.asset(
                                          icon,
                                          height: h / 15,
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),


                            ),
                          ),



                        ],

                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    }
  }

  checkInternet(String name, String dateOnwords) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }

      setState(() {
        page = 1;
      });

      getApiDevicesDetails(name, dateOnwords, page);

      /* _sc.addListener(() {
        if (_sc.position.pixels == _sc.position.maxScrollExtent) {
          getApiDevicesDetailsTry(name,dateOnwords);  //pagination
        }
      });
*/
    } on SocketException catch (_) {
      print('not connected');

      FToast.show("You are not connected to internet");
      status = "ConnectivityResult.none";

      getLocalData(name);
    }
  }

  ///use this function only for slide of list not for tap on devices   --- read it ---
  ///swipe on list tab
  checkInternetInitState() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }

      //   getLocalDataTabList(firstRecordDb);     //temperary added by arti commented okk refer this later
      getLocalDataTabList("KI-ZMts38");
    } on SocketException catch (_) {
      print('not connected');

      print("initstate::val");
      print(firstRecordDb);
      //   getLocalDataTabList(firstRecordDb);//temperary added by arti commented okk refer this later
      getLocalDataTabList("KI-ZMts38");

      status = "ConnectivityResult.none";
    }
  }

  //////////////////////////////////////////////initstate API////////////////////////////////////////////

  void getApiUserDeviceData() {
    List<dynamic> mDevices = new List();

    mDevices.clear();

    _authMethods.getUserDeviceData().then((response) {
      print("statuescode::devicedata");
      print(response);

      if (response['success'] == "1") {
        print("API::Length");
        print(response['totalcnt']);

        var count = int.parse(response['totalcnt']);
        print("apiLen::$count");
        print("dblen::: $dbValueLength");

        if (count > dbValueLength || count < dbValueLength) {
          setState(() {
            _loading = true;
          });

          //if server has greater value then load then in local db
          print("db update needed:::");

          dbHelper.clearDB();
          dbHelper.initDb();

          Map<String, dynamic> map = (response);
          mDevices = map["data"]["getdevicedetails"];

          for (int i = 0; i < mDevices.length; i++) {
            User user = new User("", "", "", "", "", "", "");
            print("deviceId:::");
            print(mDevices[i]["deviceId"]);

            user.userId = userId;
            user.name = mDevices[i]["deviceId"];
            user.password = mDevices[i]["password"];
            user.date = mDevices[i]["creation_date"];
            user.time = mDevices[i]["creation_time"];
            user.deviceName = mDevices[i]["devicename"];
            user.datenew = mDevices[i]["new_date"];

            syncData.add(user);
          }

          print("len:::");

          for (User user in syncData) {
            dbHelper.insert(User(user.name, user.password, userId, user.date,
                user.time, user.deviceName, user.datenew));
          }
          _getLen();
          print('arti:::syncData: $syncData');

          setState(() {
            _loading = false;
          });
        } else {
          print("no db update needed:::");
        }
      } else if (response['success'] == "0") {
        setState(() {
          _loading = false;
        });

        if (response['totalcnt'] == "0") {
          dbHelper.clearDB();
          _getLen();
        }
      } else {
        FToast.show("API loading error");
        setState(() {
          _loading = false;
        });
      }
    });
  }

////////////////////////////////////////////////  List part show detailed List   /////////////////////////////////////////
  ///working on this aaaaaaaaaaaaa
  void getApiDevicesDetails(String deviceID, String dateOnwords, int page) {
    print("here::");
    List<dynamic> mDevices2 = new List();

    _userModelList.clear();
    dbHelper.clearDevices(deviceID);

    print("got page value:::$page");
    _authMethods.getLatestData(page, deviceID, dateOnwords, getLatestDataType).then((response) {
      print("success msg");
      print(response['success']);

      if (response['success'] == "1") {
        setState(() {
          //     _feedData = response['data'];

          greenZone = response['greencount'];
          orangeZone = response['orangecount'];
          redZone = response['redcount'];
          totalZoneCount = response['totalcount'];
          _deviceName = response['devicename'];

          for (var user in response['data']['data']) {
            _userModelList.add(UserDetails(
                user['deviceId'],
                user['temperature'],
                user['new_date'],   //date
                user['time'],
                user['description'],
                user['Name'],
              user['timetype']

            )); //user['cards']
          }

          Map<String, dynamic> map = (response);
          mDevices2 = map["data"]["data"];

          for (int i = 0; i < mDevices2.length; i++) {
            UserDetails user = new UserDetails("", "", "", "", "", "", []);

            user.temperature = mDevices2[i]["temperature"];
            user.date = mDevices2[i]["date"];
            user.time = mDevices2[i]["time"];
            user.deviceId = mDevices2[i]["deviceId"];
            syncData2.add(user);
          }

          for (UserDetails user in syncData2) {
            dbHelper.insertDevice(UserDetails(user.deviceId, user.temperature,
                user.date, user.time, userId, user.empName, user.timeType));
          }

          dbHelper.getAllDevices(deviceID);

          setState(() {
            _loading = false;
          });
          _controller.animateTo((_controller.index + 1) % 2);
        });
      } else if (response['success'] == "0") {
        FToast.show("No Data Found");
        setState(() {
          _loading = false;
        });
      } else {
        FToast.show("API loading error1");
        setState(() {
          _loading = false;
        });
      }
    });
  }

  Future<List<UserDetails>> getLocalData(String name) async {
    _userModelList.clear();
    setState(() {
      dbHelper.getAllDevices(name).then((value) {
        print("getAllDevices::fun::");
        print(value.length);

        _userModelList = value;
        print(_userModelList.length);

        setState(() {
          _loading = false;
        });
        _controller.animateTo((_controller.index + 1) % 2);
      });
    });

    return _userModelList;
  }

  Future<List<UserDetails>> getLocalDataTabList(String name) async {
    _userModelList.clear();

    setState(() {
      dbHelper.getAllDevices(name).then((value) {
        print("getAllDevices::fun::");
        print(value.length);

        _userModelList = value;
        totalZoneCount = value.length.toString();
        print(_userModelList.length);
        setState(() {
          _loading = false;
        });
      });
    });

    return _userModelList;
  }

  void getApiDevicesDetailsTry() {
    print("in getApiDevicesDetailsTry:::");

    setState(() {
      _loading = true;
      page++;
    });

    print("got page value:::$page");
    _authMethods.getLatestData(page, _deviceid, _strDate, getLatestDataType).then((response) {

      setState(() {
        _loading = false;
      });

      print("success msg1221");
      print(response['success']);

      if (page == 1) {
        _userModelList.clear();
      }

      if (response['success'] == "1") {
        setState(() {
          greenZone = response['greencount'];
          orangeZone = response['orangecount'];
          redZone = response['redcount'];
          totalZoneCount = response['totalcount'];
          _deviceName = response['devicename'];

          for (var user in response['data']['data']) {
            _userModelList.add(UserDetails(
                user['deviceId'],
                user['temperature'],
                user['date'],
                user['time'],
                user['description'],
                user['Name'],
              user['timetype']

            )); //user['cards']
          }

        });
      } else if (response['success'] == "0") {
             FToast.showCenter("No more data.");

      } else {
        FToast.showCenter("API error");

      }
    });
  }

  ///1st pull refresh
  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      /*dbHelper.clearDB();
      dbHelper.initDb();
      getApiUserDeviceData();*/

      getApiUserDeviceData();
      new Dashboard();
    });

    return null;
  }

  ///2nd pull refresh
  Future<Null> refreshListTwo() async {
    refreshKey1.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _loading = true;
      page = 0;

      getApiDevicesDetailsTry(); //arti use this latefor refresh
    });
    return null;
  }

  refreshIcon() {
    setState(() {
      _loading = true;
      page = 0;

      getApiDevicesDetailsTry(); //arti use this latefor refresh
    });
  }

  void firebasePushNotification() {
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) async {
        //when app is fully closed
        print("msg::: onLaunch called ${(msg)}");
        print("onLaunch called");

        if (msg != null) {
          final notification = msg['data'];
          setState(() {
            showDialog(
              context: context,
              builder: (_) => FunkyOverlay(
                title: notification['title'],
                msg: notification['body'],
              ),
            );
          });
        }
      },
      onResume: (Map<String, dynamic> msg) async {
        print(
            "msg222::: onResume called ${(msg)}"); //when we click on notification

        final notification = msg['data'];
        setState(() {
          showDialog(
            context: context,
            builder: (_) => FunkyOverlay(
              title: notification['title'],
              msg: notification['body'],
            ),
          );
        });
      },
      onMessage: (Map<String, dynamic> msg) async {
        print("msg222::: onMessage called ${(msg)}");
        final notification = msg['notification'];
        setState(() {
          showDialog(
            context: context,
            builder: (_) => FunkyOverlay(
              title: notification['title'],
              msg: notification['body'],
            ),
          );

         /* if(notification['body'] == "Attendence Added"){

            print(notification['body']);
            navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => SelfAttendance()));

          }else{
            FToast.show("else");
          }*/

        });
      },
    );
  }

  void deleteDevice(String deviceId) {
    setState(() {
      _loading = true;
    });

    _authMethods.deactivateDevice(deviceId, "removedevice").then((response) {
      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if (response['success'] == "1") {
        FToast.showCenter("Device deleted");
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
      } else if (response['success'] == "0") {
        FToast.show("Device not deactivate please try again");
      } else {
        FToast.show("API error");
      }
    });
  }

  void deactivateDevice(String deviceId) {
    setState(() {
      _loading = true;
    });

    _authMethods
        .deactivateDevice(deviceId, "softDeviceRemove")
        .then((response) {
      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if (response['success'] == "1") {
        FToast.showCenter("Device deactivated");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
      } else if (response['success'] == "0") {
        FToast.show("Device not deactivate please try again");
      } else {
        FToast.show("API error");
      }
    });
  }

  Future<bool> dialogBoxDeactivate(String deviceID) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: Container(
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                  'All data for this device will be stored on server.'),
              Text('You can add this device again at later stage.'),
              Text(''),
              Text('To delete data permanently use'),
              Row(
                children: <Widget>[
                  Text(
                    'Delete ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('option'),
                ],
              )
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              setState(() {
                Navigator.pop(context);
                deactivateDevice(deviceID);
              });
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> dialogBoxDelete(String deviceID) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: Container(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('All data for this device '),
                  Text(
                    'will be ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text('permanently deleted.',style: TextStyle(fontWeight: FontWeight.bold),),
              Text('This action can not be handle.'),
              Text(''),
              Text(
                  'In case, if you want to add this device again with existing data '),
              Row(
                children: <Widget>[
                  Text('then try '),
                  Text(
                    'Deactivate ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('option'),
                ],
              )
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              deleteDevice(deviceID);
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> dialogBoxRename(String deviceID, String deviceName, int id, String date, String time, String password,String userId,String dateNew) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Row(
          children: <Widget>[
            Text('Edit - '),

            Text(
              deviceName,
              style: utils.textStyle(
                  context, 50, Colors.black, FontWeight.normal, 0.0),
            ),
          ],
        ),
        content:

        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 5),
          child: TextFormField(
            controller: renameController,
            keyboardType: TextInputType.emailAddress,

            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey, width: 1.0),
                ),
                hintText: 'Enter Device Name',
                border: OutlineInputBorder( borderRadius: BorderRadius.circular(10)),
                contentPadding:
                const EdgeInsets.only(left: 14.0)),
          ),
        ),

        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);

              if(renameController.text.isNotEmpty){
                renameApi(deviceID, renameController.text, id, date, time, password, userId, dateNew);

              }else{
                FToast.showCenter("Add Device name");
              }
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void renameApi(String deviceId, String deviceName, uid, date, time, password,
      userID, dateNew) async {
    setState(() {
      _loading = true;
    });

    _authMethods.editDeviceDetails(deviceId, deviceName).then((response) {
      var user = User("", "", "", "", "", "", "");
      user.id = uid;
      user.name = deviceId;
      user.password = password;
      user.userId = userID;
      user.date = date;
      user.time = time;
      user.deviceName = deviceName;
      user.datenew = dateNew;

      var dbHelper = Helper();
      dbHelper.update(user).then((update) {
        renameController.text = "";

 //       Navigator.of(context).pop();
        print("Data Saved successfully");
      });

      setState(() {
        _loading = false;
      });

      print('gototpRess:::');
      print(response);

      if (response['success'] == "1") {
        FToast.showCenter("Device name changed successfully");
      } else if (response['success'] == "0") {
        print("something went wrong please try again");
      } else {
        FToast.show("API error");
      }
    });
  }


  Future<bool> dialogBoxAddEmployee(String deviceID) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text('Add Employee Details'),
        content:

        Container(
       //   margin: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 2),
          child: TextFormField(
            controller: _emailIDController,
            keyboardType: TextInputType.emailAddress,

            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey, width: 1.0),
                ),
                hintText: 'mobile / email',
                border: OutlineInputBorder( borderRadius: BorderRadius.circular(10)),
                contentPadding:
                const EdgeInsets.only(left: 14.0)),
          ),
        ),

        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {

              if(_emailIDController.text.isNotEmpty){
                Navigator.pop(context);
                _loading = true;
                registerUser(deviceID);

              }else{
                FToast.showCenter("Add mobile/email");
              }
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void registerUser(String deviceID) async {

    String type;

    if(_emailIDController.text.contains("@")){
      type = "1";    //email sathi
    }else{
      type = "2";    //phone sathi
    }

    _authMethods.addEmployee("","",_emailIDController.text,
        "",context,type,deviceID).then((response) {

      setState(() {
        _loading = false;
      });

      if(response['success'] == "1"){

        print("-------");
        print(response);
        String name = _emailIDController.text;

        showDialog(
          context: context,
          builder: (_) => AttendanceDialog(msg1: "$name added successfully!",),
        );

        _emailIDController.text = "";
      }
      else if(response['success'] == "0"){
        FToast.showCenter("User Not Exist !");

      } else if(response['success'] == "2"){

        String name = _emailIDController.text;
        showDialog(
          context: context,
          builder: (_) => AttendanceDialog(msg1: " $name already exist !",),
        );

        _emailIDController.text = "";
      }
      else{
        FToast.showCenter("API error");
      }

    });
  }

  Widget myFun(BuildContext context, User values, int index) {

    return GestureDetector(
      onTap: () {
        setState(() {
          _loading = true;
          _deviceid = "";
          _strDate = "";
          page = 0;
          getLatestDataType = "";
          _deviceid = values.name;
          _strDate = values.date;

          print("printname:::");
          print(_deviceid);

          checkInternet(values.name, values.date); // arti

          //bcoz of confusion commented
        });
        //   refreshList1();
      },


      onLongPress: () {
        /*showDialog(
                    context: context,
                    builder: (_) => DialogboxDevice(
                      deviceId: values[index].name,
                      deviceName: values[index].deviceName,
                      id: values[index].id,
                      date: values[index].date,
                      time: values[index].time,
                      password: values[index].password,
                      userId: values[index].userId,
                    ),
                  );*/

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select option - '),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[

                    MaterialButton(

                        child: Text('Add Employee'), onPressed: () {

                      //    Navigator.pop(context);
                      /*showDialog(
                                  context: context,
                                  builder: (_) => DialogboxEmployee(
                                    values[index].name,
                                  ),
                                );*/
                      Navigator.pop(context);
                      dialogBoxAddEmployee(values.name);


                    }),
                    MaterialButton(
                        child: Text('Rename Device'),
                        onPressed: () {

                          Navigator.pop(context);

                          dialogBoxRename(
                            values.name,
                            values.deviceName,
                            values.id,
                            values.date,
                            values.time,
                            values.password,
                            values.userId,
                            values.datenew,
                          );

                          /*showDialog(
                                      context: context,
                                      builder: (_) => RenameDevice(
                                        deviceId: values[index].name,
                                        deviceName: values[index].deviceName,
                                        id: values[index].id,
                                        date: values[index].date,
                                        time: values[index].time,
                                        password: values[index].password,
                                        userId: values[index].userId,
                                      ),
                                    );*/

                        }

                    ),
                    MaterialButton(
                        child: Text('Delete Device'),
                        onPressed: ()  {
                          Navigator.of(context).pop();
                          dialogBoxDelete(values.name);
                        }),
                    MaterialButton(
                        child: Text('Deactivate',style: TextStyle(color: Colors.red)), onPressed: () {
                      Navigator.of(context).pop();
                      dialogBoxDeactivate(values.name);
                    }),

                    MaterialButton(
                        child: Text('Generate QR code'), onPressed: () {
                      Navigator.of(context).pop();

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => GenerateBarcode(values.name,values.password)));

                    }),


                    MaterialButton(
                      child: Text('Cancel'), onPressed: () => Navigator.of(context).pop(),)

                  ],
                ),
              ),
            );
          },
        );
      },

      child: new Card(
        elevation: 5.0,
        //       color: Colors.green,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        values.deviceName.isEmpty
                            ? "No Name"
                            : values.deviceName,
                        //values[index].deviceName
                        style: utils.textStyle(context, 45,
                            Colors.black, FontWeight.normal, 0.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        "SKIT"+values.name.substring(3), //device id name
                        style: utils.textStyle(context, 65,
                            Colors.black, FontWeight.normal, 0.0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            values.datenew,  //date
                            style: TextStyle(
                                fontSize: 10, color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            values.time,
                            style: TextStyle(
                                fontSize: 10, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );

  }

  void clearShowcase() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs.setString("showcase", "disable");
  }

}
