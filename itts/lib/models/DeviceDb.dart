/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

//local database uses this modelclass

import 'package:itts/models/userDetails.dart';
import 'package:itts/utils/FToast.dart';

class DeviceDb {
  int id;
  String temperature;
  String date;
  String time;
  String deviceId;

  DeviceDb(this.temperature, this.date, this.time, this.deviceId,[this.id]);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columntemperature: temperature,
      columndate: date,
      columntime: time,
      columndeviceId:deviceId,

    };
    if (id != null) {
      map[cid] = id;
    }
    return map;
  }
  DeviceDb.fromMap(Map<String, dynamic> map) {
    id = map[cid];
    temperature = map[columntemperature];
    date = map[columndate];
    time = map[columntime];
    deviceId = map[columndeviceId];

  }
}