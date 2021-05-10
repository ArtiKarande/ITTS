/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class MyPlans{

  var _planId, _planEnergy, _planPrice, _consumeEnergy, _remainingEnergy, _planCharges, _date, _subId;

  MyPlans(this._planId, this._planEnergy, this._planPrice, this._consumeEnergy,
      this._remainingEnergy, this._planCharges, this._date, this._subId);

  get remainingEnergy => _remainingEnergy;

  get date => _date;

  set date(value) {
    _date = value;
  }

  get subId => _subId;

  set subId(value) {
    _subId = value;
  }

  set remainingEnergy(value) {
    _remainingEnergy = value;
  }

  get planCharges => _planCharges;

  set planCharges(value) {
    _planCharges = value;
  }

  get consumeEnergy => _consumeEnergy;

  set consumeEnergy(value) {
    _consumeEnergy = value;
  }

  get planPrice => _planPrice;

  set planPrice(value) {
    _planPrice = value;
  }

  get planEnergy => _planEnergy;

  set planEnergy(value) {
    _planEnergy = value;
  }

  get planId => _planId;

  set planId(value) {
    _planId = value;
  }
}

class MyPlansDetails{

  var _stationName, _stationImage, _date, _perRequest, _energyConsume, _requestId;

  MyPlansDetails(this._stationName, this._stationImage, this._date,
      this._perRequest, this._energyConsume, this._requestId);

  get energyConsume => _energyConsume;

  set energyConsume(value) {
    _energyConsume = value;
  }

  get requestId => _requestId;

  set requestId(value) {
    _requestId = value;
  }

  get perRequest => _perRequest;

  set perRequest(value) {
    _perRequest = value;
  }

  get date => _date;

  set date(value) {
    _date = value;
  }

  get stationImage => _stationImage;

  set stationImage(value) {
    _stationImage = value;
  }

  get stationName => _stationName;

  set stationName(value) {
    _stationName = value;
  }
}

