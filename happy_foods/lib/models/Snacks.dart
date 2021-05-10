/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

class Snacks {

  String _id, _snacks;

  Snacks(this._id, this._snacks);

  get snacks => _snacks;

  set snacks(value) {
    _snacks = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }


}