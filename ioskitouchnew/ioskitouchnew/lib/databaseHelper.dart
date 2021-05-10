/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */
import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:ioskitouchnew/models/state.dart';
import 'package:ioskitouchnew/elementType.dart';

import 'common/sharedPreferece/SharedPreferneces.dart';

const String t = "kitouch";
const String cK = "key";
const String cT = "type";
const String cI = "id";
const String cN = "name";
const String cC = "icon";
const String cP = "parent";
const String cE = "extra1";

/// Model class to convert Home automation system data to map required by the database.
/// Also to extract data from map to the Home automation system data.
class DbModel {
  // Elements required by database.
  int key;
  int type;
  String id;
  String name;
  int icon;
  int parent;
  String extraInfo;

  /// Making object of [DbModel] with required information.
  DbModel(this.key, this.type, this.id, this.name,
      [this.icon, this.parent, this.extraInfo]);

  /// Converting [DbModel] data to string.
  @override
  toString() {
    return '\nHE<k:$key, t:$type, i:$id, n:$name, c:$icon, p:$parent, e:$extraInfo>';
  }

  /// Converting data to map.
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      cT: type,
      cI: id,
      cN: name,
      cC: icon,
      cP: parent,
      cE: extraInfo
    };

    if (key != null) map[cK] = key;

    return map;
  }

  /// Extracting data from map.
  DbModel.fromMap(Map<String, dynamic> map) {
    key = map[cK];
    type = map[cT];
    id = map[cI];
    name = map[cN];
    icon = map[cC];
    parent = map[cP];
    extraInfo = map[cE];
  }
}

/// [DatabaseHelper] is a class which provides interface to the database.
/// It provides interface to read, write to database, open/close the database.
class DatabaseHelper {
  /// Object of database library.
  Database database;
  Database databaseNew;

