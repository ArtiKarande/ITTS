/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

class Plan{

  String _id,_plan, _cost;

  Plan(this._id, this._plan, this._cost);

  get plan => _plan;

  get cost => _cost;

  set cost(value) {
    _cost = value;
  }

  set plan(value) {
    _plan = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }


}