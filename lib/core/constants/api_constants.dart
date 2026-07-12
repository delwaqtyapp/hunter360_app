class ApiConstants {
  static const String authenticate = '/Dashboard/Authenticate';
  static const String viewsList = '/Dashboard/ViewsList';
  static const String viewsTree = '/Dashboard/ViewsTree';
  static const String subDashboards = '/Dashboard/SubDashboards';
  static String viewByName(String name) => '/Dashboard/Views/$name';
  static const String layout = '/Dashboard/Layout';
  static const String saveLayout = '/Dashboard/Layout/';
  static const String magicBoxTemplates = '/Dashboard/Views/__MagicBoxTemplates';

  static const String tagsValuesList = '/api/Tags/ValuesList';
  static String tagValue(String tagName) => '/api/Tags/Values?TagName=$tagName';
  static const String tagsWrite = '/api/Tags/Values';
  static const String tagsList = '/api/tags/list?TagName=*';

  static const String alarmsCurrent = '/api/Alarms/Current';
  static String alarmAck(String alarmId) => '/api/Alarms/Ack?AlarmId=$alarmId';
  static String alarmsById(String id) => '/api/$id/alarms.json';
  static String chartById(String id) => '/api/$id/chart.json';

  static const String historicalTagValues = '/api/Historical/TagValues';
  static const String historicalAlarms = '/api/Historical/Alarms';

  static const String dataSetsList = '/api/DataSets/List';

  static String staticResource(String filename) =>
      '/Dashboard/StaticResources/$filename';
}
