import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:f1_app/main.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('en');
    await initializeDateFormatting('ru');
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const F1App());
    await tester.pump();
  }

  testWidgets('desktop dashboard shows OpenF1 meeting mock', (tester) async {
    await pumpApp(tester, const Size(1920, 1080));
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Monaco Grand Prix'), findsOneWidget);
    expect(find.textContaining('C. Leclerc'), findsWidgets);
  });

  testWidgets('mobile shell shows bottom navigation', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    expect(find.text('Monaco Grand Prix'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Predictions'), findsOneWidget);
  });
}
