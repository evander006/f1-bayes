import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/l10n/locale_scope.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/openf1_repository.dart';
import 'l10n/app_localizations.dart';
import 'presentation/bloc/app_context_cubit.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  await initializeDateFormatting('en');
  runApp(const F1App());
}

class F1App extends StatefulWidget {
  const F1App({super.key, this.repository, this.autoLoad = true});

  final OpenF1Repository? repository;
  final bool autoLoad;

  @override
  State<F1App> createState() => _F1AppState();
}

class _F1AppState extends State<F1App> {
  final locale = ValueNotifier(const Locale('en'));
  late final OpenF1Repository repository;

  @override
  void initState() {
    super.initState();
    repository = widget.repository ?? OpenF1Repository();
  }

  @override
  void dispose() {
    locale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      notifier: locale,
      child: RepositoryProvider.value(
        value: repository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider(
              create: (_) {
                final cubit = AppContextCubit(repository);
                if (widget.autoLoad) cubit.load();
                return cubit;
              },
            ),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return ValueListenableBuilder<Locale>(
                valueListenable: locale,
                builder: (context, value, _) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light(),
                    darkTheme: AppTheme.dark(),
                    themeMode: mode,
                    locale: value,
                    supportedLocales: const [Locale('en'), Locale('ru')],
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    home: const AppShell(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
