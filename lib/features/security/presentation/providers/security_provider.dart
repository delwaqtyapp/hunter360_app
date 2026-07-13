import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityUser {
  final String id;
  final String username;
  final String pin;
  final String role;
  final int accessLevel;
  final bool isActive;

  const SecurityUser({
    required this.id,
    required this.username,
    required this.pin,
    this.role = 'Crew',
    this.accessLevel = 50,
    this.isActive = true,
  });

  SecurityUser copyWith({
    String? username,
    String? pin,
    String? role,
    int? accessLevel,
    bool? isActive,
  }) {
    return SecurityUser(
      id: id,
      username: username ?? this.username,
      pin: pin ?? this.pin,
      role: role ?? this.role,
      accessLevel: accessLevel ?? this.accessLevel,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'pin': pin,
        'role': role,
        'accessLevel': accessLevel,
        'isActive': isActive,
      };

  factory SecurityUser.fromJson(Map<String, dynamic> json) {
    return SecurityUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      pin: json['pin']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Crew',
      accessLevel: json['accessLevel'] is int
          ? json['accessLevel']
          : int.tryParse(json['accessLevel']?.toString() ?? '50') ?? 50,
      isActive: json['isActive'] ?? true,
    );
  }
}

class UserEvent {
  final String username;
  final String action;
  final DateTime timestamp;

  const UserEvent({
    required this.username,
    required this.action,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'action': action,
        'timestamp': timestamp.toIso8601String(),
      };

  factory UserEvent.fromJson(Map<String, dynamic> json) {
    return UserEvent(
      username: json['username']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class SecurityState {
  final List<SecurityUser> users;
  final bool managementBypass;
  final bool factoryResetEnabled;
  final Map<String, bool> dialPositions;
  final List<UserEvent> events;
  final bool isLoading;

  const SecurityState({
    this.users = const [],
    this.managementBypass = false,
    this.factoryResetEnabled = false,
    this.dialPositions = const {},
    this.events = const [],
    this.isLoading = false,
  });

  SecurityState copyWith({
    List<SecurityUser>? users,
    bool? managementBypass,
    bool? factoryResetEnabled,
    Map<String, bool>? dialPositions,
    List<UserEvent>? events,
    bool? isLoading,
  }) {
    return SecurityState(
      users: users ?? this.users,
      managementBypass: managementBypass ?? this.managementBypass,
      factoryResetEnabled: factoryResetEnabled ?? this.factoryResetEnabled,
      dialPositions: dialPositions ?? this.dialPositions,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  static const _usersKey = 'security_users';
  static const _settingsKey = 'security_settings';
  static const _eventsKey = 'security_events';

  SecurityNotifier() : super(const SecurityState()) {
    _loadAll();
  }

  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();

    // Load users
    final usersJson = prefs.getString(_usersKey);
    List<SecurityUser> users = [];
    if (usersJson != null) {
      try {
        final List<dynamic> list = jsonDecode(usersJson);
        users = list.map((e) => SecurityUser.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    if (users.isEmpty) {
      users = [
        const SecurityUser(id: '1', username: 'Admin', pin: '0000', role: 'Admin', accessLevel: 100, isActive: true),
        const SecurityUser(id: '2', username: 'Crew1', pin: '1234', role: 'Crew', accessLevel: 50, isActive: true),
      ];
      await _saveUsers(users);
    }

    // Load settings
    final settingsJson = prefs.getString(_settingsKey);
    bool managementBypass = false;
    bool factoryResetEnabled = false;
    Map<String, bool> dialPositions = {};
    if (settingsJson != null) {
      try {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        managementBypass = settings['managementBypass'] ?? false;
        factoryResetEnabled = settings['factoryResetEnabled'] ?? false;
        dialPositions = Map<String, bool>.from(settings['dialPositions'] ?? {});
      } catch (_) {}
    }

    // Load events
    final eventsJson = prefs.getString(_eventsKey);
    List<UserEvent> events = [];
    if (eventsJson != null) {
      try {
        final List<dynamic> list = jsonDecode(eventsJson);
        events = list.map((e) => UserEvent.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    state = SecurityState(
      users: users,
      managementBypass: managementBypass,
      factoryResetEnabled: factoryResetEnabled,
      dialPositions: dialPositions,
      events: events,
    );
  }

  Future<void> _saveUsers(List<SecurityUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode({
      'managementBypass': state.managementBypass,
      'factoryResetEnabled': state.factoryResetEnabled,
      'dialPositions': state.dialPositions,
    }));
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final toSave = state.events.length > 100 ? state.events.sublist(0, 100) : state.events;
    await prefs.setString(_eventsKey, jsonEncode(toSave.map((e) => e.toJson()).toList()));
  }

  void _addEvent(String username, String action) {
    final event = UserEvent(username: username, action: action, timestamp: DateTime.now());
    final updated = [event, ...state.events];
    state = state.copyWith(events: updated);
    _saveEvents();
  }

  Future<void> addUser(SecurityUser user) async {
    final updated = [...state.users, user];
    state = state.copyWith(users: updated);
    await _saveUsers(updated);
    _addEvent(user.username, 'created');
  }

  Future<void> updateUser(SecurityUser updated) async {
    final updatedList = state.users.map((u) => u.id == updated.id ? updated : u).toList();
    state = state.copyWith(users: updatedList);
    await _saveUsers(updatedList);
    _addEvent(updated.username, 'updated');
  }

  Future<void> deleteUser(String userId) async {
    final user = state.users.firstWhere((u) => u.id == userId, orElse: () => const SecurityUser(id: '', username: '', pin: ''));
    final updated = state.users.where((u) => u.id != userId).toList();
    state = state.copyWith(users: updated);
    await _saveUsers(updated);
    _addEvent(user.username, 'deleted');
  }

  Future<void> toggleManagementBypass() async {
    state = state.copyWith(managementBypass: !state.managementBypass);
    await _saveSettings();
  }

  Future<void> toggleFactoryReset() async {
    state = state.copyWith(factoryResetEnabled: !state.factoryResetEnabled);
    await _saveSettings();
  }

  Future<void> toggleDialPosition(String key) async {
    final updated = Map<String, bool>.from(state.dialPositions);
    updated[key] = !(updated[key] ?? false);
    state = state.copyWith(dialPositions: updated);
    await _saveSettings();
  }
}

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier();
});
