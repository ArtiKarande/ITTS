/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/guid/GuidView.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';

class GuidScreen extends StatefulWidget {
  @override
  GuidView createState() => new GuidView();
}

/// guide screen functionality is provided here

abstract class GuidState extends State<GuidScreen> {
  bool isVisible = true;
  bool isVisible1 = false;
  int count = 0;

  /// count is maintained
  void showOverlay(BuildContext context) {
    setState(() {
      if (isVisible) {
        count = 1;
        isVisible = !isVisible;
        count++;
        print("isVisible${count}${isVisible}");
      } else {
        count = 3;
        print("isVisible${count}${isVisible}");
      }


      ///when count is 3 means user is reached to last guideline, then automatically close this guidance page
      Future.delayed(const Duration(milliseconds: 3000), () async {  //5000 milisec
        if (count == 3) {
          print("count:::$count");
          Navigator.of(context).pushReplacementNamed(MasterDetail.tag);
        }
      });
      // isVisible1 = !isVisible1;
    });
  }
}
