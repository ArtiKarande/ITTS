/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:vtrochargingstation/Profile/editProfile/EditProfileView.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';

class EditProfile extends StatefulWidget {
  @override
  EditProfileView createState() => EditProfileView();
}

abstract class EditProfileState extends State<EditProfile> {

  @protected

  APICall apiCall = APICall();

  TextEditingController _emailIDController = TextEditingController();



}
