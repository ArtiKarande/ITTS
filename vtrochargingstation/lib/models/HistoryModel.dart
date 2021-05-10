/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class HistoryModel{

  var _requestId,_stationImage,_stationId, _energyConsume, _amount, _startdate, _startTime, _type;

  HistoryModel(this._requestId, this._stationImage, this._stationId,
      this._energyConsume, this._amount, this._startdate, this._startTime, this._type);

  get startTime => _startTime;

  set startTime(value) {
    _startTime = value;
  }

  get startdate => _startdate;

  set startdate(value) {
    _startdate = value;
  }

  get type => _type;

  set type(value) {
    _type = value;
  }

  get amount => _amount;

  set amount(value) {
    _amount = value;
  }

  get energyConsume => _energyConsume;

  set energyConsume(value) {
    _energyConsume = value;
  }

  get stationId => _stationId;

  set stationId(value) {
    _stationId = value;
  }

  get stationImage => _stationImage;

  set stationImage(value) {
    _stationImage = value;
  }

  get requestId => _requestId;

  set requestId(value) {
    _requestId = value;
  }
}