import 'package:rxdart/rxdart.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

var schoolID;
class Service{

  String parentID='';

  IO.Socket socket =IO.io('http://192.168.1.215:8080' , <String, dynamic>
  {
    'transports': ['websocket']
  }) ;

  String initialCount = ''; //if the data is not passed by paramether it initializes with 0
  BehaviorSubject<String> _subjectCounter;

  Service({this.initialCount}){

    socket.on('notify', (data) {
      print(data);
      httpRequest();

    });
    _subjectCounter = new BehaviorSubject<String>.seeded(this.initialCount); //initializes the subject with element already
  }

  Stream<String> get counterObservable => _subjectCounter.stream;

  void httpRequest() async{

     schoolID = 'q2rzZdoCnWP5BR8QdLhiRqsAHtx2';


    var url = 'http://192.168.1.215:8080/mongo?query=query{getChild(parentChildID:"parent8e92d1cc") }';

    print(url);
    print('--- Kids URL ----');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);


    if (response.statusCode == 200)
    {
      var jsonResponse = convert.jsonDecode(response.body);
      var itemCount = jsonResponse;

      _subjectCounter.sink.add(response.body);

    //  print('Number of books about http: $jsonResponse.');
    }
    else {
      print('Request failed with status: ${response.statusCode}.');
    }

  }


   httpGetUserData() async{
     schoolID = 'q2rzZdoCnWP5BR8QdLhiRqsAHtx2';
     String  tid='09nURZi1qARjygR10iW5ieusZTm1';

    var url = 'http://192.168.1.215:8080/mongo?query=query{ teacherPhoneNo(mobileNo:"8888661686") }';
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);

    print("nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
    print(response);


    if (response.statusCode == 200)
    {
      var jsonResponse = convert.jsonDecode(response.body);
      var itemCount = jsonResponse;

      _subjectCounter.sink.add(response.body);

    //  print('Number of books about http: $jsonResponse.');
    }
    else {
      print('Request failed with status: ${response.statusCode}.');
    }

  }

  Future<String>  httpPostHomework(_SelectClass,_SelectSubject,_title,_description,ab,finalID,formatted) async{



    var url = 'http://192.168.1.215:8080/create/activity';

    Map data = {
      "className":_SelectClass,
      "subjectName":_SelectSubject,
      "title":_title,
      "description":_description,
      "question":ab,
      "CID":finalID,
      "schoolID":schoolID,
      "activityCreatedDate":formatted,
      "type":"homework"

    };
    var body = convert.json.encode(data);

    var response = await http.post(url,body:body,headers:{"Content-Type": "application/json"});
    var jsonResponse = convert.jsonDecode(response.body);
   //return jsonResponse['status'];

    if (response.statusCode == 200) {

      return jsonResponse['status'];

    }

    else {
      print('Request failed with status: ${response.statusCode}.');
    }

  }

  Future<String>  httpPostActivity(_SelectClass,firstConvertedDate,_ActivityName,_ActivityPoint,descrip,formatted,finalID,status) async{



    var url = 'http://192.168.1.215:8080/create/activity';

    Map data = {
      "className":_SelectClass,
      "activityPlaningDate":firstConvertedDate,
      "activityName":_ActivityName,
      "activityPoints":_ActivityPoint,
      "description":descrip,
      "CID":finalID,
      "schoolID":schoolID,
      "activityCreatedDate":formatted,
      "status":status,
      "type":"activity"

    };
    var body = convert.json.encode(data);

    var response = await http.post(url,body:body,headers:{"Content-Type": "application/json"});
    var jsonResponse = convert.jsonDecode(response.body);
    //return jsonResponse['status'];

    if (response.statusCode == 200) {

      return jsonResponse['status'];

    }

    else {
      print('Request failed with status: ${response.statusCode}.');
    }

  }

  void dispose(){
    _subjectCounter.close();
  }

  void getSharedPrefValue() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    parentID = prefs.getString('parentId');
    print(parentID.toString()+"got pid sharedprev");

    return;

  }

}


