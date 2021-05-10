/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */
/// model class for getter and setter values
class BikeInformationModel{

  var _bikeName,_bikeSeries,_bikeCompany,_bikeModel,_bikeKW,_bikeId;

  BikeInformationModel(this._bikeName, this._bikeSeries, this._bikeCompany,
      this._bikeModel, this._bikeKW, this._bikeId);

  get bikeId => _bikeId;

  set bikeId(value) {
    _bikeId = value;
  }

  get bikeKW => _bikeKW;

  set bikeKW(value) {
    _bikeKW = value;
  }

  get bikeModel => _bikeModel;

  set bikeModel(value) {
    _bikeModel = value;
  }

  get bikeCompany => _bikeCompany;

  set bikeCompany(value) {
    _bikeCompany = value;
  }

  get bikeSeries => _bikeSeries;

  set bikeSeries(value) {
    _bikeSeries = value;
  }

  get bikeName => _bikeName;

  set bikeName(value) {
    _bikeName = value;
  }
}