/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/qrCodeFormat.dart';

/// [ShareQRScreen] is a preference screen to share elements.
/// Elements of the home automation system are [Home]s, [Room]s and [Devices]s.
/// Using this screen user can share elements from the data-set with other users.
class ShareQRScreen extends StatefulWidget {
  static final String tag = 'ShareQRScreen';

  /// [type] of the new element to be added in the system.
  ///
  /// type = 0 => Sharing a [Home].
  /// type = 1 => Sharing a [Room].
  /// type = 2 => Sharing a [Devices].
  static int type;

  /// Creating state class to manage states of [ShareQRScreen].
  @override
  State<StatefulWidget> createState() => _ShareQRScreenState(type);
}

/// [_ShareQRScreenState] is a state class of [ShareQRScreen].
/// It creates and maintains UI, also its different states for [ShareQRScreen].
/// For interactive sharing of the element we have used [Stepper].
/// User can select which element are to be shared and in what format.
class _ShareQRScreenState extends State<ShareQRScreen> {
  /// type of the element to be shared.
  int type = 0;

  /// String provided to qr library to generate qr code.
  String qrString = 'Hello World';

  String nameNew='',passwordNew='';

  /// Title of the screen, it is generated based on the [type].
  String title = '';

  /// Current index of the step in [stepList] / [Stepper].
  int stepListIndex = 0;
  /// Length of the [stepList] / [Stepper].
  int stepListLength = 0;

  /// Format of the qr code {old/new} in which data is to be shared.
  bool isNewFormat = false; // false: old way

