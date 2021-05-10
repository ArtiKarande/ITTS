/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
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
      //  backgroundColor: Colors.black,
        /*appBar: AppBar(
          title: Text("Enquiry"),
        ),*/
        body:
        _myListView(context),
      ),
    );
  }

  Widget _myListView(BuildContext context) {

    return ListView(
      children: <Widget>[

        SizedBox(height: 20,),

        /*Card(
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text("info@skromanglobal.com"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.email,color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),*/
        /*ListTile(
          title: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Kushal Nadre  ',style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17, letterSpacing: 0.0,
                  color: Colors.white,
                ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('8329037953'),
                    InkWell(
                      onTap: (){
                        launch("tel:"+"8329037953");
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.call,color: Colors.white,),
                      ),
                    ),
                  ],
                ),
                *//*Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text("rajendra@skromanglobal.com"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.email,color: Colors.white),
                    ),
                  ],
                ),*//*


              ],


            ),
          ),
        ),*/

      /*  Padding(
          padding: const EdgeInsets.all(20.0),
          child: Divider(height: 1,color: Colors.white70,),
        ),*/

        ListTile(
          title: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Customer care',style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17, letterSpacing: 0.0,
                  color: Colors.white,
                ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('9373332456'),
                    InkWell(
                      onTap: (){
                        launch("tel:"+"9373332456");
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.call,color: Colors.white,),
                      ),
                    ),
                  ],
                ),
             /*   Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text("deepak@skromanglobal.com"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.email,color: Colors.white,),
                    ),
                  ],
                ),*/

              ],


            ),
          ),
        ),

       /* Card(
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Siddhesh',style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17, letterSpacing: 0.0,
                    color: Colors.white,
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
                          child: Icon(Icons.call,color: Colors.white),
                        ),
                      ),
                    ],
                  ),



                ],


              ),
            ),
          ),
        ),*/

      ],
    );
  }
}

/*

https://youtu.be/0IUh5LwqpVE



* */