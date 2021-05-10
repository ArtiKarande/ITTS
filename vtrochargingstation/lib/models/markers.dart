/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class Markers{

String _stationId, _stationName, _stationDistance, _availableBikes;
double _latitude, _longitude;

Markers(this._stationId, this._latitude, this._longitude, this._stationName,
      this._stationDistance, this._availableBikes);

  get availableBikes => _availableBikes;

  set availableBikes(value) {
    _availableBikes = value;
  }

double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  get stationDistance => _stationDistance;

  set stationDistance(value) {
    _stationDistance = value;
  }

  get stationName => _stationName;

  set stationName(value) {
    _stationName = value;
  }

  String get stationId => _stationId;

  set stationId(String value) {
    _stationId = value;
  }

  get longitude => _longitude;

  set longitude(value) {
    _longitude = value;
  }
}