  /// Making object of the [_ShareQRScreenState] with type provided by the [ShareQRScreen].
  _ShareQRScreenState(this.type);

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
        this.setState(() => (Building.getInstance().indexChildList = int.tryParse(value)));
      },
    );
  }

  /// [Room] selection dropdown, User can change selected [Room] using this dropdown.
  Widget get roomDropdown {
    return DropdownButton<String>(
        hint: Text("Choose Room"),
        items: Building.getInstance().getSelectedHome().childList.map((R) {
          return DropdownMenuItem(
            value: Building.getInstance().getSelectedHome().childList.indexOf(R).toString(),
            child: Text(R.name),
          );
        }).toList(),
        onChanged: (value) {
          this.stepListIndex = 2;
          this.setState(() => (Building.getInstance().getSelectedHome().indexChildList = int.tryParse(value)));
        });
  }

  /// [Devices] selection dropdown, User can change selected [Devices] using this dropdown.
  Widget get deviceDropdown {
    return DropdownButton<String>(
        hint: Text("Choose Device"),
        items: Building.getInstance().getSelectedRoom().childList.map((D) {
          return DropdownMenuItem(
            value: Building.getInstance().getSelectedRoom().childList.indexOf(D).toString(),
            child: Text(D.name),
          );
        }).toList(),
        onChanged: (value) {
          this.stepListIndex = 3;
          this.setState(() => (Building.getInstance().getSelectedRoom().indexChildList = int.tryParse(value)));
        });
  }
  /// [stepList] is a list of steps to be displayed in the [Stepper].
  /// These steps are used to guide user to complete sharing of the intended element.
  ///
  /// [stepList] is generated using [type].
  /// Some of these steps are different for different elements.
  List<Step> get stepList {
    List<Step> list = List();

    String message = '\nOld format of QR does not have icon and name information.';

    /// Adding steps based of the [type].
    /// For type = 0 => Steps to guide for sharing a [Home].
    /// For type = 1 => Steps to guide for sharing a [Room].
    /// For type = 2 => Steps to guide for sharing a [Device].
    if (this.type >= 0) {
      /// While sharing [Home], [Room] or [Device], we give selection for [Home].
      list.add(Step(title: Text('Selected Home: ${Building.getInstance().getSelectedHome().name}'),
          content: homeDropdown, isActive: true));

      if (this.type >= 1) {
        /// While sharing [Room] or [Device], we give selection for [Room].
        list.add(Step(title: Text('Selected Room: ${Building.getInstance().getSelectedRoom().name}'),
            content: roomDropdown, isActive: true));

        if (this.type >= 2) {
          this.title = 'Share Device';
          /// While sharing [Device], we give selection for [Device].
          list.add(Step(title: Text('Selected Device: ${Building.getInstance().getSelectedDevice().name}'),
              content: deviceDropdown, isActive: true));

          /// Also the selection for the format old/new.
          list.add(Step(title: Text('Select QR format'),
              content: Column(children: <Widget>[Text(message),
//              Row(children:<Widget>[Text(isNewFormat ? 'New': 'Old'),
//              Switch(value: isNewFormat,
//                  onChanged: (bool value) => setState(() => (isNewFormat = value)))])
              ]),
              isActive: true)
          );

          /// Last step where qr is generated and displayed.
          list.add(Step(title: Text('Scan QR in other device'), content: generatedQR,
              isActive: true));
        } else {
          this.title = 'Share Room';

          /// The selection for the format old/new.
          list.add(Step(title: Text('Select QR format'),
              content: Column(children: <Widget>[Text(message),
//              Row(children:<Widget>[Text(isNewFormat ? 'New': 'Old'),
//              Switch(value: isNewFormat,
//                  onChanged: (bool value) => setState(() => (isNewFormat = value)))])
              ]),
              isActive: true));

          /// Last step where qr is generated and displayed.
          list.add(Step(title: Text('Scan QR in other device'), content: generatedQR,
              isActive: true));
        }
      }
      else {
        this.title = 'Share Home';
        isNewFormat = true; // home can be shared in new way only

        /// Last step where qr is generated and displayed.
        list.add(Step(title: Text('Scan QR in other device'), content: generatedQR,
            isActive: true));
      }
    }
    /// Storing length of [stepList] in class variable, which is used by other methods.
    this.stepListLength = list.length;
    return list;
  }

  /// Method to generate qr based on [isNewFormat] and [type].
  /// Different qr code as per the old/new format.
  Widget get generatedQR {
    if (isNewFormat) {
      qrString = '##';
      if (this.type == 0)
        qrString += QrCodeFormat.getHomeString(Building.getInstance().getSelectedHome());
      else if (this.type == 1)
        qrString += QrCodeFormat.getRoomString(Building.getInstance().getSelectedRoom());
      else if (this.type == 2)
        qrString += QrCodeFormat.getDeviceString(Building.getInstance().getSelectedDevice());
      else
        qrString = 'Unable to share';
      qrString += '##';
      print ('Sharing in new way : qrS.length -> ${qrString.length}');
    }
    else { // qr in old way
      switch (this.type) {
        case 1:
          String name = Building.getInstance().getSelectedRoom().name;
          String id = Building.getInstance().getSelectedDevice().deviceID;
          String p = Building.getInstance().getSelectedDevice().password;
          qrString = '$name-$id-today-$p-';
          for (Devices d in Building.getInstance().getSelectedRoom().childList) qrString += 'D?${d.deviceID}?${d.password}?D-';
          qrString += '$name';
          print ('Sharing -> ${qrString.length}');
          break;
        case 2:
          String id = Building.getInstance().getSelectedDevice().deviceID;
          String name = Building.getInstance().getSelectedDevice().name;
          String p = Building.getInstance().getSelectedDevice().password;
      //    qrString = '$name-$id-today-$p-D?$id?$p?D-$name';

          qrString = 'D?'+id+'?'+p+'?D';


          setState(() {
            nameNew = name;
            passwordNew = p;
          });
          break;

        default:
          qrString = 'Unable to share QR in old way';
          print ('Unable to share QR in old way -> ${qrString.length}');
          break;
      }
    }

    /// finding right version to display qr code.
    int version = getQrVersion(qrString.length);
    print('generating qr image for $qrString; version: $version');
    if (version > 0) {
      /// for short length of qr code we can have error correction.
      if (version < 40)
        return Column(
          children: <Widget>[
            QrImage(data: qrString, backgroundColor: Colors.white, version: version, errorCorrectionLevel: QrErrorCorrectLevel.M,),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(nameNew.isEmpty ? '' : "SSID : ",style: TextStyle(fontSize: 18)),

                  Text(nameNew,style: TextStyle(fontSize: 18)),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(passwordNew.isEmpty ? '' : "Password : ", style: TextStyle(fontSize: 19)),
                Text(passwordNew, style: TextStyle(fontSize: 19)),
              ],
            ),
          ],
        );
      return QrImage(data: qrString, backgroundColor: Colors.white, version: version);
    }
    else {
      qrErrorDialog('Too much data in qr code');
      return QrImage(data: 'Too much data', backgroundColor: Colors.white);
    }
  }

  /// Finding right version of qr code based on its length.
  /// For more information see wiki for qr code versions.
  int getQrVersion(length) {
    if (length < 14) return 1;
    else if (length < 26) return 2;
    else if (length < 42) return 3;
    else if (length < 62) return 4;
    else if (length < 84) return 5;
    else if (length < 106) return 6;
    else if (length < 122) return 7;
    else if (length < 152) return 8;
    else if (length < 180) return 9;
    else if (length < 213) return 10;
    else if (length < 251) return 11;
    else if (length < 287) return 12;
    else if (length < 331) return 13;
    else if (length < 362) return 14;
    else if (length < 412) return 15;
    else if (length < 450) return 16;
    else if (length < 504) return 17;
    else if (length < 560) return 18;
    else if (length < 624) return 19;
    else if (length < 666) return 20;
    else if (length < 711) return 21;
    else if (length < 779) return 22;
    else if (length < 857) return 23;
    else if (length < 911) return 24;
    else if (length < 997) return 25;
    else if (length < 1059) return 26;
    else if (length < 1125) return 27;
    else if (length < 1190) return 28;
    else if (length < 1264) return 29;
    else if (length < 1370) return 30;
    else if (length < 1452) return 31;
    else if (length < 1538) return 32;
    else if (length < 1628) return 33;
    else if (length < 1722) return 34;
    else if (length < 1809) return 35;
    else if (length < 1911) return 36;
    else if (length < 1989) return 37;
    else if (length < 2099) return 38;
    else if (length < 2213) return 39;
    else if (length < 4296) return 40;
    else return -1;
  }

  /// Method to build UI with [title] and [Stepper]s as per the [stepList].
  /// Also the actions to be taken when user presses continue/cancel options at every step.
  ///
  /// Continue will take to the next step,
  /// If there is no next step then we take user to previous screen as work here is done.
  ///
  /// Cancel will take to the previous step,
  /// If there is no previous step then we take user to the previous screen as user wants to abort the addition of the element.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(this.title)),
      body: Container(
        child: Stepper(
          currentStep: this.stepListIndex,
          steps: stepList,
          type: StepperType.vertical,
          onStepTapped: (i) {
            setState(() => (this.stepListIndex = i));
          },
          onStepCancel: () => ((this.stepListIndex > 0)
              ? setState(() => (this.stepListIndex -= 1))
              : Navigator.of(context).pop()),
          onStepContinue: () => ((this.stepListIndex < (this.stepListLength - 1))
              ? setState(() => (this.stepListIndex += 1))
              : Navigator.of(context).pop()),
        ),
      ),
    );
  }

  /// Dialog which is shown with error messages, if something went wrong when scanning qr code.
  qrErrorDialog(message) { // qr scanner error dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('QR Code Error'),
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
}
