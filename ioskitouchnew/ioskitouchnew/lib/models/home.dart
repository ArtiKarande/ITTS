/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/room.dart';

/// [Home] class to hold data associated with homes.
/// One or more [Homes]s forms a [Building].
/// [Home] is a representation of a actual home in with multiple [Room]s in it.
class Home {
  /// ID of the [Home], should be unique code.
  String iD;

  /// Name of the [Home], User can assign/change this name.
  String name;

  /// Index of icon associated with [Home] in the icon pack.
  /// User can assign/change this icon.
  int iconIndex;

  /// List of [Room]s associated with the [Home].
  /// Eg. [Home] can have multiple [Room]s configured under it.
  List<Room> childList;

  /// Index pointing to selected child in [childList].
  int indexChildList;

  /// List of [ControlPoint]s associated with this [Home] as scenes.
  /// Scenes are the aggregated control elements.
  List<ControlPoint> sceneList;

  /// Constructor to make object of [Home] class.
  Home(this.iD, this.name,
      [this.iconIndex = 0, this.childList, this.sceneList, this.indexChildList = 0]) {

    // Assign default values if child list is null.
    if (this.childList == null)
      this.childList = getDefaultRomList();

    // Assign default values if scene list is null.
    if (this.sceneList == null)
      this.sceneList = getDefaultSceneList();
  }

  /// Default configuration of [childList] for [Home] with a demo room.
  List<Room> getDefaultRomList() {
    return <Room>[Room('R1', 'Demo Room', 0),];
  }

  /// Default Scenes list of length 8.
  List<ControlPoint> getDefaultSceneList() {
    return List<ControlPoint>.generate(8, (int _i) => ControlPoint('SC', (_i+1).toString()));
  }

  /// Validation method to validate [childList] of [Home].
  /// It checks and corrects [childList], [indexChildList] and [sceneList].
  checkChild() {
    // Tag to track print statements in console.
    final String fTAG = 'Home.checkChild.' + this.name;

    // Validation of [childList],
    // if it is not blank then validate every child inside it, else load default values.
    if (this.childList != null && this.childList.length > 0) {

      // Validation of [indexChildList],
      // if index is bigger than count in list, we need to reset it.
      if (this.childList.length <= this.indexChildList) {
        print('$fTAG: childList.length <= this.indexChildList; resetting indexChildList to 0.');
        this.indexChildList = 0;
      }

      // Validating every child in list.
      for (int i = 0; i < this.childList.length; i++)
        this.childList[i].checkChild();
    } else {
      // loading default values if list is empty.
      print('$fTAG: childList is empty; loading default values.');
      print('$fTAG: cL is empty; loading default value');
      this.childList = getDefaultRomList();
    }

    // Validation of [sceneList],
    // if it is blank then load default values.
    if (this.sceneList == null || this.sceneList.length <= 0) {
      print('$fTAG: sceneList is empty; loading default values.');
      this.sceneList = getDefaultSceneList();
    }
  }

  toJson() {
    return {
      'iD': iD,
      'name': name,
      'iconIndex': iconIndex,
      'childList': childList,
      'sceneList': sceneList,
      'indexChildList': indexChildList,
    };
  }
}
