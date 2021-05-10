/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

class PackagePlan{

 String _id, _package, _cost, _days;

 PackagePlan(this._id, this._package, this._cost, this._days);

 get package => _package;

 set package(value) {
   _package = value;
 }

 get days => _days;

 set days(value) {
   _days = value;
 }

 get cost => _cost;

 set cost(value) {
   _cost = value;
 }

 String get id => _id;

 set id(String value) {
   _id = value;
 }


}