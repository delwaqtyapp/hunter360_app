import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

class TagValue {
  final String tagName;
  final String rawValue;
  final String scaledValue;
  final String status;
  final String? timeStamp;

  TagValue({
    required this.tagName,
    required this.rawValue,
    required this.scaledValue,
    required this.status,
    this.timeStamp,
  });

  factory TagValue.fromJson(Map<String, dynamic> json) {
    return TagValue(
      tagName: json['TagName']?.toString() ?? '',
      rawValue: json['RawValue']?.toString() ?? '',
      scaledValue: json['ScaledValue']?.toString() ?? '',
      status: json['Status']?.toString() ?? '',
      timeStamp: json['TimeStamp']?.toString(),
    );
  }
}

class RealtimeService {
  final ApiClient _apiClient;
  Timer? _timer;
  final Map<String, TagValue> _tagValues = {};
  final Set<String> _subscribedTags = {};
  final StreamController<Map<String, TagValue>> _streamController = StreamController.broadcast();
  int _intervalMs = 1000;
  int _consecutiveErrors = 0;

  RealtimeService(this._apiClient);

  Stream<Map<String, TagValue>> get tagValuesStream => _streamController.stream;
  Map<String, TagValue> get currentValues => Map.unmodifiable(_tagValues);
  String getValue(String tagName) => _tagValues[tagName]?.scaledValue ?? '';
  String getStatus(String tagName) => _tagValues[tagName]?.status ?? '-';
  String getRawValue(String tagName) => _tagValues[tagName]?.rawValue ?? '';
  bool get isConnected => _consecutiveErrors == 0 && _subscribedTags.isNotEmpty;

  void updateInterval(int ms) {
    _intervalMs = ms;
    if (_timer?.isActive == true) {
      stop();
      start();
    }
  }

  void subscribe(List<String> tags) {
    for (final tag in tags) {
      if (tag.isNotEmpty && !tag.startsWith('"')) {
        _subscribedTags.add(tag);
      }
    }
    _fetchValues();
  }

  void unsubscribeAll() {
    _subscribedTags.clear();
  }

  void start() {
    stop();
    _timer = Timer.periodic(Duration(milliseconds: _intervalMs), (_) => _fetchValues());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchValues() async {
    if (_subscribedTags.isEmpty) return;
    try {
      final tags = _subscribedTags.toList();
      final response = await _apiClient.post(
        ApiConstants.tagsValuesList,
        data: tags,
        contentType: 'application/json',
      );
      final data = response.data;
      final values = data is Map ? (data['Values'] ?? []) : (data is List ? data : []);
      for (final v in values) {
        if (v is Map) {
          final tagVal = TagValue.fromJson(Map<String, dynamic>.from(v));
          _tagValues[tagVal.tagName] = tagVal;
        }
      }
      _streamController.add(Map.unmodifiable(_tagValues));
      _consecutiveErrors = 0;
    } catch (_) {
      _consecutiveErrors++;
    }
  }

  Future<void> fetchOnce(List<String> tags) async {
    if (tags.isEmpty) return;
    try {
      final response = await _apiClient.post(
        ApiConstants.tagsValuesList,
        data: tags,
        contentType: 'application/json',
      );
      final data = response.data;
      final values = data is Map ? (data['Values'] ?? []) : (data is List ? data : []);
      for (final v in values) {
        if (v is Map) {
          final tagVal = TagValue.fromJson(Map<String, dynamic>.from(v));
          _tagValues[tagVal.tagName] = tagVal;
        }
      }
      _streamController.add(Map.unmodifiable(_tagValues));
      _consecutiveErrors = 0;
    } catch (_) {
      _consecutiveErrors++;
    }
  }

  void dispose() {
    stop();
    _streamController.close();
  }
}

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(ref.read(apiClientProvider));
  ref.onDispose(() => service.dispose());
  return service;
});
