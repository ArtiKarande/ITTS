/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

/// model class for getter and setter values
class AdminSubscriptionPkg{

  var _id,_planType,_pkgType, _fromDate,_toDate,_roleId,_noofmeals,_totalCost,_address,_creationDate,_status;
  var  _snackType,_snackTotal;
  var _customeName,_age,_height_cms,_weight,_medicalCondition,_deliveryAddress,_dob;

  AdminSubscriptionPkg(this._id, this._planType, this._pkgType, this._fromDate,
      this._toDate, this._roleId, this._noofmeals, this._totalCost,
      this._address, this._creationDate, this._status, this._snackType,
      this._snackTotal, this._customeName, this._age, this._height_cms,
      this._weight, this._medicalCondition, this._deliveryAddress, this._dob);

  get dob => _dob;

  set dob(value) {
    _dob = value;
  }

  get deliveryAddress => _deliveryAddress;

  set deliveryAddress(value) {
    _deliveryAddress = value;
  }

  get medicalCondition => _medicalCondition;

  set medicalCondition(value) {
    _medicalCondition = value;
  }

  get weight => _weight;

  set weight(value) {
    _weight = value;
  }

  get height_cms => _height_cms;

  set height_cms(value) {
    _height_cms = value;
  }

  get age => _age;

  set age(value) {
    _age = value;
  }

  get customeName => _customeName;

  set customeName(value) {
    _customeName = value;
  }

  get snackTotal => _snackTotal;

  set snackTotal(value) {
    _snackTotal = value;
  }

  get snackType => _snackType;

  set snackType(value) {
    _snackType = value;
  }

  get status => _status;

  set status(value) {
    _status = value;
  }

  get creationDate => _creationDate;

  set creationDate(value) {
    _creationDate = value;
  }

  get address => _address;

  set address(value) {
    _address = value;
  }

  get totalCost => _totalCost;

  set totalCost(value) {
    _totalCost = value;
  }

  get noofmeals => _noofmeals;

  set noofmeals(value) {
    _noofmeals = value;
  }

  get roleId => _roleId;

  set roleId(value) {
    _roleId = value;
  }

  get toDate => _toDate;

  set toDate(value) {
    _toDate = value;
  }

  get fromDate => _fromDate;

  set fromDate(value) {
    _fromDate = value;
  }

  get pkgType => _pkgType;

  set pkgType(value) {
    _pkgType = value;
  }

  get planType => _planType;

  set planType(value) {
    _planType = value;
  }

  get id => _id;

  set id(value) {
    _id = value;
  }


}