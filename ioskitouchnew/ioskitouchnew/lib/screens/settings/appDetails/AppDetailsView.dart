/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
import 'package:ioskitouchnew/common/StyleColor.dart';
import 'package:ioskitouchnew/screens/settings/appDetails/appDetails.dart';

class AppDetailsView extends AppDetailsState{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(StringConstants.ABOUT_APP),
        backgroundColor: Theme.of(context).primaryColor,
        // automaticallyImplyLeading: false,
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[toTextBuild()],
        ),
      ),
    ) ;
  }

  Widget toTextBuild() {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
      // Edit
      new Container(
      child: new Text("Version: $version"),
      margin: const EdgeInsets.all(15.0),
    ),
            new Container(
              child: new Text("Name: Skroman iTouch"),
              margin: const EdgeInsets.all(15.0),
            )]));}
}