/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class PreviousPlanModel{

  var _planEnergy, _planPrice, _planCharges, _consumeEnergy, _rechargeOn, _stationName, _landmark, _stationImage, _date, _percentageRequest, _energyConsume;

  PreviousPlanModel(
      this._planEnergy,
      this._planPrice,
      this._planCharges,
      this._consumeEnergy,
      this._rechargeOn,
      this._stationName,
      this._landmark,
      this._stationImage,
      this._date,
      this._percentageRequest,
      this._energyConsume);

  get energyConsume => _energyConsume;

  set energyConsume(value) {
    _energyConsume = value;
  }

  get percentageRequest => _percentageRequest;

  set percentageRequest(value) {
    _percentageRequest = value;
  }

  get date => _date;

  set date(value) {
    _date = value;
  }

  get stationImage => _stationImage;

  set stationImage(value) {
    _stationImage = value;
  }

  get landmark => _landmark;

  set landmark(value) {
    _landmark = value;
  }

  get stationName => _stationName;

  set stationName(value) {
    _stationName = value;
  }

  get rechargeOn => _rechargeOn;

  set rechargeOn(value) {
    _rechargeOn = value;
  }

  get consumeEnergy => _consumeEnergy;

  set consumeEnergy(value) {
    _consumeEnergy = value;
  }

  get planCharges => _planCharges;

  set planCharges(value) {
    _planCharges = value;
  }

  get planPrice => _planPrice;

  set planPrice(value) {
    _planPrice = value;
  }

  get planEnergy => _planEnergy;

  set planEnergy(value) {
    _planEnergy = value;
  }
}