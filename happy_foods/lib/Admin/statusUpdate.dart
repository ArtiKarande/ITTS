/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/Admin/adminDashboard.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/productionHouse/productionDashboard.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class StatusUpdate extends StatefulWidget {
  String msg1 = "",msg2="", subId='', loginWith='';

  StatusUpdate({Key key, this.msg1,this.msg2, this.subId,}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StatusUpdateState();
}

class StatusUpdateState extends State<StatusUpdate>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  List<Company> _companies = Company.getCompanies();
  List<DropdownMenuItem<Company>> _dropdownMenuItems;
  Company _selectedCompany;

  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;

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
      print(_selectedCompany.name);
    });
  }

  @override
  void initState() {
    super.initState();

    _dropdownMenuItems = buildDropdownMenuItems(_companies);

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: AppTheme.BUTTON_BG_COLOR,
          size: 50,
        ),
        dismissible: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              width: w / 1.2,
              height: h / 3,
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0))),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      InkWell(
                        child: Icon(Icons.cancel, color: Colors.red, size: 30,

                        ),onTap: (){
                        Navigator.pop(context);
                      },),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[

                              Icon(Icons.thumbs_up_down, color: Colors.orange,),

                              Text(
                                widget.msg2,
                                style: TextStyle(fontSize: h / 40,fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                     /* Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            widget.msg1,
                            style: TextStyle(fontSize: h / 40),
                          ),
                        ),
                      ),*/

                      DropdownButton(
                        itemHeight: 70,
                        focusColor: Colors.green,
                        iconEnabledColor: Colors.green,
                        iconSize: 50,

                        dropdownColor: Colors.deepOrangeAccent[50],
                        hint: Text("Subscription Status"),
                        value: _selectedCompany,
                        items: _dropdownMenuItems,
                        style: TextStyle(fontSize: 15,color: Colors.black, ),

                        onChanged: onChangeDropdownItem,
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: MaterialButton(

                            splashColor: AppTheme.BUTTON_BG_COLOR,
                            height: h / 18,
                            elevation: 2.0,
                            child: Text("OK",style: TextStyle(color: Colors.white),),

                            color: AppTheme.BUTTON_BG_COLOR,
                            shape: StadiumBorder(), onPressed: () {

                              if(_selectedCompany == null || _selectedCompany.name.isEmpty  ){
                                FToast.showCenter('Please update status');
                              }else{
                                updateSubscription(widget.subId, _selectedCompany.name[0]);

                              }

                          },
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///API call
  void updateSubscription(String subId, String status) {

    setState(() {
      _loading =true;
    });

    _authMethods.updateSubscription(subId,status).then((response) {

      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if(response['success'] == "1"){

        Navigator.pop(context);

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AdminDashboard()));   //todo


        FToast.show('Customer Subscription update successfully!');

      }
      else if(response['success'] == "0"){
          FToast.show("Something went wrong. Please try again! ");

        Navigator.pop(context);


      }else{
        FToast.show("API error");

      }
    });
  }
}

class Company {
  int id;
  String name;

  Company(this.id, this.name);

  static List<Company> getCompanies() {
    return <Company>[
      Company(1, 'Approved'),
      Company(2, 'Reject'),
      Company(3, 'Pending'),

    ];
  }
}
