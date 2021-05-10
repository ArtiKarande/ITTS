/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class Recommended{

  var _amount;

  Recommended(this._amount);

  get amount => _amount;

  set amount(value) {
    _amount = value;
  }
}