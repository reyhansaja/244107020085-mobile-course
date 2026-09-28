import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/prefs.dart';
import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsRepository().markOpenedNow();
  runApp(const ProviderScope(child: MyApp()));
}

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NotesPage(),
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return const NotFoundPage();
        return NoteDetailPage(noteId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp.router(
        title: 'Week 5 - Offline Notes',
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: isDark ? Brightness.dark : Brightness.light,
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Catatan tidak ditemukan')),
      );
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Offline Notes')),
        body: Center(child: Text('$count')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => count++),
          child: const Icon(Icons.add),
        ),
      );
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Stats')),
        body: const Center(child: Text('Statistics')),
      );
}