/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:happyfoods/Dashboard/DashboardTab.dart';
import 'package:happyfoods/bloc_pattern.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/payment/payment.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPayment extends StatefulWidget {

  String plan,package,noOfMeals,fromDate,toDate, pkgCost,pkgDays;

  SubscriptionPayment(this.plan,this.package,this.noOfMeals,this.fromDate,this.toDate, this.pkgCost, this.pkgDays);

  @override
  _SubscriptionPaymentState createState() => _SubscriptionPaymentState();
}

class _SubscriptionPaymentState extends State<SubscriptionPayment> {
  String UID="";
  String mobile="";
  String date, address1 = '', address2 = '';
  String fName = "",lName='',email='',userId;
  FToast utils=new FToast();
  SharedPreferences _preferences;
  double totalMealCost = 0.0;

  bool _saving = false;
  AuthMethods _authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();
    totalCalculation();
    getPreferencesValues();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(title: Text('Confirmation'),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
         // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            FDottedLine(
              color: Colors.orange,
              corner: FDottedLineCorner.all(6.0),
              child: Column(

                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(fName + ' ' + lName, style: utils.textStyle(context,50,Colors.black,FontWeight.bold,1.0),),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(email,
                      overflow: TextOverflow.ellipsis,
                      style: utils.textStyle(context,50,Colors.black,FontWeight.normal,0.0),),
                  ),


                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Address : ",
                          overflow: TextOverflow.ellipsis,
                          style: utils.textStyle(context,50,Colors.black,FontWeight.normal,0.0),),

                        Flexible(
                          child: Text(address1.isEmpty ? '' : address1,
                            overflow: TextOverflow.ellipsis,
                            style: utils.textStyle(context,50,Colors.black,FontWeight.normal,0.0),),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


            spaceHeight(40.0),


            Text('ORDER DETAILS' + '  (' + widget.noOfMeals + ' Meals )' ,style: utils.textStyle(context,40,Colors.black,FontWeight.bold,0.0),),

            SizedBox(height: 20,),

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Plan'),
                  Text(widget.plan),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Duration'),
                  Text(widget.package),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Meals Per Day '),
                  Text(widget.noOfMeals),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Start Date '),
                  Text(widget.fromDate),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('End Date '),
                  Text(widget.toDate),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Price '),
                  Text("₹ "+widget.pkgCost),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Delivery Charges'),
                  Text('Free',style: TextStyle(),),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top:30),
              child: Divider(
                height: 2.0,
                color: Colors.grey[400],
              ),
            ),

            SizedBox(height: 10,),

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Total'),
                  Text('₹ ' + totalMealCost.toString()),
                ],
              ),
            ),



            spaceHeight(50.0),
          //  SizedBox(height: 200,),

            GestureDetector(
              onTap: (){
                  //      confirmationDialog();
                addSubscription();
              },
              child: Container(
                height: h / 18,
                width: w/1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    color: AppTheme.BUTTON_BG_COLOR
                ),
                child: Center(child: const Text('CONTINUE',
                    style:TextStyle(fontSize: 18,color:Colors.white,)
                )
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  void getPreferencesValues() async{
    _preferences = await SharedPreferences.getInstance();
    setState(() {

      address1 = _preferences.getString("address1");
      address2 = _preferences.getString("address2");
      fName = _preferences.getString("fname");
      lName = _preferences.getString("lname");
      email = _preferences.getString("email");

    });

    print('address1:::$address1');
    print('address2::$address2');
  }

 Widget spaceHeight(height){
    return SizedBox(height: height,);
  }

  totalCalculation(){
    double oneMealCost = 0.0;
    int totalMeal = 0;

    setState(() {
      oneMealCost =  double.parse(widget.pkgCost);
      totalMeal = int.parse(widget.noOfMeals);

      totalMealCost = ( oneMealCost * totalMeal );

    });

    print(oneMealCost);
    print(totalMeal);
    print(totalMealCost);
  }

  Future<bool> confirmationDialog() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Payment Confirmation'),
        content: Container(
          height: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Do you want to payment with '),
                  Text('Gpay', style: TextStyle(color: Colors.blue),)
                ],
              ),

              SizedBox(height: 10,),

              Text('If yes then please tap on'),
              Row(
                children: <Widget>[
                  Text('yes ', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                  Text('option '),
                ],
              ),


            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);

          //    addSubscription();


            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void addSubscription() async {

    final StateProviderManagement counterBloc = Provider.of<StateProviderManagement>(context);


    setState(() {
      _saving = true;
    });

    _authMethods.addSubscription(widget.plan,widget.package,widget.pkgCost,widget.pkgDays,
        widget.fromDate,widget.toDate,widget.noOfMeals, totalMealCost, address1).then((response) {

      setState(() {
        _saving = false;
      });

      if(response['success'] == "1"){

        Navigator.pop(context);

        ///to redirect to [payment] screem pass [3rd  index]
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DashboardTab(3)));

        FToast.show("Thanks for subscribing with Hashtag Happy Food. Have a great day! ");

        counterBloc.setTagValue('SELECT PLAN');
        counterBloc.setPkgValue('SELECT PACKAGE');
        counterBloc.setPackageCost('');
        counterBloc.setFromDate('yyyy-mm-dd');
        counterBloc.setToDate('yyyy-mm-dd');
      }
      else if(response['success'] == "0"){
        FToast.show("subscription error");
      }
    });
  }
}
