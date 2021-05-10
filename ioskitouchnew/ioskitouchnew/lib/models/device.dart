/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'package:ioskitouchnew/models/controlPoint.dart';

/// [Devices] class to hold data of devices.
/// One or more [Devices]s forms a [Room].
/// [Devices] is a representation of a actual kiTouch device.
class Devices {
  /// Device ID of the KiTouch device, generally printed in qr code.
  String deviceID;

  /// Password of the KiTouch device, generally printed in qr code.
  String ssidPassword;

  /// Name of the [Devices], User can assign/change this name.
  String name;

  /// Control password of the [Devices].
  /// Used for the over the net (mqtt) communication.
  String password;

  /// IP of the [Devices] in local network.
  String ip = '192.168.4.1';

  /// Index of icon associated with [Devices] in the icon pack.
  /// User can assign/change this icon.
  int iconIndex;

  /// List of [ControlPoint]s associated with the [Devices].
  /// [ControlPoint]s are the basic control elements of the [Devices].
  /// Eg. List of Light, Fan, Master, Socket, etc.
  List<ControlPoint> childList;

  /// List of [ControlPoint]s associated with the [Devices] as scenes.
  /// Scenes are the aggregated control elements of the [Devices].
  List<ControlPoint> sceneList;

  /// Constructor to make object of [Devices] class.
  Devices(this.deviceID, this.password, this.name,
      [this.iconIndex = 0, this.childList, this.sceneList, this.ssidPassword]) {

    // Assign default values if control point list is null.
    if (this.childList == null)
      this.childList = getDefaultChildList1();

    // Assign default values if scene list is null.
    if (this.sceneList == null)
      this.sceneList = getDefaultSceneList();

    // Assign default values to ssidPassword same as password if it is null.
    if (this.ssidPassword == null)
      this.ssidPassword = this.password;
  }

  /// Configuration of a 085110 device as a default configurations.
  List<ControlPoint> getDefaultChildList() {
    return <ControlPoint>[
      ControlPoint('F', '1', true),
      ControlPoint('L', '2'),
      ControlPoint('L', '3', true),
      ControlPoint('L', '4'),
      ControlPoint('S', '5', true),
      ControlPoint('M', '6'),
    ];
  }

  List<ControlPoint> getDefaultChildList1() {
    return <ControlPoint>[
    ];
  }

  /// Default Scenes list of length 8.
  List<ControlPoint> getDefaultSceneList() {
    return List <ControlPoint>.generate(8, (int _i) => ControlPoint('SC',(_i+1).toString()));
  }

  /// Validation method to validate [childList] of [Devices].
  /// It checks and corrects [childList], [sceneList] and [ssidPassword].
  checkChild() {
    // Tag to track print statements in console.
    final String fTAG = 'Device.checkChild.' + this.name;

    // Validation of [childList],
    // if it is not blank then validate every child inside it, else load default values.
    if (this.childList != null && this.childList.length > 0) {

      // Validating every child in list.
      for (int i = 0; i < this.childList.length; i++) {
        this.childList[i].checkChild();
      }
    } else {
      // loading default values if list is empty.
      print('$fTAG: arti childList is empty; loading default values.');
      this.childList = getDefaultChildList1();       //// arti 24 aug
    }

    // Validation of [sceneList],
    // if it is blank then load default values.
    if (this.sceneList == null || this.sceneList.length <= 0) {
      print('$fTAG: sceneList is empty; loading default values.');
      this.sceneList = getDefaultSceneList();
    }

    // Validation of [ssidPassword],
    // if it is blank then load password as default value.
    if (this.ssidPassword == null)
      this.ssidPassword = this.password;

    // Sorting of childList after validation of the same.
    sortChild();
  }

  /// Sorting of [childList] as per their [type] and [idChar].
  sortChild() {
    this.childList.sort((a, b) =>
        (a.type + a.idChar).compareTo(b.type + b.idChar));
  }
}
