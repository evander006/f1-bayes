import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../dashboard/dashboard_screen.dart';
import '../driver_detail/driver_detail_screen.dart';
import '../widgets/async_states.dart';

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    return BlocBuilder<AppContextCubit, AppContextState>(
      builder: (context, store) {
        return AsyncBody(
          status: store.status,
          strings: s,
          error: store.error,
          onRetry: context.read<AppContextCubit>().load,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 16, compact ? 16 : 28, 28),
            itemCount: store.drivers.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return Padding(padding: const EdgeInsets.only(bottom: 16), child: ScreenTitle(title: s.drivers));
              final driver = store.drivers[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DriverDetailScreen(driverNumber: driver.driverNumber)),
                  ),
                  child: F1Card(
                    child: Row(
                      children: [
                        TeamFlagBar(color: Color(driver.teamColorValue), height: 36),
                        const SizedBox(width: 10),
                        DriverAvatar(driver: driver, size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driver.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
                              Text('${driver.teamName} · #${driver.driverNumber} · ${driver.nameAcronym}',
                                  style: const TextStyle(color: AppColors.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
