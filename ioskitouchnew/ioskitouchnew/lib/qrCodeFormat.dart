/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'package:ioskitouchnew/models/controlPoint.dart';
import 'package:ioskitouchnew/models/device.dart';
import 'package:ioskitouchnew/models/home.dart';
import 'package:ioskitouchnew/models/room.dart';
import 'package:ioskitouchnew/models/state.dart';

/// [QrCodeFormat] is a collection of functions to manage qr codes.
/// Encoding and Decoding qr strings in new format is done with these functions.
///
/// While encoding we put all required properties of element in the string.
/// Wile decoding we extract all required properties of element from string.
///
/// All the encodings have same starting and ending for simple error detection.
///
/// Separation character for every element is different.
///   - Char '~' for [Home] element.
///   - Char '-' for [Room] element.
///   - Char '?' for [Devices] element.
///   - Char '<' for [ControlPoint] element.
///   - Char '>' for [State] element.
class QrCodeFormat {

  /// Encoding a [Home] element into the string.
  /// This String in turn fed to the qr generator to make qr code.
  static String getHomeString(Home home) {
    String qrString = 'H~${home.iD}~${home.name}~${home.iconIndex}~';
    for (Room r in home.childList) qrString += (getRoomString(r) + '~');
    qrString += 'H';
    return qrString;
  }

  /// Decoding a [Home] element from input [qrString].
  static Home getHomeElement(String qrString) {
    Home processedObject;
    final List<String> qrStringParts = qrString.split('~');
    if (qrStringParts.length > 5) {
      if (qrStringParts.first == qrStringParts.last) {
        processedObject = Home(qrStringParts[1], qrStringParts[2], int.tryParse(qrStringParts[3]), [], []);
        for (int i=4; i<(qrStringParts.length-1); i++) {
          if (qrStringParts[i].startsWith('R')) processedObject.childList.add(getRoomElement(qrStringParts[i]));
        }
        processedObject.checkChild();
      }
    }
    return processedObject;
  }

  /// Encoding a [Room] element into the string.
  /// This String in turn fed to the qr generator to make qr code.
  /// Or can be used inside the [Home] element to represents its children.
  static String getRoomString(Room room) {
    String qrString = 'R-${room.iD}-${room.name}-${room.iconIndex}-';
    for (Devices d in room.childList) qrString += (getDeviceString(d) + '-');
    qrString += 'R';
    return qrString;
  }

  /// Decoding a [Room] element from input [qrString].
  static Room getRoomElement(String qrString) {
    Room processedObject;
    final List<String> qrStringParts = qrString.split('-');
    if (qrStringParts.length > 5) {
      if (qrStringParts.first == qrStringParts.last) {
        processedObject = Room(qrStringParts[1], qrStringParts[2], int.tryParse(qrStringParts[3]), [], []);
        for (int i=4; i<(qrStringParts.length-1); i++) {
          if (qrStringParts[i].startsWith('D')) processedObject.childList.add(getDeviceElement(qrStringParts[i]));
        }
        processedObject.checkChild();
      }
    }
    return processedObject;
  }

  /// Encoding a [Devices] element into the string.
  /// This String in turn fed to the qr generator to make qr code.
  /// Or can be used inside the [Room] element to represents its children.
  static String getDeviceString(Devices device) {
    String qrString = 'D?${device.deviceID}?${device.password}?${device.name}?${device.iconIndex}?${device.ssidPassword}?';
    for (ControlPoint c in device.childList) qrString += (getControlPointString(c) + '?');
    qrString += 'D';
    return qrString;
  }

  /// Decoding a [Devices] element from input [qrString].
  static Devices getDeviceElement(String qrString) {
    Devices processedObject;
    final List<String> qrStringParts = qrString.split('?');
    if (qrStringParts.length > 7) {
      if (qrStringParts.first == qrStringParts.last) {
        processedObject = Devices(qrStringParts[1], qrStringParts[2], qrStringParts[3], int.tryParse(qrStringParts[4]), [], [], qrStringParts[5]);
        for (int i=6; i<(qrStringParts.length-1); i++) {
          if (qrStringParts[i].startsWith('C')) processedObject.childList.add(getControlPointElement(qrStringParts[i]));
        }
        processedObject.checkChild();
      }
    }
    return processedObject;
  }

  /// Encoding a [ControlPoint] element into the string.
  /// This String is used inside the [Devices] element to represents its children.
  static String getControlPointString(ControlPoint controlPoint) {
    String qrString = 'C<${controlPoint.type}<${controlPoint.idChar}<${controlPoint.name}<';
    for (StateS s in controlPoint.listStates) qrString += (getStateString(s) + '<');
    qrString += 'C';
    return qrString;
  }

  /// Decoding a [ControlPoint] element from input [qrString].
  static ControlPoint getControlPointElement(String qrString) {
    ControlPoint processedObject;
    final List<String> qrStringParts = qrString.split('<');
    if (qrStringParts.length > 5) {
      if (qrStringParts.first == qrStringParts.last) {
        processedObject = ControlPoint(qrStringParts[1], qrStringParts[2], false, [], 0, qrStringParts[3]);
        for (int i=4; i<(qrStringParts.length-1); i++) {
          processedObject.listStates.add(getStateElement(qrStringParts[i]));
        }
      }
    }
    return processedObject;
  }

  /// Encoding a [State] element into the string.
  /// This String is used inside the [ControlPoint] element to represents its children.
  static String getStateString(StateS state) {
    return('S>${state.idChar}>${state.name}>${state.iconIndex}>S');
  }

  /// Decoding a [State] element from input [qrString].
  static StateS getStateElement(String qrString) {
    StateS processedObject;
    final List<String> qrStringParts = qrString.split('>');
    if (qrStringParts.length == 5) {
      if (qrStringParts.first == qrStringParts.last) {
        processedObject = StateS(int.tryParse(qrStringParts[3]), qrStringParts[1], qrStringParts[2]);
      }
    }
    return processedObject;
  }
}