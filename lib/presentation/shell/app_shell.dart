import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/adaptive_logo.dart';
import '../../widgets/ui_kit.dart';
import '../accuracy/accuracy_screen.dart';
import '../calendar/calendar_screen.dart';
import '../championship/championship_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../drivers/drivers_screen.dart';
import '../live/live_screen.dart';
import '../more/more_screen.dart';
import '../predictions/predictions_screen.dart';
import '../settings/settings_screen.dart';
import '../teams/teams_screen.dart';

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

    final desktopPages = [
      DashboardScreen(compact: !wide),
      CalendarScreen(compact: !wide),
      LiveScreen(compact: !wide),
      DriversScreen(compact: !wide),
      TeamsScreen(compact: !wide),
      ChampionshipScreen(compact: !wide),
      PredictionsScreen(compact: !wide),
      AccuracyScreen(compact: !wide),
      SettingsScreen(compact: !wide),
    ];

    final mobilePages = [
      DashboardScreen(compact: true),
      CalendarScreen(compact: true),
      LiveScreen(compact: true),
      DriversScreen(compact: true),
      const MoreScreen(),
    ];

    if (!wide) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        body: IndexedStack(index: index, children: mobilePages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          indicatorColor: AppColors.red.withValues(alpha: 0.12),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.space_dashboard_outlined), selectedIcon: const Icon(Icons.space_dashboard_rounded, color: AppColors.red), label: s.dashboard),
            NavigationDestination(icon: const Icon(Icons.flag_outlined), selectedIcon: const Icon(Icons.flag_rounded, color: AppColors.red), label: s.races),
            NavigationDestination(icon: const Icon(Icons.timeline_outlined), selectedIcon: const Icon(Icons.timeline_rounded, color: AppColors.red), label: s.live),
            NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people, color: AppColors.red), label: s.drivers),
            NavigationDestination(icon: const Icon(Icons.more_horiz), selectedIcon: const Icon(Icons.more_horiz, color: AppColors.red), label: s.more),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          _DesktopRail(
            selected: index,
            s: s,
            onSelect: (i) => setState(() => index = i),
          ),
          Expanded(child: desktopPages[index]),
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
      (Icons.flag_outlined, s.calendar, 1),
      (Icons.timeline_rounded, s.tracker, 2),
      (Icons.people_alt_outlined, s.drivers, 3),
      (Icons.groups_outlined, s.teams, 4),
      (Icons.emoji_events_outlined, s.championship, 5),
      (Icons.insights_rounded, s.predictions, 6),
      (Icons.bar_chart_rounded, s.accuracy, 7),
      (Icons.settings_outlined, s.settings, 8),
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
                    onTap: () => onSelect(item.$3),
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
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.sidebarMuted;
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
                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
