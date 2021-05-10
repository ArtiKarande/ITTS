/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/FToast.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
import 'package:ioskitouchnew/common/Style.dart';
import 'package:ioskitouchnew/common/StyleColor.dart';
import 'package:ioskitouchnew/screens/account/signUp.dart';

/// User Interface provider in this class is provided

class SignUpView extends SignUpState {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Sign up"),
          backgroundColor: Colors.blue,
        ),
        body: new Stack(children: <Widget>[
          Center(
            child: new Form(
                key: formKey,
                child: new Center(
                  child: new Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: new SingleChildScrollView(
                            child: new Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: EdgeInsets.fromLTRB(10.0, 0.0,10.0, 0.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          usernameEditFiled(),
                          emailEditFiled(),
                          mobileNumberEditFiled(),
                          passwordEditFiledNew(),
                          confirmPasswordEditFiledNew(),
                          confirmButton(context)
                          // changePassText()
                        ],
                      ),
                    ))),
                )),
          )
        ]));
  }

  Widget usernameEditFiled() {
    return new Container(
      margin: const EdgeInsets.only(top:8.0),
      child: new TextFormField(
        key: Key('username'),
        style: CommonStyle.whiteText,
        keyboardType: TextInputType.text,
        obscureText: false,
        controller: nameController,
        validator: (val) => val.isEmpty ? 'Username can\'t be empty.' : null,
        decoration: new InputDecoration(
          border: new UnderlineInputBorder(),
          hintStyle: CommonStyle.whiteText,
          hintText: '',
          labelText: 'Username*',
          labelStyle: CommonStyle.whiteText,
        ),
        onSaved: (val) => username = val,
      ),
    );
  }

  Widget emailEditFiled() {
    return new Container(
      child: new TextFormField(
        key: Key('emailId'),
        style: CommonStyle.whiteText,
        keyboardType: TextInputType.emailAddress,
        obscureText: false,
        controller: emailController,
        validator: validateEmail,
        decoration: new InputDecoration(
          border: new UnderlineInputBorder(),
          hintStyle: CommonStyle.whiteText,
          hintText: '',
          labelText: 'EmailId*',
          labelStyle: CommonStyle.whiteText,
        ),
        onSaved: (val) => emailId = val,
      ),
    );
  }

  Widget mobileNumberEditFiled() {
    return new Container(
      margin: const EdgeInsets.only(top:8.0),
      child: new TextFormField(
        key: Key('mobile number'),
        style: CommonStyle.whiteText,
        obscureText: false,
        controller: mobileController,
        maxLength: 10,
        keyboardType: TextInputType.number,
        validator: validateMobile,
        decoration: new InputDecoration(
          border: new UnderlineInputBorder(),
          hintStyle: CommonStyle.whiteText,
          hintText: '',
          labelText: 'Mobile number*',
          labelStyle: CommonStyle.whiteText,
        ),
        onSaved: (val) => mobileNumber = val,
      ),
    );
  }

  Widget passwordEditFiledNew() {
    return new Container(
      margin: const EdgeInsets.only(bottom:8.0),
      child: new TextFormField(
        key: Key('password'),
        style: CommonStyle.whiteText,
        keyboardType: TextInputType.text,
        obscureText: obscurePasswordText,
        controller: passController,
        validator:validatePassword,
        onSaved: (val) => password = val,
        decoration: new InputDecoration(
          border: new UnderlineInputBorder(),
          suffixIcon: new IconButton(
            icon: Icon(
              obscurePasswordText ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                obscurePasswordText = !obscurePasswordText;
              });
            },
          ),
          hintText: '',
          hintStyle: CommonStyle.whiteText,
          labelText: 'Password*',
          labelStyle: CommonStyle.whiteText,
        ),
      ),
    );
  }

  Widget confirmPasswordEditFiledNew() {
    return new Container(
      margin: const EdgeInsets.only(bottom:8.0),
      child: new TextFormField(
        key: Key('Confirm Password'),
        style: CommonStyle.whiteText,
        obscureText: obscurePasswordText1,
        keyboardType: TextInputType.text,
        controller: confirmPassController,
        validator: validatePassword,
        onSaved: (val) => password = val,
        decoration: new InputDecoration(
          border: new UnderlineInputBorder(),
          suffixIcon: new IconButton(
            icon: Icon(
              obscurePasswordText1 ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              setState(() {
                obscurePasswordText1 = !obscurePasswordText1;
              });
            },
          ),
          hintText: '',
          hintStyle: CommonStyle.whiteText,
          labelText: 'Confirm Password*',
          labelStyle: CommonStyle.whiteText,
        ),
      ),
    );
  }

  Widget confirmButton(BuildContext context) {
    return new Container(
      width: MediaQuery.of(context).size.width,
      height: 44.0,
      child: new FlatButton(
          color: ColorCode.BUTTON_BG_COLOR,
          onPressed: initConnectivity,
          child: new Text(
            StringConstants.SUBMIT,
            style: CommonStyle.whiteText,
          )),
      margin: const EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0,
      ),
    );
  }

}
