/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ioskitouchnew/videoGuide/videoGuide.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';

class AppGuideNew extends StatefulWidget {
  @override
  _AppGuideNewState createState() => _AppGuideNewState();
}

class _AppGuideNewState extends State<AppGuideNew> {

  String pathPDF = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f.path;
        print(pathPDF);
      });
    });
  }
  Future<File> createFileOfPdfUrl() async {
    final url = "https://skromanglobal.com/ITTS/ITTS-20_manual.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Colors.blue,
          size: 50,
        ),
        dismissible: false,
        child: Scaffold(

          appBar: AppBar(title: Text("Options"),),

         body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
     //    crossAxisAlignment: CrossAxisAlignment.center,
             children: <Widget>[
               InkWell(
                 onTap: (){

                   setState(() {
                     _loading = true;
                   });

                   Navigator.push(context,
                       MaterialPageRoute(builder: (context) => YoutubePlayerDemoApp()));

                   setState(() {
                     _loading = false;
                   });
                 },

                 child: Container(
                   alignment: Alignment.center,
                   //height: h / 20,
                   width: w / 2.5,
                   padding: const EdgeInsets.symmetric(vertical: 10.0),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(colors: [
                       Colors.blue,
                       Colors.blue,
                     ]),
                     borderRadius: BorderRadius.circular(10),

                   ),
                   child: Text(
                     "Watch video online",
                     style:
                     TextStyle(fontSize: h / 45, color: Colors.white),
                   ),
                 ),
               ),


               /*SizedBox(height:20 ,),

               InkWell(
                 onTap: ()async{

                   await new Future.delayed(const Duration(seconds: 4));
                   *//*Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => PDFScreen(pathPDF)),
                   );*//*
                 },
                 child: Container(
                   alignment: Alignment.center,
                   //height: h / 20,
                   width: w / 2.5,
                   padding: const EdgeInsets.symmetric(vertical: 10.0),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(colors: [
                       Colors.blue,
                       Colors.blue,
                     ]),
                     borderRadius: BorderRadius.circular(10),

                   ),
                   child: Text(
                     "App Instructions",
                     style:
                     TextStyle(fontSize: h / 45, color: Colors.white),
                   ),
                 ),
               ),*/

             ],
           ),
         ),

        ),
      ),
    );
  }
}
