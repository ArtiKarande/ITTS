/*
 * Created by Mahendra Phule in the year of 2018.
 * Copyright (c) 2018 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/models/subTile.dart';
import 'package:ioskitouchnew/models/tile.dart';

///
/// Look and theme of the application are maintained and provided by [ThemeManager] class.
///
class ThemeManager {
  /// Default theme of the application.
  static get defaultTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.black,
      accentColor: Colors.lightBlueAccent,
    );
  }

  /// Name of the application.
  static final String applicationName = 'Skroman iTouch';

  /// Value of a selection color.
  static final Color colorSelected = Colors.lightBlueAccent;    //lightBlueAccent
  static final Color boxSelected = Colors.yellowAccent;
  static final Color boxCSelected = Colors.amber;

  /// Value of unselected color.
  static final Color unselectedColor = Colors.white;
  static final Color boxUnselectedColor = Colors.grey;

  /// List of icons for homes.
  static final List<Tile> iconListForHome = [
    Tile(Icons.home),
    Tile(Icons.supervisor_account),
    Tile(Icons.location_city),
    Tile(Icons.local_convenience_store),
    Tile(Icons.account_balance),
    Tile(Icons.business),
    Tile(Icons.local_mall),
    Tile(Icons.school),
  ];

  /// List of icons for rooms.
  static final List<Tile> iconListForRoom = [
    Tile(Icons.live_tv),
    Tile(Icons.room),
    Tile(Icons.local_hotel),
    Tile(Icons.local_dining),
    Tile(Icons.restaurant),
    Tile(Icons.local_parking),
    Tile(Icons.room_service),
    Tile(Icons.smoking_rooms),
    Tile(Icons.kitchen),
    Tile(Icons.import_contacts),
    Tile(Icons.local_florist),
    Tile(Icons.local_bar),
    Tile(Icons.local_cafe),
    Tile(Icons.local_drink),
    Tile(Icons.local_hospital),
    Tile(Icons.local_laundry_service),
    Tile(Icons.local_library),
    Tile(Icons.child_care),
    Tile(Icons.local_movies),
    Tile(Icons.local_see),
    Tile(Icons.dashboard),
    Tile(Icons.local_pizza),
    Tile(Icons.toys),

  ];

  /// List of icons for devices.
  static final List<Tile> iconListForDevice = [
    Tile(Icons.device_hub),
    Tile(Icons.chevron_left),
    Tile(Icons.chevron_right),
    Tile(Icons.devices),
    Tile(Icons.devices_other),
    Tile(Icons.center_focus_strong),
    Tile(Icons.filter_vintage),
    Tile(Icons.flare),
    Tile(Icons.looks_one),
    Tile(Icons.looks_two),
    Tile(Icons.looks_3),
    Tile(Icons.looks_4),
    Tile(Icons.looks_5),
    Tile(Icons.looks_6),
    Tile(Icons.looks),

//    Tile(Icons.local_mall),
//    Tile(Icons.local_movies),
//    Tile(Icons.local_offer),
//    Tile(Icons.local_see),
//    Tile(Icons.local_florist),
//    Tile(Icons.local_gas_station),
//    Tile(Icons.local_grocery_store),
//    Tile(Icons.local_hospital),
//    Tile(Icons.important_devices),
//    Tile(Icons.open_in_browser),
//    Tile(Icons.local_florist),
//    Tile(Icons.local_airport),
//    Tile(Icons.local_atm),
//    Tile(Icons.local_bar),
//    Tile(Icons.local_cafe),
//    Tile(Icons.local_car_wash),
  ];

  /// List of icons for control points.
  static final List<Tile> iconListForControlPoint = [
    Tile(Icons.lightbulb_outline),
    Tile(Icons.toys),
    Tile(Icons.brightness_1),
    Tile(Icons.brightness_low),
    Tile(Icons.brightness_medium),
    Tile(Icons.brightness_high),
    Tile(Icons.offline_bolt),
    Tile(Icons.power_settings_new),
    Tile(Icons.filter),
    Tile(Icons.memory),
    Tile(Icons.ac_unit),
    Tile(Icons.surround_sound),
    Tile(Icons.favorite_border),
    Tile(Icons.favorite),

    Tile(Icons.power),
    Tile(Icons.power_input),
    Tile(Icons.settings_power),
    Tile(Icons.fast_rewind),
    Tile(Icons.pause),
    Tile(Icons.play_arrow),
    Tile(Icons.fast_forward),
  ];

  /// List of icons for scenes.
  static final List<Tile> iconListForScene = [
    Tile(Icons.looks_one),
    Tile(Icons.looks_two),
    Tile(Icons.looks_3),
    Tile(Icons.looks_4),
    Tile(Icons.looks_5),
    Tile(Icons.looks_6),
    Tile(Icons.ac_unit),
    Tile(Icons.apps),
    Tile(Icons.map),
    Tile(Icons.looks),
    Tile(Icons.alarm),
    Tile(Icons.alarm_on),
    Tile(Icons.alarm_off),
    Tile(Icons.alarm_add),
    Tile(Icons.offline_bolt),
    Tile(Icons.offline_pin),
    Tile(Icons.opacity),
    Tile(Icons.open_with),
    Tile(Icons.open_in_new),
    Tile(Icons.memory),
  ];

  static final List<SubTile> iconList = [
    //, width: 32.0, height: 32.0,color: Colors.white)
    // SubTile(new Image(image: const AssetImage('images/home.png'), width: 48.0, height: 48.0,color: Colors.white,)),
    // SubTile(new Image(image: const AssetImage('images/fan.png'), width: 48.0, height: 48.0,color: Colors.white)),
    SubTile(const AssetImage('images/light.png')),
    SubTile(const AssetImage('images/brightness_1.png')),
    SubTile(const AssetImage('images/brightness_low.png')),
    SubTile(const AssetImage('images/brightness_med.png')),
    SubTile(const AssetImage('images/brightness_high.png')),
    SubTile(const AssetImage('images/plug_socket.png')),
    SubTile(const AssetImage('images/power.png')),
    SubTile(const AssetImage('images/memory.png')),
    SubTile(const AssetImage('images/ac.png')),
    SubTile(const AssetImage('images/favourite_outline.png')),
    SubTile(const AssetImage('images/favourite_filled.png')),
    SubTile(const AssetImage('images/power_input.png')),
    SubTile(const AssetImage('images/rewind_forward.png')),
    SubTile(const AssetImage('images/pause.png')),
    SubTile(const AssetImage('images/fast_forward.png')),
    SubTile(const AssetImage('images/cctv.png')),
    SubTile(const AssetImage('images/plug.png')),
    SubTile(const AssetImage('images/play.png')),
  ];
}
