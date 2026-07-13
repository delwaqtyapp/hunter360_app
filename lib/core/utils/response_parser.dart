class ResponseParser {
  /// Parse tags list response from /api/tags/list?TagName=*
  /// Server returns EITHER:
  ///   - A Map/dictionary: {"C001.Station1": {tagObj}, "C001.Station2": {tagObj}, ...}
  ///   - An object with a list: {"Tags": [...]}, {"Data": [...]}, or {"tags": [...]}
  ///   - A plain List: [{tagObj}, ...]
  /// Always returns a List<Map<String, dynamic>> of tag objects.
  static List<Map<String, dynamic>> parseTagsList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      // Try common wrapper keys
      for (final key in ['Tags', 'tags', 'Data', 'data', 'Items', 'items', 'Result', 'result']) {
        final inner = map[key];
        if (inner is List) {
          return inner
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      // Dictionary format: keys are tag names, values are tag objects
      // Filter out non-object values (like "IsSuccess", metadata, etc.)
      final List<Map<String, dynamic>> tags = [];
      for (final entry in map.entries) {
        if (entry.value is Map) {
          final tagMap = Map<String, dynamic>.from(entry.value);
          // Ensure the tag has a TagName field; if not, set it from the key
          if (!tagMap.containsKey('TagName') || tagMap['TagName'] == null || tagMap['TagName'].toString().isEmpty) {
            tagMap['TagName'] = entry.key;
          }
          tags.add(tagMap);
        }
      }
      if (tags.isNotEmpty) return tags;

      // If no Map values found, the response might have tag data in an unexpected format
      // Try to extract any list-like structure
      return [];
    }
    return [];
  }

  /// Parse alarms list response from /api/Alarms/Current or /api/Historical/Alarms
  /// Server returns EITHER:
  ///   - A Map: {"Alarms": [...]}, {"Data": [...]}, {"Values": [...]}
  ///   - A plain List: [{alarmObj}, ...]
  ///   - A Map/dictionary of alarms
  /// Always returns a List<Map<String, dynamic>> of alarm objects.
  static List<Map<String, dynamic>> parseAlarmsList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      // Try common wrapper keys
      for (final key in ['Alarms', 'alarms', 'Data', 'data', 'Values', 'values', 'Items', 'items', 'Result', 'result']) {
        final inner = map[key];
        if (inner is List) {
          return inner
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      // Dictionary format
      final List<Map<String, dynamic>> alarms = [];
      for (final entry in map.entries) {
        if (entry.value is Map) {
          alarms.add(Map<String, dynamic>.from(entry.value));
        }
      }
      if (alarms.isNotEmpty) return alarms;

      return [];
    }
    return [];
  }

  /// Parse tag values response from /api/Tags/ValuesList
  /// Server returns: {"Values": [{TagName, ScaledValue, Status, ...}, ...]}
  /// OR a plain List
  static List<Map<String, dynamic>> parseTagValuesList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      for (final key in ['Values', 'values', 'Data', 'data', 'Items', 'items', 'Result', 'result']) {
        final inner = map[key];
        if (inner is List) {
          return inner
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      // Single tag value response
      if (map.containsKey('TagName') || map.containsKey('ScaledValue')) {
        return [map];
      }

      return [];
    }
    return [];
  }

  /// Extract controller group ID from a tag name
  /// e.g. "C001.Station1.Name" → "C001"
  static String extractGroupId(String tagName) {
    final parts = tagName.split('.');
    if (parts.length >= 2) {
      final first = parts[0];
      // Controller IDs are like C000, C001, etc.
      if (first.startsWith('C') && first.length >= 4) {
        return first;
      }
    }
    return '';
  }
}
