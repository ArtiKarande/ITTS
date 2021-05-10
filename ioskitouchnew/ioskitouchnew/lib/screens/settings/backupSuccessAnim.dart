import 'package:flutter/material.dart';

class FunkyOverlay extends StatefulWidget {

  String msg = "";

  FunkyOverlay({Key key, this.msg}) : super(key: key);


  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
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
            height: h / 5.5,
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
                   /* Center(
                        child: Image.asset(
                      "images/logo_skroman.png",
                      width: 80,
                      height: 50,
                    )),*/

                    Text('Connection Failed!',style: TextStyle(fontSize: h / 40,color: Colors.black, fontWeight: FontWeight.bold)),

                    SizedBox(height: 10,),
                    Center(
                      child: Text(
                        widget.msg,
                        style: TextStyle(fontSize: h / 45,color: Colors.black),
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
