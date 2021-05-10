/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:vtrochargingstation/Settings/ChangeUrl.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'mqtt/MQTTAppState.dart';

/// entry point function
void main() async {
 // WidgetsFlutterBinding.ensureInitialized();
//  await Firebase.initializeApp();
//  setCrashAnalytics();
  runApp(MyApp());
}

/// firebase crash report method
void setCrashAnalytics() async {
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  Function originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    // Forward to original handler.
    originalOnError(errorDetails);
  };

  // FirebaseCrashlytics.instance.crash();   //forcefully crash app trial only
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// This is the root of your application.

  @override
  Widget build(BuildContext context) {

    /// for state management [provider] is used
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MQTTAppState>(
          create: (context) => MQTTAppState(),
        ),
      ],

      /// theme data for charging station app [Neumorphic]
      child: NeumorphicApp(
        debugShowCheckedModeBanner: false,
        title: 'Charging Station',
        theme: NeumorphicThemeData(
        baseColor: AppTheme.background,
        intensity: 0.99,  // 0.7 shadow cha effect
        lightSource: LightSource.topLeft,
        depth: 5,
       ),

       /// first view from [main] Navigation
       home: ChangeUrl(),

    ),
    );
  }
}