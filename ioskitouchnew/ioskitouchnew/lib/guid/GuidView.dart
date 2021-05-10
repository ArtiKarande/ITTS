/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/guid/Guid.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';

/// user interface of guidance there are 3 widgets
/// menu, homepage, cloud symbol guidance

class GuidView extends GuidState {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        body: new InkWell(
            onTap: () {
              print("tap");
              showOverlay(context);
            },
            child: count == 0
                ? new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        new Container(
                          height: 90.0,
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 30.0),
                          child: new Image.asset('images/rightarrow.png'),
                        ),
                        new Container(
                          height: 50.0,
                          child: Text(
                              'Menu: To change Home, Settings to add home, room & \n device and Syn for data synchronization.'),
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 20.0),
                        ),
                      ])
                : count == 2
                    ? new Column(
                        children: <Widget>[
                          new Container(
                            child: new RaisedButton(
                              onPressed: () {},
                              child: new Text("Home"),
                              color: Colors.grey,
                            ),
                            alignment: Alignment.center,
                          ),
                          new Container(
                            height: 90.0,
                            alignment: Alignment.center,
                            child: new Image.asset('images/straightarrow.png'),
                          ),
                          new Container(
                            height: 50.0,
                            alignment: Alignment.center,
                            child: Text('Home Name'),
                            margin: const EdgeInsets.only(left: 20.0),
                          ),
                        ],
                      )
                    : count == 3
                        ? new Column(
                            children: <Widget>[
                              new Container(
                                height: 90.0,
                                alignment: Alignment.topRight,
                                margin: const EdgeInsets.only(right: 30.0),
                                child: new Image.asset('images/leftarrow.png'),
                              ),
                              new Container(
                                height: 50.0,
                                alignment: Alignment.topRight,
                                child: Text('Switch to turn cloud mode ON/OFF'),
                                margin: const EdgeInsets.only(right: 20.0),
                              ),
                            ],
                          )
                        : new Container()),
        backgroundColor: Colors.black.withOpacity(0.5));
  }
}
//                new Container(
//                  child: new Icon(Icons.menu),
//                  height: 30.0,
//                  width: MediaQuery.of(context).size.width,
//                  alignment: Alignment.topLeft,
//                  margin: const EdgeInsets.only(left: 10.0),
//                ),
