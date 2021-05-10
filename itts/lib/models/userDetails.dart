/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:itts/utils/FToast.dart';

class UserDetails{

  int id;
var _deviceId,_temperature,_date,_time;
var userId,empName,timeType, newDate1;

UserDetails(this._deviceId, this._temperature, this._date, this._time,
    this.userId,this.empName,this.timeType,[this.id]);

get time => _time;

set time(value) {
  _time = value;
}

get date => _date;

set date(value) {
  _date = value;
}

get temperature => _temperature;

set temperature(value) {
  _temperature = value;
}

get deviceId => _deviceId;

set deviceId(value) {
  _deviceId = value;
}

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
UserDetails.fromMap(Map<String, dynamic> map) {
  id = map[cid];
  temperature = map[columntemperature];
  date = map[columndate];
  time = map[columntime];
  deviceId = map[columndeviceId];

}


}