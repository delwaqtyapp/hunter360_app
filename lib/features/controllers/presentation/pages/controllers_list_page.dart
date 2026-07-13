import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import '../providers/controllers_provider.dart';

class ControllersListPage extends ConsumerStatefulWidget {
  const ControllersListPage({super.key});

  @override
  ConsumerState<ControllersListPage> createState() => _ControllersListPageState();
}

class _ControllersListPageState extends ConsumerState<ControllersListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(controllersProvider.notifier).loadControllers());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(controllersProvider);

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF156082)))
          : state.controllers.isEmpty
              ? _buildEmptyState(l10n)
              : _buildControllerList(l10n, state),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_input_antenna, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            l10n.noControllersFound,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapToViewDetails,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(controllersProvider.notifier).loadControllers(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF156082)),
          ),
        ],
      ),
    );
  }

  Widget _buildControllerList(AppLocalizations l10n, ControllersState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(controllersProvider.notifier).loadControllers(),
      color: const Color(0xFF156082),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.controllers.length,
        itemBuilder: (context, index) {
          final controller = state.controllers[index];
          return _controllerCard(context, l10n, controller);
        },
      ),
    );
  }

  Widget _controllerCard(BuildContext context, AppLocalizations l10n, IrrigationController controller) {
    final project = AppConstants.controllers.firstWhere(
      (c) => c['id'] == controller.id,
      orElse: () => {'id': controller.id, 'name': controller.id},
    );
    final projectName = project['name'] ?? controller.displayName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go('/controllers/${controller.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF156082).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing,
                      color: Color(0xFF156082),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.id}-$projectName',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.controllerName,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.online,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoChip(Icons.tag, '${controller.tagCount}', l10n.tagsCount),
                    _infoChip(Icons.device_hub, controller.id, l10n.controllerName),
                    _infoChip(Icons.circle, l10n.online, l10n.status),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.tapToViewDetails,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF156082)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}
