/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrochargingstation/GoldCard/GoldCard.dart';
import 'package:vtrochargingstation/Group/GroupAddBalance.dart';
import 'package:vtrochargingstation/Group/YourGroup.dart';
import 'package:vtrochargingstation/History/history.dart';
import 'package:vtrochargingstation/InternetConnectivity/network_info.dart';
import 'package:vtrochargingstation/Login/login.dart';
import 'package:vtrochargingstation/Reservation/Reservation.dart';
import 'package:vtrochargingstation/Settings/Setting.dart';
import 'package:vtrochargingstation/Support/help_screen.dart';
import 'package:vtrochargingstation/VtroPlans/plans.dart';
import 'package:vtrochargingstation/Wallet/Wallet.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedKeys.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedPreferneces.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';
import 'editProfile/EditProfile.dart';

class MyProfileView extends StatefulWidget {
  @override
  _MyProfileViewState createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  SharedPreferences _preferences;

  ///date declaration
  DateTime firstDate;
  var firstConvertedDate = 'yyyy-mm-dd'; //     dd-mm-yyyy

  SharedPreference pref = new SharedPreference();

  String emailormobile='';

  bool _status = true;
  bool _loading = false;

  final TextEditingController _ageController = TextEditingController();

  AppTheme utils = AppTheme();
  String mobile = "",email='', userId;

  ///img
 // File sampleImage;
  String fileName = "";

//  File _image;
  String message = '';

  bool loading = false;

  bool editProfileButton = false;

  String strImg = 'https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg';

  ///mqtt
  MQTTAppState currentAppState;

