import 'package:flutter/material.dart';

class DeleteDialog extends StatefulWidget {

  String msg = "", msg1 = "";

  DeleteDialog({Key key, this.msg, this.msg1}) : super(key: key);


  @override
  State<StatefulWidget> createState() => DeleteDialogState();
}

class DeleteDialogState extends State<DeleteDialog>
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
            height: h / 5.1,
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
                //  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.msg1,
                      style: TextStyle(fontSize: h / 35,color: Colors.black,fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 10,),

                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        widget.msg,
                        style: TextStyle(fontSize: h / 46,color: Colors.black,fontWeight: FontWeight.normal),
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
