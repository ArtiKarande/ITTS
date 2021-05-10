import 'dart:async';

import 'package:connectivity/connectivity.dart';

class InternetUtil {
  static void isInternetAvailable(Function completionHandler) {
    var connectionStatus = InternetUtil.checkNetworkStatus();
    connectionStatus.then((bool status) {
      completionHandler(status);
     // return status;
    });
  }

  static Future<bool> checkNetworkStatus() async {
    try {
      var connectionStatus = await (new Connectivity().checkConnectivity());
      if (connectionStatus == ConnectivityResult.none) {
        return false;
      } else {
        return true;
      }
    } on Exception catch (e) {
      return false;
    }
  }
}
