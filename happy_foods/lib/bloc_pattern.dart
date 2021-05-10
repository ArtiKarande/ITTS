/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';

class StateProviderManagement extends ChangeNotifier {

  String _setPlan = 'SELECT PLAN';
  String get planValue => _setPlan;

  String _setPkg = 'SELECT PACKAGE';
  String get packageValue => _setPkg;

  String _setPkgcost = '';
  String get packageCost => _setPkgcost;




  set planValue(String value) {
    _setPlan = value;
    notifyListeners();
  }

  setTagValue(String title) {
    planValue = title;
  }

  set packageValue(String value) {
    _setPkg = value;
    notifyListeners();
  }

  setPkgValue(String title) {
    packageValue = title;
  }



  set packageCost(String value) {
    _setPkgcost = value;
    notifyListeners();
  }

  setPackageCost(String title) {
    packageCost = title;
  }

  String _setFromDate = 'yyyy-mm-dd';
  String get fromDate => _setFromDate;

  set fromDate(String value) {
    _setFromDate = value;
    notifyListeners();
  }

  setFromDate(String title) {
    fromDate = title;
  }


  String _setToDate = 'yyyy-mm-dd';
  String get toDate => _setToDate;

  set toDate(String value){
    _setToDate = value;
    notifyListeners();
  }

  setToDate(String title){
    toDate = title;
  }

  String _setMeal = '1';
  String get mealValue => _setMeal;

  set mealValue(String value){
    _setMeal = value;
    notifyListeners();
  }

  setMealValue(String title){
    mealValue = title;
  }

}
