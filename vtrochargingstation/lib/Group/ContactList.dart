/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/Group/NewGroup.dart';
import 'package:vtrochargingstation/Group/UserContactItem.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';
import 'package:vtrochargingstation/neo/text_field.dart';

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppTheme utils = new AppTheme();
  Iterable<Contact> _contacts;
  var phones = [];

  String nameStr = '', planCheckList = '';
  List<String> checksMobile = new List<String>();
  List<String> checksName = new List<String>();
  List<String> checksUserImage = new List<String>();

  List<UserContactItem> _userList = new List<UserContactItem>();
  TextEditingController _searchNameController = new TextEditingController();

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: false, /// keyboard issue handled

      /// UI
      body: SafeArea(
        child: Stack(
          children: [

            Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: CircularSoftButton(
                        radius: 20,
                        icon: Padding(
                          padding: EdgeInsets.only(left: h / 90),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: w / 4),
                      child: Text('Create group',
                          style: utils.textStyleRegular(context, 54, AppTheme.text1,
                              FontWeight.normal, 0.0, '')),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NeumorphicTextField(
                    textSize: 48,
                    height: 15.0,
                    text: _searchNameController.text,
                    hint: 'Enter/Search Mobile Number',
                    onChanged: itemTitleChange,
                  ),
                ),
                contactList(),
              ],
            ),

            ///CREATE GROUPS pay button
            Hero(
              tag: 'group',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: h / 14,
                      margin: EdgeInsets.symmetric(horizontal: h / 22, vertical: w/10),
                      child: NeumorphicButton(
                        onPressed: () {

                          print(checksMobile.length);
                          print(checksMobile);

                          if(checksMobile.length >= 1 ){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NewGroup(checksMobile, checksName)));
                          }else{
                            ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Select at least 1 group member');
                          }
                        },
                        style: NeumorphicStyle(
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(30)),
                            color: AppTheme.background,
                            depth: 5,
                            surfaceIntensity: 0.20,
                            intensity: 0.95,
                            shadowDarkColor: AppTheme.bottomShadow,
                            //outer bottom shadow
                            shadowLightColor:
                            Colors.white // outer top shadow
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Add',
                                style: utils.textStyleRegular(context, 50, AppTheme.text2, FontWeight.w700, 0.0, '')),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF808080),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// [flutter_contact] plugin used
  Future<void> getContacts() async {
    var iter = 0;

    /// We already have permissions for contact when we get to this page, so we
    /// are now just retrieving it
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
      contacts.forEach((contact) => contact.phones.forEach((phone) => phones.add(phone.value)));

    });
    contacts.forEach((contact) async {
      var mobileNum = contact.phones.toList();

      if (mobileNum.length != 0) {
        setState(() {
          _userList.add(UserContactItem(contact.displayName, mobileNum[0].value, contact.displayName));
          iter++;
        });
      } else {
        iter++;
      }
    });
  }

  /// show all contact list in vertical order with check box
  contactList() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return _contacts != null
        /// Build a list view of all contacts, displaying their avatar and display name
        ? Flexible(
            child: Container(
              //    height: h / 1.13,
              width: w,
              height: h,
              child: ScrollConfiguration(
                behavior: ScrollBehavior(),
                child: ListView.builder(
                  itemCount: _userList.length,
                  itemBuilder: (BuildContext context, int index) {

                  //  print(_userList[index].imageUrl);
                    Contact contact = _contacts?.elementAt(index);
                    return CheckboxListTile(
                      activeColor: AppTheme.greenShade1,
                      checkColor: AppTheme.white,
                      value: checksMobile.contains(_userList[index].number),
                      onChanged: (bool value) {

                        setState(() {
                          if (checksMobile.contains(_userList[index].number)) {
                            checksMobile.remove(_userList[index].number);
                            checksName.remove(_userList[index].contactName);
                            checksUserImage.remove(_userList[index].imageUrl);
                            print('delete');
                          } else {
                            checksMobile.add(_userList[index].number);
                            checksName.add(_userList[index].contactName);
                      //      checksUserImage.add(_userList[index].imageUrl);
                          }
                        });
                      },
                      title: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: h / 120, horizontal: w / 20),
                        leading:
                        CircleAvatar(
                                child: Text(contact.initials(), style: TextStyle(color: AppTheme.greenShade1),),
                            //    backgroundColor: Theme.of(context).accentColor,
                                backgroundColor: AppTheme.greenShade2,
                              ),
                        title: Text(_userList[index].contactName),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        : Center(child: const CircularProgressIndicator());
  }

  /// value changes to edittext callback method
  void itemTitleChange(String title) {
    setState(() async {
      this._searchNameController.text = title;

      print('text val...');
      print(_searchNameController.text);

      // Get contacts matching a string
      Iterable<Contact> contacts = await ContactsService.getContacts(query: title);
      _contacts = contacts;
    });
  }
}
