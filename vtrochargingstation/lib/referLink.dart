/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

/*
what codes are referred?? those links are provided
---------------------------------------: Links to refer code : ----------------------------------------

Google Maps Integration:::

1. Autocomplete places
https://medium.com/comerge/location-search-autocomplete-in-flutter-84f155d44721

2. show map, calculate route, show path between to route, cal distance
https://blog.codemagic.io/creating-a-route-calculator-using-google-maps/

3. custom map creation - by akshay guide link
https://developers.google.com/maps/documentation/android-sdk/styling

flutter android map style json file
map style android

reference link:

https://medium.com/@shubham.narkhede8/flutter-google-map-with-direction-6a26ad875083

4. google map custom draw link:
https://medium.com/@matthiasschuyten/google-maps-styling-in-flutter-5c4101806e83


5.
Direction API - to draw route

//map finished

reference:
https://www.alfianlosari.com/posts/building-places-location-search-mapview-flutter/
.........................................................................

Login:::

1. Social - google login
https://blog.codemagic.io/firebase-authentication-google-sign-in-using-flutter/

Info - firebase credential used for this:
login used from this account - VTROMOTORS@GMAIL.COM
enable for gmail, mobile, facebook

2. social - facebook login

https://codesundar.com/flutter-facebook-login/
https://www.youtube.com/watch?v=r0JtCUkSdWQ   refer this tutorial for facebook settings and code also

3. normal login -

API Integrate for this login, u will get otp for this and then user is authenticate


//login finished
.........................................................................

** firebase crashlytics **
https://pub.dev/packages/firebase_crashlytics/example

follow:
https://github.com/nhandrew?before=Y3Vyc29yOnYyOpK5MjAxOS0xMS0yMlQyMjowNTowOSswNTozMM4NUXyy&tab=repositories



//crashlytics finished
.........................................................................

// switch button

https://github.com/cgustav/lite_rolling_switch


// radio button
https://www.nicesnippets.com/blog/flutter-radio-button-example-tutorial



listview scroll animation
https://pub.dev/packages/scroll_snap_list




//aes encrytion library
https://pub.dev/packages/encrypt




beautiful design
https://github.com/NearHuscarl/flutter_login

https://www.iconfinder.com/
https://github.com/GeekyAnts/flutter-login-home-animation/blob/master/README.md

https://github.com/leoelstin/Flutter-UI-Kits

https://github.com/tiamo/flutter-concentric-transition


Animations:
https://morioh.com/p/486792c65398


provider keywords identification:

scan qr - [ack] text used
request charging - [start] keyword is used
if no any ack recived then [fail] keyword is used


stop charging - [bill] keyword is used


button:
height: h/11,
margin: EdgeInsets.symmetric(vertical: w/15, horizontal: h/15), // horizontal = width, vertical = height(kiti varun khali)


https://fluttergems.dev/bottom-navigation-bar/

font:
https://flutter.dev/docs/cookbook/design/fonts#from-packages

tabbar:
https://medium.com/flutter-community/flutter-widgets-tabbar-tabbarview-the-whole-picture-dad81c952544


dropdown option:
https://github.com/khaliqdadmohmand/flutter_dynamic_dropdownLists/blob/master/lib/main.dart


radio button
https://www.coderzheaven.com/2019/01/27/radio-radiolisttile-in-flutter-android-ios/

contact list:
https://theflutterblog.com/2020/06/17/get-phone-contacts/

https://stackoverflow.com/questions/60796674/flutter-contact-services-not-giving-phone-number-of-contact



-----------------------------------------------------------

style: NeumorphicStyle(

                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                      color: AppTheme.background,
                      depth: 5,
                      intensity: 0.99, //drop shadow
                      shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                      shadowLightColor: Colors.white,  // upper top shadow
                      //    surfaceIntensity: 0.20, // no use

                    ),



text style reference:



14 px   h/45
12 px   h/48


  style:utils.textStyleRegular(context,45, AppTheme.text1,FontWeight.w400, 0.0,'')

  style:utils.textStyleRegular2(context,FontWeight.w400)),

  ShowCustomSnack.getCustomSnack(context, _scaffoldKey, '');

 Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));

onPressed: connectionInfo == 'Connected' ? null : connection,

button height:
 height: h/13,


cashfree:

https://dev.cashfree.com/payment-gateway/integrations/mobile-integration/flutter-sdk

https://www.xspdf.com/resolution/54851268.html
*/