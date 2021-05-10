/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */
/// model class for getter and setter values
class Station {
  String id;
  String latitude;
  String longitude;
  String name;
  String distance;
  String totalPlugpoint;
  List<AvailablePoint> availablePoint;

  Station(
      {this.id,
        this.latitude,
        this.longitude,
        this.name,
        this.distance,
        this.totalPlugpoint,
        this.availablePoint});

  Station.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
    distance = json['distance'];
    totalPlugpoint = json['total_plugpoint'];
    if (json['available_point'] != null) {
      availablePoint = new List<AvailablePoint>();
      json['available_point'].forEach((v) {
        availablePoint.add(new AvailablePoint.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['name'] = this.name;
    data['distance'] = this.distance;
    data['total_plugpoint'] = this.totalPlugpoint;
    if (this.availablePoint != null) {
      data['available_point'] =
          this.availablePoint.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvailablePoint {
  String chargerType;
  String plugpointCount;

  AvailablePoint({this.chargerType, this.plugpointCount});

  AvailablePoint.fromJson(Map<String, dynamic> json) {
    chargerType = json['charger_type'];
    plugpointCount = json['plugpoint_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['charger_type'] = this.chargerType;
    data['plugpoint_count'] = this.plugpointCount;
    return data;
  }
}