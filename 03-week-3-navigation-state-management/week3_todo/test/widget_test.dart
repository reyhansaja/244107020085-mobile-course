// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  testWidgets('dapat berpindah dari daftar tugas ke statistik',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(
              shouldFail: () => false,
              delay: Duration.zero,
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('ToDo Riverpod'), findsOneWidget);

    await tester.tap(find.byTooltip('Buka statistik'));
    await tester.pumpAndSettle();

    expect(find.text('Statistik'), findsOneWidget);
    expect(find.text('Penjualan: 120'), findsOneWidget);
  });
}
