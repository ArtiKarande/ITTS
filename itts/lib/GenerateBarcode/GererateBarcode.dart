/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itts/utils/FToast.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateBarcode extends StatefulWidget {

  String ssid,password;

  GenerateBarcode(this.ssid,this.password);

  @override
  _GenerateBarcodeState createState() => _GenerateBarcodeState();
}

class _GenerateBarcodeState extends State<GenerateBarcode> {

  FToast utils = new FToast();

  @override
  void initState() {

    print(widget.ssid);
    print(widget.password);
    print("SKIT"+widget.ssid.substring(3),);

    print('D?'+ "SKIT"+widget.ssid.substring(3) + '?' + widget.password + '?D');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Device Barcode"),),
        body: Container(
          child: Center(
            child: Column(

              children: <Widget>[

                SizedBox(height: 20,),

                QrImage(
                  data: 'D?'+ "SKIT"+widget.ssid.substring(3) + '?' + widget.password + '?D',
                  version: QrVersions.auto,
                  size: 250,
                  gapless: false,
                ),
                SizedBox(height: 20,),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("SSID : ",style: utils.textStyle(context, 30,
                          Colors.black, FontWeight.bold, 0.0),),

                      Text("SKIT"+widget.ssid.substring(3),style: utils.textStyle(context, 30,
                          Colors.black, FontWeight.normal, 0.0),),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                      Text("Password : ", style: utils.textStyle(context, 30,
                          Colors.black, FontWeight.bold, 0.0),),

                    Text(widget.password, style: utils.textStyle(context, 30,
                        Colors.black, FontWeight.normal, 0.0),),
                    ],
              ),
                ),



              ],
            ),
          )
        ),
      ),
    );
  }
}
