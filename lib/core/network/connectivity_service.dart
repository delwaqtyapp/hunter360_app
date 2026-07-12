import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

enum ConnectivityStatus { wifi, mobile, ethernet, none }

class ConnectivityService {
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  final _connectivity = Connectivity();

  Stream<ConnectivityStatus> get stream => _controller.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((result) {
      _controller.add(_mapConnectivityResult(result));
    });
  }

  ConnectivityStatus _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectivityStatus.wifi;
      case ConnectivityResult.mobile:
        return ConnectivityStatus.mobile;
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.ethernet;
      default:
        return ConnectivityStatus.none;
    }
  }

  Future<ConnectivityStatus> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return _mapConnectivityResult(result);
  }

  void dispose() {
    _controller.close();
  }
}
