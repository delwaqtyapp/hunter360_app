import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Hunter 360';
  static const String appNameAr = 'هنتر 360';
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

  static String get defaultServerUrl {
    if (kIsWeb) return '';
    return 'http://10.10.8.60:49110';
  }

  static const String mqttBroker = 'localhost';
  static const int mqttPort = 1883;

  static int get realtimePollingIntervalMs => 1000;
  static int get historicalPollingIntervalMs => 5000;
}
