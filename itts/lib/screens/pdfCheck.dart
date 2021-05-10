/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

/*


import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

///not in use this classss for now

class pdfCheck extends StatefulWidget {
  @override
  _pdfCheckState createState() => _pdfCheckState();
}

class _pdfCheckState extends State<pdfCheck> {

  bool _isLoading = true;
  PDFDocument document;
  String pathPDF = "";


  @override
  void initState() {
    // TODO: implement initState

    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f.path;
        print(pathPDF);
      });
    });

   // doc();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body:

      Center(
        child: RaisedButton(
          child: Text("Open PDF"),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PDFScreen(pathPDF)),
          ),
        ),
      ),

    );
  }

  void doc() async{

    document = await PDFDocument.fromURL(
        "https://skromanglobal.com/ITTS/pdf_api/pdf/getlatestdata10000008.pdf");

    setState(() => _isLoading = false);
  }

  Future<File> createFileOfPdfUrl() async {
    final url = "https://skromanglobal.com/ITTS/pdf_api/pdf/getlatestdata10000008.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Details"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                shareFile();

              },
            ),
          ],
        ),
        path: pathPDF);
  }

  Future<void> shareFile() async {

    print("got path::: $pathPDF");
//    List<dynamic> docs = await DocumentsPicker.pickDocuments;
//    if (docs == null || docs.isEmpty) return null;

   */
/* await FlutterShare.shareFile(
      title: 'share',
      text: 'share text',
    //  filePath: docs[0] as String,
      filePath: pathPDF,
    );*//*

    ShareExtend.share(pathPDF, "file");
  }
}
*/
