/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/common/app_theme.dart';

/// common class for edit text UI
class NeumorphicTextField extends StatefulWidget {
  final String label;
  final double height;
  final String hint;
  final String text;
  final double textSize;
  final bool autofocus;
  final bool multilines;

  final ValueChanged<String> onChanged;

  NeumorphicTextField({
    Key key,
    this.label,
    this.height,
    this.hint,
    this.text,
    this.textSize,
    this.autofocus = false,
    this.multilines = false,
    this.onChanged,
  }) : super(key: key);

  @override
  _TextFieldState createState() => _TextFieldState();
}

class _TextFieldState extends State<NeumorphicTextField> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.text);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    AppTheme utils = new AppTheme();

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null) TextFieldLabel(widget.label),
        Neumorphic(
          margin: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 4),
          style: NeumorphicStyle(
          //  depth: NeumorphicTheme.embossDepth(context),
            depth: -7,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),  // side border
              shadowDarkColorEmboss: AppTheme.bottomShadow,  //  inner top shadow
              shadowLightColorEmboss: Colors.white, // inner bottom shadow
              disableDepth: false,
             surfaceIntensity: 5,

              color: AppTheme.background,
              shape: NeumorphicShape.convex,
              intensity: 0.99,// inner shadow effect
          ),
          padding: EdgeInsets.symmetric(vertical: widget.height, horizontal: 14),
          child: TextField(style: utils.textStyleRegular(context,widget.textSize, AppTheme.text1,FontWeight.w700, 0.0,''), // writing text color
            cursorColor: AppTheme.greenShade1,
            onChanged: widget.onChanged,
            controller: _controller,
            autofocus: widget.autofocus,
        //    keyboardType: TextInputType.number,
            maxLines: 1,
            decoration: InputDecoration.collapsed(hintText: widget.hint,
          //      hintStyle: TextStyle(color: Color(0xFFB2B2B2), fontSize: h/45)),  // hint text color
                hintStyle: utils.textStyleRegular(context,widget.textSize, AppTheme.text4,FontWeight.w700, 0.0,'')), // hint text color
          ),
        )
      ],
    );
  }
}

class TextFieldLabel extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry padding;


  const TextFieldLabel(
      this.label, {
        Key key,
        this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme utils = new AppTheme();

    return Padding(
      padding: padding,
      child: Text(
        label,
        style: utils.textStyleRegular2(context, FontWeight.w400),
      ),
    );
  }
}
