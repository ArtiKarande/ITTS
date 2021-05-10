/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

//local database uses this modelclass

import 'package:itts/models/userDetails.dart';
import 'package:itts/utils/FToast.dart';

class Employee {
  int id;
  String empId1;
  String empName1;
  String empEmail1;


  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      empId: empId1,
      empName: empName1,
      empEmail: empEmail1,

    };
    if (id != null) {
      map[eId] = id;
    }
    return map;
  }

  Employee( this.empId1, this.empName1,this.empEmail1);

  Employee.fromMap(Map<String, dynamic> map) {
    id = map[eId];
    empId1 = map[empId];
    empName1 = map[empName];
    empEmail1 = map[empEmail];

  }
}