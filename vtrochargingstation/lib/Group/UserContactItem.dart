/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class UserContactItem{

  var _contactName, _number, _imageUrl;

  UserContactItem(this._contactName, this._number, this._imageUrl);

  get imageUrl => _imageUrl;

  set imageUrl(value) {
    _imageUrl = value;
  }

  get number => _number;

  set number(value) {
    _number = value;
  }

  get contactName => _contactName;

  set contactName(value) {
    _contactName = value;
  }
}