import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../widgets/ui_kit.dart';
import '../accuracy/accuracy_screen.dart';
import '../championship/championship_screen.dart';
import '../predictions/predictions_screen.dart';
import '../settings/settings_screen.dart';
import '../teams/teams_screen.dart';
import '../telemetry/telemetry_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        F1Card(
          child: Column(
            children: [
              ListTile(
                title: Text(s.teams),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, const TeamsScreen(compact: true)),
              ),
              ListTile(
                title: Text(s.championship),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, const ChampionshipScreen(compact: true)),
              ),
              ListTile(
                title: Text(s.predictions),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, const PredictionsScreen(compact: true)),
              ),
              ListTile(
                title: Text(s.accuracy),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, const AccuracyScreen(compact: true)),
              ),
              ListTile(
                title: Text(s.telemetry),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TelemetryScreen()),
                ),
              ),
              ListTile(
                title: Text(s.settings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, const SettingsScreen(compact: true)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: page)));
  }
}
