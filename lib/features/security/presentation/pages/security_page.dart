import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import '../providers/security_provider.dart';

class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(securityProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF156082)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 20),
                _buildSectionTitle(l10n.userManagement, Icons.people, const Color(0xFF156082)),
                const SizedBox(height: 8),
                _buildUserList(l10n, state),
                const SizedBox(height: 24),
                _buildSectionTitle(l10n.settings, Icons.security, Colors.orange.shade700),
                const SizedBox(height: 8),
                _buildSecuritySettings(l10n, state),
                const SizedBox(height: 24),
                _buildSectionTitle(l10n.dialPositionTitle, Icons.tune, Colors.teal),
                const SizedBox(height: 8),
                _buildDialPositions(l10n, state),
                const SizedBox(height: 24),
                _buildSectionTitle(l10n.userEventsLog, Icons.history, Colors.purple),
                const SizedBox(height: 8),
                _buildEventsLog(l10n, state),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D3B4F), Color(0xFF156082)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.securityTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(l10n.userManagement, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildUserList(AppLocalizations l10n, SecurityState state) {
    return Column(
      children: [
        ...state.users.map((user) => _buildUserCard(user, l10n)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showUserForm(context, l10n),
            icon: const Icon(Icons.person_add, size: 18),
            label: Text(l10n.addUser),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF156082),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(SecurityUser user, AppLocalizations l10n) {
    final isAdmin = user.role == 'Admin';
    final roleColor = isAdmin ? const Color(0xFF156082) : Colors.teal;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showUserForm(context, l10n, user: user),
        onLongPress: () => _confirmDeleteUser(user, l10n),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: roleColor.withOpacity(0.1),
                child: Icon(Icons.person, color: roleColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.username, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(user.role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: roleColor)),
                        ),
                        const SizedBox(width: 8),
                        Text('Lv.${user.accessLevel}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: user.isActive ? Colors.green : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  boxShadow: user.isActive ? [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 4)] : null,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteUser(SecurityUser user, AppLocalizations l10n) {
    final securityL10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(securityL10n.deleteUserLabel),
        content: Text(securityL10n.deleteUserConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(securityL10n.cancel)),
          TextButton(
            onPressed: () {
              ref.read(securityProvider.notifier).deleteUser(user.id);
              Navigator.pop(ctx);
            },
            child: Text(securityL10n.deleteUserLabel, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUserForm(BuildContext context, AppLocalizations l10n, {SecurityUser? user}) {
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final pinCtrl = TextEditingController(text: user?.pin ?? '');
    String role = user?.role ?? 'Crew';
    int accessLevel = user?.accessLevel ?? 50;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user != null ? l10n.editUserLabel : l10n.addUser, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.usernameLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pinCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.pinCode,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(
                      labelText: l10n.roleLabelD,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Admin', child: Text(l10n.adminRole)),
                      DropdownMenuItem(value: 'Crew', child: Text(l10n.crewRole)),
                    ],
                    onChanged: (v) {
                      if (v != null) setSheetState(() => role = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('${l10n.accessLevelD}: $accessLevel', style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Slider(
                    value: accessLevel.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '$accessLevel',
                    activeColor: const Color(0xFF156082),
                    onChanged: (v) => setSheetState(() => accessLevel = v.round()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (usernameCtrl.text.trim().isEmpty) return;
                            final newUser = SecurityUser(
                              id: user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              username: usernameCtrl.text.trim(),
                              pin: pinCtrl.text,
                              role: role,
                              accessLevel: accessLevel,
                              isActive: user?.isActive ?? true,
                            );
                            if (user != null) {
                              ref.read(securityProvider.notifier).updateUser(newUser);
                            } else {
                              ref.read(securityProvider.notifier).addUser(newUser);
                            }
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF156082),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSecuritySettings(AppLocalizations l10n, SecurityState state) {
    return Column(
      children: [
        _buildToggleCard(
          l10n.userManagementBypass,
          Icons.admin_panel_settings,
          state.managementBypass,
          () => ref.read(securityProvider.notifier).toggleManagementBypass(),
        ),
        const SizedBox(height: 8),
        _buildToggleCard(
          l10n.factoryResetLabel,
          Icons.restore_from_trash,
          state.factoryResetEnabled,
          () => ref.read(securityProvider.notifier).toggleFactoryReset(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildToggleCard(String title, IconData icon, bool value, VoidCallback onToggle, {bool isDestructive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.red.shade600 : const Color(0xFF156082), size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Switch(
            value: value,
            onChanged: (_) => onToggle(),
            activeColor: isDestructive ? Colors.red : const Color(0xFF156082),
          ),
        ],
      ),
    );
  }

  Widget _buildDialPositions(AppLocalizations l10n, SecurityState state) {
    final dialItems = [
      ('runDial', l10n.runDial),
      ('dateTimeDial', l10n.dateTimeDial),
      ('startTimes', l10n.startTimes),
      ('stationRuntimes', l10n.stationRuntimes),
      ('daysToWater', l10n.daysToWater),
      ('pumpOperation', l10n.pumpOperation),
      ('seasonalAdjustmentDial', l10n.seasonalAdjustmentDial),
      ('solarSync', l10n.solarSync),
      ('manualOperationDial', l10n.manualOperationDial),
      ('systemOff', l10n.systemOff),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: dialItems.map((item) {
          final isChecked = state.dialPositions[item.$1] ?? false;
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => ref.read(securityProvider.notifier).toggleDialPosition(item.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF156082).withOpacity(0.08) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isChecked ? const Color(0xFF156082) : Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isChecked ? const Color(0xFF156082) : Colors.grey.shade400,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(item.$2, style: TextStyle(fontSize: 12, fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventsLog(AppLocalizations l10n, SecurityState state) {
    if (state.events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(l10n.noData, style: TextStyle(color: Colors.grey.shade400))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        children: state.events.take(20).map((event) {
          final isLogin = event.action == 'created';
          final icon = isLogin ? Icons.login : event.action == 'deleted' ? Icons.person_remove : Icons.edit;
          final color = isLogin ? Colors.green : event.action == 'deleted' ? Colors.red : Colors.blue;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.username, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(event.action, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Text(
                  _formatEventTime(event.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatEventTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
