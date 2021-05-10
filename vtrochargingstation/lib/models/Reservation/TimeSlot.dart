/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class TimeSlot{
  var _timeSlot, _status;

  TimeSlot(this._timeSlot, this._status);

  get status => _status;

  set status(value) {
    _status = value;
  }

  get timeSlot => _timeSlot;

  set timeSlot(value) {
    _timeSlot = value;
  }
}