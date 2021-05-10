/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

/// [State] class to hold data of states.
/// Control point has different states.
/// Identification of state is done by [idChar].
/// [name] and [iconIndex] are used to display respective state of control point on UI.
class StateS {
  /// Identification character associated with state.
  /// Eg. 0 -> to indicate off state of the control point.
  String idChar;

  /// Name of the state to display if required. Like 'Off'.
  String name;

  /// To hold index of Icon associated with State in the icon pack.
  int iconIndex;

  /// Constructor to make object of [State] class.
  StateS([this.iconIndex = 0, this.idChar = '0', this.name = 'Off']);
}
