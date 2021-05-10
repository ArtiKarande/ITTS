/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

//dialog_homework
import 'package:flutter/material.dart';
import 'package:itts/utils/FToast.dart';

class DialogDevice extends StatefulWidget {

  DialogDevice({Key key, }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DialogDeviceState();
}

class DialogDeviceState extends State<DialogDevice>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  @override
  void initState() {
    super.initState();

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

    FToast utils = new FToast();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            width: w / 1.2,
            height: h / 2,
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:h/70.0,right: w/40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      InkWell(
                        child: Icon(Icons.cancel, color: Colors.red, size: 40,

                        ),onTap: (){
                        Navigator.pop(context);
                      },),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                 //     SizedBox(height: 10,),

                      Text(
                        'Details',
                        style: utils.textStyle(context, 40,
                            Colors.black, FontWeight.bold, 2.0),
                      ),


                      SizedBox(height: 10,),
                      Row(
                        children: <Widget>[
                          Text(
                            'Device ID: ',
                            style: utils.textStyle(context, 60,
                                Colors.black, FontWeight.normal, 1.0),
                          ),

                          Text(
                            '26th may ',
                            style: utils.textStyle(context, 60,
                                Colors.black, FontWeight.normal, 1.0),
                          ),


                        ],
                      ),


                      Text(
                        'Password ',
                        style: utils.textStyle(context, 60,
                            Colors.black, FontWeight.normal, 1.0),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 1,
                          width: double.maxFinite,
                          color: Colors.grey[200],
                        ),
                      ),

                      Text(
                        'Temperature ',
                        style: utils.textStyle(context, 50,
                            Colors.black, FontWeight.normal, 2.0),
                      ),


                      new Container(
                        margin:  EdgeInsets.only(top:h/45.0),
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300])
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("50 degree ",maxLines: 4,
                            style: utils.textStyle(context, 60,
                                Colors.black, FontWeight.bold, 1.0),

                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top:h/20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Time Frame',
                              style: utils.textStyle(context, 50,
                                  Colors.black, FontWeight.bold, 2.0),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Date : ',
                                      style: utils.textStyle(
                                          context,
                                          55,
                                          Colors.black,
                                          FontWeight.normal,
                                          1.0),
                                    ),
                                    InkWell(
                                      onTap: () {

                                      },
                                      child: Text(
                                        '2020-05-05',
                                        style: utils.textStyle(
                                            context,
                                            55,
                                            Colors.grey,
                                            FontWeight.normal,
                                            1.0),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: h / 20,
                                    width: 1,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Time : ',
                                      style: utils.textStyle(
                                          context,
                                          55,
                                          Colors.black,
                                          FontWeight.normal,
                                          1.0),
                                    ),
                                    InkWell(
                                      onTap: () {

                                      },
                                      child: Text(
                                        '06:49',
                                        style: utils.textStyle(
                                            context,
                                            55,
                                            Colors.grey,
                                            FontWeight.normal,
                                            1.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
