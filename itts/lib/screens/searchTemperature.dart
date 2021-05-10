/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:itts/animation/DelayedAimation.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/models/User.dart';
import 'package:itts/models/UserDevice.dart';
import 'package:itts/models/userDetails.dart';
import 'package:itts/screens/pdfCheck.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

class DashboardTry extends StatefulWidget {
  @override
  _DashboardTryState createState() => _DashboardTryState();
}

class _DashboardTryState extends State<DashboardTry> {

  bool isLoading = false;
  FToast utils = new FToast();
  DateTime firstdate;
  var firstConvertedDate = 'dd-mm-yyyy';
  String _fromDate="",_toDate="";
  var firstToDate = 'dd-mm-yyyy',_userData;

  AuthMethods _authMethods = AuthMethods();
  List<UserDevice> _userDeviceList = new List<UserDevice>();

  String status,greenZone,orangeZone,redZone,totalZoneCount;
  bool _loading = false,shareVisible = false;
  ScrollController _sc = new ScrollController();

  String pathPDF = "";
  int flag = 0;


  List<Company> _companies = Company.getCompanies();
  List<DropdownMenuItem<Company>> _dropdownMenuItems;
  Company _selectedCompany;

  List<DropdownMenuItem<Company>> buildDropdownMenuItems(List companies) {
    List<DropdownMenuItem<Company>> items = List();
    for (Company company in companies) {
      items.add(
        DropdownMenuItem(
          value: company,
          child: Text(company.name),
        ),
      );
    }
    return items;
  }
  onChangeDropdownItem(Company selectedCompany) {
    setState(() {
      _selectedCompany = selectedCompany;
    });
  }
  @override
  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_companies);
    super.initState();
  }

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
            actions: <Widget>[shareButton],
            title: const Text("Search"),
          ),
          body: Container(
            child: Column(
           //   mainAxisAlignment: MainAxisAlignment.end,

              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: <Widget>[

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'From : ',
                                style: utils.textStyle(context, 50, Colors.black,
                                    FontWeight.normal, 1.0),
                              ),
                              InkWell(
                                onTap: () {
                                  _selectStartDate();
                                },
                                child: Text(
                                  '$firstConvertedDate',
                                  style: utils.textStyle(context, 50, Colors.black54,
                                      FontWeight.normal, 1.0),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
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
                              InkWell(
                                onTap: () {
                                  _selectToDate();
                                },
                                child: Text(
                                  '$firstToDate',
                                  style: utils.textStyle(context, 50, Colors.black54,
                                      FontWeight.normal, 1.0),
                                ),
                              ),
                            ],
                          ),


                        ],
                      ),

                      DropdownButton(
                        dropdownColor: Colors.red[50],
                        hint: Text("temperature"),
                        value: _selectedCompany,
                        items: _dropdownMenuItems,
                        style: TextStyle(fontSize: 13,color: Colors.black, ),

                        onChanged: onChangeDropdownItem,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),

                      InkWell(
                        onTap: (){
                         checkInternet();

                        },
                        child: Container(
                          alignment: Alignment.center,
                          //height: h / 20,
                          width: w / 4,
                          padding: const EdgeInsets.symmetric(vertical: 7.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              AppTheme.BUTTON_BG_COLOR,
                              AppTheme.BUTTON_BG_COLOR
                            ]),
                            borderRadius: BorderRadius.circular(10),

                          ),
                          child: Text(
                            "Search",
                            style:
                            TextStyle(fontSize: h / 45, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: h / 1.57,

                  child:  api_seectedListViewShow(context, h, 50, h/50, 30, 50, 80),

                ),

              ],
            ),
          ),
          resizeToAvoidBottomPadding: false,
        ),
      ),
    );
  }

  Future _selectStartDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),

        firstDate: new DateTime(2019),
        lastDate: new DateTime(2022));
    if (picked != null) {
      setState(() {
        /*_value = picked.toString();
           var formattedDate = "${_value.day}-${date.month}-${date.year}";*/
        firstdate = picked;
        firstConvertedDate =
            "${firstdate.day}-${firstdate.month}-${firstdate.year}";

        _fromDate = firstConvertedDate;
      });
    }
    print(_fromDate);
    return firstConvertedDate;
  }

  Future _selectToDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2019),
        lastDate: new DateTime(2022));
    if (picked != null) {
      setState(() {
        /*_value = picked.toString();
           var formattedDate = "${_value.day}-${date.month}-${date.year}";*/
        firstdate = picked;
        firstToDate = "${firstdate.day}-${firstdate.month}-${firstdate.year}";

        _toDate = firstToDate;
      });
    }

    print(_toDate);
    return firstToDate;
  }

  ///API call
  void getSearchDataByDate() {

    print("aaaaa");
  //  print(_selectedCompany.id);

    if(_fromDate.isEmpty || _fromDate == null){
      FToast.showCenter("Please select from date");

    }else if(_toDate.isEmpty || _toDate == null){
      FToast.showCenter("Please select to date");
    }
    else if(_selectedCompany == null){
      FToast.showCenter("Please select temperature type");
    }

    else{

      setState(() {
        _loading =true;
      });

      _userDeviceList.clear();
      _authMethods.getBySearch(firstConvertedDate,firstToDate,_selectedCompany.id).then((response) {

        setState(() {
          _loading = false;
        });

        print('gotdateresponse:::');
        print(response);
        print(response['pdffile']);

        print('checkres:::111:::');

        if(response['success'] == "1"){
          setState(() {
            pathPDF = response['pdffile'];

            setState(() {
              shareVisible = true;

              createFileOfPdfUrl().then((f) {
                setState(() {
                  pathPDF = f.path;
                  print("aaa111");
                  print(pathPDF);
                });
              });

            });

            print("API::LengthTry");

            totalZoneCount = response['totalcount'];

            for (var user in response['data']['data']) {
              _userDeviceList.add(UserDevice(user['deviceId'],user['temperature'], user['new_date'],user['time'],
                user['devicename'],user['timetype'],user['Name'],
              ));//user['cards']
            }
          });
        }
        else if(response['success'] == "0"){
          FToast.show("No data found");

          setState(() {
            _loading=false;
            shareVisible = false;
          });
        }else{
          FToast.show("API error");
          setState(() {
            _loading=false;
          });
        }
      });
    }
  }

  api_seectedListViewShow(
      BuildContext context,
      double height,
      titleFontSize,
      subTitleFontSize,
      int titleFont,
      int subTitleFont,
      double seeMoreFontSize,
      ) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      //    color: Colors.red,
  //    height: height / 2.0,

      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _userDeviceList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[200],
                    ),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      _userDeviceList[index].userName.toString().trim(),
                                     // style: utils.textStyle(context, titleFontSize, Colors.black, FontWeight.bold, 1.0),

                                      style: TextStyle(fontFamily: AppTheme.fontName,
                                        fontStyle: _userDeviceList[index].userName == " Guest" ? FontStyle.italic : FontStyle.normal,
                                        fontSize: 17,
                                        letterSpacing: 0.0, color: AppTheme.darkText,
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text("  "+
                                        _userDeviceList[index].timetype,
                                      style: utils.textStyle(
                                          context,
                                          40,
                                          Colors.deepOrange,
                                          FontWeight.bold,
                                          0.0),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[


                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      _userDeviceList[index].deviceName + " [ " + "SKIT"+_userDeviceList[index].deviceId + " ]",
                                      style: utils.textStyle(
                                          context,
                                          titleFontSize,
                                          Colors.black,
                                          FontWeight.bold,
                                          0.0),
                                    ),
                                  ),


                                  Row(
                                    children: <Widget>[
                                      Text(
                                        _userDeviceList[index].temperature,
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.black,
                                            FontWeight.bold,
                                            0.0),
                                      ),

                                      Text(
                                        ' C',
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.black,
                                            FontWeight.bold,
                                            0.0),
                                      ),
                                    ],
                                  ),

                                ],
                              ),


                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      /*Text(
                                        "date: ",
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.black,
                                            FontWeight.normal,
                                            0.0),
                                      ),*/

                                      Text(
                                        _userDeviceList[index].date,
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.black,
                                            FontWeight.normal,
                                            0.0),
                                      ),

                                    ],
                                  ),


                                  Text(
                                    _userDeviceList[index].time,
                                    style: utils.textStyle(
                                        context,
                                        subTitleFont,
                                        Colors.black,
                                        FontWeight.normal,
                                        0.0),
                                  ),

                                ],
                              ),

                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                )),
          );
        }),
    );
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

  Widget get shareButton => Visibility(
    visible: shareVisible,
    child:


    InkWell(
        onTap: ()async{
          setState(() {
            _loading = true;
          });
          await new Future.delayed(const Duration(seconds: 4));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PDFScreen(pathPDF)),
          );
          setState(() {
            _loading = false;
          });
        },
        child: Center(child: Text(" Export to PDF  "))),

  );

  Future<File> createFileOfPdfUrl() async {
    final url = pathPDF;
    final pdfName = "ITTSExport.pdf";

    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$pdfName');
    await file.writeAsBytes(bytes);
    return file;

  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Details"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                shareFile();

              },
            ),
          ],
        ),
        path: pathPDF);
  }

  Future<void> shareFile() async {

    print("got path::: $pathPDF");
    ShareExtend.share(pathPDF, "file");

  }
}

class Company {
  int id;
  String name;

  Company(this.id, this.name);

  static List<Company> getCompanies() {
    return <Company>[
      Company(1, 'All'),
      Company(2, 'High temperature'),
    ];
  }
}