/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */


/// model class for getter and setter values

class ChargerList{

  var _plugPoint, _chargerType, _activeStatus;

  ChargerList(this._plugPoint, this._chargerType, this._activeStatus);

  get activeStatus => _activeStatus;

  set activeStatus(value) {
    _activeStatus = value;
  }

  get chargerType => _chargerType;

  set chargerType(value) {
    _chargerType = value;
  }

  get plugPoint => _plugPoint;

  set plugPoint(value) {
    _plugPoint = value;
  }
}