/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class GroupHistoryModel{

  var _id, _userId, _type, _requestId, _userName, _amount, _createdOn, _stationImage, _stationName, _startDate, _energyConsume;

  GroupHistoryModel(this._id, this._userId, this._type, this._requestId,
      this._userName, this._amount, this._createdOn, this._stationImage, this._stationName, this._startDate, this._energyConsume);

  get createdOn => _createdOn;

  set createdOn(value) {
    _createdOn = value;
  }

  get energyConsume => _energyConsume;

  set energyConsume(value) {
    _energyConsume = value;
  }

  get stationImage => _stationImage;

  set stationImage(value) {
    _stationImage = value;
  }

  get amount => _amount;

  set amount(value) {
    _amount = value;
  }

  get userName => _userName;

  set userName(value) {
    _userName = value;
  }

  get requestId => _requestId;

  set requestId(value) {
    _requestId = value;
  }

  get type => _type;

  set type(value) {
    _type = value;
  }

  get userId => _userId;

  set userId(value) {
    _userId = value;
  }

  get id => _id;

  set id(value) {
    _id = value;
  }

  get stationName => _stationName;

  set stationName(value) {
    _stationName = value;
  }

  get startDate => _startDate;

  set startDate(value) {
    _startDate = value;
  }
}