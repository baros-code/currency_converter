import '../core/network/api_manager_helpers.dart';
import 'package:flutter/material.dart';

class AppConfig {
  static ApiSetupParams apiSetupParams = ApiSetupParams(
    baseUrl: _apiBaseUrl,
    retryCount: 1,
  );
  static const String baseCurrency = 'EUR';

  static const String _apiBaseUrl = 'https://api.frankfurter.dev/v1';

  static const Color primaryColor = Colors.blueAccent;

  static const Color backgroundPrimary = Color(0xFF212121);

  static const Color backgroundSecondary = Color(0xFF303030);
}
