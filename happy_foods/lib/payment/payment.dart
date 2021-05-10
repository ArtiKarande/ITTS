/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:happyfoods/API/api_call.dart';
import 'package:happyfoods/API/api_response.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';

class Payment extends StatefulWidget {
  const Payment({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String UID="";
  String mobile="";
  String date;

  FToast utils=new FToast();

  ///cache declaration
  ApiCall _apiCall = new ApiCall();



  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;


    return Scaffold(

      body:

   /*   FutureBuilder<ApiResponse>(
        future: _apiCall.getUserDataResponse(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<UserData> usersList = List<UserData>();

            usersList = snapshot.data.plans;

            print('my cache');
            print(usersList.length);
            print(usersList);

            return ListView.builder(
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  UserData userData = usersList[index];

                  print(userData.type);

                  return ListTile(
                    title: Text(userData.type + " " + userData.cost),
                    subtitle: Text(userData.plan),
                  );
                });

          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
*/
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          SizedBox(height: 100,),
          Image.asset('images/payment.png',),

          SizedBox(height: 80,),

          Text("Hashtag Happy Food Gpay Number Is  ",
            style: utils.textStyle(context,40,Colors.green,FontWeight.normal,0.0),),

          SizedBox(height: 10,),

          Text("9960656560",
            overflow: TextOverflow.ellipsis,
            style: utils.textStyle(context,20,Colors.black,FontWeight.normal,0.0),),

        ],
      ),


    );
  }
}
