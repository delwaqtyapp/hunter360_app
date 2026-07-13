import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hunter360_app/app/app.dart';
import 'package:hunter360_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _serverController = TextEditingController();
  final _settingsService = SettingsService();
  bool _isEditingServer = false;
  bool _testingConnection = false;

  @override
  void initState() {
    super.initState();
    _serverController.text = ref.read(serverUrlProvider);
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final serverUrl = ref.watch(serverUrlProvider);
    final currentLocale = ref.watch(localeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final autoLogoutMinutes = ref.watch(autoLogoutMinutesProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(l10n, user),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.serverConfig),
          const SizedBox(height: 8),
          _buildServerConfigCard(l10n, serverUrl),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.generalSettings),
          const SizedBox(height: 8),
          _buildDarkModeTile(l10n, isDarkMode),
          _buildLanguageTile(l10n, currentLocale),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.notificationSettingsSection),
          const SizedBox(height: 8),
          _buildNotificationsCard(l10n, notificationsEnabled),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.autoLogoutSetting),
          const SizedBox(height: 8),
          _buildAutoLogoutCard(l10n, autoLogoutMinutes),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.about),
          const SizedBox(height: 8),
          _buildAboutTile(l10n, serverUrl),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.settingsSection),
          const SizedBox(height: 8),
          _buildExportDataCard(l10n),
          _buildClearCacheCard(l10n),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.dangerZone),
          const SizedBox(height: 8),
          _buildResetDefaultsCard(l10n),
          _buildLogoutButton(l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AppLocalizations l10n, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B4F), Color(0xFF156082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF156082).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              (user?.name ?? 'A')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Admin',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.badge, size: 14, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.roleLabel}: ${user?.role ?? 'admin'}',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.shield, size: 14, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.accessLevelLabel}: ${user?.accessLevel ?? 0}',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF156082),
      ),
    );
  }

  Widget _buildServerConfigCard(AppLocalizations l10n, String serverUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF156082).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.dns, color: Color(0xFF156082), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.streamServerLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                if (_isEditingServer)
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    onPressed: _saveServerUrl,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Color(0xFF156082)),
                    onPressed: () => setState(() => _isEditingServer = true),
                  ),
              ],
            ),
            if (_isEditingServer) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _serverController,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'http://192.168.1.100:49110',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.link, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _testingConnection ? null : _testConnection,
                      icon: _testingConnection
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_find, size: 18),
                      label: Text(l10n.testConnection),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditingServer = false;
                        _serverController.text = serverUrl;
                      });
                    },
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  serverUrl,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveServerUrl() async {
    final url = _serverController.text.trim();
    if (url.isEmpty) return;
    ref.read(serverUrlProvider.notifier).state = url;
    await _settingsService.setServerUrl(url);
    setState(() => _isEditingServer = false);
  }

  Future<void> _testConnection() async {
    setState(() => _testingConnection = true);
    try {
      final url = _serverController.text.trim();
      final testDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final response = await testDio.get(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).connectionSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Connection refused')) {
        msg = 'Connection refused - is the server running on this IP?';
      } else if (msg.contains('Connection timed out') || msg.contains('timeout')) {
        msg = 'Connection timed out - check VPN and server IP';
      } else if (msg.contains('SocketException')) {
        msg = 'Cannot reach server - check VPN connection';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).connectionFailed}: $msg'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _testingConnection = false);
    }
  }

  Widget _buildDarkModeTile(AppLocalizations l10n, bool isDarkMode) {
    return Card(
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF156082).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: const Color(0xFF156082),
            size: 20,
          ),
        ),
        title: Text(l10n.darkMode),
        subtitle: Text(isDarkMode ? 'ON' : 'OFF'),
        value: isDarkMode,
        onChanged: (v) async {
          ref.read(themeModeProvider.notifier).state = v;
          await _settingsService.setDarkMode(v);
        },
      ),
    );
  }

  Widget _buildLanguageTile(AppLocalizations l10n, Locale currentLocale) {
    final isArabic = currentLocale.languageCode == 'ar';
    return Card(
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF156082).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.language, color: Color(0xFF156082), size: 20),
        ),
        title: Text(l10n.language),
        subtitle: Text(isArabic ? l10n.arabic : l10n.english),
        value: isArabic,
        onChanged: (v) async {
          final newLocale = v ? const Locale('ar') : const Locale('en');
          ref.read(localeProvider.notifier).state = newLocale;
          await _settingsService.setLanguage(v ? 'ar' : 'en');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.requiresRestart),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildNotificationsCard(AppLocalizations l10n, bool enabled) {
    return Card(
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF156082).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            enabled ? Icons.notifications_active : Icons.notifications_off,
            color: const Color(0xFF156082),
            size: 20,
          ),
        ),
        title: Text(l10n.notifications),
        subtitle: Text(enabled ? l10n.notificationsEnabledLabel : l10n.notificationsDisabledLabel),
        value: enabled,
        onChanged: (v) async {
          ref.read(notificationsEnabledProvider.notifier).state = v;
          await _settingsService.setNotificationsEnabled(v);
        },
      ),
    );
  }

  Widget _buildAutoLogoutCard(AppLocalizations l10n, int minutes) {
    final String subtitle;
    if (minutes == 0) {
      subtitle = l10n.disabled;
    } else {
      subtitle = '$minutes ${l10n.minutesUnit}';
    }

    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF156082).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.timer_outlined, color: Color(0xFF156082), size: 20),
        ),
        title: Text(l10n.autoLogoutSetting),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showAutoLogoutDialog(l10n, minutes),
      ),
    );
  }

  void _showAutoLogoutDialog(AppLocalizations l10n, int currentMinutes) {
    int selectedMinutes = currentMinutes;
    final options = [0, 5, 10, 15, 30, 60];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.autoLogoutDialog),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.selectMinutes, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((m) {
                  final isSelected = selectedMinutes == m;
                  final label = m == 0 ? l10n.disabled : '$m ${l10n.minutesUnit}';
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: const Color(0xFF156082),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (_) => setDialogState(() => selectedMinutes = m),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF156082)),
              onPressed: () async {
                ref.read(autoLogoutMinutesProvider.notifier).state = selectedMinutes;
                await _settingsService.setAutoLogoutMinutes(selectedMinutes);
                if (mounted) Navigator.of(ctx).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile(AppLocalizations l10n, String serverUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _aboutRow(Icons.info_outline, l10n.appVersion, '4.99.12'),
            const Divider(height: 24),
            _aboutRow(Icons.business_outlined, l10n.licensedToLabel, l10n.companyName),
            const Divider(height: 24),
            _aboutRow(Icons.dns, l10n.serverUrlLabel, serverUrl),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF156082), size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExportDataCard(AppLocalizations l10n) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.file_download_outlined, color: Colors.blue, size: 20),
        ),
        title: Text(l10n.exportData),
        trailing: const Icon(Icons.chevron_right),
        onTap: _exportData,
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final data = await _settingsService.exportAll();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      await Clipboard.setData(ClipboardData(text: jsonStr));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings copied to clipboard'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Widget _buildClearCacheCard(AppLocalizations l10n) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.cleaning_services_outlined, color: Colors.orange, size: 20),
        ),
        title: Text(l10n.clearCache),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final keys = prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
          for (final key in keys) {
            await prefs.remove(key);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.cacheCleared),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildResetDefaultsCard(AppLocalizations l10n) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restore, color: Colors.red, size: 20),
        ),
        title: Text(l10n.resetToDefaults, style: const TextStyle(color: Colors.red)),
        trailing: const Icon(Icons.chevron_right, color: Colors.red),
        onTap: () => _confirmReset(l10n),
      ),
    );
  }

  void _confirmReset(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetToDefaults),
        content: Text(l10n.resetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _settingsService.resetToDefaults();
              ref.read(themeModeProvider.notifier).state = false;
              ref.read(localeProvider.notifier).state = const Locale('en');
              ref.read(serverUrlProvider.notifier).state = 'http://10.10.8.60:49110';
              ref.read(notificationsEnabledProvider.notifier).state = true;
              ref.read(autoLogoutMinutesProvider.notifier).state = 0;
              _serverController.text = 'http://10.10.8.60:49110';
              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.settingsReset),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: Text(
            l10n.logout,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
