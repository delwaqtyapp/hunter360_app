class ApiConstants {
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String logout = '/api/v1/auth/logout';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String controllers = '/api/v1/controllers';
  static String controllerById(String id) => '/api/v1/controllers/$id';
  static String controllerCommand(String id) => '/api/v1/controllers/$id/command';
  static String controllerStatus(String id) => '/api/v1/controllers/$id/status';
  static const String schedules = '/api/v1/schedules';
  static String scheduleById(String id) => '/api/v1/schedules/$id';
  static const String weatherStations = '/api/v1/weather/stations';
  static String weatherData(String stationId) => '/api/v1/weather/$stationId';
  static const String flowMeters = '/api/v1/flow/meters';
  static String flowData(String meterId) => '/api/v1/flow/$meterId';
  static const String alarms = '/api/v1/alarms';
  static String alarmAcknowledge(String id) => '/api/v1/alarms/$id/acknowledge';
  static const String reports = '/api/v1/reports';
  static String reportGenerate(String type) => '/api/v1/reports/$type';
  static const String userProfile = '/api/v1/user/profile';
  static const String userSettings = '/api/v1/user/settings';
  static const String notifications = '/api/v1/notifications';
  static String dashboardData(String id) => '/api/v1/dashboard/$id';
}
