import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../driver_detail/driver_detail_screen.dart';
import '../race_details/race_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final store = context.watch<AppContextCubit>().state;
    final q = query.toLowerCase();
    final drivers = store.drivers.where((d) {
      return d.fullName.toLowerCase().contains(q) ||
          d.teamName.toLowerCase().contains(q) ||
          d.nameAcronym.toLowerCase().contains(q);
    });
    final meetings = store.meetings.where((m) {
      return m.meetingName.toLowerCase().contains(q) ||
          m.countryName.toLowerCase().contains(q) ||
          m.circuitShortName.toLowerCase().contains(q);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(s.search)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(hintText: s.searchHint, prefixIcon: const Icon(Icons.search)),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 16),
          if (q.isNotEmpty) ...[
            Eyebrow(s.drivers),
            for (final d in drivers)
              ListTile(
                leading: DriverAvatar(driver: d),
                title: Text(d.fullName),
                subtitle: Text(d.teamName),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DriverDetailScreen(driverNumber: d.driverNumber)),
                ),
              ),
            Eyebrow(s.calendar),
            for (final m in meetings)
              ListTile(
                title: Text(m.meetingName),
                subtitle: Text(m.countryName),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => RaceDetailsScreen(meeting: m)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
