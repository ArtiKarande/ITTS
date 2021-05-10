/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:url_launcher/url_launcher.dart';

class EnquiryDetails extends StatefulWidget {

  @override
  _EnquiryDetailsState createState() => _EnquiryDetailsState();
}

class _EnquiryDetailsState extends State<EnquiryDetails> {

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.background1,
        appBar: AppBar(
          title: Text("Enquiry"),
        ),
        body:
        _myListView(context),
      ),
    );
  }

  Widget _myListView(BuildContext context) {

    return ListView(
      children: <Widget>[
        Card(

          child: ListTile(
            title: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text("sales@skromanglobal.com"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.email,color: AppTheme.darkText,),
                      ),
                    ],
                  ),


                ],


              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Rajendra  ',style: TextStyle(fontFamily: AppTheme.fontName, fontWeight: FontWeight.w400, fontSize: 17, letterSpacing: 0.0,
                    color: AppTheme.darkText,
                  ),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('8956457909'),
                      InkWell(
                        onTap: (){
                          launch("tel:"+"8956457909");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.call,color: AppTheme.darkText,),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text("rajendra@skromanglobal.com"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.email,color: AppTheme.darkText,),
                      ),
                    ],
                  ),


                ],


              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Deepak',style: TextStyle(fontFamily: AppTheme.fontName, fontWeight: FontWeight.w400, fontSize: 17, letterSpacing: 0.0,
                    color: AppTheme.darkText,
                  ),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('9766297155'),
                      InkWell(
                        onTap: (){
                          launch("tel:"+"9766297155");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.call,color: AppTheme.darkText,),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text("deepak@skromanglobal.com"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.email,color: AppTheme.darkText,),
                      ),
                    ],
                  ),


                ],


              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Siddhesh',style: TextStyle(fontFamily: AppTheme.fontName, fontWeight: FontWeight.w400, fontSize: 17, letterSpacing: 0.0,
                    color: AppTheme.darkText,
                  ),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('8237100114'),
                      InkWell(
                        onTap: (){
                          launch("tel:"+"8237100114");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.call,color: AppTheme.darkText,),
                        ),
                      ),
                    ],
                  ),



                ],


              ),
            ),
          ),
        ),
      ],
    );
  }
}
