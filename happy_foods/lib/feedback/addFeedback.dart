/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'file:///D:/skromanApp/happy_foods/lib/dialogBox/successDialog.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;

class AddFeedback extends StatefulWidget {
  @override
  _AddFeedbackState createState() => _AddFeedbackState();
}

class _AddFeedbackState extends State<AddFeedback> {
  bool _saving = false;

  final color2 = const Color(0xFFF2F2F2);
//  var teacherDetails = new List<TeacherPojo>();
  FToast utils = new FToast();
  String _mySelection,description;
  List data = List(); //edited line
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();


  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return LayoutBuilder(builder: (context, constrain) {

      if (constrain.maxWidth <= 600) {

        return ModalProgressHUD(
          inAsyncCall: _saving,
          opacity: 0.5,
          progressIndicator: SpinKitFadingCircle(
            color: Color(0xFF765d93),
            size: 100,
          ),
          dismissible: false,
          child: Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.deepOrange, //change your color here
                ),
                backgroundColor: Color(0xFFFAFAFA),
                title: Text('Feedback', style: TextStyle(
                    color: Colors.deepOrange,
                    )),),

              body: SingleChildScrollView(
                child: Container(
                  height: h,
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
                      image: new AssetImage('images/doodle.jpg'),
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                   /* Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Great ! Is there anything that we can improve?',
                        style: utils.textStyle(context, 60, Colors.red, FontWeight.normal, 0.0,),),
                      ],
                    ),*/

                      Container(
                          height: 30,
                          width: w,
                          color: Colors.red[50],
                          child: Center(
                            child: Text(
                                'Great ! Is there anything that we can improve?',
                              style: utils.textStyle(context, 60, Colors.red, FontWeight.normal, 0.0,),),
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: h/10,left: w/20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[

                            feedback(50),

                            rating(),

                            SizedBox(height: 40,),

                            MaterialButton(
                              splashColor: AppTheme.BUTTON_BG_COLOR,
                              height: h / 18,
                              minWidth: w/3,
                              elevation: 2.0,

                              child: Text("Submit",style: TextStyle(color: Colors.white),),

                              color: AppTheme.BUTTON_BG_COLOR,
                              shape: StadiumBorder(), onPressed: () {

                              if(_titleController.text.isEmpty){

                                FToast.showCenter('Please enter feedback title');
                              }else if(_descriptionController.text.isEmpty){
                                FToast.showCenter('Please enter description');
                              }else{
                                showDialog(
                                  context: context,
                                  builder: (_) => FunkyOverlay(
                                    msg: "Thanks for your feedback!",
                                  ),
                                );

                                _titleController.text ='';
                                _descriptionController.text ='';
                              }


                            },
                            ),



                          ],
                        ),
                      )

                    ],
                  ),
                ),
              )),
        );
      } else {
        return Scaffold();
      }
    });
  }



  feedback(int font1) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Feedback',
              style: utils.textStyle(context, font1, Colors.black, FontWeight.normal, 1.0),

            ),

            getTextField("title", "Please Enter title",
                _titleController),

            Padding(
              padding: EdgeInsets.only(right: w / 20,top: h/30),
              child: Material(
                child: TextFormField(
                  controller: _descriptionController,
                    maxLines: 6,
                    maxLength: 200,
                    decoration: InputDecoration(
                        labelText: 'Description',
                        counterText: "",
                        border: OutlineInputBorder()),

                    onSaved: (String val) {
                      description = val;
                    }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  rating(){

    double h = MediaQuery.of(context).size.height;

    return  Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top:h/25),
              child: Text("How was your experience? ",),
            ),
            FlutterRatingBar(
              initialRating: 4,
              fillColor: Colors.deepOrange[400],
              itemCount: 5,
              itemSize: 35.0,
              borderColor: Colors.deepOrange.withAlpha(90),
              allowHalfRating: true,

              onRatingUpdate: (rating) {
                setState(() {
                  rating = rating;
                  // ratingValue=rating.toString();

                  print(rating);
                  print(rating.toInt());
                  print("myratings");
                  //   ratingValue=counterBloc.ratingvalue.toString();
                  //  counterBloc.setRatingValue(rating);
                });
              },
            ),
          ],
        ),
      ],
    );

  }

  getTextField(hintText, errorText, TextEditingController _controller) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(right:20.0,top: 10),
      child: TextFormField(
        controller: _controller,
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
            border: OutlineInputBorder( borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.only(left: 14.0)),
      ),
    );
  }

}
