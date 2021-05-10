/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ioskitouchnew/CommunicationManager.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/ProgressBar.dart';
import 'package:ioskitouchnew/common/fileUtils.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/databaseHelper.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:ioskitouchnew/models/tile.dart';
import 'package:ioskitouchnew/qrCodeFormat.dart';
import 'package:ioskitouchnew/screens/controlScreens/roomView.dart';
import 'package:ioskitouchnew/screens/masterDetail.dart';
import 'package:ioskitouchnew/themeManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [AddElementScreen] is a preference screen to add elements.
/// Elements of the home automation system are [Home]s, [Room]s and [Devices]s.
/// Using this screen user can add new elements in the data-set.
class AddElementScreen extends StatefulWidget {
  static final String tag = 'AddElementScreen';

  /// [type] of the new element to be added in the system.
  ///
  /// For type = 0 => Adding new [Home].
  /// For type = 1 => Adding new [Room].
  /// For type = 2 => Adding new [Devices].
  static int type;

  /// Creating state class to manage states of [AddElementScreen].
  @override
  State<StatefulWidget> createState() => _AddElementScreenState(type);
}

/// [_AddElementScreenState] is a state class of [AddElementScreen].
/// It creates and maintains UI, also its different states for [AddElementScreen].
/// For interactive addition of the new element we have used [Stepper].
/// User can provide information like icon, name, and other information required for that element.
class _AddElementScreenState extends State<AddElementScreen> {
  DatabaseHelper database = DatabaseHelper(); //by arti

  /// [type] of the new element to be added in the system.
  int type = 0;

  /// Current index of the step in [stepList] / [Stepper].
  int stepListIndex = 0;

  /// Length of the [stepList] / [Stepper].
  int stepListLength = 0;

  /// Place holder for new Icon.
  int newIcon = 0;

  /// Place holder for new Name.
  String newName = '';

  /// Title of the screen, it is generated based on the [type].
  String title = '';
  SharedPreference pref = new SharedPreference();

  SharedPreferences sharedPreferences;
  bool prefHome = false;

  /// [TextEditingControllers] required for the text edits of the information required by the element.
  final editControlName = TextEditingController();
  final editControlDeviceID = TextEditingController(); // controller for device id field
  final editControlPassword = TextEditingController(); // controller for device password field


  Map<String, dynamic> cMap = new HashMap();
  String data='';
  String qrStringTemp='';


  /// Makes object of the [_AddElementScreenState] with type provided by [AddElementScreen].
  /// Default Name of the new element is set to 'Demo'.
  _AddElementScreenState(this.type) {
    editControlName.text = '';
  }

  /// [Home] selection dropdown, User can change selected [Home] using this dropdown.
  Widget get homeDropdown {
    return DropdownButton<String>(
      hint: Text("Choose Home"),
      items: Building.getInstance().childList.map((H) {
        return DropdownMenuItem(
          value: Building.getInstance().childList.indexOf(H).toString(),
          child: Text(H.name),
        );
      }).toList(),
      onChanged: (value) {
        this.stepListIndex = 1;
        this.setState(() =>
            (Building.getInstance().indexChildList = int.tryParse(value)));
      },
    );
  }

  /// [Room] selection dropdown, User can change selected [Room] using this dropdown.
  Widget get roomDropdown {
    return DropdownButton<String>(
        hint: Text("Choose Room"),
        items: Building.getInstance().getSelectedHome().childList.map((R) {
          return DropdownMenuItem(
            value: Building.getInstance()
                .getSelectedHome()
                .childList
                .indexOf(R)
                .toString(),
            child: Text(R.name),
          );
        }).toList(),
        onChanged: (value) {
          this.stepListIndex = 2;
          this.setState(() => (Building.getInstance()
              .getSelectedHome()
              .indexChildList = int.tryParse(value)));
        });
  }

