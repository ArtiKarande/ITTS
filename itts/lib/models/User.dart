/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

//local database uses this modelclass

import 'package:itts/models/userDetails.dart';
import 'package:itts/utils/FToast.dart';

class User {
  int id;
  String name;
  String password;
  String userId;
  String date;
  String time;
  String deviceName;
  String datenew;
  List<UserDetails> childList;
  int indexChildList;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnPassword: password,
      columnUserId: userId,
      columnDate:date,
      columnTime:time,
      columnDeviceName:deviceName,
      columnNewDate:datenew,

    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  User( this.name, this.password, this.userId, this.date, this.time,this.deviceName,this.datenew,
      [this.id, this.indexChildList,this.childList]);

  User.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    password = map[columnPassword];
    userId = map[columnUserId];
    date = map[columnDate];
    time= map[columnTime];
    deviceName= map[columnDeviceName];
    datenew= map[columnNewDate];

  }
}