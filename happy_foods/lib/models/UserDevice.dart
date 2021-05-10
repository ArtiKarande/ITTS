

/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

class UserDevice{

  int id;
  var _deviceId,_temperature,_date,_time,_deviceName;

  UserDevice(this._deviceId, this._temperature, this._date, this._time,this._deviceName,[this.id]);

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

  get deviceId => _deviceId;

  set deviceId(value) {
    _deviceId = value;
  }
}