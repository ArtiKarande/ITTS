
/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:itts/models/Employee.dart';
import 'package:itts/utils/FToast.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'models/DeviceDb.dart';
import 'models/User.dart';
import 'models/UserDevice.dart';
import 'models/userDetails.dart';


class Helper {
  static final Helper _instance = new Helper.internal();
  factory Helper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "aaaa.db"); //later change to itts
    var theDb = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
          create table $tableUser ( 
          $columnId integer primary key autoincrement, 
          $columnName text not null,
          $columnPassword text not null,
          $columnUserId text not null,
          $columnDate text not null,
          $columnTime text not null,
          $columnDeviceName text not null,
          $columnNewDate text not null)
          ''');

     await db.execute('''
          create table $tableDevices ( 
          $cid integer primary key autoincrement, 
          $columndate text not null,
          $columntime text not null,
          $columndeviceId text not null,
          $columntemperature text not null)
          ''');

      await db.execute('''
          create table $tableEmployee ( 
          $eId integer primary key autoincrement, 
          $empId text not null,
          $empName text not null,
          $empEmail text not null)
          ''');

    });
    return theDb;
  }

  Helper.internal();

  Future<User> insert(User user) async {

    var dbClient = await db;
    user.id = (await dbClient.insert(tableUser, user.toMap()));
    return user;
  }

  Future<UserDetails> insertDevice(UserDetails user) async {

    var dbClient = await db;
    user.id = (await dbClient.insert(tableDevices, user.toMap()));

    return user;
  }

  ///insert emp
  Future<Employee> insertEmp(Employee employee) async {

    var dbClient = await db;
    employee.id = (await dbClient.insert(tableEmployee, employee.toMap()));
    return employee;
  }

  Future<User> getUser(int id) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableUser,
        columns: [columnId, columnName,columnPassword,columnUserId,columnDate,columnTime,columnDeviceName,columnNewDate],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return User.fromMap(maps.first);
    }
    return null;
  }

 Future<List> getAllUsers() async {
    List<User> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableUser,
        columns: [columnId, columnName, columnPassword,columnUserId,columnDate,columnTime,columnDeviceName,columnNewDate]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(User.fromMap(f));
       //   print("getAllUsers"+ User.fromMap(f).toString());
      });
 //     print("database values print:::$maps");

    }
    return user;
  }

  /// 2nd table print values
  Future<List> getAllDevices(String name) async {
    List<UserDetails> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableDevices,
        columns: [cid, columntemperature, columnDate,columnTime,columndeviceId],where: '$columndeviceId = ?',whereArgs: [name]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(UserDetails.fromMap(f));
          // print("db::getAllUsers"+ UserDevice.fromMap(f).toString());
      });
  //         print("db::database values print:::$maps");

    }
    return user;
  }

  ///3rd get all emp
  ///
/*  Future<List> getAllEmployee() async {
    List<Employee> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableEmployee,
        columns: [empId,empName]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(Employee.fromMap(f));
        //   print("getAllUsers"+ User.fromMap(f).toString());
      });
      //     print("database values print:::$maps");

    }
    return user;
  }*/

  Future<List> getAllDevicesDemo() async {
    List<UserDetails> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableDevices,
        columns: [cid, columntemperature, columnDate,columnTime,columndeviceId]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(UserDetails.fromMap(f));
        // print("db::getAllUsers"+ UserDevice.fromMap(f).toString());
      });
//      print("db::database values print:::$maps");

    }
    return user;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<int> delete(String id) async {
    var dbClient = await db;
    return await dbClient.delete(tableUser, where: '$columnId = ?', whereArgs: [id]);
  }

  clearDB() async {
    var dbClient = await db;
    await dbClient.delete(tableUser);
  }

  clearEmp() async {
    var dbClient = await db;
    await dbClient.delete(tableEmployee);
  }


  clearDevices(String deviceId)async{

    print("gotid::$deviceId");
    var dbClient = await db;
    return await dbClient.delete(tableDevices, where: '$columndeviceId = ?', whereArgs: [deviceId]);
  }

  Future<int> updateItem(item) async {
    //databaseHelper has been injected in the class
    var dbClient = await db;
    return await dbClient.update("todos", item.toMap(),
        where: "id = ?", whereArgs: [item.id]);
  }

  Future<int> update(User user) async {
    var dbClient = await db;
    return await dbClient.update(tableUser, user.toMap(),
        where: '$columnId = ?', whereArgs: [user.id]);
  }

/////////////////////
///employee


  Future<List> getAllEmployee() async {
    List<Employee> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableEmployee,
        columns: [columnId, empId, empName,empEmail]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(Employee.fromMap(f));
        //   print("getAllUsers"+ User.fromMap(f).toString());
      });
           print("database values print:::$maps");

    }
    return user;
  }

}
