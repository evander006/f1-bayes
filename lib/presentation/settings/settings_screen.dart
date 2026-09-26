import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/theme_cubit.dart';
import '../dashboard/dashboard_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final locale = LocaleScope.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 16, compact ? 16 : 28, 28),
      children: [
        ScreenTitle(title: s.settings),
        const SizedBox(height: 16),
        F1Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(s.language),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'en', label: Text('EN')),
                  ButtonSegment(value: 'ru', label: Text('RU')),
                ],
                selected: {locale.value.languageCode},
                onSelectionChanged: (value) {
                  locale.value = Locale(value.first);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(s.darkMode),
                value: context.watch<ThemeCubit>().state == ThemeMode.dark,
                onChanged: (_) => context.read<ThemeCubit>().toggle(),
              ),
              const SizedBox(height: 8),
              Text(
                context.read<OpenF1Repository>().isAuthenticated
                    ? s.liveAuthenticated
                    : s.errorSubscription,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
