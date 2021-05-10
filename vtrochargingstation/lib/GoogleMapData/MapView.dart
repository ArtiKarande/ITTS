/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:typed_data';
import 'dart:ui';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vtrochargingstation/GoldCard/Trial.dart';
import 'package:vtrochargingstation/GoogleMapData/scanQR.dart';
import 'package:vtrochargingstation/InternetConnectivity/network_info.dart';
import 'package:vtrochargingstation/Profile/MyProfileView.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:location/location.dart' as loc;
import 'package:maps_launcher/maps_launcher.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrochargingstation/Booking/BookSlot.dart';
import 'package:vtrochargingstation/Reservation/ResevationDetails.dart';
import 'package:vtrochargingstation/charging/StartCharging.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/common/urlConstant.dart';
import 'package:vtrochargingstation/dialog/FunkeyOverlay.dart';
import 'package:vtrochargingstation/models/NearByLocation.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:dio/dio.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedKeys.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedPreferneces.dart';
import 'package:vtrochargingstation/secrets.dart'; // Stores the Google Maps API Key
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show asin, cos, pi, sqrt;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../CommunicationManager.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import '../mqttConnectionManager.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// google maps parameters
  GoogleMapController mapController;
  bool isExpanded = false;
  final Geolocator _geolocator = Geolocator();
  Position _currentPosition;
  String _currentAddress, token = '', strImg = '';
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;
  Set<Marker> markers = {};
  double totalTimeCalculate = 0.0;

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  /// marker parameters
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor currentLocationIcon;
  BitmapDescriptor pinLocationIconHide;
  String _mapStyle;

  SharedPreference pref = new SharedPreference();

  bool stationCardVisibility = false;

  bool _loading = false;
  Marker destinationMarker;
  double currentLat, currentLong;

  ///new QR params
  APICall apiCall = APICall();

  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  /// notification params
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  ///mqtt
  MQTTAppState currentAppState;
  MqttConnectionManager mqttConnection;
  bool searchLocation = true;

  AppTheme utils = new AppTheme();
  loc.Location location = new loc.Location();

  SharedPreferences _preferences;

  _getCurrentLocation() async {
    /// enable user location
    bool isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    print(isLocationEnabled);
    if (isLocationEnabled) {
    } else {
      await location.requestService();
    }

    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        currentLat = position.latitude;
        currentLong = position.longitude;

        FlutterApp.currentLatitude = currentLat;
        FlutterApp.currentLongitude = currentLong;

        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15.0, //18
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print('current loc--exception---');
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    ProgressBar.show(context);
    try {
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        /* _currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;*/

        _currentAddress =
            "${place.name}, ${place.subLocality}, ${place.locality}, ${place.country}, ${place.postalCode}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;

        print(startAddressController.text);
        //    print("${place.position}, ${place.administrativeArea}, ${place.subAdministrativeArea}, ${place.thoroughfare}, ${place.subThoroughfare}");

        print('my current address');
        print(_currentAddress);

        searchNearby(_currentPosition.latitude,
            _currentPosition.longitude); // auto search API calling
      });
    } catch (e) {
      print(e);
      ProgressBar.dismiss(context);

      ///new
    }
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  /// Create the polylines for showing the route between two places
  _createPolylines(Position start, double lat, double longi) async {
    print('inside polyline');
    print(start);
    print(lat);
    print(longi);

    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(lat, longi),
      travelMode: TravelMode.transit,
    );

    print('aaaa');
    print(result.points);

    if (result.points.isNotEmpty) {
      print('inside polyline1');

      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    destinationAddressController.text = 'To Station';
    startAddressController.text = 'Searching...';

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
          devicePixelRatio: 2.0, textDirection: TextDirection.ltr),
      'images/current_location_marker.png',
    ).then((onValue) {
      currentLocationIcon = onValue;
    });

    _getCurrentLocation();

    /// custom map style designed, which is located in - [images/map_style.txt]
    rootBundle.loadString('images/map_style.txt').then((string) {
      _mapStyle = string;
    });

    nearbyLocationIconSet(); //current
    getPreferencesValues();
    firebasePushNotification();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    final MQTTAppState appState =
        Provider.of<MQTTAppState>(context, listen: true);
    currentAppState = appState;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false, //new
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              /// Map View

              // visible: currentAppState.mapVisibility,
              GoogleMap(
                markers: markers != null ? Set<Marker>.from(markers) : null,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      FlutterApp.currentLatitude, FlutterApp.currentLongitude),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                //true
                myLocationButtonEnabled: true,
                mapToolbarEnabled: false,
                // to hide default map 2 buttons
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  if (!mounted) return;
                  setState(() {
                    mapController = controller;
                    mapController.setMapStyle(_mapStyle);
                  });
                },
              ),

              /// card view - location search tap
              /* InkWell(
                onTap: () async {

           final sessionToken = Uuid().v4();
                  final Suggestion result = await showSearch(
                    context: context,
                    delegate: AddressSearch(sessionToken),
                  );
                  // This will change the text displayed in the TextField
                  if (result != null) {
                    final placeDetails = await PlaceApiProvider(sessionToken)
                        .getPlaceDetailFromId(result.placeId);
                    setState(() {
                      startAddressController.text = result.description;
                      _destinationAddress = result.description;
                    });
                  }*/

              Container(
                height: h / 9,
                width: w,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.only(
                        bottomRight: Radius.circular(40),
                        bottomLeft: Radius.circular(40))),
                    color: AppTheme.background,
                    depth: 5,
                    intensity: 0.99,
                    //drop shadow
                    shadowDarkColor: AppTheme.bottomShadow,
                    // upper bottom shadow
                    shadowLightColor: Colors.white, // upper top shadow
                    //    surfaceIntensity: 0.20, // no use
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    //  crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: w / 30, right: w / 40),
                        child: Image.asset(
                          'images/location_icon.png',
                          height: h / 25,
                        ),
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(startAddressController.text,
                                overflow: TextOverflow.ellipsis,
                                style: utils.textStyleRegular1(
                                    context, FontWeight.w400)),
                            Text(
                                'There’re ' +
                                    markers.length.toString() +
                                    ' Charging Point available near you',
                                style: utils.textStyleRegular4(
                                    context, FontWeight.w400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Show current location button
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  //       padding: EdgeInsets.only(right: h / 45, bottom: h / 5.5),
                  padding: EdgeInsets.only(
                      right: h / 45,
                      bottom: FlutterApp.rStationName.isNotEmpty ||
                              currentAppState.getReceivedText.contains('stop')
                          ? h / 3.2
                          : h / 5.5),
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent, // button color
                      child: InkWell(
                        splashColor: Colors.transparent, // inkwell color
                        child: SizedBox(
                          width: h / 16,
                          height: h / 16,
                          //    child: Icon(Icons.my_location, color: Colors.white,),
                          child: Image.asset(
                            'images/currentLocation.png',
                            height: h / 20,
                          ),
                        ),
                        onTap: () {
                          if (currentLat != null) {
                            mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    _currentPosition.latitude,
                                    _currentPosition.longitude,
                                  ),
                                  zoom: 15.0, //18
                                ),
                              ),
                            );
                          } else {
                            FToast.show(
                                'Dear user, kindly enable location permission');
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              /// upcoming reservation black window
              Visibility(
                //    visible: FlutterApp.rStationName.isNotEmpty ? true : false,
                visible: currentAppState.getUpcomingReservationVisibility,
                child: Padding(
                  padding: EdgeInsets.only(bottom: h / 5.4),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReservationDetails(
                                    FlutterApp.splashScreenReservationId,
                                    FlutterApp.rStationName,
                                    "",
                                    FlutterApp.rTimeSlot,
                                    "",
                                    "",
                                    FlutterApp.reservationStationImage,
                                    'map',
                                    FlutterApp.reservationStartTime)));
                      },
                      child: Container(
                          height: h / 8.5,
                          width: w,
                          color: Color(0xFF3C3C3C),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: w,
                                  color: Color(0xFF343434),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: w / 13,
                                        top: h / 170,
                                        bottom: h / 170),
                                    child: Text(
                                        'Upcoming reservation: ' +
                                            FlutterApp.reservationStationID,
                                        style: utils.textStyleRegular(
                                            context,
                                            55,
                                            AppTheme.white,
                                            FontWeight.w500,
                                            0.0,
                                            '')),
                                  )),
                              Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: w / 13, top: h / 70),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(FlutterApp.rStationName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: utils.textStyleRegular(
                                                  context,
                                                  60,
                                                  AppTheme.white,
                                                  FontWeight.w500,
                                                  0.0,
                                                  '')),
                                          Row(
                                            children: [
                                              Image.asset('images/normal.png',
                                                  height: h / 40),
                                              Text(
                                                  FlutterApp.rTimeSlot +
                                                      ' [ Rid: ' +
                                                      FlutterApp
                                                          .splashScreenReservationId +
                                                      ' ]',
                                                  style: utils.textStyleRegular(
                                                      context,
                                                      60,
                                                      AppTheme.white,
                                                      FontWeight.w700,
                                                      0.0,
                                                      '')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 0,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: w / 13),
                                      child: Row(
                                        children: [
                                          Image.asset('images/navigateMap.png',
                                              height: h / 30),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ),

              /// charging is started state
              Visibility(
                visible: currentAppState.getReceivedText.contains('stop')
                    ? true
                    : false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: h / 5.4),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StartCharging(
                                    currentAppState.getRequestedPercentage,
                                    '')));
                      },
                      child: Container(
                          height: h / 8.5,
                          width: w,
                          color: Color(0xFF3C3C3C),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: w,
                                  color: Color(0xFF343434),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: w / 13,
                                        top: h / 170,
                                        bottom: h / 170),
                                    child: Text('Vehicle Charging Status',
                                        style: utils.textStyleRegular(
                                            context,
                                            55,
                                            AppTheme.white,
                                            FontWeight.w500,
                                            0.0,
                                            '')),
                                  )),
                              Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: w / 13, top: h / 70),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Estimated time left ' +
                                                  currentAppState
                                                      .getEstimatedTime
                                                      .toStringAsFixed(0) +
                                                  ' [hrs]',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: utils.textStyleRegular(
                                                  context,
                                                  60,
                                                  AppTheme.white,
                                                  FontWeight.w500,
                                                  0.0,
                                                  '')),
                                          Row(
                                            children: [
                                              Image.asset('images/normal.png',
                                                  height: h / 40),
                                              Text(
                                                  currentAppState
                                                      .getRequestedPercentage
                                                      .toString(),
                                                  style: utils.textStyleRegular(
                                                      context,
                                                      60,
                                                      AppTheme.white,
                                                      FontWeight.w700,
                                                      0.0,
                                                      '')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 0,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: w / 13),
                                      child: Row(
                                        children: [
                                          Image.asset('images/navigateMap.png',
                                              height: h / 30),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ),

              /// scanner / battery / profile options
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: h / 25), //30
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: h / 8,
                        width: w,
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        // horizontal = width, vertical = kiti varun khali
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                offset: const Offset(4, 4),
                                blurRadius: 8.0),
                          ],
                        ),

                        child: Row(
                          //      mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: AppTheme.buttonRippleShade,
                                  onTap: () async {
                                    scan();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'images/scanner.png',
                                      fit: BoxFit.contain,
                                      height: h / 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: w / 30),
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: AppTheme.buttonRippleShade,
                                  onTap: () {
                                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => Percentage()));

                                    ShowCustomSnack.getCustomSnack(context,
                                        _scaffoldKey, Messages.upcoming);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'images/battery.png',
                                      fit: BoxFit.contain,
                                      height: h / 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: w / 30),
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: AppTheme.buttonRippleShade,
                                  onTap: () {
                                    //       profilePressed();
                                    //       currentAppState.setReceivedText('proceed');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyProfileView()));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'images/profileIcon.png',
                                      fit: BoxFit.contain,
                                      height: h / 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: w / 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: h / 26, left: 10),
                      child: Container(
                        height: h / 7.5, //7.5
                        width: w / 4,

                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                offset: const Offset(6, 6),
                                blurRadius: 8.0),
                          ],
                        ),

                        child: NeumorphicButton(
                          onPressed: () {},
                          style: NeumorphicStyle(
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(15)),
                            //  shape: NeumorphicShape.concave,

                            color: AppTheme.background,
                            depth: 1,
                            surfaceIntensity: 0.20,
                            intensity: 15,
                            //drop shadow
                            shadowDarkColor:
                                Color(0xFFe2e2e2), // upper bottom shadow
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              'images/vtrologo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Api calling here and custom marker
  void _handleResponse(data) async {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    for (var subscription in data['station']) {
      /*  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      Size canvasSize = Size(w/5, h/5);  //5, 6
      Size markerSize = Size(w/3.5, h/9.0);  //3.5, 9

      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: subscription['total_plugpoint'].toString(),
        style: TextStyle(fontSize: h/35, fontWeight: FontWeight.w700, color:subscription['total_plugpoint'] == '0' ? Colors.transparent : Colors.white),
      );
      textPainter.layout();

      final Paint infoPaint = Paint()..color = subscription['total_plugpoint'] == '0' ? Colors.transparent : Colors.black;
      //    final Paint infoStrokePaint = Paint()..color = Colors.red.shade300;
      final double infoHeight = h/14; //15
      final double strokeWidth =  w/60;//12

      final Paint markerPaint = Paint()..color = Colors.transparent;//
      final double shadowWidth = 0.0;//30  // black marker kiti vr

      final Paint borderPaint = Paint()..color = Colors.transparent..strokeWidth=0.0..style = PaintingStyle.stroke;//

   //   final double imageOffset = shadowWidth*.5;

      canvas.translate(canvasSize.width/2, canvasSize.height/2+infoHeight/2);
      canvas.drawOval(Rect.fromLTWH(-markerSize.width/2, -markerSize.height/2, markerSize.width, markerSize.height), markerPaint);
      canvas.drawOval(Rect.fromLTWH(-markerSize.width/2+shadowWidth, -markerSize.height/2+shadowWidth, markerSize.width-2*shadowWidth, markerSize.height-2*shadowWidth), borderPaint);
      Rect oval = Rect.fromLTWH(-markerSize.width/2+.5* shadowWidth, -markerSize.height/2+.5*shadowWidth, markerSize.width-shadowWidth, markerSize.height-shadowWidth);

      //save canvas before rotate
      canvas.save();
      double rotateRadian = (pi/180.0)*0.0;//180

      //Rotate Image
      canvas.rotate(rotateRadian);

      // Add path for oval image
      canvas.clipPath(Path()
        ..addOval(oval));

      // Add image
      ui.Image image = await getImageFromPath(subscription['total_plugpoint'] == '0' ? 'images/nearbyUnavailable.png' : 'images/applogo.png');
      paintImage(canvas: canvas,image: image, rect: oval, fit: BoxFit.fitHeight);

      canvas.restore();
      //info info box
      canvas.drawPath(Path()..addRRect(RRect.fromLTRBR(-textPainter.width/2-infoHeight/2+strokeWidth, -canvasSize.height/2-infoHeight/2+1+strokeWidth, textPainter.width/2+infoHeight/2-strokeWidth, -canvasSize.height/2+infoHeight/2+1-strokeWidth,Radius.circular(32.0)))
        ..moveTo(-15+strokeWidth/2, -canvasSize.height/2+infoHeight/2+1-strokeWidth)
        ..lineTo(0, -canvasSize.height/2+infoHeight/2+25-strokeWidth*2)
        ..lineTo(15-strokeWidth/2, -canvasSize.height/2+infoHeight/2+1-strokeWidth)
          , infoPaint);
      textPainter.paint(
          canvas,
          Offset(
              - textPainter.width / 2,//text on left side
              -canvasSize.height/2-infoHeight/2+infoHeight / 2 - textPainter.height / 2
          )
      );

      canvas.restore();

      // Convert canvas to image
      final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
          canvasSize.width.toInt(),
          canvasSize.height.toInt()
      );

      // Convert image to bytes
      final ByteData byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List uint8List = byteData.buffer.asUint8List();


      setState(() {
        pinLocationIcon = BitmapDescriptor.fromBytes(uint8List);
        pinLocationIconHide = BitmapDescriptor.fromBytes(uint8List);
      });*/

      /// current lat long marker
      setState(() {
        markers.add(Marker(
            markerId: MarkerId('marker1'),
            position:
                LatLng(FlutterApp.currentLatitude, FlutterApp.currentLongitude),
            icon: currentLocationIcon));
      });

      markers.add(
        Marker(
            markerId: MarkerId(subscription['id']),
            //     icon: pinLocationIcon,
            icon: subscription['total_plugpoint'] == '0'
                ? pinLocationIconHide
                : pinLocationIcon,
            position: LatLng(double.parse(subscription['latitude']),
                double.parse(subscription['longitude'])),
            infoWindow: InfoWindow(
                title: subscription['id'],
                onTap: () {
                  String normalCount = '0', fastCount = '0';
                  print('on tap of info window');

                  if (subscription['total_plugpoint'] != '0') {
                    print(subscription['available_point'][0]['charger_type']);
                    print(
                        subscription['available_point'][0]['plugpoint_count']);
                    print(subscription['available_point'][1]['charger_type']);
                    print(
                        subscription['available_point'][1]['plugpoint_count']);

                    normalCount =
                        subscription['available_point'][0]['plugpoint_count'];
                    fastCount =
                        subscription['available_point'][1]['plugpoint_count'];
                  }

                  showModalBottomSheet<void>(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.6),
                                  offset: const Offset(4, 4),
                                  blurRadius: 8.0),
                            ],
                          ),

                          child: getBottomSheet(
                            _startAddress,
                            subscription['landmark'],
                            _destinationAddress,
                            double.parse(subscription['latitude']),
                            double.parse(subscription['longitude']),
                            subscription['name'],
                            subscription['distance'],
                            normalCount,
                            fastCount,
                            subscription['id'],
                            subscription['total_plugpoint'],
                            subscription['station_image'],
                          ),
                          height: h / 4.0,
                          //    color: Colors.red,
                        ),
                      );
                    },
                  );
                }),
            onTap: () {
              String normalCount = '0', fastCount = '0';
              print('on tap of marker');
              print(subscription['reservation_normal_type_cost']);

              if (subscription['total_plugpoint'] != '0') {
                print(subscription['available_point'][0]['charger_type']);
                print(subscription['available_point'][0]['plugpoint_count']);
                print(subscription['available_point'][1]['charger_type']);
                print(subscription['available_point'][1]['plugpoint_count']);

                normalCount =
                    subscription['available_point'][0]['plugpoint_count'];
                fastCount =
                    subscription['available_point'][1]['plugpoint_count'];
              }

              showModalBottomSheet<void>(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              offset: const Offset(4, 4),
                              blurRadius: 8.0),
                        ],
                      ),
                      child: getBottomSheet(
                        _startAddress,
                        subscription['landmark'],
                        _destinationAddress,
                        double.parse(subscription['latitude']),
                        double.parse(subscription['longitude']),
                        subscription['name'],
                        subscription['distance'],
                        normalCount,
                        fastCount,
                        subscription['id'],
                        subscription['total_plugpoint'],
                        subscription['station_image'],
                      ),
                      height: h / 4.0, //4.5
                      //    color: Colors.red,
                    ),
                  );
                },
              );
            }),
      );
    }
  }

  /// when user click on marker, open bottom sheet UI
  Widget getBottomSheet(
      String startAddress,
      landmark,
      destinationAddress,
      lat,
      longitude,
      stationName,
      totalDistance,
      normalFreePlugCount,
      fastFreePlugCount,
      stationId,
      totalPlug,
      stationImage) {
    totalTimeCalculate = 0.0;
    //  calculateDistance(lat, longitude);

    totalTimeCalculate += _coordinateDistance(FlutterApp.currentLatitude,
        FlutterApp.currentLongitude, lat, longitude);

    print('total time::');
    print(totalTimeCalculate);

    print(stationId);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: Padding(
                    padding: EdgeInsets.only(top: h / 30),
                    child: Padding(
                      padding: EdgeInsets.only(left: h / 70),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          stationImage,
                          height: h / 16,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                backgroundColor: Colors.green,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(left: w / 30, top: h / 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stationName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: utils.textStyleRegular1(
                                context, FontWeight.w500)),
                        Text(landmark,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: utils.textStyleRegular4(
                                context, FontWeight.w400)),
                        Row(
                          children: [
                            Text(
                                totalTimeCalculate.toStringAsFixed(2) + ' min.',
                                style: utils.textStyleRegular(context, 60,
                                    AppTheme.text2, FontWeight.w400, 0.0, '')),
                            SizedBox(
                              width: w / 50,
                            ),
                            Text(
                                totalPlug == '0'
                                    ? 'No current slot available'
                                    : totalPlug + ' Slots Available',
                                style: utils.textStyleRegular(
                                    context,
                                    60,
                                    AppTheme.greenShade1,
                                    FontWeight.w400,
                                    0.0,
                                    '')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: GestureDetector(
                    onTap: (_startAddress != '')
                        ? () async {
                            /// shows google map route between 2 points[working code]
                            /* ProgressBar.show(context);

                                setState(() {
                                  if (polylines.isNotEmpty) polylines.clear();
                                  if (polylineCoordinates.isNotEmpty)
                                    polylineCoordinates.clear();
                                  _placeDistance = null;
                                });
                                _calculateDistance(lat, longitude).then((isCalculated) {});*/

                            /// navigate to map app
                            //    MapsLauncher.launchCoordinates(lat, longitude, 'Google Headquarters are here');
                            MapsLauncher.launchQuery(stationName);
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'images/navigateMap.png',
                        height: h / 20,
                      ),
                    ),
                  ),
                ),

                /*  Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: Padding(
                    padding: EdgeInsets.only(right: w / 25),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        width: h / 25,
                        height: h / 25,
                        child: FloatingActionButton(
                          backgroundColor: AppTheme.greenShade2,
                          child: //Icon(Icons.location_on, color: Colors.white,size: 45,),
                              Image.asset(
                            'images/navigateMap.png', height: h/30,
                          ),
                          onPressed: (_startAddress != '')
                              ? () async {
                                  /// shows google map route between 2 points[working code]
                                  */
                /* ProgressBar.show(context);

                                  setState(() {
                                    if (polylines.isNotEmpty) polylines.clear();
                                    if (polylineCoordinates.isNotEmpty)
                                      polylineCoordinates.clear();
                                    _placeDistance = null;
                                  });
                                  _calculateDistance(lat, longitude).then((isCalculated) {});*/
                /*

                                  /// navigate to map app
                                  MapsLauncher.launchCoordinates(lat, longitude,
                                      'Google Headquarters are here');
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
            Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: Image.asset(
                    'images/normal.png',
                    height: h / 25,
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹' + FlutterApp.normalBikeCost.toString() + '/Unit',
                          style: utils.textStyleRegular(context, 60,
                              AppTheme.text2, FontWeight.w400, 0.0, '')),
                      Text(
                          normalFreePlugCount == '0'
                              ? 'occupied'
                              : normalFreePlugCount + ' Available',
                          style: utils.textStyleRegular(context, 60,
                              AppTheme.text1, FontWeight.w400, 0.0, '')),
                    ],
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: Image.asset(
                    'images/turbo.png',
                    height: h / 25,
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹' + FlutterApp.fastBikeCost.toString() + '/Unit',
                          style: utils.textStyleRegular(context, 60,
                              AppTheme.text2, FontWeight.w400, 0.0, '')),
                      Text(
                          fastFreePlugCount == '0'
                              ? 'occupied'
                              : fastFreePlugCount + ' Available',
                          style: utils.textStyleRegular(context, 60,
                              AppTheme.text1, FontWeight.w400, 0.0, '')),
                    ],
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                  child:

                      /// book slot - button
                      Padding(
                    padding: EdgeInsets.only(right: w / 20.0),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: h / 35,
                      ),
                      height: h / 17,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(35)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              offset: const Offset(4, 4),
                              blurRadius: 8.0),
                        ],
                      ),
                      child: NeumorphicButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BookSlot(stationId)));

                          if (FlutterApp.userEmailStatus == '0') {
                            FToast.show('Complete your profile first');
                            Navigator.pop(context);
                            ShowCustomSnack.getCustomSnack(context,
                                _scaffoldKey, 'Complete your profile first');
                          } else if (FlutterApp.userMobileStatus == '0') {
                            Navigator.pop(context);
                            ShowCustomSnack.getCustomSnack(context,
                                _scaffoldKey, 'Complete your profile first');
                          } else {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookSlot(stationId)));
                          }
                        },
                        style: NeumorphicStyle(
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(30)),
                            color: AppTheme.background,
                            depth: 10,
                            surfaceIntensity: 0.20,
                            intensity: 15,
                            shadowDarkColor: Color(0xFFe2e2e2),
                            //outer bottom shadow
                            shadowLightColor: Colors.white // outer top shadow
                            ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('BOOK',
                                style: utils.textStyleRegular(context, 60,
                                    AppTheme.text2, FontWeight.w700, 0.0, '')),
                            Padding(
                              padding: EdgeInsets.only(left: w / 80),
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
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// on press of android back button action
  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text('No'),
              ),
              new FlatButton(
                //    onPressed: () => exit(0),
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// get user taken with the help of [SharedPreferences]
  void getPreferencesValues() async {
    _preferences = await SharedPreferences.getInstance();

    pref.getString(SharedKey().token).then((value) {
      setState(() {
        token = value;
        FlutterApp.token = token;
      });
    });
  }

  /// notification received callback method
  void firebasePushNotification() {
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) async {
        //when app is fully closed
        print("msg::: onLaunch called ${(msg)}");
        print("onLaunch called");

        if (msg != null) {
          final notification = msg['data'];
          setState(() {
            showDialog(
              context: context,
              builder: (_) => FunkyOverlay(
                title: notification['title'],
                msg: notification['body'],
              ),
            );
          });
        }
      },
      onResume: (Map<String, dynamic> msg) async {
        print(
            "msg222::: onResume called ${(msg)}"); //when we click on notification

        final notification = msg['data'];
        setState(() {
          showDialog(
            context: context,
            builder: (_) => FunkyOverlay(
              title: notification['title'],
              msg: notification['body'],
            ),
          );
        });
      },
      onMessage: (Map<String, dynamic> msg) async {
        print('notification -- on msg --');
        print("msg222::: onMessage called ${(msg)}");
        final notification = msg['notification'];

        showDialog(
            context: context,
            builder: (context) {
              /*  Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pop(true);
              });*/
              return TrialDialog(
                title: notification['title'],
                msg: '',
                color: AppTheme.greenShade1,
              );
            });
      },
    );
  }

  /// API Integration - search nearby location
  void searchNearby(double latitude, double longitude) async {
    setState(() {
      markers.clear();
    });

    try {
      Dio dio = new Dio();

      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers = {
        "Authorization":
            'Bearer be1faebe9d710e9f0ad968eff2312ca2b053a61309539224b3ec3795ac19898'
      };

      var response = await dio.post(UrlConstants.getStation, data: {
        "tag": "get_chargingstation",
        "km": "5",
        "latitude": "$currentLat",
        "longitude": "$currentLong",
      });

      if (response.statusCode == 200 && response.data['status'] == true) {
        FlutterApp.reservationNormalCoast = double.parse(
            response.data['station'][0]['reservation_normal_type_cost']);
        FlutterApp.reservationFastCoast = double.parse(
            response.data['station'][0]['reservation_fast_type_cost']);

        ProgressBar.dismiss(context);
        _handleResponse(response.data);

        /// when no marker found, add only current location marker on [mapview]
        /// current lat long marker
        setState(() {
          markers.add(Marker(
              markerId: MarkerId('marker1'),
              position: LatLng(
                  FlutterApp.currentLatitude, FlutterApp.currentLongitude),
              icon: currentLocationIcon));
        });
      } else {
        ProgressBar.dismiss(context);
        print('places not found');

        ShowCustomSnack.getCustomSnack(
            context, _scaffoldKey, 'No nearby places found!');
        //throw Exception('An error occurred getting places nearby');
      }
    } on DioError catch (e) {
      print(e);
      ProgressBar.dismiss(context);
    }
  }

  calculateDistance(destinationLatitude, destinationLongitude) async {
    double distanceInMeters = await Geolocator().distanceBetween(
      FlutterApp.currentLatitude,
      FlutterApp.currentLongitude,
      destinationLatitude,
      destinationLongitude,
    );

    print('total distance::');
    print(distanceInMeters);
  }

  @override
  void dispose() {
    // mapController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('in resume state::');
      _initMapStyle();
    }
  }

  /// custom map style designed, located in - [images/map_style.txt]
  Future<void> _initMapStyle() async {
    _getCurrentLocation();

    rootBundle.loadString('images/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  /// set custom marker icons
  nearbyLocationIconSet() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
          devicePixelRatio: 2.0, textDirection: TextDirection.ltr),
      'images/applogo.png',
      //    'images/gif/mapgif.gif',
    ).then((onValue) {
      pinLocationIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
          devicePixelRatio: 2.0, textDirection: TextDirection.ltr),
      'images/nearbyUnavailable.png',
    ).then((onValue) {
      pinLocationIconHide = onValue;
    });

    rootBundle.loadString('images/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  /// common internet dialog - box
  noInternetDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return NetworkInfo(
            title: Messages.NO_INTERNET,
          );
        });
  }

  /// on tap of scan button
  ///    - check for charging state [start/stop]
  ///    - check for profile complete or not using email/mobile
  void scan() async {
    if (currentAppState.getReceivedText == 'stop') {
      ShowCustomSnack.getCustomSnack(context, _scaffoldKey,
          'Already in charging state, You can not scan now!');
    } else if (FlutterApp.userEmailStatus == '0') {
      ShowCustomSnack.getCustomSnack(
          context, _scaffoldKey, 'Complete your profile first');
    } else if (FlutterApp.userMobileStatus == '0') {
      ShowCustomSnack.getCustomSnack(
          context, _scaffoldKey, 'Complete your profile first');
    } else {
      clearData();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ScanQR('', 'map', '', '')));
    }
  }

  /// on tap of profile button
  void profilePressed() async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true) {
      /* if (_preferences.getString('fullName') != null) {
        FlutterApp.fullName = _preferences.getString("fullName");
      } else if (_preferences.getString('profilePic') != null) {
        FlutterApp.profilePic = _preferences.getString("profilePic");
      }*/
      currentAppState.setReceivedText('proceed');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyProfileView()));
    } else {
      noInternetDialog();
    }
  }

  /// Method for calculating the distance between two places
  Future<bool> _calculateDistance(double lat, double longi) async {
    try {
      List<Placemark> p5 =
          await _geolocator.placemarkFromCoordinates(lat, longi);

      List<Placemark> startPlacemark =
          await _geolocator.placemarkFromAddress(_startAddress);

      if (startPlacemark != null) {
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
                latitude: _currentPosition.latitude,
                longitude: _currentPosition.longitude)
            : startPlacemark[0].position;
        Position destinationCoordinates = p5[0].position;

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker

        print('destination::::');
        print(destinationCoordinates);

        markers.remove(destinationMarker); // remove previous marker
        destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(lat, longi),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that
        // southwest coordinate <= northeast coordinate
        if (startCoordinates.latitude <= destinationCoordinates.latitude) {
          _southwestCoordinates = startCoordinates;
          _northeastCoordinates = destinationCoordinates;
        } else {
          _southwestCoordinates = destinationCoordinates;
          _northeastCoordinates = startCoordinates;
        }
        await _createPolylines(startCoordinates, lat, longi);

        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          Navigator.pop(context);
        });
        return true;
      } else {
        print('else statement:');

        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
                latitude: _currentPosition.latitude,
                longitude: _currentPosition.longitude)
            : startPlacemark[0].position;
        Position destinationCoordinates = p5[0].position;

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker

        print('destination::::');
        print(destinationCoordinates);

        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(lat, longi),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        markers.add(startMarker);
        markers.add(destinationMarker);

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        await _createPolylines(startCoordinates, lat, longi);
        return true;
      }
    } catch (e) {
      print(e);
      print('exce1');
    }
    return false;
  }

  /// clear data when user try to scan QR
  void clearData() {
    FlutterApp.groupId = '';
    //  FlutterApp.splashScreenReservationId = '';
    currentAppState.setReceivedText('proceed');
    currentAppState.setRequestPercentage(0.0);
    currentAppState.setSliderMoveControl(false);
    currentAppState.setEstimatedCost(0.0);
    currentAppState.setEstimatedTime(0);
    currentAppState.setPlugAnim(false);
    FlutterApp.plugPoint = '0';
    FlutterApp.activeStatus = '';
  }
}
