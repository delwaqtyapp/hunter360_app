import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hunter360_app/app/app.dart';
import 'package:hunter360_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _serverController = TextEditingController();
  bool _isEditingServer = false;

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
          _buildNotificationsCard(l10n),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.autoLogoutSetting),
          const SizedBox(height: 8),
          _buildAutoLogoutCard(l10n, user),
          const SizedBox(height: 24),
          _buildSectionTitle(l10n.about),
          const SizedBox(height: 8),
          _buildAboutTile(l10n),
          const SizedBox(height: 24),
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
                const Icon(Icons.dns, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(
                  l10n.streamServerLabel,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                if (_isEditingServer)
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    onPressed: () {
                      ref.read(serverUrlProvider.notifier).state = _serverController.text.trim();
                      setState(() => _isEditingServer = false);
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Color(0xFF156082)),
                    onPressed: () => setState(() => _isEditingServer = true),
                  ),
              ],
            ),
            if (_isEditingServer) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _serverController,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'http://192.168.1.100:49110',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.link, size: 18),
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                serverUrl,
                style: TextStyle(color: Colors.grey.shade600, fontFamily: 'monospace', fontSize: 13),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.connectedToServer,
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeTile(AppLocalizations l10n, bool isDarkMode) {
    return Card(
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        secondary: const Icon(Icons.dark_mode, color: Color(0xFF156082)),
        title: Text(l10n.darkMode),
        subtitle: Text(isDarkMode ? 'ON' : 'OFF'),
        value: isDarkMode,
        onChanged: (v) => ref.read(themeModeProvider.notifier).state = v,
      ),
    );
  }

  Widget _buildLanguageTile(AppLocalizations l10n, Locale currentLocale) {
    final isArabic = currentLocale.languageCode == 'ar';
    return Card(
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        secondary: const Icon(Icons.language, color: Color(0xFF156082)),
        title: Text(l10n.language),
        subtitle: Text(isArabic ? l10n.arabic : l10n.english),
        value: isArabic,
        onChanged: (v) {
          ref.read(localeProvider.notifier).state = v ? const Locale('ar') : const Locale('en');
        },
      ),
    );
  }

  Widget _buildNotificationsCard(AppLocalizations l10n) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.notifications_outlined, color: Color(0xFF156082)),
        title: Text(l10n.notifications),
        subtitle: Text(l10n.notificationsComingSoon),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _buildAutoLogoutCard(AppLocalizations l10n, dynamic user) {
    final minutes = user?.autoLogoutMinutes ?? 0;
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.timer_outlined, color: Color(0xFF156082)),
        title: Text(l10n.autoLogoutSetting),
        subtitle: Text('$minutes ${l10n.minutesUnit}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _buildAboutTile(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _aboutRow(Icons.info_outline, l10n.appVersion, '4.99.12'),
            const Divider(height: 24),
            _aboutRow(Icons.business_outlined, l10n.licensedToLabel, l10n.companyName),
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
        Text(value, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return SizedBox(
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
    );
  }
}
