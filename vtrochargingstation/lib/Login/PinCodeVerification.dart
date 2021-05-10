/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:vtrochargingstation/BikeInformation/AddBikeInfoId.dart';
import 'package:vtrochargingstation/CommunicationManager.dart';
import 'package:vtrochargingstation/GoogleMapData/MapView.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedKeys.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedPreferneces.dart';
import 'package:vtrochargingstation/models/message.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';

class PinCodeVerification extends StatefulWidget {
  final String phoneNumber;
  final String pageFrom;

  PinCodeVerification(this.phoneNumber, this.pageFrom);

  @override
  _PinCodeVerificationState createState() =>
      _PinCodeVerificationState();
}

class _PinCodeVerificationState extends State<PinCodeVerification> {
  var onTapRecognizer;
  int onBackPressCounter = 0;

  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  bool _loading = false;
  String currentText = "";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  var re = RegExp(r'\d(?!\d{0,2}$)');

  AppTheme utils = AppTheme();

  APICall apiCall = APICall();
  SharedPreference pref = new SharedPreference();

  /// mqtt
  MQTTAppState currentAppState;
  CommunicationManager _manager;

  /// fcm
  final List<Message> messages = [];
  String fcmToken = "",
      userToken = '',
      prefFcm = '';

  @override
  void initState() {
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    final MQTTAppState appState = Provider.of<MQTTAppState>(
        context, listen: true);
    currentAppState = appState;

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
        key: scaffoldKey,

        /// UI
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [

                Center(child: Container(
                    height: h / 1.3,
                    child: Padding(
                      padding: EdgeInsets.only(right: h / 5),
                      child: Image.asset(
                        "images/loginCircle.png", fit: BoxFit.cover,),
                    ))),

                Container(
                  height: h,
                  width: w,
                  child: Column(
                    children: <Widget>[

                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image.asset(
                          'images/vtrologo.png', height: h / 7,),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Check this Mobile/Email ' +
                                widget.phoneNumber.replaceAll(re, '*'),
                                style: utils.textStyleRegular(
                                    context, 35, AppTheme.text1,
                                    FontWeight.w700, 0.0, '')),

                            Text(
                                'Requested OTP will be shared on the registered Mobile Number ',
                                style: utils.textStyleRegular2(
                                    context, FontWeight.w400)),
                          ],
                        ),
                      ),

                      SizedBox(height: 20,),

                      Form(
                        key: formKey,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 25),
                            child: PinCodeTextField(
                              appContext: context,
                              pastedTextStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                              length: 6,
                              obscureText: false,
                              //   obscuringCharacter: '*',
                              animationType: AnimationType.fade,
                              validator: (v) {
                                if (v.length < 6) {
                                  return "Please enter 6 digits OTP";
                                } else {
                                  return null;
                                }
                              },
                              pinTheme: PinTheme(
                                inactiveColor: Colors.grey[300],
                                activeColor: Colors.white,

                                inactiveFillColor: Colors.grey[300],
                                selectedColor: Colors.green[200],
                                selectedFillColor: AppTheme.background,
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeFillColor: hasError
                                    ? Colors.white54
                                    : Colors.white,
                              ),
                              animationDuration: Duration(milliseconds: 300),
                              backgroundColor: AppTheme.background,
                              enableActiveFill: true,
                              errorAnimationController: errorController,
                              controller: textEditingController,
                              keyboardType: TextInputType.number,
                              onCompleted: (v) {
                                print("Completed");
                              },
                              // onTap: () {
                              //   print("Pressed");
                              // },
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  currentText = value;
                                });
                              },
                              beforeTextPaste: (text) {
                                print("Allowing to paste $text");
                                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                return true;
                              },
                            )),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {

                              setState(() {
                                FlutterApp.resendCount++;
                              });

                              if(FlutterApp.resendCount < 3){
                                normalLogin();
                              }else{
                                ShowCustomSnack.getCustomSnack(context, scaffoldKey, 'resend limit crossed');
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: h / 35.0),
                              child:
                              Text('Resend OTP!',
                                  style: utils.textStyleRegular1(context, FontWeight.w400)),
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: h / 12),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: h / 13,
                              margin: EdgeInsets.symmetric(horizontal: h / 15),
                              // horizontal = width, vertical = height
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius:
                                const BorderRadius.all(Radius.circular(35)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      offset: const Offset(4, 4),
                                      blurRadius: 8.0),
                                ],
                              ),

                              child: NeumorphicButton(
                                onPressed: () {
                                  formKey.currentState.validate();
                                  if (currentText.length != 6) {
                                    errorController.add(ErrorAnimationType
                                        .shake); // Triggering error shake animation
                                    setState(() {
                                      hasError = true;
                                    });
                                  }
                                  else if (currentText.length == 6) {
                                    print('len = 6');
                                    submitPinVerification();
                                  }
                                  else {
                                    setState(() {
                                      hasError = false;
                                      scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text("Aye!!"),
                                            duration: Duration(seconds: 2),
                                          ));
                                    });
                                  }
                                },

                                style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(30)),
                                    color: AppTheme.background,
                                    depth: 10,
                                    surfaceIntensity: 0.20,
                                    intensity: 15,
                                    shadowDarkColor: Color(0xFFe2e2e2),
                                    //outer bottom shadow
                                    shadowLightColor: Colors
                                        .white // outer top shadow
                                ),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('VERIFY',
                                        style: utils.textStyleRegular(
                                            context, 45, AppTheme.text2,
                                            FontWeight.w700, 0.0, '')),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Color(0xFF808080),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// API - otpVerify
  void submitPinVerification() {
    String mode;

    setState(() {
      _loading = true;
    });

    pref.getString(SharedKey().otpSession).then((otpSession) {
      if (otpSession.isEmpty) {
        otpSession = '';
      }

      if (widget.phoneNumber.contains('@')) {
        mode = 'email_address';
      } else {
        mode = 'mobile_no';
      }

      pref.getString(SharedKey().token).then((token) {
        apiCall.otpVerify(
            widget.phoneNumber, otpSession, currentText, token, mode).then((
            response) {
          FlutterApp.token = token;

          setState(() {
            _loading = false;
          });

          if (response['status'] == true) {
            pref.putBool(SharedKey().IS_LOGGED_IN, true);

            getDetailsApi();

            textEditingController.clear();

     //       subscribeTopic();

            if (response['is_bike_details'] == true) {

              /// from profile
              if(widget.pageFrom == 'profile'){
                Navigator.pop(context);

             //   Navigator.pop(context);

              }else{
                ///from login
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));
              }
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddBikeInfoId('login'))); //BikeInformation
      //        Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));
            }
          } else if (response['status'] == false) {
            //       FToast.show(Messages.otpError);
            ShowCustomSnack.getCustomSnack(
                context, scaffoldKey, Messages.otpError);
          } else {
            FToast.show(Messages.elseMethod);
          }
        });
      });
    });
  }

  /// splash screen API - to retrieve all data of user
  void getDetailsApi() {
    apiCall = APICall(state: currentAppState); //new
    apiCall.getDetailsSplashScreen().then((response) {
      if (response['status'] == true) {
        currentAppState.setWalletAmount(response['wallet_amount']);

      } else {
        print('-- splash screen api - false --');
        print('status - false');
      }
    });
  }

  /// API - login
  void normalLogin() async{
    ProgressBar.show(context);

    if (widget.phoneNumber.contains('@',)) {
      apiCall.login(widget.phoneNumber, 'email_address', '1', 'gmail').then((response) {  //normal
        ProgressBar.dismiss(context);

        if(response['status'] == true){
          print('otp API -> True');
          print(response);

        }else if(response['status'] == false){
          FToast.show(Messages.otpError);

        }else{
          FToast.show(Messages.elseMethod);
        }
      });
    }
    else {
      apiCall.login(widget.phoneNumber, 'mobile_no', '1', '').then((response) {  //1

        print(response);
        ProgressBar.dismiss(context);

        if(response['status'] == true){
          print('---otp -> True');
          print(response);

        }else{
          FToast.show(Messages.WENT_WRONG);
        }
      });
    }
  }

}