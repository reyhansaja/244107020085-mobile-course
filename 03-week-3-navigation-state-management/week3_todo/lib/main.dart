import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/stats_page.dart';
import 'pages/todo_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TodoPage(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsPage(),
    ),
  ],
);

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Week 3 - ToDo',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      routerConfig: appRouter,
      );
}