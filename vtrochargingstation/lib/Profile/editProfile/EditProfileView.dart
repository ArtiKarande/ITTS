/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vtrochargingstation/BikeInformation/AddBikeInfoId.dart';
import 'package:vtrochargingstation/BikeInformation/BikeInformation.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/Login/PinCodeVerification.dart';
import 'package:vtrochargingstation/Profile/editProfile/EditProfile.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/models/bikeInformation.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';
import 'package:vtrochargingstation/neo/text_field.dart';
import 'package:image/image.dart' as Img;

class EditProfileView extends EditProfileState with SingleTickerProviderStateMixin{

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = AppTheme();

  bool _enabled = true;

  int index = 0;
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Profile'),
    Tab(text: 'Notifications'),

  ];

  TabController _tabController;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailIDController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();

  SharedPreferences _preferences;
  String fName = "",lName='',email='',userId;

  File _image;
  String strImg = 'https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg';
  bool loading = false;

  List<BikeInformationModel> _bikeList = new List<BikeInformationModel>();

  ///img
  File sampleImage;
  String fileName = "", prefImage = 'images/profile/profile.png';

  String suffixMobileText = '', suffixEmailText = '';
  Icon suffixMobileIcon = Icon(Icons.ad_units_outlined);
  Icon suffixEmailIcon = Icon(Icons.ad_units_outlined);

  @override
  void initState() {

    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);

    _nameController.text = FlutterApp.fullName;
    _emailIDController.text = FlutterApp.userEmailId;
    _mobileController.text = FlutterApp.userMobileNo;

    getProfile();

  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _nameController.dispose();
    _emailIDController.dispose();
    _mobileController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false, /// keyboard issue handled

      /// UI
      body: SafeArea(
        child: Stack(children: [
          Column(
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
                    padding: EdgeInsets.only(left: w / 3.5),
                    child: Text('Profile',
                        style: utils.textStyleRegular(context, 54, AppTheme.text1, FontWeight.normal, 0.0, '')),
                  ),
                ],
              ),
              profileTab(h, w),
            ],
          )
        ],),
      ),

    );
  }

  /// there are 2 tabs provided
  ///     - profile tab
  ///     - notification tab [now its removed]
  Widget profileTab(double h, double w) {
    return Padding(
      padding: EdgeInsets.only(left:w/20, right: w/20),
      child: SingleChildScrollView(
        child: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Stack(
                  fit: StackFit.loose,
                  children: <Widget>[

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                       Hero(
                         tag: 'image',
                         child: Container(
                           decoration: new BoxDecoration(
                             borderRadius: new BorderRadius.all(new Radius.circular(80.0)),
                             border: new Border.all(
                               color: Colors.white70,
                               width: 4.0,
                             ),
                           ),
                            child: ClipOval(child: Image.network(FlutterApp.profilePic.isNotEmpty ?
                            FlutterApp.profilePicBaseUrl +
                                FlutterApp.profilePic : strImg,
                                height: h/8,width: h/8, fit: BoxFit.fill,)),
                          ),
                       ),

                      ],
                    ),

                    /// upload profile image
                    GestureDetector(

                      onTap: () {
                        getImage();
                      },

                      child: Padding(
                          padding: EdgeInsets.only(top: h / 12, left: w / 5),
                          child: new Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('images/profile/editImage.png', height: h/18,)
                            ],
                          )),
                    ),

                  ]),

              getTextField('Enter Name', "Enter Name", _nameController, 35, TextInputType.text, null, null),
          //    getTextField('Enter Mobile Number', "Enter Mobile Number", _mobileController, 10, TextInputType.number, suffixMobileText, suffixMobileIcon),
          //    getTextField('Enter Email-Id', "Enter Email-Id", _emailIDController, 35, TextInputType.emailAddress, suffixEmailText, suffixEmailIcon),

              ///mobile
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                child:   new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Flexible(
                      child:  TextField(
                        enabled: suffixMobileText == 'Pending' ? true : false,
                        controller: _mobileController,
                        maxLines: 1,
                        style: utils.textStyleRegular(context,50, AppTheme.text1,FontWeight.normal, 0.0,''),
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 10,
                        decoration: InputDecoration(hintText: 'Enter Mobile Number', labelText: 'Enter Mobile Number',
                          labelStyle: utils.textStyleRegular(context,50, AppTheme.text4,FontWeight.normal, 0.0,''),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.line1),
                          ),
                  //        suffixText: suffixMobileText,
                          suffixIcon: IconButton(
                              icon: suffixMobileText == 'Pending' ? Icon(Icons.cancel_outlined, color: AppTheme.red) :
                              Icon(Icons.check_circle_outline, color: AppTheme.greenShade1),
                              onPressed: () {

                                if(_mobileController.text.isEmpty){
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter valid mobile number');
                                }
                                else if(_mobileController.text.length < 10){
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter valid mobile number');
                                }
                                else{
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  sendOtp(_mobileController.text, "mobile_no"); //mobile
                                }


                              }),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.greenShade1),   // activated color
                          ),
                          counter: Offstage(),
                        ),
                        onChanged: (text) {
                          // value = text;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              ///email
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                child:   new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Flexible(
                      child:  TextField(
                        enabled: suffixEmailText == 'Pending' ? true : false,
                        controller: _emailIDController,
                        maxLines: 1,
                        style: utils.textStyleRegular(context,50, AppTheme.text1,FontWeight.normal, 0.0,''),
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 35,

                        decoration: InputDecoration(hintText: 'Enter Email-Id', labelText: 'Enter Email-Id',
                          labelStyle: utils.textStyleRegular(context,50, AppTheme.text4,FontWeight.normal, 0.0,''),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.line1),
                          ),

                          suffixIcon: IconButton(
                              icon: suffixEmailText == 'Pending' ? Icon(Icons.cancel_outlined, color: AppTheme.red) :
                              Icon(Icons.check_circle_outline, color: AppTheme.greenShade1),
                              onPressed: () {
                       //         sendOtp(_emailIDController.text, "email_address");

                                if(_emailIDController.text.isEmpty){
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter valid mobile number');
                                }
                                /*else if(_emailIDController.text.contains(other)){
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please enter valid mobile number');
                                }*/
                                else{
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  sendOtp(_emailIDController.text, "email_address");
                                }

                              }),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.greenShade1),   // activated color
                          ),
                          counter: Offstage(),
                        ),
                        onChanged: (text) {
                          // value = text;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h/30,),

              Text('Bike Information', style:utils.textStyleRegular(context,50, AppTheme.text4,FontWeight.normal, 0.0,'')),

              SizedBox(height: h/50,),
              getBikeDetailsApi(),

              SizedBox(height: h/30,),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddBikeInfoId('profile'))); //BikeInformation
                      },
                      child:
                      Text('+ Add New Bike', style:utils.textStyleRegular(context,52, AppTheme.greenShade1,FontWeight.normal, 0.0,''))),
                ],
              ),

              Container(

                height: h/14,
                margin: EdgeInsets.symmetric(horizontal: h/15, vertical: h/25),
                child: NeumorphicButton(
                  onPressed: (){

                    if(_nameController.text.isEmpty){
                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Enter your full name');

                    }else if(_mobileController.text.isEmpty){
                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Enter your mobile number');

                    }else if(_emailIDController.text.isEmpty){
                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Enter your email id');

                    }else{
                      updateProfile();
                    }
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

                      Text('UPDATE', style:utils.textStyleRegular2(context, FontWeight.w700)),

                      Padding(
                        padding: const EdgeInsets.only(left:10.0),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

          ],),
        ),
      ),
    );
  }

  /// take input from user
  getTextField(String labelText, String hintText, TextEditingController _controller, maxLine, TextInputType text,
      String suffixText, Icon suffixIcon) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      child:   new Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Flexible(
            child:  TextField(
              controller: _controller,
              maxLines: 1,
              style: utils.textStyleRegular(context,50, AppTheme.text1,FontWeight.normal, 0.0,''),
              keyboardType: text,
              textCapitalization: TextCapitalization.words,
              maxLength: maxLine,
             /* decoration: InputDecoration(
                counter: Offstage(),
              ),*/

              decoration: InputDecoration(hintText: hintText, labelText: labelText,
                labelStyle: utils.textStyleRegular(context,50, AppTheme.text4,FontWeight.normal, 0.0,''),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.line1),
                ),
                suffixText: suffixText,
                suffixIcon: suffixIcon,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.greenShade1),   // activated color
                ),
                counter: Offstage(),
              ),
              onChanged: (text) {
                // value = text;
              },
            ),
          ),
        ],
      ),
    );
  }

  /// get user bike details API
  getBikeDetailsApi() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
        height: h/9,
        width: w,
        child: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child:_bikeList.length > 0 ? ListView.builder(

             scrollDirection: Axis.horizontal,
             itemCount: _bikeList.length,
              itemBuilder:(context, index) {

                return Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Neumorphic(

                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                      color: AppTheme.background,
                      depth: 5,
                      intensity: 0.99, //drop shadow
                      shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                      shadowLightColor: Colors.white,  // upper top shadow
                    ),

                    child: Container(
                      width: w/3.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_bikeList[index].bikeName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style:utils.textStyleRegular(context,50, AppTheme.text1,FontWeight.w700, 0.0,'')),
                          Text(_bikeList[index].bikeKW + ' kWh',
                              style:utils.textStyleRegular(context,50, AppTheme.text2,FontWeight.w400, 0.0,'')),

                        ],
                      ),
                    ),
                  ),
                );
              }) : Shimmer.fromColors(
        baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          enabled: _enabled,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left:w/20, right: w/20),
                child: SizedBox(
                  height: h/9.5,
                  child: Container(color: AppTheme.background),
                ),
              ),
            ],
          ),
        ),
        ),
      );
  }

  /// notification part
  notificationTab(double h, double w) {
    return Container(height: h/2,
      child: getNotificationApi(),
    );
  }

  /// UI of second tab
  getNotificationApi() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      width: w,
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: ListView.builder(

            scrollDirection: Axis.vertical,
            // itemCount: _planList.length,
            itemCount: 3,
            itemBuilder:(context, index) {

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Neumorphic(

                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                    color: AppTheme.background,
                    depth: 5,
                    intensity: 0.99, //drop shadow
                    shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                    shadowLightColor: Colors.white,  // upper top shadow
                    //    surfaceIntensity: 0.20, // no use
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('images/vtrologo.png', height: h/15),
                        Flexible(child: Padding(
                          padding: EdgeInsets.only(left:w/20.0, right: 3),
                          child: Text('Hello VTRO notifications check out! \nhave a good day!',
                              style:utils.textStyleRegular(context,50, AppTheme.text2,FontWeight.w400, 0.0,'')),
                        )),
                      ],
                    ),
                  ),
                ),
              );

            }),
      ),
    );
  }

  /// get profile and bike list
  void getProfile() async{

    _preferences = await SharedPreferences.getInstance();
    _bikeList.clear();

    apiCall.getProfile().then((response) {

      if(response['status'] == true){

        setState(() {

          suffixEmailText = response['email_status'];
          suffixMobileText = response['mobile_status'];

          if(suffixMobileText == '0'){
            _mobileController.text = '';
            suffixMobileText = 'Pending';
          }else{
            suffixMobileText = '';
            suffixMobileIcon = Icon(Icons.check_circle_outline, color: AppTheme.greenShade1);
          }

          if(suffixEmailText == '0'){
            suffixEmailText = 'Pending';
          }else{
            suffixEmailText = '';
            suffixEmailIcon = Icon(Icons.check_circle_outline, color: AppTheme.greenShade1);
          }
            for (var bike in response['bike_name']) {
              _bikeList.add(BikeInformationModel(bike['bike_name'], bike['bike_series'], bike['bike_company'], bike['bike_model'],
                  bike['bike_kw'], bike['bike_id'])); //user['cards']
            }
        });
      }else{
        print('---edit profile API -> False');

      }
    });
  }

  /// update user profile - API
  void updateProfile() {
    apiCall.updateUserProfile(_nameController.text, _emailIDController.text, _mobileController.text).then((response) {

      if(response['status'] == true){
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Your profile updated successfully!');
      }else{
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Profile update failed!');
      }
    });
  }

  /// image upload
  Future getImage() async {

    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() => _image = tempImage);

    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    if(tempImage != null){

      setState(() {
        sampleImage = tempImage;
      });

      if(tempImage!=null){
        upload(sampleImage);
      }
      else{
        FToast.show("Upload issue! please select another image");
      }
    }else{
     // todo
    }
  }

  upload(File file) async {
    ProgressBar.show(context);
    if (file == null) return;
    apiCall.uploadProfileImage(file).then((response) {

      ProgressBar.dismiss(context);

      if (response['status'] == true) {

        print(response);

        setState(() {
          FlutterApp.profilePic = response['image_path'];
        });

        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Image saved successfully, please update it now');

        strImg = '';
     //   return;
      } else {
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Image not uploaded. Please try again!');
      }


    });
  }

  void setPref(image) async{
    setState(() {
      _preferences.setString("profilePic", image);
      FlutterApp.profilePic = image;
    });
  }

  void sendOtp(String emailOrMobile, String mode) {

    apiCall.resendOTP(emailOrMobile, mode).then((response) {
      if(response['status'] == true){
        Navigator.push(context, MaterialPageRoute(builder: (context) => PinCodeVerification(_mobileController.text, 'profile')));
      }
      else if(response['status'] == 'timeout'){
        Navigator.pop(context);

        return showDialog(
          context: context,
          builder: (_) => TrialDialog(
            title: 'Timeout',
            msg: Messages.NO_INTERNET,
            color: AppTheme.red,
          ),
        );
      }
      else{
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.WENT_WRONG);
      }
    });

  }

}