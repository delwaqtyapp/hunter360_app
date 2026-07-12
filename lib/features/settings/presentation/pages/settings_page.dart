import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: Color(0xFF1B5E20), child: Icon(Icons.person, color: Colors.white, size: 30)),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('admin@hunter360.com', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // General
          const Text('General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _settingsTile(Icons.language, 'Language', 'English', () {}),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: Text(isDarkMode ? 'On' : 'Off'),
            value: isDarkMode,
            onChanged: (v) => ref.read(themeModeProvider.notifier).state = v,
          ),
          _settingsTile(Icons.notifications, 'Notifications', '', () {}),
          _settingsTile(Icons.lock, 'Change Password', '', () {}),

          const SizedBox(height: 24),
          const Text('Connection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _settingsTile(Icons.wifi, 'Network Settings', '', () {}),
          _settingsTile(Icons.cloud, 'Cloud Sync', 'Connected', () {}),
          _settingsTile(Icons.bluetooth, 'Bluetooth', '', () {}),

          const SizedBox(height: 24),
          const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _settingsTile(Icons.info, 'App Version', '1.0.0', () {}),
          _settingsTile(Icons.description, 'Terms of Service', '', () {}),
          _settingsTile(Icons.privacy_tip, 'Privacy Policy', '', () {}),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String trailing, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty) Text(trailing, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
