/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
import 'package:ioskitouchnew/common/Style.dart';
import 'package:ioskitouchnew/common/StyleColor.dart';
import 'package:ioskitouchnew/screens/account/forgotPassword.dart';
import 'package:ioskitouchnew/screens/account/login/login.dart';

///User Interface provider in this class


class LoginView extends LoginState {
  @override
  Widget build(BuildContext context) {
    /// orientation landscape
    var hasDetailPage =
        MediaQuery.of(context).orientation == Orientation.landscape;
    print("hasDetailPage::$hasDetailPage");
    // TODO: implement build
    return new Scaffold(
      body: SingleChildScrollView(   //by arti
        child: new Container(
          color: Colors.black,
          child: new Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height ,  //* 0.82
                child: Center(
                  child: new Form(
                    key: formKey,
                    child: _getFormUI(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget child;

  Widget usernameEditFiled() {
    return new Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.only(left: 10.0),
      child: new TextFormField(
        key: Key('username'),
        style: CommonStyle.whiteText,
        keyboardType: TextInputType.emailAddress,
        obscureText: false,
        controller: nameController,
        validator: (val) => val.isEmpty ? 'Email ID can\'t be empty.' : null,
        decoration: new InputDecoration(
          border: new UnderlineInputBorder(),
          hintStyle: CommonStyle.whiteText,
          hintText: '',
          labelText: 'Email ID',
          labelStyle: CommonStyle.whiteText,
        ),
        onSaved: (val) => username = val,
      ),
    );
  }

  Widget passwordEditFiledNew() {
    return new Container(
      padding: const EdgeInsets.only(left: 10.0),
      margin: const EdgeInsets.all(8.0),
      child: new TextFormField(
        key: Key('password'),
        style: CommonStyle.whiteText,
        keyboardType: TextInputType.text,
        obscureText: obscurePasswordText,
        controller: passController,
        validator: (val) => val.isEmpty ? 'Password can\'t be empty.' : null,
        onSaved: (val) => password = val,
        decoration: new InputDecoration(
          border: new UnderlineInputBorder(),
          suffixIcon: new IconButton(
            icon: Icon(
              obscurePasswordText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              setState(() {
                obscurePasswordText = !obscurePasswordText;
              });
            },
          ),
          hintText: '',
          hintStyle: CommonStyle.whiteText,
          labelText: 'Password',
          labelStyle: CommonStyle.whiteText,
        ),
      ),
    );
  }

  Widget newUserText() {
    return new Padding(
        padding: new EdgeInsets.all(2.0),
        child: new Padding(
            padding: new EdgeInsets.all(0.0),
            child: new Container(
              height: 48.0,
              // width: MediaQuery.of(context).size.width,
              //   decoration: CommonStyle().decoration,
              child: new FlatButton(
                  onPressed: navigateToSignUp,
                  child: new Text(
                    'New user?',
                    style: new TextStyle(
                        fontSize: 18.0,
                        color: ColorCode.SECONDARY_COLOR,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  )),
            )));
  }

  Widget confirmButton() {
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

  Widget forgotButton() {
    return  Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        alignment: Alignment.centerRight,
        child: InkWell(
          child: Text('Forgot Password' ,
            style: TextStyle(
                fontSize: 20
            ),),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ForgetPassword()));
          },
        ),
      ),
    );
  }


  Widget usernameEditFiledLand() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Expanded(
          child: new TextFormField(
            key: Key('username'),
            style: CommonStyle.whiteText,
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            controller: nameController,
            validator: (val) =>
                val.isEmpty ? 'Email ID can\'t be empty.' : null,
            decoration: new InputDecoration(
              border: new UnderlineInputBorder(),
              hintStyle: CommonStyle.whiteText,
              hintText: '',
              labelText: 'Email ID',
              labelStyle: CommonStyle.whiteText,
            ),
            onSaved: (val) => username = val,
          ),
        )
      ],
    );
  }

  Widget passwordEditFiledNewLand() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Expanded(
          child: new TextFormField(
            key: Key('password'),
            style: CommonStyle.whiteText,
            keyboardType: TextInputType.text,
            obscureText: obscurePasswordText,
            controller: passController,
            validator: (val) =>
                val.isEmpty ? 'Password can\'t be empty.' : null,
            onSaved: (val) => password = val,
            decoration: new InputDecoration(
              border: new UnderlineInputBorder(),
              suffixIcon: new IconButton(
                icon: Icon(
                  obscurePasswordText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  setState(() {
                    obscurePasswordText = !obscurePasswordText;
                  });
                },
              ),
              hintText: '',
              hintStyle: CommonStyle.whiteText,
              labelText: 'Password',
              labelStyle: CommonStyle.whiteText,
            ),
          ),
        )
      ],
    );
  }

  Widget newUserTextLand() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Expanded(
            child: new Padding(
                padding: new EdgeInsets.all(2.0),
                child: new Padding(
                    padding: new EdgeInsets.all(0.0),
                    child: new Container(
                      height: 48.0,
                      // width: MediaQuery.of(context).size.width,
                      //   decoration: CommonStyle().decoration,
                      child: new FlatButton(
                          onPressed: navigateToSignUp,
                          child: new Text(
                            'New user?',
                            style: new TextStyle(
                                fontSize: 18.0,
                                color: ColorCode.SECONDARY_COLOR,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          )),
                    ))))
      ],
    );
  }

  Widget confirmButtonLand() {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
            child: new FlatButton(
                color: ColorCode.BUTTON_BG_COLOR,
                onPressed: initConnectivity,
                child: new Text(
                  StringConstants.SUBMIT,
                  style: CommonStyle.whiteText,
                )),
          )
        ]);
  }

  Widget _getFormUI() {
    return SingleChildScrollView(
        child: new Column(
      children: [
        new Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        new Container(
          child: Image.asset(
            "images/logo_skroman.png",
            height: 190,
            fit: BoxFit.cover,
          ),
        ),
            new SizedBox(
              height: 23,
            ),
            usernameEditFiled(),
            new SizedBox(height: 10.0),
            passwordEditFiledNew(),
            new SizedBox(height: 5.0),
            newUserText(),
            new SizedBox(height: 5.0),
            confirmButton(),

            new SizedBox(height: 20.0),
            forgotButton(),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: new SizedBox(height: 5.0),
            ),
      ],
    ));
  }
}
