/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

/*

import 'dart:io';
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/utils/FToast.dart';

List<GraphModel> _osales = new List<GraphModel>();

class SimpleBarChart extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  factory SimpleBarChart.withRandomData(List<GraphModel> graphList) {
    return new SimpleBarChart(_createRandomData(graphList));
  }

  /// Create random data.
  static List<charts.Series<GraphModel, String>> _createRandomData(List<GraphModel> graphList) {

    print("len::::");
    print(graphList.length);


    final data = [
      new GraphModel('111', "40.00",),
      new GraphModel('222', "50.00"),
      new GraphModel('3333', "50.00"),
    ];

    return [
      new charts.Series<GraphModel, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (GraphModel sales, _) => sales.date.substring(0,2),
        measureFn: (GraphModel sales, _) => int.parse(sales.temperature.substring(0,2)),
        data: graphList,
      )
    ];
  }

  @override
  _SimpleBarChartState createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart> {

  String status="";
  AuthMethods _authMethods = AuthMethods();
  bool _loading = false ;

  @override
  void initState() {

    //checkInternet();
    print("arti::");
    print(widget.seriesList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: fun(),
      ),
    );
  }

  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";

        getAttendanceApi();
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

  ///API call
  void getAttendanceApi() {

    setState(() {
      _loading =true;
    });

    setState(() {
      _osales.clear();
      _authMethods.attendanceList("10000086").then((response) {

        setState(() {
          _loading = false;
        });

        print('gotdateresponse:::');
        print(response);

        if(response['success'] == "1"){
          for (var user in response['data']['data']) {

            _osales.add(GraphModel(
              user['new_date'],user['temperature'],
            ));//user['cards']
          }
          print("length of::");
          print(_osales.length);

        }
        else if(response['success'] == "0"){
          FToast.show("No data to load");

        }else{
          FToast.show("API error");
        }
      });
    });
  }

  fun() {

   return charts.BarChart(
      widget.seriesList,
      animate: widget.animate,
    );
  }
}
/// Sample ordinal data type.
class GraphModel {
  String date;
  String temperature;

  GraphModel(this.date, this.temperature);


  GraphModel.fromMap(Map<String, dynamic> map) {
    date = map[date];
    temperature = map[temperature];
  }

}

*/


