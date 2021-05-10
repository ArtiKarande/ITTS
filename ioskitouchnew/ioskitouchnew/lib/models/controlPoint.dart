/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'package:ioskitouchnew/models/state.dart';

/// [ControlPoint] class to hold data of control points.
/// [ControlPoint]s are basic control elements in a [Device].
/// It represents a element like Light, fan, etc of actual device.
class ControlPoint {
  /// Type of control point.
  /// Eg. 'L' for Light, 'F' for Fan, etc.
  String type;

  /// Identification character associated with control point.
  /// Eg. '1' in 'Light 1', etc.
  String idChar;

  /// Name associated with with control point.
  /// Eg. 'Light', 'Fan', etc.
  String name;

  /// Flag to display on / off state of the control point.
  /// Eg. Light is 'on' or 'off'.
  bool flagOnOff;

  /// List of all possible states of a control point.
  /// Eg. On/Off is a state for lights/sockets/master/mood.
  /// Fan can have states like '1', '2', etc.
  List<StateS> listStates;

  /// Index pointing to current state of control point in [listStates].
  int stateIndex;

  /// Flag to indicate whether this control point is visible on UI or not.
  bool isVisible;

  /// Constructor to make object of [ControlPoint] class.
  ControlPoint(this.type, this.idChar,
      [this.flagOnOff = false,
      this.listStates,
      this.stateIndex = 0,
      this.name,
      this.isVisible = true]) {
    // Assign default values if state list is null.
    if (this.listStates == null) this.listStates = getDefaultStateList();

    // Assign default values if state name is null.
    if (this.name == null) this.name = getDefaultName();
  }

  /// List of states of control point, according to [type].
  List<StateS> getDefaultStateList() {
    switch (this.type.toLowerCase()) {
      // States of fan
      case 'f':
        return ([
          StateS(1, '1', 'Speed 1'),
          StateS(2, '2', 'Speed 2'),
          StateS(3, '3', 'Speed 3'),
          StateS(4, '4', 'Speed 4'),
        ]);

      // States of Socket.
      case 's':
        return ([StateS(5)]);

      // States of Master.
      case 'm':
        return ([StateS(6)]);

      // States of scenes.
      case 'sc':
        switch (this.idChar.toLowerCase()) {
          case '1':
            return ([StateS(0)]);
          case '2':
            return ([StateS(1)]);
          case '3':
            return ([StateS(2)]);
          case '4':
            return ([StateS(3)]);
          case '5':
            return ([StateS(4)]);
          case '6':
            return ([StateS(5)]);
          case '7':
            return ([StateS(6)]);
          default:
            return ([StateS(7)]);
        }
        break;
      default:
        // Making state of light for all other combinations.
        return ([StateS()]);
    }
  }

  /// Name  of control point, according to [type].
  getDefaultName() {
    switch (this.type.toLowerCase()) {
      case 'f':
        return ('Fan ' + this.idChar);
      case 's':
        return ('Socket ' + this.idChar);
      case 'm':
        return ('Master ' + this.idChar);
      case 'sc':
        return ('Mood ' + this.idChar);
      default:
        return ('Light ' + this.idChar);
    }
  }

  /// Validation method to validate states of control points.
  /// It checks and corrects [listStates] and [stateIndex].
  checkChild() {
    // Tag to track print statements in console.
    final String fTAG = 'ControlPoint.checkChild.' + this.name;

    // Validation of [listStates],
    // if it is not blank then check every state inside it, else load default values.
    if (this.listStates != null && this.listStates.length > 0) {
      // Validation of [stateIndex]
      // if index is bigger than count in list, we need to reset it.
      if (this.listStates.length <= this.stateIndex) {
        print('$fTAG: listStates.length <=stateIndex; resetting stateIndex to 0');
        this.stateIndex = 0;
      }
      // checking every state in state list
      // if state is null/blank, reset it to default.
      for (int i = 0; i < this.listStates.length; i++) {
        if (this.listStates[i] == null) {
          print('$fTAG.${i.toString()}: is empty; loading default value.');
          this.listStates[i] = StateS();
        }
      }
    } else {
      print('$fTAG: listStates is empty; loading default values.');
      this.listStates = getDefaultStateList();
      this.stateIndex = 0;
    }
  }

  /// Toggles [flagOnOff] flag.
  toggleOnOff() => (flagOnOff = !flagOnOff);

  /// Increments [stateIndex] in [listStates].
  /// Resets [stateIndex] if it crosses end.
  incrementState() {
    stateIndex++;
    if (stateIndex >= listStates.length) stateIndex = 0;
  }

  /// Decrements [stateIndex] in [listStates].
  /// Resets [stateIndex] if it goes behind start.
  decrementState() {
    stateIndex--;
    if (stateIndex < 0) stateIndex = listStates.length - 1;
  }
}
