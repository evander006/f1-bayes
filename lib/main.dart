import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/l10n/locale_scope.dart';
import 'core/theme/app_theme.dart';
import 'presentation/shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  await initializeDateFormatting('en');
  runApp(const F1App());
}

class F1App extends StatefulWidget {
  const F1App({super.key});

  @override
  State<F1App> createState() => _F1AppState();
}

class _F1AppState extends State<F1App> {
  final locale = ValueNotifier(const Locale('en'));

  @override
  void dispose() {
    locale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      notifier: locale,
      child: ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (context, value, _) {
          return MaterialApp(
           // title: 'F1 Analytics',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: value,
            supportedLocales: const [Locale('en'), Locale('ru')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

