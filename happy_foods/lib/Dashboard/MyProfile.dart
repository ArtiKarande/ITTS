/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/dialogBox/successDialog.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:image/image.dart' as Img;
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool _status = true;

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _medicalConditionController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _emailIDController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  SharedPreferences _preferences;
  String fName = "",lName='',email='',userId;

  String _address1 = '', _address2 = '' , _age = '', _weight = '', _medical= '', _imgPref = '', _height = '';

  ///img
  File sampleImage;
  String fileName = "";

  File _image;
  String message = '';

  //replace the url by your url
  String url = 'https://skromanglobal.com/HappyFood/login_api/image_upload.php'; // your rest api url
  bool loading = false;

  bool editProfileButton = false;

  String strImg = 'https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg';

  @override
  void initState() {
    super.initState();
    getPreferencesValues();
    getProfileDetails();

    print(strImg);
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
//      backgroundColor: Color(0xFF493366),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: AppTheme.BUTTON_BG_COLOR,
          size: 50,
        ),
        dismissible: false,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Form(
                  child: ListView(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.all(10)),
                          Container(
                            child: Column(
                              children: <Widget>[
                                new Stack(
                                    fit: StackFit.loose,
                                    children: <Widget>[
                                      // yellow edit icon use
                                      new Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                         /* Container(
                                              width: w / 4,
                                              height: w / 4, //changes
                                              decoration: new BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(width: 0.5,color: Colors.orangeAccent),
                                                image: new DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image:_image != null ? Image.file(_image,
                                                      height: 30,
                                                      width: w,
                                                      fit: BoxFit.cover,
                                                    ) :  new AssetImage("images/food.png")),
                                              )
                                          ),*/

                                          loading ? Padding(
                                            padding: EdgeInsets.only(top: 52),
                                            child: Center(child: CircularProgressIndicator()),
                                          ) : _image != null ? Image.file(_image,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ) : Image.network(strImg,height: 100,width: 100,),

                                        ],
                                      ),

                                      GestureDetector(

                                        onTap: () {
                                          getImage();
                                        },

                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                top: h / 10, right: w / 6),
                                            child: new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                new CircleAvatar(
                                                  backgroundColor: Colors.amber,
                                                  radius: 25.0,
                                                  child: new Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),

                                    ]),
                                new Container(
                                  color: Color(0xffFFFFFF),
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: w / 15,
                                              right: w / 20.0,),
                                          child: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  _status
                                                      ? _getEditIcon()
                                                      : new Container(),
                                                ],
                                              )
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: w / 15,
                                              right: w / 20.0,
                                              top: h / 20.0),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    fName + ' ' + lName ,
                                                    style: TextStyle(
                                                        fontSize: h / 40,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),

                                      getTextField('+91', "Enter First Name", _emailIDController),
                               //       getTextField("@gmail.com", "Enter Last Name", _emailIDController),

                                      basicInformation(context),

                                      Padding(
                                          padding: EdgeInsets.only(left: w / 15, right: w / 20.0,),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  new Text(
                                                    'Address 1',
                                                    style: TextStyle(
                                                        fontSize: h / 40.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0,
                                              right: 25.0,
                                              top: 2.0),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Flexible(
                                                child: new TextFormField(
                                                  keyboardType: TextInputType.text ,
                                                  controller:_address1Controller ,
                                                  decoration: InputDecoration(hintText: 'eg. pune'), enabled: !_status,
                                                ),
                                              ),
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: w / 15,
                                              right: w / 20.0,
                                              top: h / 20),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  new Text(
                                                    'Address 2', style: TextStyle(fontSize: h / 40.0, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(
                                            left: w / 15,
                                            right: w / 20.0,
                                          ),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Flexible(
                                                child: new TextFormField(
                                                  keyboardType: TextInputType.text ,
                                                  controller:_address2Controller,
                                                  decoration: InputDecoration(hintText: 'eg. pune'), enabled: !_status,
                                                ),
                                              ),
                                            ],
                                          )),

                                      SizedBox(height: 50,),

                                      Visibility(
                                        visible: !_status,
                                        child: InkWell(
                                          onTap:(){

                                        //   editProfile();         //temperary

                                            if(_emailIDController.text.isEmpty){
                                              FToast.showCenter('mobile number should not be empty');
                                            }else if(_ageController.text.isEmpty){
                                              FToast.showCenter('Please enter your age');
                                            }else if(_heightController.text.isEmpty){
                                              FToast.showCenter('Please enter your height');
                                            }else if(_weightController.text.isEmpty){
                                              FToast.showCenter('Please enter your weight');
                                            }
                                            else if(_medicalConditionController.text.isEmpty){
                                              FToast.showCenter('medical condition field is empty');
                                            }else if(_address1Controller.text.isEmpty){
                                              FToast.showCenter('Address id empty');
                                            }else if(_address2Controller.text.isEmpty){
                                              FToast.showCenter('address is empty');
                                            }else{
                                              editProfile();
                                            }


                                          },
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
                                              "Update Profile",
                                              style:
                                              TextStyle(fontSize: h / 45, color: Colors.white),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  basicInformation(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      color: Color(0xffFFFFFF),
      child: Padding(
        padding: EdgeInsets.only(bottom: 25.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            Padding(
                padding:
                EdgeInsets.only(left: w / 15, right: w / 20.0, top: h / 20),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          'Age',
                          style: TextStyle(
                              fontSize: h / 40.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                )),
            Padding(
                padding: EdgeInsets.only(
                  left: w / 15,
                  right: w / 20.0,
                ),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Flexible(
                      child: new TextFormField(
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        controller: _ageController,
                        decoration: InputDecoration(hintText: 'eg. 25'),
                        enabled: !_status,
                      ),
                    ),
                  ],
                )),

            Padding(
                padding:
                EdgeInsets.only(left: w / 15, right: w / 20.0, top: h / 20),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          'Height',
                          style: TextStyle(
                              fontSize: h / 40.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                )),


            Padding(
                padding: EdgeInsets.only(
                  left: w / 15,
                  right: w / 20.0,
                ),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Flexible(
                      child: new TextFormField(
                        controller: _heightController,
                        decoration: InputDecoration(hintText: 'eg. 5.3'),
                        enabled: !_status,
                      ),
                    ),
                  ],
                )),


            Padding(
                padding:
                    EdgeInsets.only(left: w / 15, right: w / 20.0, top: h / 20),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          'Weight',
                          style: TextStyle(
                              fontSize: h / 40.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                )),
            Padding(
                padding: EdgeInsets.only(
                  left: w / 15,
                  right: w / 20.0,
                ),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Flexible(
                      child: new TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(hintText: 'eg. 50'),
                        enabled: !_status,
                      ),
                    ),
                  ],
                )),

            Padding(
                padding:
                    EdgeInsets.only(left: w / 15, right: w / 20.0, top: h / 20),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          'Medical Condition',
                          style: TextStyle(
                              fontSize: h / 40.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                )),
            Padding(
                padding: EdgeInsets.only(
                  left: w / 15,
                  right: w / 20.0,
                ),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Flexible(
                      child: new TextFormField(
                        keyboardType: TextInputType.text ,
                        controller: _medicalConditionController,
                        decoration: InputDecoration(hintText: 'eg. Healthy !'),
                        enabled: !_status,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  getTextField(hintText, errorText, TextEditingController _controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: TextFormField(
        controller: _controller,
        enabled: !_status,
        autofocus: !_status,
        validator: (_controller) {
          if (_controller.isEmpty) {
            return errorText;
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.only(left: 14.0)),
      ),
    );
  }

  void getPreferencesValues() async{
    _preferences = await SharedPreferences.getInstance();
    setState(() {

      fName = _preferences.getString("fname");
      lName = _preferences.getString("lname");
      email = _preferences.getString("email");
      userId = _preferences.getString("user_id");


      _address1 = _preferences.getString("address1");
      _address2 = _preferences.getString("address2");
      _age = _preferences.getString("age");
      _height = _preferences.getString("height_cms");
      _weight = _preferences.getString("weight");
      _medical = _preferences.getString("medicalCondition");
      _imgPref = _preferences.getString("userImg");

      _emailIDController.text = email;
      _ageController.text = _age;
      _heightController.text = _height;
      _address1Controller.text = _address1;
      _address2Controller.text = _address2;

      _weightController.text = _weight;
      _medicalConditionController.text = _medical;

      print(fName[0]);

    });

    print('Arti:gotUserId:::$userId');
  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() => _image = tempImage);
    fileName = (tempImage.path);

    print(fileName + "gotname" + "\n");

    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    //compress image code
    Img.Image image = Img.decodeImage(tempImage.readAsBytesSync());
    Img.Image smallerImg = Img.copyResize(image, width: 500);

//    compressImg = new File(fileName)
//      ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 85));

    setState(() {
      sampleImage = tempImage;
    });

    print("imgfilename::");
    print(sampleImage);

    if(tempImage!=null){
      upload(sampleImage);
    }
    else{
      FToast.show("Upload issue! please select another image");
    }
  }

  void editProfile() async {

    setState(() {
      _loading = true;
    });

    String type;

    if(_emailIDController.text.contains("@")){
      type = "1";    //email sathi
    }else{
      type = "2";    //phone sathi
    }

    print("imgfilename::");
    print(sampleImage);

    _authMethods.editProfile(fName,lName,_emailIDController.text,type,_ageController.text,'5-9-1993',_heightController.text,
    _weightController.text,_medicalConditionController.text,
        _address1Controller.text,_address2Controller.text,strImg).then((response) {

      setState(() {
        _loading = false;
      });

      if(response['success'] == "1"){

        getProfileDetails();  ///to update details in pref values call API again now this is short cut later on implement this with pref values only

        setState(() {
          _status = true;       // edit icon reset to [true]
        });

        showDialog(
          context: context,
          builder: (_) => FunkyOverlay(
            msg: "Profile details updated successfully",
          ),
        );
      }
      else if(response['success'] == "0"){
        FToast.show("something went wrong please try again!");
      }
    });
  }

  upload(File file) async {

    if (file == null) return;

    setState(() {
      loading = true;
    });

    Map<String, String> headers = {
      "Accept": "application/json",
    };
    var uri = Uri.parse(url);
    var length = await file.length();

    print(length);
    http.MultipartRequest request = new http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        // replace file with your field name exampe: image
        http.MultipartFile('userImg', file.openRead(), length, filename: userId+'.png',),
      );
    request.fields['tag'] = 'image_upload';
    request.fields['userId'] = userId;

    print('check userId here::');

    var response = await http.Response.fromStream(await request.send());

    print(response.statusCode);
    print(response.body);

    var decodedData = jsonDecode(response.body);

    setState(() {
      loading = false;
    });

 //   print(decodedData['imageref']['image_url'].toString());


    if (response.statusCode == 200) {

      FToast.showCenter("Image upload successfully");

      strImg = '';

      return;
    } else
      FToast.show("Image not uploaded. Please try again!");
  }

  void getProfileDetails() async{

    SharedPreferences _prefs = await SharedPreferences.getInstance();
   /* setState(() {
      _loading = true;
    });*/

    _authMethods.getProfile().then((response) {

      /*if(mounted){
        setState(() {
          _loading = false;
        });
      }
*/
      print('gotdateresponse:::');
      print(response);
      print(response['success']);

      bool resStatus = response['success'];

      if (resStatus == true) {

        setState(() {

          _emailIDController.text = response['login_with'];
      //    _mobileController.text = response['login_with'];
          _ageController.text = response['age'];
          _heightController.text = response['height_cms'];
          _weightController.text = response['weight'];
          _medicalConditionController.text = response['medicalCondition'];
          _address1Controller.text = response['deliveryAddress1'];
          _address2Controller.text = response['deliveryAddress2'];
          strImg = response['userImg'];

          _prefs.setString("address1", response['deliveryAddress1']);
          _prefs.setString("address2", response['deliveryAddress2']);
          _prefs.setString("age", response['age']);
          _prefs.setString("height_cms", response['height_cms']);
          _prefs.setString("weight", response['weight']);
          _prefs.setString("medicalCondition", response['medicalCondition']);
          _prefs.setString("userImg", response['userImg']);


        });

      } else if (resStatus == false) {
        FToast.show("success 0");
      }
    });
  }

}

