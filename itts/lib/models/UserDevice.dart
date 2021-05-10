/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:itts/utils/FToast.dart';

class UserDevice{

  int id;

  get timetype => _timetype;

  set timetype(value) {
    _timetype = value;
  }

  get userName => _userName;

  set userName(value) {
    _userName = value;
  }

  String _deviceId,_temperature,_date,_time,_deviceName,_timetype,_userName;

  UserDevice(this._deviceId, this._temperature, this._date, this._time,this._deviceName,this._timetype,this._userName,[this.id]);

  get time => _time;

  set time(value) {
    _time = value;
  }

  get deviceName => _deviceName;

  set deviceName(value) {
    _deviceName = value;
  }

  get date => _date;

  set date(value) {
    _date = value;
  }

  get temperature => _temperature;

  set temperature(value) {
    _temperature = value;
  }

  get deviceId => _deviceId.substring(3);  //arti changes

  set deviceId(value) {
    _deviceId = value;
  }
}