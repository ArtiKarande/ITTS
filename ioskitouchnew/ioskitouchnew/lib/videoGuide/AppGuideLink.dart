import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppGuideLink extends StatefulWidget {
  @override
  _AppGuideLinkState createState() => _AppGuideLinkState();
}

class _AppGuideLinkState extends State<AppGuideLink> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
      //  mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('This video demonstrates the features and how to guide for Skroman iTouch app.', )),
          ),

          SizedBox(height: 60,),

          RaisedButton(
              elevation: 0.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(0.0)),
              padding: EdgeInsets.only(
                  top: 17.0, bottom: 17.0, right: 70.0, left: 17.0),
              onPressed: () {
                _launchURL();
              },
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Image.asset('images/youtube.png',
                      height: 40.0, width: 50.0),
                  Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Watch Configuration Steps  ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15.0),
                      ))
                ],
              ),
              textColor: Colors.black,
              color: Colors.white),



        ],
      ),
    );
  }

  _launchURL() async {
    const url = 'https://youtu.be/0IUh5LwqpVE';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
