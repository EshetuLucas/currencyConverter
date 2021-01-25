import 'package:connectivity/connectivity.dart';

class CheckInternet {
  Future<bool> getInternet() async {
    bool isInternetOn = false;

    await Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.mobile ||
          value == ConnectivityResult.wifi) {
        isInternetOn = true;
      } else
        isInternetOn = false;
    });
    return isInternetOn;
  }
}
