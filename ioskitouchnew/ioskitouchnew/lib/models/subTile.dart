/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';

/// Simple tile with icon and name.
class SubTile {
 // Image icon;
  AssetImage icon;
  String name;
  Color color;

  SubTile([this.icon = const AssetImage('assets/explore.png'), this.name = 'Invalid',this.color= const Color(0xFFFEEAE6)]);
}
