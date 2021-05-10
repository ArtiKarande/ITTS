/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class GoldCardModel{

  var _requestId, _stationImage, _stationId, _stationName, _energyConsume, _amount, _startDate, _startTime;

  GoldCardModel(
      this._requestId,
      this._stationImage,
      this._stationId,
      this._stationName,
      this._energyConsume,
      this._amount,
      this._startDate,
      this._startTime);

  get startTime => _startTime;

  set startTime(value) {
    _startTime = value;
  }

  get startDate => _startDate;

  set startDate(value) {
    _startDate = value;
  }

  get amount => _amount;

  set amount(value) {
    _amount = value;
  }

  get energyConsume => _energyConsume;

  set energyConsume(value) {
    _energyConsume = value;
  }

  get stationName => _stationName;

  set stationName(value) {
    _stationName = value;
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