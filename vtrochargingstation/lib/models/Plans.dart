/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class PlansModel{

  var _planId, _planEnergy, _planPrice, _planCharges;

  PlansModel(this._planId, this._planEnergy, this._planPrice, this._planCharges);

  get planPrice => _planPrice;

  set planPrice(value) {
    _planPrice = value;
  }

  get planEnergy => _planEnergy;

  set planEnergy(value) {
    _planEnergy = value;
  }

  get planCharges => _planCharges;

  set planCharges(value) {
    _planCharges = value;
  }

  get planId => _planId;

  set planId(value) {
    _planId = value;
  }
}