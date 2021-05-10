/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:itts/utils/StyleColor.dart';

class FailDialog extends StatefulWidget {
  String msg1 = "",msg2="";

  FailDialog({Key key, this.msg1,this.msg2}) : super(key: key);

  @override
  State<StatefulWidget> createState() => FailDialogState();
}

class FailDialogState extends State<FailDialog>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

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

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            width: w / 1.2,
            height: h / 3.5,
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      child: Icon(Icons.cancel, color: Colors.red, size: 30,

                      ),onTap: (){
                      Navigator.pop(context);
                    },),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Text(
                          widget.msg2,
                          style: TextStyle(fontSize: h / 35,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          widget.msg1,
                          style: TextStyle(fontSize: h / 40),
                        ),
                      ),
                    ),

                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Center(
                          child: MaterialButton(
                            splashColor: AppTheme.BUTTON_BG_COLOR,
                            height: h / 18,
                            elevation: 2.0,
                            child: Text("Retry",style: TextStyle(color: Colors.white),),

                            color: AppTheme.BUTTON_BG_COLOR,
                            shape: StadiumBorder(), onPressed: () {

                            Navigator.pop(context);


                          },
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
