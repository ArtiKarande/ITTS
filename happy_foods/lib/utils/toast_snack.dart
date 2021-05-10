/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';

class ShowCustomSnack{

  static getCustomSnack(BuildContext context , GlobalKey<ScaffoldState> _scaffoldKey , String text){

    return _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,

            ),
          ),
        )
    );

  }

}
