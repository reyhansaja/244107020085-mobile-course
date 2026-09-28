import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:week5_offline_notes/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Can add a note', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Tambah'));
    await tester.pump();

    final title = 'Catatan ${DateTime.now().microsecondsSinceEpoch}';
    await tester.enterText(find.byType(TextField).at(0), title);
    await tester.enterText(find.byType(TextField).at(1), 'Isi catatan');
    await tester.tap(find.text('Simpan'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(title), findsOneWidget);
    expect(find.text('Isi catatan'), findsAtLeastNWidgets(1));
  });
}
