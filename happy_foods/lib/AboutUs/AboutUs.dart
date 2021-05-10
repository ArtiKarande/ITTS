/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: Colors.deepOrange, //change your color here
          ),
          backgroundColor: Color(0xFFFAFAFA),
          title: Text('About US',
              style: TextStyle(
                color: Colors.deepOrange,
              )),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Center(child: Image.asset('images/fresh.jpg',height: 200,)),

                SizedBox(height: 30,),

                Text('Healthy meal delivery service.'),
                Text('Healthy meal subscription.'),
                Text('Diet food subscriptions.'),
                Text('Nutritionist.'),
                Text('Fitness expert'),

                SizedBox(height: 30,),

                Center(child: Text('No more dieting, lets start editing',style: TextStyle(
                    color: Colors.blue,fontWeight: FontWeight.bold))),

                SizedBox(height: 30,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('Know more... '),
                    Text('8600190140', style: TextStyle(
                      color: Colors.deepOrange,fontWeight: FontWeight.bold
                    )),
                  ],
                ),
                SizedBox(height: 30,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                        onTap: (){
                          launch('https://instagram.com/hashtaghappyfoods?igshid=y2qzhymn6hdm');
                        },
                        child: Image.asset('images/instagram.png',height: 40,)),
                    InkWell(
                        onTap: (){
                          launch("https://facebook.com");
                        },
                        child: Image.asset('images/facebook.png',height: 40,)),
                  ],
                ),

                SizedBox(height: 30,),

              ],
            ),
          ),
        ));
  }
}
