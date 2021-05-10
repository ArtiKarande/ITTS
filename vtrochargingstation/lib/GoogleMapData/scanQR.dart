/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:io';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/GoogleMapData/ChargerTypeNeu.dart';
import 'package:vtrochargingstation/Support/help_screen.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedKeys.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';
import 'package:vtrochargingstation/neo/text_field.dart';

class ScanQR extends StatefulWidget {

  String stationID, reservation, reservationID, chargerType;
  ScanQR(this.stationID, this.reservation, this.reservationID, this.chargerType);

  @override
  _ScanQRState createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  Barcode result;
  QRViewController mController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  TextEditingController _textController = new TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils=new AppTheme();

  bool disabledButton = true;

  ///mqtt
  MQTTAppState currentAppState;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      mController.pauseCamera();
    }
    print('again called init');
    mController.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {

    /// state management - current state maintain [provider]
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false, /// keyboard issue handled

      /// UI
      body: SafeArea(
        child: Column(
          children: <Widget>[

            /// Appbar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
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
                Text('scan',
                    style: utils.textStyleRegular1(context, FontWeight.normal)),

                NeumorphicButton(
                  onPressed: () async {

                    await mController?.toggleFlash();
                    setState(() {});

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
                    'images/flash.png',
                    height: 20,
                    width: 20,

                  ),
                ),
              ],
            ),

            /// text field
            Padding(
              padding:  EdgeInsets.only(top: h/15, left: w/20, right: w/20, bottom: h/30),
              child: NeumorphicTextField(
                textSize: 48,
                height: 15.0,
                text: _textController.text,
                hint: 'Enter Code Manually',
                onChanged: itemTitleChanget,
              ),
            ),

            Text('OR',style:utils.textStyleRegular1(context,FontWeight.w400)),
            Text('SCAN VIA CODE',style:utils.textStyleRegular1(context,FontWeight.w400)),

            SizedBox(height: h/30),

            Expanded(flex: 2, child: _buildQrView(context)),

            ///Done button
            Padding(
              padding: EdgeInsets.only(bottom: h / 25, top: h/20),
              child: Container(
                height: h / 14,
                margin: EdgeInsets.symmetric(horizontal: h / 15, vertical: h/25),
                child: AbsorbPointer(
                  absorbing: disabledButton, //changed
                  child: NeumorphicButton(
                    onPressed: () async {
                      mController.stopCamera();  /// stop camera first

                      /// navigation from reservation check for both station is same or not
                      if(widget.reservation == 'reservation'){
                        if(widget.stationID == _textController.text){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              ChargerTypeNeu(_textController.text, widget.reservationID, widget.chargerType)));
                        }else{
                          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'booking QR code does not match with current QR');
                          mController.resumeCamera();
                        }
                      }else{
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChargerTypeNeu(_textController.text, '', '')));
                      }
                    },
                    style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                        color: AppTheme.background,
                        depth: 5,
                        surfaceIntensity: 0.20,
                        intensity: disabledButton == true ? 0.50 : 0.95, //changed
                        shadowDarkColor: AppTheme.bottomShadow,
                        //outer bottom shadow
                        shadowLightColor:
                        Colors.white // outer top shadow
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('DONE',
                            style: utils.textStyleRegular(context, 50, disabledButton == true ? AppTheme.buttonDisabled :
                            AppTheme.text2, FontWeight.w700, 0.0, '')),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Icon(Icons.arrow_forward,
                            color: disabledButton == true ? AppTheme.buttonDisabled : AppTheme.text2,
                        ),)
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    /// For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    /// To ensure the Scanner view is properly sizes after rotation
    /// we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
    //    overlayColor: AppTheme.background,
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {

    print('again called..');
    setState(() {
     this.mController = controller;
    });

    mController.resumeCamera();

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        FlutterApp.plugPoint = '0';// reset value
        FlutterApp.activeStatus = '';// reset value
        result = scanData;

        print('qr result:: ');
        print(result.code);

        if(result.code.isEmpty){

          ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Scan QR code');
        }else{

          mController.stopCamera();
          FlutterApp.scanQR = result.code;

          /// navigation from reservation check for both station is same or not
          if(widget.reservation == 'reservation'){
            if(widget.stationID == result.code){

              Navigator.push(context, MaterialPageRoute(builder: (context) => ChargerTypeNeu(result.code, widget.reservationID, widget.chargerType)));

            }else{
              ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'booking QR code does not match with current QR');
              mController.resumeCamera();
            }
          }else{

            Navigator.push(context, MaterialPageRoute(builder: (context) => ChargerTypeNeu(result.code, '', '')));
          }
        }
      });
    });
  }

  /// value changes to edittext callback method
  void itemTitleChanget(String title) {
    setState(() {
      this._textController.text = title;

      if(title.length != 0){
        disabledButton = false;
      }else{
        disabledButton = true;
      }

      print('text val...');
      print(_textController.text);

    });
  }

  @override
  void dispose() {
    _textController.dispose();
    mController?.dispose();
    super.dispose();
  }
}