  /// Method to open database.
  /// If database is not there then create new one.
  Future open() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "home.db");

    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await createTable(db, version);
    });
  }

  /// Method to create table in the database.
  createTable([Database db, int version]) async {
    await db.execute('''create table $t (
      $cK integer primary key autoincrement,
      $cT integer not null,
      $cI text not null,
      $cN text not null,
      $cC integer,
      $cP integer,
      $cE text)''');
  }

  /// Method to delete table.
  dropTable() async {
    await database.execute('DROP TABLE ' + '$t');
  }

  /// Method to completely flush the database.
  clearDB() async {
    await dropTable();
    await createTable(database);
  }

  /// Storing Home automation system data to database.
  /// For Database design see file 'DatabaseDesign.pdf' file.
  /// It shows how Home automation system elements are mapped to database.
  ///
  /// While storing data to database we parse complete tree of data.
  /// Then convert it to required database format,
  /// And then store it into the database.
  SharedPreference pref = new SharedPreference();

  storeDataInDb() async {
    List<String> mTempDevicesList = new List();
    Map<dynamic, String> mDevicesMQTTList = new HashMap();

    DbModel be = await insert(DbModel(
        0,
        ElementType.building,
        Building.getInstance().iD,
        Building.getInstance().name,
        Building.getInstance().iconIndex));
    for (Home h in Building.getInstance().childList) {
      DbModel he = await insert(
          DbModel(null, ElementType.home, h.iD, h.name, h.iconIndex, be.key));
      for (Room r in h.childList) {
        DbModel re = await insert(
            DbModel(null, ElementType.room, r.iD, r.name, r.iconIndex, he.key));
        for (Devices d in r.childList) {
          d.sortChild();
          String extra = d.password + '-' + d.ssidPassword + '-' + d.ip;
          DbModel de = await insert(DbModel(null, ElementType.device,
              d.deviceID, d.name, d.iconIndex, re.key, extra));
          mDevicesMQTTList["${d.name}"] = "";
          //  mDevicesMQTTList["${d.name}"]="disconnected";
          String val = jsonEncode(mDevicesMQTTList);
          pref.putString(SharedKey().DEVICES_LIST, val); //todo add devices to the map

          mTempDevicesList.add("${d.deviceID}${d.password}");
          String tempVal = jsonEncode(mTempDevicesList);
          pref.putString(SharedKey().TEMP_DEVICE_LIST,
              tempVal); //todo add devices to the map
        //  print("mDevicesMQTTList:::$val");
       //   print("mTempDevicesList:::$tempVal");
          for (ControlPoint c in d.childList) {
    //        print("Adding Device:::$c");
            DbModel ce = await insert(DbModel(null, ElementType.controlPoint,
                c.idChar, c.name, null, de.key, c.type));
            for (StateS s in c.listStates) {
              await insert(DbModel(null, ElementType.state, s.idChar, s.name,
                  s.iconIndex, ce.key));
            }
          }
          for (ControlPoint c in d.sceneList) {
            DbModel ce = await insert(DbModel(null, ElementType.mood, c.idChar,
                c.name, null, de.key, c.type));
            for (StateS s in c.listStates) {
              await insert(DbModel(null, ElementType.state, s.idChar, s.name,
                  s.iconIndex, ce.key));
            }
          }
        }
        for (ControlPoint c in r.sceneList) {
          DbModel ce = await insert(DbModel(
              null, ElementType.mood, c.idChar, c.name, null, re.key, c.type));
          for (StateS s in c.listStates) {
            await insert(DbModel(null, ElementType.state, s.idChar, s.name,
                s.iconIndex, ce.key));
          }
        }
      }
      for (ControlPoint c in h.sceneList) {
        DbModel ce = await insert(DbModel(
            null, ElementType.mood, c.idChar, c.name, null, he.key, c.type));
        for (StateS s in c.listStates) {
          await insert(DbModel(
              null, ElementType.state, s.idChar, s.name, s.iconIndex, ce.key));
        }
      }
    }

    getHomeListDataFromSelectedItem();
  }

  /// Insert method to insert a single row in the database.
  Future<DbModel> insert(DbModel e) async {
    e.key = await database.insert(t, e.toMap());
    return e;
  }

  /// Extracting Home automation system data from database.
  /// For Database design see file 'DatabaseDesign.pdf' file.
  /// It shows how Home automation system elements are mapped to database.
  ///
  /// While extracting data from database we parse each entry in table.
  /// Then convert it to required home automation system format,
  /// And then store it into the building data-set.
  extractDataFromDatabase() async {
    List<Map> maps =
        await database.query(t, columns: [cK, cT, cI, cN, cC, cP, cE]);
    List<DbModel> mapsHE = List();
    if (maps.length > 0) {
      for (int index = 0; index < maps.length; index++) {
        mapsHE.add(DbModel.fromMap(maps[index]));
      }
    }

    for (DbModel be in mapsHE) {
      if (be.type == ElementType.building) {
        Building.getInstance().iD = be.id;
        Building.getInstance().name = be.name;
        Building.getInstance().iconIndex = be.icon;

        Building.getInstance().childList.clear();

        for (DbModel he in mapsHE) {
          if ((he.type == ElementType.home) && (he.parent == be.key)) {
            Home h = Home(he.id, he.name, he.icon, [], []);
            for (DbModel re in mapsHE) {
              if ((re.type == ElementType.room) && (re.parent == he.key)) {
                Room r = Room(re.id, re.name, re.icon, [], []);
                for (DbModel de in mapsHE) {
                  if ((de.type == ElementType.device) &&
                      (de.parent == re.key)) {
                    List<String> extraParts = de.extraInfo.split('-');

                    String password = 'password';
                    String ssidPassword = 'password';
                    String ip = '192.168.41.1';

                    if (extraParts.length > 0) {
                      password = extraParts[0]; // Extracting control password
                      ssidPassword = extraParts[0];
                      if (extraParts.length > 1) {
                        ssidPassword =
                            extraParts[1]; // Extracting hotspot password
                        if (extraParts.length > 2) {
                          ip = extraParts[2]; // Extracting IP
                        }
                      }
                    }

                    Devices d = Devices(de.id, password, de.name, de.icon, [],
                        [], ssidPassword);
                    d.ip = ip;
                    for (DbModel ce in mapsHE) {
                      if ((ce.type == ElementType.controlPoint) &&
                          (ce.parent == de.key)) {
                        ControlPoint c = ControlPoint(
                            ce.extraInfo, ce.id, false, [], 0, ce.name);
                        for (DbModel se in mapsHE) {
                          if ((se.type == ElementType.state) &&
                              (se.parent == ce.key)) {
                            StateS s = StateS(se.icon, se.id, se.name);
                            c.listStates.add(s);
                          }
                        }
                        d.childList.add(c);
                      }
                      d.sortChild();
                      if ((ce.type == ElementType.mood) &&
                          (ce.parent == de.key)) {
                        ControlPoint c = ControlPoint(
                            ce.extraInfo, ce.id, false, [], 0, ce.name);
                        for (DbModel se in mapsHE) {
                          if ((se.type == ElementType.state) &&
                              (se.parent == ce.key)) {
                            StateS s = StateS(se.icon, se.id, se.name);
                            c.listStates.add(s);
                          }
                        }
                        d.sceneList.add(c);
                      }
                    }
                    r.childList.add(d);
                  }
                  if ((de.type == ElementType.mood) && (de.parent == re.key)) {
                    ControlPoint c = ControlPoint(
                        de.extraInfo, de.id, false, [], 0, de.name);
                    for (DbModel se in mapsHE) {
                      if ((se.type == ElementType.state) &&
                          (se.parent == de.key)) {
                        StateS s = StateS(se.icon, se.id, se.name);
                        c.listStates.add(s);
                      }
                    }
                    r.sceneList.add(c);
                  }
                }
                h.childList.add(r);
              }
              if ((re.type == ElementType.mood) && (re.parent == he.key)) {
                ControlPoint c =
                    ControlPoint(re.extraInfo, re.id, false, [], 0, re.name);
                for (DbModel se in mapsHE) {
                  if ((se.type == ElementType.state) && (se.parent == re.key)) {
                    StateS s = StateS(se.icon, se.id, se.name);
                    c.listStates.add(s);
                  }
                }
                h.sceneList.add(c);
              }
            }
            Building.getInstance().childList.add(h);
          }
        }
      }
    }
    Building.getInstance().checkChild();
  }

  /// Method to close database.
  Future close() async => database.close();

  getHomeListDataFromSelectedItem1() {
    print("inside database");

    Map<String, dynamic> cMap = new HashMap();
    List<dynamic> mSynchData = new List();

    for (Home h in Building.getInstance().childList) {
      Map<String, dynamic> homeMap = new HashMap();
      homeMap["home_name"] = h.name;
      homeMap["iconIndex"] = h.iconIndex;
      homeMap["home_id"] = "dummy";
      List<dynamic> mRoomList = new List();
      for (Room r in h.childList) {
        Map<String, dynamic> roomMap = new HashMap();
        roomMap["home_id"] = "dummy";
        roomMap["room_id"] = "dummy";
        roomMap["room_name"] = r.name;
        roomMap["iconIndex"] = r.iconIndex;
        List<dynamic> mSwitchBoxes = new List();
        for (Devices d in r.childList) {
          Map<String, dynamic> deviceMap = new HashMap();
          deviceMap["room_id"] = "dummy";
          deviceMap["switchbox_id"] = d.deviceID;
          deviceMap["topic"] = "${d.deviceID}${d.password}";
          deviceMap["mac_address"] = "dummy";
          deviceMap["ssid"] = "${d.deviceID}";
          deviceMap["password"] = "${d.password}";
          deviceMap["name"] = d.name;
          deviceMap["iconIndex"] = d.iconIndex;
          deviceMap["ip"] = d.ip;   //solved by arti


          /*print("deviceID 1:: ${d.deviceID}");
          Map<String, dynamic> map = json.decode(val);

          if (map.containsKey(d.deviceID)) {
            String payload = map[d.deviceID];
            print("payload::: $payload");
            deviceMap["switches"] = payload;
          }*/


          List<dynamic> mControlPoints = new List();
          for (ControlPoint c in d.childList) {
            Map<String, dynamic> pointMap = new HashMap();
            pointMap["name"] = c.name;
            pointMap["type"] = c.type;
            pointMap["isVisible"] = c.isVisible;
            pointMap["idChar"] = c.idChar;        // used for switch point for rename points [at backend side useful]
            pointMap["demo"] = "hello";  //by arti
            mControlPoints.add(pointMap);

            List<dynamic> mStates = new List();
            for (StateS s in c.listStates) {
              Map<String, dynamic> stateMap = new HashMap();
              stateMap["idChar"] = s.idChar;
              stateMap["name"] = s.name;
              stateMap["iconIndex"] = s.iconIndex;

              mStates.add(stateMap);
            }
            pointMap["states"] = mStates;
            // syncData    mControlPoints.add(pointMap);
          }
          deviceMap["points"] = mControlPoints;
          mSwitchBoxes.add(deviceMap);
        }
        roomMap["switchboxes"] = mSwitchBoxes;
        mRoomList.add(roomMap);
      }
      homeMap["rooms"] = mRoomList;
      mSynchData.add(homeMap);
    }
    cMap["syncData"] = mSynchData;
    cMap["user_id"] = FlutterApp.userID;
    String data = json.encode(cMap);
    pref.putString(SharedKey().SYNC_DATA, data);
  //  print("--database[getHomeListDataFromSelectedItem()]--$cMap");
  }

  Map<String, dynamic> cMap = new HashMap();
  List<dynamic> mSynchData = new List();

  getHomeListDataFromSelectedItem() {

    pref.getString(SharedKey().RECEIVE_DATA).then((val) {
      if (val != null) {

        for (Home h in Building.getInstance().childList) {
          Map<String, dynamic> homeMap = new HashMap();
          homeMap["home_name"] = h.name;
          homeMap["iconIndex"] = h.iconIndex;
          homeMap["home_id"] = "dummy";
          List<dynamic> mRoomList = new List();
          for (Room r in h.childList) {
            Map<String, dynamic> roomMap = new HashMap();
            roomMap["home_id"] = "dummy";
            roomMap["room_id"] = "dummy";
            roomMap["room_name"] = r.name;
            roomMap["iconIndex"] = r.iconIndex;
            List<dynamic> mSwitchBoxes = new List();
            for (Devices d in r.childList) {
              Map<String, dynamic> deviceMap = new HashMap();
              deviceMap["room_id"] = "dummy";
              deviceMap["switchbox_id"] = d.deviceID;
              deviceMap["topic"] = "${d.deviceID}${d.password}";
              deviceMap["mac_address"] = "dummy";
              deviceMap["ssid"] = "${d.deviceID}";
              deviceMap["password"] = "${d.password}";
              deviceMap["name"] = d.name;
              deviceMap["iconIndex"] = d.iconIndex;
              deviceMap["ip"] = d.ip;   //solved by arti

              print("deviceID 1:: ${d.deviceID}");
              Map<String, dynamic> map = json.decode(val);

              if (map.containsKey(d.deviceID)) {
                String payload = map[d.deviceID];
                print("payload::: $payload");
                deviceMap["switches"] = payload;
              }

              //print("homeViewDeviceString::$FlutterApp.deviceString");
              List<dynamic> mControlPoints = new List();
              for (ControlPoint c in d.childList) {
                Map<String, dynamic> pointMap = new HashMap();
                pointMap["name"] = c.name;
                pointMap["type"] = c.type;
                pointMap["isVisible"] = c.isVisible;
                pointMap["idChar"] = c.idChar;

                //added by arti for loop for liststate for icons
                List<dynamic> mStates = new List();

                for(int i=0;i<c.listStates.length;i++){
                  Map<String, dynamic> stateMap = new HashMap();
                  stateMap["idChar"] = c.listStates[i].idChar;
                  stateMap["name"] = c.listStates[i].name;
                  stateMap["iconIndex"] = c.listStates[i].iconIndex;
                  mStates.add(stateMap);
                }
                pointMap["states"] = mStates;
                mControlPoints.add(pointMap);

              }
              deviceMap["points"] = mControlPoints;
              mSwitchBoxes.add(deviceMap);
            }
            roomMap["switchboxes"] = mSwitchBoxes;
            mRoomList.add(roomMap);
          }
          homeMap["rooms"] = mRoomList;
          mSynchData.add(homeMap);
        }
      } else {
        print('--else--');
      }

      cMap["syncData"] = mSynchData;
      cMap["user_id"] = FlutterApp.userID;
      String data = json.encode(cMap);
      pref.putString(SharedKey().SYNC_DATA, data);
  //    print("db new ----syncdata--:$cMap");

    });
  }

}
