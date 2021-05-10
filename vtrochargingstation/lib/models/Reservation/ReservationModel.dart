/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class ReservationModel{

  var _reservation_id, _user_id, _chargerType, _bookDate, _timeSlot, _station_id, _amount, _stationName, _stationImage,
      _is_redirect_scan, _is_cancel_redirect, _rStartTime;

  ReservationModel(
      this._reservation_id,
      this._user_id,
      this._chargerType,
      this._bookDate,
      this._timeSlot,
      this._station_id,
      this._amount,
      this._stationName,
      this._stationImage,
      this._is_redirect_scan,
      this._is_cancel_redirect,
      this._rStartTime);

  get rStartTime => _rStartTime;

  set rStartTime(value) {
    _rStartTime = value;
  }

  get is_redirect_scan => _is_redirect_scan;

  set is_redirect_scan(value) {
    _is_redirect_scan = value;
  }

  get is_cancel_redirect => _is_cancel_redirect;

  set is_cancel_redirect(value) {
    _is_cancel_redirect = value;
  }

  get stationImage => _stationImage;

  set stationImage(value) {
    _stationImage = value;
  }

  get stationName => _stationName;

  set stationName(value) {
    _stationName = value;
  }

  get amount => _amount;

  set amount(value) {
    _amount = value;
  }

  get station_id => _station_id;

  set station_id(value) {
    _station_id = value;
  }

  get timeSlot => _timeSlot;

  set timeSlot(value) {
    _timeSlot = value;
  }

  get bookDate => _bookDate;

  set bookDate(value) {
    _bookDate = value;
  }

  get chargerType => _chargerType;

  set chargerType(value) {
    _chargerType = value;
  }

  get user_id => _user_id;

  set user_id(value) {
    _user_id = value;
  }

  get reservation_id => _reservation_id;

  set reservation_id(value) {
    _reservation_id = value;
  }
}