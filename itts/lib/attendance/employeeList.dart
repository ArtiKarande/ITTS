/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itts/Helper.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/models/Employee.dart';
import 'package:itts/models/UserDevice.dart';
import 'file:///D:/skromanApp/itts/lib/attendance/attendanceList.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
//import 'package:simple_permissions/simple_permissions.dart';

class EmployeeList extends StatefulWidget {

  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {

  int radioValue = 0;
  String message = '';
  bool a7 = false, a8 = false, a9 = false;
  bool i5 = false, i6 = false;
  String appDocPath;

  bool isLoading = false;
  FToast utils = new FToast();

  AuthMethods _authMethods = AuthMethods();
  List<UserDevice> _userDeviceList = new List<UserDevice>();

  bool _loading = false,shareVisible = false;
  ScrollController _sc = new ScrollController();

  int flag = 0;
  String status="";

  int dbValueLength = 0;
  var dbHelper = Helper();
  List<Employee> syncData = new List();
  List<Employee> items = new List();
  bool insertItem = false;
  List<Employee> values;
  ScrollController _scrollController;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  DateTime selectedDate ;
  String excelLink;
//  Permission permission;
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();

    selectedDate = DateTime.now();

    setState(() {
      _getLen();
      checkInternet();

    });

    getDir();

    WidgetsFlutterBinding.ensureInitialized();
    FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
    );

 //   initPlatformState();

  }

/*  initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = await SimplePermissions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  requestPermission() async {
    final res = await SimplePermissions.requestPermission(permission);
    print("permission request result is " + res.toString());
  }*/

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

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
          appBar: AppBar(
            actions: <Widget>[excellSheet],
            title: const Text("Check Attendance"),
          ),
          body:empList(),

             /* Column(children: <Widget>[

                empList(),

                Offstage(
                  offstage: !Platform.isIOS,
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: i6,
                        onChanged: (v) {
                          setState(() {
                            i6 = v;
                          });
                        },
                      ),
                      Text('Storage'),
                    ],
                  ),
                ),

            //    RaisedButton(onPressed: Permission.openSettings, child: new Text("Open settings")),
                Text(message),
              ],),*/


          resizeToAvoidBottomPadding: false,
        ),
      ),
    );
  }

  ///API call
  void getSearchDataByDate() {

    List<dynamic> mEmp = new List();

    mEmp.clear();

    /*setState(() {
      _loading =true;
    });*/

    _userDeviceList.clear();
    _authMethods.employeeList().then((response) {

    /*  setState(() {
        _loading = false;
      });*/

      print('gotdateresponse:::');
      print(response);

      if (response['success'] == "1") {
        print("API::Length");
        print(response['totalcount']);

        var count = int.parse(response['totalcount']);
        print("apiLen::$count");
        print("dblen::: $dbValueLength");

        if (count > dbValueLength || count < dbValueLength) {
          setState(() {
            _loading = true;
          });

          print("db update needed emp:::");

          dbHelper.clearEmp();
          dbHelper.initDb();

          Map<String, dynamic> map = (response);
          mEmp = map["data"]["getEmployee"];

          for (int i = 0; i < mEmp.length; i++) {
            Employee user = new Employee("", "", "");
            print("deviceId:::");
            print(mEmp[i]["Name"]);

         //   user.empId = userId;
            user.empId1 = mEmp[i]["empId"];
            user.empName1 = mEmp[i]["Name"];
            user.empEmail1 = mEmp[i]["email"];

            syncData.add(user);
          }

          print("len:::");

          for (Employee user in syncData) {
            dbHelper.insertEmp(Employee(user.empId1, user.empName1, user.empEmail1));
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

        dbHelper.clearEmp();
        setState(() {
          _loading = false;
        });

        if (response['totalcount'] == "0") {
          _getLen();
          dbHelper.clearEmp();
        }
      } else {
        FToast.show("API loading error");
        setState(() {
          _loading = false;
        });
      }
    });
  }

  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";

        getSearchDataByDate();
      }


    } on SocketException catch (_) {
      print('not connected');

      FToast.show("You are not connected to internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }

  _getLen() async {
    await dbHelper.getAllEmployee().then((value) {
      print(value.length);
      setState(() {
        dbValueLength = value.length;
        print('db:::length employee');
      });
    });
  }

  /// Get all emp data
  getAllEmployee() {
    return FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return createListView(context, snapshot);
        });
  }

  ///Fetch data from database
  Future<List<Employee>> _getData() async {
    var dbHelper = Helper();
    await dbHelper.getAllEmployee().then((value) {

      items = value;
      if (insertItem) {
        _listKey.currentState.insertItem(values.length);
        insertItem = false;
      }
    });

    return items;
  }

  ///create List View with Animation
  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    values = snapshot.data;

    if (values != null ) {

      return Container(
        //    color: Colors.red,
     //   height: 400,

        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: values.length,
            itemBuilder: (context, index) {

              return Card(
                child: ListTile(
                  onTap: () => onItemClick(values[index]),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[

                      Text(
                        values[index].empName1,
                        style: TextStyle(
                            fontSize: 18.0,
                            fontStyle: FontStyle.normal,
                            color: Colors.black),
                        maxLines: 2,
                        softWrap: true,
                      ),

                      SizedBox(height: 5,),

                      Text(
                        values[index].empEmail1,
                        style: TextStyle(
                            fontSize: 13.0,
                            fontStyle: FontStyle.normal,
                            color: Colors.black),
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ],
                  ),

                ),
              );

            }),
      );

    } else
      return Container(

      );
  }

  onItemClick(Employee values) {
    print("Clicked position is ${values.empId1}");

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AttendanceList(values.empId1,values.empName1)));

  }

  empList() {

    if (dbValueLength == 0) {
      return Container(
    //    height: 500,
        child: Center(child: Text("No Data Found"))
      );

    }else{
      return Container(
        child: getAllEmployee(),
      );
    }

  }

  Widget get excellSheet => InkWell(
      onTap: (){

        //requestPermission();

        showMonthPicker(
          context: context,
          firstDate: DateTime(DateTime.now().year - 1, 5),
          lastDate: DateTime(DateTime.now().year + 1, 9),
          initialDate: selectedDate,
          locale: Locale("en"),
        ).then((date) {
          if (date != null) {
            setState(() {
              selectedDate = date;

              print(selectedDate.month);
              print(selectedDate.year);

             attendanceExport(selectedDate.month,selectedDate.year);

            });
          }else{
        //    FToast.show("message");
          }
        });

      },
      child: Center(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.file_download),
      )));

  void attendanceExport(month, year) async{

    setState(() {
      _loading = true;
    });

    _authMethods.attendanceExport(month, year).then((response){

      setState(() {
        _loading = false;
      });
      print(response);
      excelLink = response;


      final taskId = FlutterDownloader.enqueue(
        url: response,
        fileName: 'EmployeeRecord',
        savedDir: appDocPath,
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );

    });
  }

  void getDir()async {

      Directory appDocDir = await getExternalStorageDirectory(); //getExternalStorageDirectory()   getApplicationDocumentsDirectory
      appDocPath = appDocDir.path;

      print("paths:::");
      print(appDocPath);

     /* var request = await HttpClient().getUrl(Uri.parse(appDocPath));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);

      File file = new File('$appDocPath/$excelName');
      await file.writeAsBytes(bytes);
      return file;*/

  }
}

