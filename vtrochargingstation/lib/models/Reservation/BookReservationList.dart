/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class Book{
  var _date, _day, _currentDate;
  List<TimeSlotNew> _time;

  Book(this._date, this._day, this._currentDate, this._time);

  get day => _day;

  set day(value) {
    _day = value;
  }

  get currentDate => _currentDate;

  set currentDate(value) {
    _currentDate = value;
  }

  get date => _date;

  set date(value) {
    _date = value;
  }

  List<TimeSlotNew> get time => _time;

  set time(List<TimeSlotNew> value) {
    _time = value;
  }
}

class TimeSlotNew{

  var _status;

  TimeSlotNew(this._status);

  get status => _status;

  set status(value) {
    _status = value;
  }
}
