/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';

class ShowCustomSnack{
  static bool _isSnackbarActive = false ;

  static getCustomSnack(BuildContext context , GlobalKey<ScaffoldState> _scaffoldKey , String text){

    _isSnackbarActive = true ;

    return _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        )
    ).closed.then((SnackBarClosedReason reason) {

      _isSnackbarActive = false ;
    //  _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.removeCurrentSnackBar();
    });
  }

  static getCustomSnackColor(BuildContext context , GlobalKey<ScaffoldState> _scaffoldKey , String text, MaterialColor color){

    _isSnackbarActive = true;

    return _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: color,
          duration: const Duration(seconds: 8),
          content: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        )
    ).closed.then((SnackBarClosedReason reason) {

      _isSnackbarActive = false ;
      _scaffoldKey.currentState.removeCurrentSnackBar();
    });
  }
}
