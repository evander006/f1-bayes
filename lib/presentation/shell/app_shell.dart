import 'package:f1_app/widgets/adaptive_logo.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../accuracy/accuracy_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../live/live_screen.dart';
import '../predictions/predictions_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final s = LocaleScope.stringsOf(context);
    final pages = [
      DashboardScreen(compact: !wide),
      LiveScreen(compact: !wide),
      PredictionsScreen(compact: !wide),
      AccuracyScreen(compact: !wide),
    ];

    if (!wide) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: Row(
            children: [
              const AdaptiveLogo(),
              const SizedBox(width: 10),
              Text(s.appName, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: LocaleToggle(),
            ),
          ],
        ),
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          indicatorColor: AppColors.red.withValues(alpha: 0.12),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.space_dashboard_outlined), selectedIcon: const Icon(Icons.space_dashboard_rounded, color: AppColors.red), label: s.dashboard),
            NavigationDestination(icon: const Icon(Icons.timeline_outlined), selectedIcon: const Icon(Icons.timeline_rounded, color: AppColors.red), label: s.live),
            NavigationDestination(icon: const Icon(Icons.insights_outlined), selectedIcon: const Icon(Icons.insights_rounded, color: AppColors.red), label: s.predictions),
            NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart_rounded, color: AppColors.red), label: s.accuracy),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Row(
        children: [
          _DesktopRail(
            selected: index,
            s: s,
            onSelect: (i) => setState(() => index = i),
          ),
          Expanded(child: pages[index]),
        ],
      ),
    );
  }
}

class _DesktopRail extends StatelessWidget {
  const _DesktopRail({
    required this.selected,
    required this.s,
    required this.onSelect,
  });

  final int selected;
  final AppStrings s;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.space_dashboard_rounded, s.dashboard, 0),
      (Icons.speed_rounded, s.cars, null),
      (Icons.cloud_outlined, s.weather, null),
      (Icons.timeline_rounded, s.tracker, 1),
      (Icons.grid_view_rounded, s.grid, null),
      (Icons.insights_rounded, s.predictions, 2),
      (Icons.people_alt_outlined, s.drivers, null),
      (Icons.emoji_events_outlined, s.constructors, null),
      (Icons.flag_outlined, s.races, null),
      (Icons.bar_chart_rounded, s.accuracy, 3),
      (Icons.settings_outlined, s.settings, null),
    ];

    return Container(
      width: 96,
      color: AppColors.sidebar,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          const AdaptiveLogo(),
          const SizedBox(height: 22),
          Expanded(
            child: ListView(
              children: [
                for (final item in items)
                  _RailItem(
                    icon: item.$1,
                    label: item.$2,
                    selected: item.$3 == selected,
                    enabled: item.$3 != null,
                    onTap: item.$3 == null ? null : () => onSelect(item.$3!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Colors.white
        : enabled
            ? AppColors.sidebarMuted
            : AppColors.sidebarMuted.withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}