/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/databaseHelper.dart';
import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';

/// [Building] class to hold data associated with building.
/// One or more [Homes]s forms a [Building].
/// [Building] is a representation of multiple homes of the user.
/// [Building] class holds complete set of data required by a home automation system.
/// External libraries need this instance to access any data related to home automation system.
class Building {

  /// ID of the [Building], should be unique code.
  String iD;

  /// Name of the [Building], for future use.
  String name;

  /// Index of icon associated with [Building] in the icon pack, for future use.
  int iconIndex;

  /// List of [Home]s associated with the [Building].
  /// Eg. [Building] can have multiple [Home]s configured under it.
  List<Home> childList;

  /// Index pointing to selected child in [childList].
  int indexChildList;

  /// Static singleton instance of this class.
  static Building instance;

  /// Data change notifies notifies if there is change in any data.
  /// Other part of the code can listen to this notifier to take actions accordingly.
  /// Also the parts which are changing data can toggle this notifies to generate change events.
  ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);

  /// Database required to read/store/update the data of the system.
  DatabaseHelper database = DatabaseHelper();

  /// Flag displaying whether database is updating.
  /// When database is updating we need to notify ui and avoid concurrent operations.
  static ValueNotifier<bool> isDatabaseUpdating = ValueNotifier(false);
  static ValueNotifier<bool> isLocalConnectionUpdating = ValueNotifier(false);

  /// Singleton implementation of the data.
  /// With this implementation we have can keep only one copy of the data.
  static Building getInstance() {
    if (instance == null) {
      instance = Building('B1', 'Mahendra');
    }
    return instance;
  }

  /// Constructor to make object of [Building] class.
  Building(this.iD, this.name,
      [this.iconIndex = 0, this.childList, this.indexChildList = 0]) {

    // Assign default values if child list is null.
    if (this.childList == null)
      this.childList = getDefaultHomeList();

    // Read data from database into data fields.
    readDB();
  //  readNewDB();
  }

  /// Read data from database and store it into the required data fields.
  readDB() async {
    // Marking database as busy.
    isDatabaseUpdating.value = true;

    // Opening database before read.
    await database.open();

    // Reading and storing data in required fields.
    await database.extractDataFromDatabase();

    // Closing database after read.
    await database.close();

    // Generating data change notifications.
    dataChangeNotifier.value = !dataChangeNotifier.value;

    // Marking database operations as complete.
    isDatabaseUpdating.value = false;
  }

  /// Store data from the data fields into the database.
  updateDB() async {
    print("updateDB:::${Building.getInstance().childList.length}");
    // Marking database as busy.
    isDatabaseUpdating.value = true;

    // Opening database before read.
    await database.open();

    // Clearing previous database.
    await database.clearDB();

    // Storing data from data fields into the database.
    await database.storeDataInDb();

    // Closing database after read.
    await database.close();

    // Marking database operations as complete.
    isDatabaseUpdating.value = false;
  }

  updateOnLogin() async{
    print("updateDB:::${Building.getInstance().childList.length}");
    // Marking database as busy.
    isDatabaseUpdating.value = true;

    // Opening database before read.
    await database.open();

    // Storing data from data fields into the database.
    await database.storeDataInDb();

    // Closing database after read.
    await database.close();

    // Marking database operations as complete.
    isDatabaseUpdating.value = false;
  }


  /// Default configuration of [childList] for [Building] with homes and rooms for demo purpose.
  /// These configurations can be updated or simply deleted while installation and configurations by the use.
  List<Home> getDefaultHomeList() {
    return <Home>[
      Home(
        'H1',
        'My Home',
        0, //IconData(0xe88a, fontFamily: 'MaterialIcons'),
      ),
    ];
  }

  /// Validation method to validate [childList] of [Building].
  /// It checks and corrects [childList], [indexChildList].
  checkChild() {
    // Tag to track print statements in console.
    final String fTAG = 'Home.checkChild.' + this.name;

    // Validating instance,
    // if not null then validate its childList, else load default values.
    if (instance != null) {
      // Validation of [childList],
      // if it is not blank then validate every child inside it, else load default values.
      if (instance.childList != null && instance.childList.length > 0) {

        // Validation of [indexChildList],
        // if index is bigger than count in list, we need to reset it.
        if (instance.childList.length <= instance.indexChildList) {
          print('$fTAG: childList.length <= indexChildList; resetting indexChildList to 0.');
          instance.indexChildList = 0;
        }

        // Validating every child in list.
        for (int i = 0; i < instance.childList.length; i++)
          instance.childList[i].checkChild();
      } else {
        // loading default values if list is empty.
        print('$fTAG: childList is empty; loading default values.');
        instance.childList = getDefaultHomeList();
        instance.indexChildList = 0;
      }
    } else {
      print('$fTAG: instance is null; loading default values.');
      instance = Building.getInstance();
    }
  }

  /// Getter method to get selected [Home] by user.
  Home getSelectedHome() => this.childList[this.indexChildList];

  /// Getter method to get selected [Room] by user.
  Room getSelectedRoom() =>
      getSelectedHome().childList[getSelectedHome().indexChildList];

  /// Getter method to get selected [Devices] by user.
  Devices getSelectedDevice() =>
      getSelectedRoom().childList[getSelectedRoom().indexChildList];

  /// Getter method to get [Home] pointed by given index.
  Home getHomeAtIndex(i) => this.childList[i];

  /// Getter method to get [Room] pointed by given index in the selected [Home].
  Room getRoomAtIndex(i) => getSelectedHome().childList[i];

  /// Getter method to get [Devices] pointed by given index in the selected [Room].
  Devices getDeviceAtIndex(i) => getSelectedRoom().childList[i];

  /// Getter method to get [ControlPoint] pointed by given index in the selected [Devices].
  ControlPoint getControlPointAtIndex(i) => getSelectedDevice().childList[i];

  /// Getter method to get [Scene] pointed by given index in the scene list of selected [Home].
  ControlPoint getHomeSceneAtIndex(i) => getSelectedHome().sceneList[i];

  /// Getter method to get [Scene] pointed by given index in the scene list of selected [Room].
  ControlPoint getRoomSceneAtIndex(i) => getSelectedRoom().sceneList[i];

  /// Getter method to get [Scene] pointed by given index in the scene list of selected [Devices].
  ControlPoint getDeviceSceneAtIndex(i) => getSelectedDevice().sceneList[i];
}
