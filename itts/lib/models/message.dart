/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';

@immutable
class Message {
  final String title;
  final String body;

  const Message({
    @required this.title,
    @required this.body,
  });
}