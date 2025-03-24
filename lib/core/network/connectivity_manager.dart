import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityManager {
  Future<bool> get hasConnection;
  Stream<ConnectionResult> get onConnectionChanged;
}

class ConnectivityManagerImpl implements ConnectivityManager {
  ConnectivityManagerImpl() {
    _startListeningConnectivityChanges();
  }

  late StreamController<ConnectionResult> _onConnectionChangedController;

  @override
  Future<bool> get hasConnection async {
    return _hasInternetConnection();
  }

  @override
  Stream<ConnectionResult> get onConnectionChanged =>
      _onConnectionChangedController.stream;

  void _startListeningConnectivityChanges() {
    _onConnectionChangedController = StreamController.broadcast();

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      if (!result.contains(ConnectivityResult.none)) {
        if (await _hasInternetConnection()) {
          _onConnectionChangedController.add(ConnectionResult.connected);
        }
      } else {
        _onConnectionChangedController.add(ConnectionResult.disconnected);
      }
    });
  }

  Future<bool> _hasInternetConnection() async {
    try {
      // Try to resolve any of the ip addresses of the domains below.
      final result = await Future.wait([
        InternetAddress.lookup('example.com'),
        InternetAddress.lookup('google.com'),
        InternetAddress.lookup('opendns.com'),
      ]).timeout(const Duration(seconds: 3));
      // If lookup is successful, then it means we have internet connection.
      if (result.any((e) => e.isNotEmpty && e[0].rawAddress.isNotEmpty)) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}

enum ConnectionResult {
  connected,
  disconnected,
}
