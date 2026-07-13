import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Abqarino SCADA';
  static const String appNameAr = 'عبقرينو سكادا';
  static const String version = '4.99.12';
  static const int splashDuration = 3000;
  static const int animationDuration = 300;
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const int maxRetryAttempts = 3;
  static const int cacheExpirationHours = 24;
  static const String dbName = 'hunter360_db';

  static const String storageKeyAuth = 'AuthRepsonseSuccess';
  static const String storageKeyServerUrl = 'ServerAddress';
  static const String storageKeyLicense = 'LicenseData';

  static String get defaultServerUrl {
    if (kIsWeb) return '';
    return 'http://10.10.8.60:49110';
  }

  static const String mqttBroker = 'localhost';
  static const int mqttPort = 1883;

  static int get realtimePollingIntervalMs => 1000;
  static int get historicalPollingIntervalMs => 5000;

  static const List<Map<String, String>> controllers = [
    {'id': 'C000', 'name': 'C000'},
    {'id': 'C001', 'name': 'Lanova'},
    {'id': 'C002', 'name': 'CBP'},
    {'id': 'C003', 'name': 'KAI'},
  ];
}
