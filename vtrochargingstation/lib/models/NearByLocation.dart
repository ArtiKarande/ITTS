/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:convert';

NearByLocation nearByLocationFromJson(String str) => NearByLocation.fromJson(json.decode(str));

String nearByLocationToJson(NearByLocation data) => json.encode(data.toJson());

/// model class for getter and setter values
class NearByLocation {
  NearByLocation({
    this.status,
    this.message,
    this.station,
  });

  bool status;
  String message;
  List<Station> station;

  factory NearByLocation.fromJson(Map<String, dynamic> json) => NearByLocation(
    status: json["status"],
    message: json["message"],
    station: List<Station>.from(json["station"].map((x) => Station.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "station": List<dynamic>.from(station.map((x) => x.toJson())),
  };
}

class Station {
  Station({
    this.id,
    this.latitude,
    this.longitude,
    this.name,
    this.distance,
    this.totalPlugpoint,
    this.availablePoint,
  });

  String id;
  String latitude;
  String longitude;
  String name;
  String distance;
  String totalPlugpoint;
  List<AvailablePoint> availablePoint;

  factory Station.fromJson(Map<String, dynamic> json) => Station(
    id: json["id"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    name: json["name"],
    distance: json["distance"],
    totalPlugpoint: json["total_plugpoint"],
    availablePoint: List<AvailablePoint>.from(json["available_point"].map((x) => AvailablePoint.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "latitude": latitude,
    "longitude": longitude,
    "name": name,
    "distance": distance,
    "total_plugpoint": totalPlugpoint,
    "available_point": List<dynamic>.from(availablePoint.map((x) => x.toJson())),
  };
}

class AvailablePoint {
  AvailablePoint({
    this.chargerType,
    this.plugpointCount,
  });

  ChargerType chargerType;
  String plugpointCount;

  factory AvailablePoint.fromJson(Map<String, dynamic> json) => AvailablePoint(
    chargerType: chargerTypeValues.map[json["charger_type"]],
    plugpointCount: json["plugpoint_count"],
  );

  Map<String, dynamic> toJson() => {
    "charger_type": chargerTypeValues.reverse[chargerType],
    "plugpoint_count": plugpointCount,
  };
}

enum ChargerType { FAST, NORMAL }

final chargerTypeValues = EnumValues({
  "Fast": ChargerType.FAST,
  "Normal": ChargerType.NORMAL
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