  @override
  void initState() {
    // TODO: implement initState

    print('pic...');
    print(FlutterApp.profilePic);
    print(FlutterApp.changeMqttUrl);
    print(FlutterApp.changeUrl);
    getPreferencesValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final MQTTAppState appState = Provider.of<MQTTAppState>(context, listen: true);
    currentAppState = appState;

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    List<String> images = [
      "images/profile/wallet.png",
      "images/profile/goldcard.png",
      "images/profile/group.png",
      "images/profile/reservation.png",
      "images/profile/plansIcon.png",
      "images/profile/viewhistory.png",
      "images/profile/support.png",
      "images/profile/settings.png",
    ];

    List<String> values = ["Vtro Wallet","Gold Card","Group","Reservation","Plans","View History","Support","Settings"];  //Support  Logout

    return WillPopScope(
      onWillPop: (){
   //     currentAppState.setMapVisibility(true);//5apr
        Navigator.pop(context);
        return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.background,
        //     backgroundColor: AppTheme.red,

        /// UI
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 0.5,
          progressIndicator: SpinKitFadingCircle(
            color: Colors.yellow,
            size: 50,
          ),
          dismissible: false,
          child: SafeArea(
            child: Stack(
              children: <Widget>[

                Column(
                  children: [

                    /// Appbar
                    Row(
                      children: [
                        InkWell(
                          onTap: (){
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
                          padding: EdgeInsets.only(left:w/4),
                          child: Text('Profile', style: utils.textStyleRegular(context,50, AppTheme.text1,FontWeight.normal, 0.0,'')),
                        ),
                      ],
                    ),

                    /// 1st card
                    Padding(
                      padding: EdgeInsets.only(top:h/50, left: w/30, right: w/30),
                      child: GestureDetector(
                        onTap: () async{
                          bool result = await DataConnectionChecker().hasConnection;
                          if(result == true) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                          }else{
                            noInternetDialog();
                          }
                        },

                        child: Container(
                          height: h/6.5,
                          width: w,
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                              color: AppTheme.background,
                              shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                              shadowLightColor: Colors.white,  // upper top shadow

                            ),
                            child: Stack(
                              children: [

                                /// edit icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        child: NeumorphicButton(
                                          onPressed: ()async{

                                          bool result = await DataConnectionChecker().hasConnection;
                                          if(result == true) {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                                          }else{
                                            noInternetDialog();
                                          }


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
                                            'images/edit.png',
                                            height: h/40,
                                            width: h/40,
                                          ),

                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    Row(
                                      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        //     Image.asset('images/profile.png', height: h/6.7,),

                                        Padding(
                                          padding: EdgeInsets.only(left:w/30),
                                          child: Hero(
                                            tag: 'image',
                                            child: Container(
                                              decoration: new BoxDecoration(
                                                borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                                border: new Border.all(
                                                  color: Colors.white70,
                                                  width: 5.0,
                                                ),
                                              ),
                                              child: ClipOval(
                                                child: Image.network(FlutterApp.profilePic.isNotEmpty ?
                                                FlutterApp.profilePicBaseUrl +
                                                    FlutterApp.profilePic : strImg,
                                                    fit: BoxFit.fill, height: h/10,width: h/10)),

                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: EdgeInsets.only(left:w/25),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(FlutterApp.fullName.toString().isEmpty ? 'User Name' : FlutterApp.fullName.toString(),
                                                    maxLines: 1,
                                                    style:utils.textStyleRegular(context,50, AppTheme.text1,FontWeight.normal, 0.0,'')),
                                                Text(emailormobile,
                                                    overflow: TextOverflow.ellipsis,
                                                    style:utils.textStyleRegular4(context, FontWeight.w400)),
                                                 ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: h/40),

                    /// grid options
                    Flexible(
                      child: Container(
                          color: AppTheme.background,
                          //  height: h/1.5,
                          padding: EdgeInsets.all(5.0),
                          child: ScrollConfiguration(
                            behavior: ScrollBehavior(),
                            child: GridView.builder(
                              itemCount: images.length,
                              padding: EdgeInsets.all(10),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height / 3.1),
                                crossAxisCount: 2,
                                crossAxisSpacing: 15.0, // middle space
                                mainAxisSpacing: 15.0,
                              ),
                              itemBuilder: (BuildContext context, int index){
                                return GestureDetector(
                                  onTap: () async{
                                    profileClickEvent(index);
                                  },
                                  child: Neumorphic(
                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                          color: AppTheme.background,
                                          shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                                          shadowLightColor: Colors.white,  // upper top shadow
                                    ),
                                    child: Container(
                                      color: AppTheme.background,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(images[index], height: h/19,width: h/19,),
                                          Text(values[index], style:utils.textStyleRegular(context,50, AppTheme.text2,FontWeight.normal, 0.0,'')),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void clearData() {
    pref.putBool(SharedKey().IS_LOGGED_IN, false);
    pref.putString(SharedKey().chargingStatus, "");
    pref.putString(SharedKey().REQUESTID, '');
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }

  /// get user login [email/mobile] details
  void getPreferencesValues() async{
    _preferences = await SharedPreferences.getInstance();

    pref.getString(SharedKey().email_or_mobile).then((value) {
      setState(() {
        emailormobile = value;
      });
      print('User login by :::$emailormobile');
    });
  }

  /// common internet dialog - box
  noInternetDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return NetworkInfo(
            title: Messages.NO_INTERNET,
          );
        });
  }

  /// [gridview] click event and navigate accordingly
  void profileClickEvent(int index) async{

    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {
      setState(() {
        if(index == 0){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Wallet()));
        }
        else if(index == 1){
          if(FlutterApp.isGoldCardUser == true){
            Navigator.push(context, MaterialPageRoute(builder: (context) => GoldCard()));
          }else{
            ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Dear user, You are not Gold Card member of VTRO');
          }
        }

        else if(index == 2){
          Navigator.push(context, MaterialPageRoute(builder: (context) => YourGroup()));
        }

        else if(index == 3){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Reservation()));
        }
        else if(index == 4){
          Navigator.push(context, MaterialPageRoute(builder: (context) => VTroPlans()));
        }
        else if(index == 5){
          Navigator.push(context, MaterialPageRoute(builder: (context) => History()));

        }
        else if(index == 6){
          Navigator.push(context, MaterialPageRoute(builder: (context) => HelpScreen()));
        }
        else if(index == 7){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
        }
      });
    }else{
      noInternetDialog();
    }

  }

}