  /// [Icon] selection dropdown, User can select new [Icon] using this dropdown.
  getIconDropDown(List<Tile> l) {
    return DropdownButton<int>(
      items: l.map((T) {
        return DropdownMenuItem(
          value: l.indexOf(T),
          child: Icon(T.icon),
        );
      }).toList(),
      onChanged: (value) => (setState(() => (newIcon = value))),
      hint: Icon(l[newIcon].icon),
    );
  }

  /// [stepList] is a list of steps to be displayed in the [Stepper].
  /// These steps are used to guide user to complete addition of the intended element.
  ///
  /// [stepList] is generated using [type].
  /// Some of these steps are different for different elements.
  List<Step> get stepList {
    List<Step> list = List();

    /// [TextField] for the name of the new element.
    final TextField textFieldName = TextField(
      textCapitalization: TextCapitalization.words,
      autofocus: false,
      controller: editControlName,
      decoration: InputDecoration(labelText: 'Assign Name', hintText: 'Name'),
    );

    /// [TextField] for the deviceID of the new [Device] element.
    final TextField textFieldDeviceID = TextField(
      autofocus: false,
      controller: editControlDeviceID,
      decoration:
          InputDecoration(labelText: 'Device ID', hintText: 'SKIT6982Y0'),
    );

    /// [TextField] for the password of the new [Device] element.
    final TextField textFieldPassword = TextField(
      autofocus: false,
      controller: editControlPassword,
      obscureText: true,
      decoration: InputDecoration(labelText: 'Password', hintText: 'password'),
    );

    /// Adding steps based of the [type].
    /// For type = 0 => Steps to guide for adding new [Home].
    /// For type = 1 => Steps to guide for adding new [Room].
    /// For type = 2 => Steps to guide for adding new [Device].
    if (this.type >= 0) {
      if (this.type >= 1) {
        /// While adding new [Room] we give selection for [Home].
        list.add(Step(
          title: Text('Selected Home: ' +
              Building.getInstance().getSelectedHome().name),
          content: homeDropdown,
          isActive: true,
        ));
        if (this.type >= 2) {
          /// While adding new [Device], we give selection for [Home] and [Room].
          list.add(Step(
            title: Text('Selected Room: ' +
                Building.getInstance().getSelectedRoom().name),
            content: roomDropdown,
            isActive: true,
          ));

          ///  While adding new [Device], we also give steps to provide deviceID and password of the device.
          if (this.type == 2) {
            this.title = 'Add New Device';
            list.add(Step(
              title: Text('Basic Configurations'),
              content: Column(
                children: <Widget>[
                  textFieldDeviceID,
                  textFieldPassword,
                ],
              ),
              isActive: true,
            ));
            list.add(Step(
              title: Text('Assign Identity'),
              content: Column(
                children: <Widget>[
                  textFieldName,
                  Row(
                    children: <Widget>[
                      Text('Assign Icon: '),
                      getIconDropDown(ThemeManager.iconListForDevice),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                ],
              ),
              isActive: true,
            ));
          }
        } else {
          /// While adding new [Room], along with [home] selection,
          /// we give steps to enter [Name] and [Icon].
          this.title = 'Add New Room';
          list.add(Step(
            title: Text('Assign Name to New Room'),
            content: textFieldName,
            isActive: true,
          ));
          list.add(Step(
            title: Text('Assign Icon to New Room'),
            content: Row(
              children: <Widget>[
                Text('Assign Icon: '),
                getIconDropDown(ThemeManager.iconListForRoom)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            isActive: true,
          ));
        }
      } else {
        /// While adding new [Home], we give steps to enter [Name] and [Icon].
        this.title = 'Add New Home';
        list.add(Step(
          title: Text('Assign Name to New Home'),
          content: textFieldName,
          isActive: true,
        ));
        list.add(Step(
          title: Text('Assign Icon to New Home'),
          content: Row(
            children: <Widget>[
              Text('Assign Icon: '),
              getIconDropDown(ThemeManager.iconListForHome)
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          isActive: true,
        ));
      }
    }

    /// Storing length of [stepList] in class variable, which is used by other methods.
    this.stepListLength = list.length;
    return list;
  }

  /// Method to add element in data-set.
  /// Based on [type] appropriate element is added to the data-set.
  void addElement(context) async {
    newName = editControlName.text;

    if (type == 0) {
      // Adding new [Home].

      if(data.contains(newName)){
        FToast.showRed('Home already exist!');
      }else{

        pref.getString(SharedKey().homeNameForBackup).then((val) {
          print('....aa....');
          print(val);

          if( val == null || val.isEmpty ){
            ///if room added then store this values in preferences bcoz to take backup for unique data
            setState(() {

              pref.putString(SharedKey().OneHomeAutobackup, '');
              pref.putString(SharedKey().homeBackupKey, '1');
              pref.putString(SharedKey().homeNameForBackup, editControlName.text);
            });

            removedDefaultData();
            Building.getInstance().childList.add(Home(newName, newName, newIcon));
            getDataFromList();
            Building.getInstance().updateDB();
            Navigator.of(context).pop();

          }else{
            FToast.showRed(val + ' this Home backup is pending!');
          }
        });

      }

    }
    else if (type == 1) {
      // Adding new [Room].

      print(data.contains(newName));
      print(cMap.containsKey(newName));

      if(data.contains(newName)){
        FToast.showRed('Room already exist!');
      }else{

    //    pref.putString(SharedKey().OneRoomAutobackup, '');
   //     pref.putString(SharedKey().roomNameForBackup, '');

        pref.getString(SharedKey().roomNameForBackup).then((val) {
          print('....aa....');
          print(val);

          if( val == null || val.isEmpty ){
            ///if room added then store this values in preferences bcoz to take backup for unique data
            setState(() {

              pref.putString(SharedKey().OneRoomAutobackup, '');
              pref.putString(SharedKey().roomBackupKey, '1');
              pref.putString(SharedKey().roomNameForBackup, editControlName.text);
            });

            removedDefaultData();
            Building.getInstance().getSelectedHome().childList.add(Room(newName, newName, newIcon));
            getDataFromList();
            Building.getInstance().updateDB();
            Navigator.of(context).pop();

          }else{
            FToast.showRed(val + ' this Room backup is pending!');
          }
        });
      }
    }
    // Adding new [Device].
    else if (type == 2) {

      if(qrStringTemp.isEmpty){
        setState(() {
          qrStringTemp = editControlDeviceID.text;
          editControlName.text = editControlDeviceID.text;
        });
      }

     if(data.contains(qrStringTemp)){
        FToast.showRed('$qrStringTemp Device already exist hardcoded values !');
        qrStringTemp='';
      }

      else{

        FToast.showGreen('Device added manually');

        pref.getString(SharedKey().deviceNameForBackup).then((val) {    //used to check backup pending or not
          print('....aaa....');
          print(val);

          if( val == null || val.isEmpty ){
            ///if device added through barcode then store this values in preferences bcoz to take backup for specific data
            setState(() {
              print('....state....');
              pref.putString(SharedKey().ONEDEVICE_AUTOBACKUP, '');
              pref.putString(SharedKey().deviceBackupKey, '1');   // arti 26 aug
              pref.putString(SharedKey().deviceNameForBackup, editControlDeviceID.text);
            });

            removedDefaultData();
            Building.getInstance().getSelectedRoom().childList.add(Devices(editControlDeviceID.text, editControlPassword.text, editControlDeviceID.text, newIcon));

      //      getDataFromList();
            MasterDetail.isCommunicationOverInternet.value = true;
            Navigator.of(context).pop();

          }else{
            FToast.showRed(val + ' this device backup is pending!');
          }
        });
      }
    }else{
      print('else');
    }
  }

  Map<String, dynamic> mMap = new HashMap();
  String valueMap='';
  List<dynamic> mHomeList = new List();
  Map<String, dynamic> roomMap = new HashMap();
  List<String> mTempDevicesList = new List();
  Map<dynamic, String> mDevicesMQTTList = new HashMap();

  void getDataFromList() {
    FlutterApp.childList = Building.getInstance().childList;
    var dName, dssidPwd;
    for (Home h in Building.getInstance().childList) {
      Map<String, dynamic> homeMap = new HashMap();
      homeMap["name"] = h.name;
      homeMap["id"] = h.iD;
      homeMap["iconIndex"] = h.iconIndex;
      homeMap["indexChildList"] = h.indexChildList;
      List<dynamic> mRoomList = new List();

      for (Room r in h.childList) {

        roomMap["name"] = r.name;
        roomMap["id"] = r.iD;
        roomMap["iconIndex"] = r.iconIndex;
        roomMap["indexChildList"] = r.indexChildList;


        List<dynamic> mDeviceList = new List();
        for (Devices d in r.childList) {
          Map<String, dynamic> deviceMap = new HashMap();
          dName = d.name;
          dssidPwd = d.ssidPassword;
          deviceMap["name"] = d.name;
          deviceMap["deviceID"] = d.deviceID;
          deviceMap["iconIndex"] = d.iconIndex;
          deviceMap["ssidPassword"] = d.ssidPassword;
          deviceMap["password"] = d.password;
          deviceMap["ip"] = d.ip;

          mDeviceList.add(deviceMap);
//          mDevicesMQTTList["${dName}"]="disconnected";
//          String val = jsonEncode(mDevicesMQTTList);
//          pref.putString(SharedKey().DEVICES_LIST,val);//todo add devices to the map
//
//          mTempDevicesList.add("${dName}${dssidPwd}");
//          String tempVal = jsonEncode(mTempDevicesList);
//          pref.putString(SharedKey().TEMP_DEVICE_LIST,tempVal);//todo add devices to the map
//          print("mDevicesMQTTList:::$val");
//          print("mTempDevicesList:::$tempVal");
        }
        roomMap["childList"] = mDeviceList;
        mRoomList.add(roomMap);
      }
 //     print("roomData:::$roomMap");
      homeMap["childList"] = mRoomList;
 //     print("homeMap:::$homeMap");
      mHomeList.add(homeMap);
      //mRoomList.clear();
    }
    mMap["homes"] = mHomeList;
    valueMap = json.encode(mMap);
    pref.putString(SharedKey().CHILD_LIST, valueMap);
//    print("homeMap....$valueMap");
    FileUtils.saveToFile(valueMap);
  }

  /// Method to build UI with [title] and [Stepper]s as per the [stepList].
  /// Also the actions to be taken when user presses continue/cancel options at every step.
  ///
  /// Continue will take to the next step,
  /// If there is no next step then we add the new element to data-set,
  /// And take user to previous screen as work here is done.
  ///
  /// Cancel will take to the previous step,
  /// If there is no previous step then we take user to the previous screen as user wants to abort the addition of the element.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(this.title),
            actions: <Widget>[qrScanButton],
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop(); //by arti

                })),
        body: Container(
          child: Stepper(
            currentStep: this.stepListIndex,
            steps: stepList,
            type: StepperType.vertical,
            onStepTapped: (i) => (setState(() => (this.stepListIndex = i))),
            onStepCancel: () => ((this.stepListIndex > 0)
                ? setState(() => (this.stepListIndex -= 1))
                : Navigator.of(context).pop()),
            onStepContinue: () =>
                ((this.stepListIndex < (this.stepListLength - 1))
                    ? setState(() => (this.stepListIndex += 1))
                    : addElement(context)),
          ),
        ),
      ),
      onWillPop: () => Future.value(false),
    );
  }

