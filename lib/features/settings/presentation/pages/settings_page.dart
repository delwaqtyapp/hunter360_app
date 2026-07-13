import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hunter360_app/app/app.dart';
import 'package:hunter360_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hunter360_app/core/network/api_client.dart';

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
    final isDarkMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final serverUrl = ref.watch(serverUrlProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D3B4F), Color(0xFF156082)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              CircleAvatar(radius: 30, backgroundColor: Colors.white.withOpacity(0.2), child: Text((user?.name ?? 'A')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.name ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                Text('Role: ${user?.role ?? 'admin'}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                Text('Access Level: ${user?.accessLevel ?? 0}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Server Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF156082))),
          const SizedBox(height: 8),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.dns, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                const Text('Stream Server URL', style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                if (_isEditingServer)
                  IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () {
                    ref.read(serverUrlProvider.notifier).state = _serverController.text.trim();
                    setState(() => _isEditingServer = false);
                  })
                else
                  IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => setState(() => _isEditingServer = true)),
              ]),
              if (_isEditingServer) ...[
                const SizedBox(height: 8),
                TextField(controller: _serverController, decoration: InputDecoration(hintText: 'http://192.168.1.100:49110', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              ] else ...[
                const SizedBox(height: 4),
                Text(serverUrl, style: TextStyle(color: Colors.grey.shade600, fontFamily: 'monospace')),
                const SizedBox(height: 4),
                Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Connected', style: TextStyle(fontSize: 12, color: Colors.green)),
                ]),
              ],
            ]),
          )),
          const SizedBox(height: 16),
          const Text('General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF156082))),
          const SizedBox(height: 8),
          SwitchListTile(tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), secondary: const Icon(Icons.dark_mode), title: const Text('Dark Mode'), subtitle: Text(isDarkMode ? 'On' : 'Off'), value: isDarkMode, onChanged: (v) => ref.read(themeModeProvider.notifier).state = v),
          SwitchListTile(tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), secondary: const Icon(Icons.language), title: const Text('Arabic Language'), subtitle: Text(currentLocale.languageCode == 'ar' ? 'Arabic' : 'English'), value: currentLocale.languageCode == 'ar', onChanged: (v) => ref.read(localeProvider.notifier).state = v ? const Locale('ar') : const Locale('en')),
          const SizedBox(height: 16),
          const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF156082))),
          const SizedBox(height: 8),
          _settingsTile(Icons.info, 'App Version', '4.99.12', () {}),
          _settingsTile(Icons.business, 'Licensed to', 'Abqarino Technology', () {}),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String trailing, VoidCallback onTap) {
    return Card(child: ListTile(
      leading: Icon(icon, color: const Color(0xFF156082)),
      title: Text(title),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (trailing.isNotEmpty) Text(trailing, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right),
      ]),
      onTap: onTap,
    ));
  }
}