  /// Button to add element by qr code.
  /* Widget get qrScanButton =>
      IconButton(icon: Icon(Icons.add_a_photo), onPressed: qrScan);*/

  Widget get qrScanButton {
    if (type == 0) {
      return Visibility(
          visible: false,
          child: IconButton(icon: Icon(Icons.add_a_photo), onPressed: qrScan));
    }

    //todo qr code sharing
    else if (type == 1) {
      return Visibility(
          visible: false,
          child: IconButton(icon: Icon(Icons.add_a_photo), onPressed: qrScan));
    }
    else {
      return IconButton(icon: Icon(Icons.add_a_photo), onPressed: qrScan);
    }
  }

  /// Method to add element by scanning qr code.
  Future qrScan() async {
    // Scanning QR code using [BarcodeScanner] lib.
    // {for More information, visit documentation of the [barcode_scan: ^0.0.7] library for flutter}.
    // Error dialog to show if there is something went wrong while scanning the qr code.
    try {
      // Scan qr code.
      String qrScanResult = await BarcodeScanner.scan();
      print('AddElementScreen: qr scan result: $qrScanResult');

      // Process qr code.
      String qrProcessMessage = processQr(qrScanResult, false);

      // if qr code is invalid show error dialog.
      if (qrProcessMessage.contains('Invalid QR code')) {
        qrErrorDialog('Invalid QR code: \n $qrScanResult');
        return;
      }
      // If qr code is valid, show confirmation dialog to add new element to data-set.
      // if user confirms, add elements as per the qr in data-set.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm to add entities from QR'),
            content: Text(qrProcessMessage),
            actions: <Widget>[
              FlatButton(
                child: Text("CANCEL"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text("YES, ADD"),

                onPressed: () {
                  ///if device already exist in our database then avoid to add duplicate entries conditions
                  if(data.contains(qrStringTemp)){
                    FToast.showRed('Device already exist!');
                  }

                  else{

                    pref.getString(SharedKey().deviceNameForBackup).then((val) {
                      print(val);

                      if( val == null || val.isEmpty ){
                        ///if device added through barcode then store this values in preferences bcoz to take backup for specific data
                        setState(() {

                          pref.putString(SharedKey().ONEDEVICE_AUTOBACKUP, '');
                          pref.putString(SharedKey().deviceBackupKey, '1');   // arti 26 aug
                          pref.putString(SharedKey().deviceNameForBackup, editControlDeviceID.text);
                        });

                        removedDefaultData();
                        getDataFromList();

                        Navigator.of(context).pop();
                        processQr(qrScanResult, true);

                        print("build data::${Building.getInstance().childList.length}");
                        MasterDetail.isCommunicationOverInternet.value = true;

                      }else{
                        FToast.showRed(val + ' this device backup is pending!');
                      }

                    });
                  }
                },
              ),
            ],
          );
        },
      );
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied)
        qrErrorDialog('User did not grant the camera permission!');
      else
        qrErrorDialog('Unknown error: $e');
    } on FormatException {
      qrErrorDialog('Scan Cancelled, probably because "Back" button pressed');
    } catch (e) {
      qrErrorDialog('Unknown error: $e');
    }
  }

  /// Dialog which is shown with error messages, if something went wrong when scanning qr code.
  qrErrorDialog(message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('QR Scanner Error'),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  showSyncPopup(String qrProcessMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm to sync device'),
          content: Text("Added device will be sync to server"),
          actions: <Widget>[
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text("YES, ADD"),
              onPressed: () {

                Navigator.of(context).pop();
                getHomeListDataFromSelectedItem();

              },
            ),
          ],
        );
      },
    );
  }

  var deviceString;

  List<dynamic> mSynchData = new List();
  String userID;

  getHomeListDataFromSelectedItem() {
  //  print("addElementScreen getHomeListDataFromSelectedItem");

    List<dynamic> mSynchData = new List();
    //todo get [userId] from login details
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
          deviceMap["ip"] = d.ip;       //by arti

          deviceMap["switches"] = FlutterApp.deviceString;

          String fApp = FlutterApp.deviceString;
          print("addElementDeviceString::$FlutterApp.deviceString");

          List<dynamic> mControlPoints = new List();
          for (ControlPoint c in d.childList) {
            Map<String, dynamic> pointMap = new HashMap();
            pointMap["name"] = c.name;
            pointMap["type"] = c.type;
            pointMap["isVisible"] = c.isVisible;
            pointMap["idChar"] = c.idChar;
            List<dynamic> mStates = new List();
            for (int i = 0; i < c.listStates.length; i++) {
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
    cMap["syncData"] = mSynchData;
    cMap["user_id"] = FlutterApp.userID;
    data = json.encode(cMap);
    pref.putString(SharedKey().SYNC_DATA, data);
    log("cMapData::$data");
  }

  /// Processing of the scanned qr code,
  /// Validation and extraction of the information as per the predefined formats of the qr code.
  /// If [shouldAdd] flag is true then new elements are added to data-set.
  /// else only dry run is done and new elements are validated.

  String processQr(String qrString, bool shouldAdd) {
    // Message about whether if qr code is valid or not,
    // and if valid, what all elements are there in qr code.
    String message = '';

    // Element extracted from processing of the qr code.
    dynamic processedElement;

    // type = 1 if we are adding home,
    // type = 2 if we are adding room,
    // type = 3 if we are adding device
    int type = 0;

    // if qr starts with ## it is in new format.
    if (qrString.substring(0, 2).contains('##')) {
      message = 'Format: NEW\n';
      // find out what we are adding home/room/device;
      // update 'type' variables
      // make home/room/device objects with qr information and assign it to processedObj

      if (qrString.startsWith('##D') && qrString.endsWith('D##')) {
        // we are adding new [Device].
        type = 3;
        final List<String> qrSP = qrString.split('##');
        processedElement = QrCodeFormat.getDeviceElement(qrSP[1]);
        Devices t = processedElement as Devices;
        message +=
            '\n\nThis QR code has Device of Name: ${t.name} and ID: ${t.deviceID}\n';
      } else if (qrString.startsWith('##R') && qrString.endsWith('R##')) {
        // we are adding new [Room].
        type = 2;
        final List<String> qrSP = qrString.split('##');
        processedElement = QrCodeFormat.getRoomElement(qrSP[1]);
        message +=
            '\n\nThis QR code has Room with Name: ${(processedElement as Room).name}\n';
        message +=
            'And this room have total ${(processedElement as Room).childList.length} devices.';
      } else if (qrString.startsWith('##H') && qrString.endsWith('H##')) {
        // we are adding new [Home].
        type = 1;
        final List<String> qrSP = qrString.split('##');
        processedElement = QrCodeFormat.getHomeElement(qrSP[1]);
        message +=
            '\n\nThis QR code has Home with Name: ${(processedElement as Home).name}\n';
        message +=
            'And this home have total ${(processedElement as Home).childList.length} Rooms.';
      }
    } else {
      // if qr doesn't starts with '##' then it might be in old format.
      message = 'Format: OLD\n';
      message += '[ OLD formats does not have name and icon information. ]\n';

      // if there is only 1 device in qr [printed qr code], making qr string with room for it.
      if (qrString.startsWith('D?') && qrString.endsWith('?D')) {
        final List<String> _qrSP = qrString.split('?');
        if (_qrSP.length > 3) {
          qrString = _qrSP[1] +
              '-' +
              _qrSP[1] +
              '-Today-' +
              _qrSP[2] +
              '-' +
              qrString +
              '-' +
              _qrSP[1];
        }

        setState(() {
          qrStringTemp = _qrSP[1];
        });

     /*   print('qrstring...');
        print(_qrSP[1]);
        print(_qrSP[2]);*/

        editControlDeviceID.text = _qrSP[1];
        editControlPassword.text = _qrSP[2];


      }



      print('QRS: $qrString');
      // old qr code are separated by '-';
      // example : HALL-SKIT8HzU5G-Today-j3613Fyd-D?SKIT8HzU5G?j3613Fyd?D-D?SKITyL0Ojh?i82ui0p4?D-D?SKITwXY9t7?rpx4L955?D-D?SKIT04r09I?7237y3Xn?D-D?SKITY05VU9?4h72dM93?D-D?SKIThM91B5?G80acGxA?D-HALL
      final List<String> qrStringParts = qrString.split('-');

      // Extracting [Room] and [Device] information from qr code.
      if ((qrStringParts.length > 5) &&
          (qrStringParts.first == qrStringParts.last)) {
        if (qrStringParts.length == 6) {
          // We are adding new [Device].
          type = 3;
          final List<String> qrSPP = qrStringParts[4].split('?');
          processedElement = Devices(
              qrSPP[1], qrSPP[2], qrStringParts[0], 0, null, null, qrSPP[2]);
          Devices t = processedElement as Devices;
          message +=
              '\n\nThis QR code has Device of Name: ${t.name} and ID: ${t.deviceID}\n';
        } else {
          // We are adding new [Room] and [Device]s under it.
          type = 2;
          String roomName = qrStringParts.first;
          message += '\n\nThis QR code has Room with Name: $roomName\n';
          Room room = Room('R' + qrStringParts[1], roomName, 0, []);
          int devices = 0;
          for (String qrPart in qrStringParts) {
            if (qrPart.startsWith('D?')) {
              //devices += 1;
              final List<String> qrSPP = qrPart.split('?');
              if (qrSPP[1] != "TC28511TC2" || qrSPP[2] != "TC28511TC2") {
                devices += 1;
                room.childList.add(Devices(
                    qrSPP[1], qrSPP[2], qrSPP[1], 0, null, null, qrSPP[2]));
              }
              //eD += '+ Device with id: ${qrSPP[1]} and pass: ${qrSPP[2]}\n';
            }
          }
          message += 'And this room have total $devices devices.\n';
          processedElement = room;
        }
      } else
        message += 'Invalid QR code\n';
    }

    /// If [shouldAdd] flag is true then new elements are added to data-set.

    if (shouldAdd) {
      switch (type) {
        case 1: // adding [Home].
          Home t = processedElement as Home;
          if (t.name != "My Home") {
            Building.getInstance().childList.add(t);
          }
          break;
        case 2: // adding [Room].
          Room t = processedElement as Room;
          if (t.name != "Demo Room") {
            Building.getInstance().getSelectedHome().childList.add(t);
          }
          break;
        case 3: // adding [Device].
          Devices t = processedElement as Devices;
          if (t.name != "Demo Device" ||
              t.ssidPassword != "TC28511TC2" ||
              t.name != "TC28511TC2") {
            Building.getInstance().getSelectedRoom().childList.add(t);
            print(
                'Adding device ${t.name} in Room ${Building.getInstance().getSelectedRoom().name}');
          }
          break;

        /* case 4: // adding [Control point].
          ControlPoint t = processedElement as ControlPoint;

          print('arti control point:::${t.name}');
            Building
                .getInstance()
                .getSelectedDevice()
                .childList
                .add(t);
          break;*/

        default:
          qrErrorDialog('Something went wrong, no entities are added');
          break;
      }
      // Notify building and database that data has changed.
      Building.getInstance().checkChild();
      Building.getInstance().dataChangeNotifier.value =
          !(Building.getInstance().dataChangeNotifier.value);
      Building.getInstance().updateDB();
      Navigator.of(context).pop();
      return ('Successfully added qr');
    } else
      return message;
  }

  List<Home> mHomes = new List();

  void removedDefaultData() {
    for (Home h in Building.getInstance().childList) {
      Home home = new Home("", "");
      if (h.name != "My Home") {
        home.name = h.name;
        home.iD = h.iD;
        home.indexChildList = h.indexChildList;
        home.iconIndex = h.iconIndex;
        home.sceneList = h.sceneList;
        List<Room> mRooms = new List();
        for (Room r in h.childList) {
          Room room = new Room("", "");
          if (r.name != "Demo Room") {
            room.name = r.name;
            room.iD = r.iD;
            room.childList = r.childList;
            room.iconIndex = r.iconIndex;
            room.sceneList = r.sceneList;

            List<Devices> mDevices = new List();
            for (Devices d in r.childList) {
              Devices device = new Devices("", "", "");
              if (d.name != "Demo Device") {
                device.name = d.name;
                device.iconIndex = d
                    .iconIndex; //arti   icons yet nvte.. now its working [ device icons ]
                device.deviceID = d.deviceID;
                device.password = d.password;
                device.ssidPassword = d.ssidPassword;
                device.sceneList = d.sceneList;

                device.childList =
                    d.childList; //added by arti to update its icon
                device.ip = d.ip;
                mDevices.add(device);
              }
            }
            room.childList = mDevices;
            mRooms.add(room);
          }
        }
        home.childList = mRooms;
        mHomes.add(home);
      }
      Building.getInstance().childList = mHomes;
      print(
          "mHomes::${Building.getInstance().childList.length}::${mHomes.length}");
    }
  }

  List<Home> mHomes1 = new List();

  //by arti this function trial
  void removedDefaultData1() {
    for (Home h in Building.getInstance().childList) {
      Home home = new Home("", "");
      if (h.name != "My Home") {
        home.name = h.name;
        home.iD = h.iD;
        home.indexChildList = h.indexChildList;
        home.iconIndex = h.iconIndex;
        home.sceneList = h.sceneList;
        List<Room> mRooms = new List();
        for (Room r in h.childList) {
          Room room = new Room("", "");
          if (r.name != "Demo Room") {
            room.name = r.name;
            room.iD = r.iD;
            room.childList = r.childList;
            room.iconIndex = r.iconIndex;
            room.sceneList = r.sceneList;

            List<Devices> mDevices = new List();
            List<ControlPoint> mControlPoint = new List();
            Devices device = new Devices("", "", "");
            //added by arti, why - switches clear hot hote so icons/name navte diasat
            ControlPoint controlPoint = new ControlPoint(
              "",
              "",
            );

            for (Devices d in r.childList) {
              if (d.name != "Demo Device") {
                device.name = d.name;
                device.iconIndex = d
                    .iconIndex; //arti   icons yet nvte.. now its working [ device icons ]
                device.deviceID = d.deviceID;
                device.password = d.password;
                device.ssidPassword = d.ssidPassword;
                device.sceneList = d.sceneList;

                device.ip = d.ip; //by arti
                device.childList = d.childList;

                for (ControlPoint c in d.childList) {
                  controlPoint.name = c.name;
                  controlPoint.type = c.type;
                  controlPoint.isVisible = c.isVisible;
                  controlPoint.idChar = c.idChar;
                  controlPoint.stateIndex = c.stateIndex;
                  controlPoint.listStates = c.listStates;
                  mControlPoint.add(controlPoint);
                }
                device.childList = mControlPoint;
                mDevices.add(device);
              }
              //  device.childList= mControlPoint;
            }
            room.childList = mDevices;
            mRooms.add(room);
          }
        }
        home.childList = mRooms;
        mHomes1.add(home);
      }
      Building.getInstance().childList = mHomes1;
      print(
          "mHomes1::${Building.getInstance().childList.length}::${mHomes1.length}");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    editControlName.clear();

    super.dispose();
  }
  @override
  void initState() {

    super.initState();

    pref.getString(SharedKey().DEVICE_STRING).then((value) {
      setState(() {
        deviceString = value;
        print("deviceString::$deviceString");
      });
      pref.getString(SharedKey().USER_ID).then((val) {
        setState(() {
          if (val != null) {
            userID = val;
            print("userID::$userID");
          }
        });
      });
    });
    getDataFromList();  // initstate
    getHomeListDataFromSelectedItem();
    //   removedDefaultData();  //comment by arti
    //bcoz when i try to add new device then its icon and name all is set to default icons
  }
}
