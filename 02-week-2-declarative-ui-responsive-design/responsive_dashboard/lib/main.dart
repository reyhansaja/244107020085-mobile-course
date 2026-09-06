import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const kWideBreakpoint = 700.0;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    final cards = [
      const InfoCardData(
        title: 'Assignments',
        value: '8',
        detail: 'Due this week',
        icon: Icons.assignment_outlined,
      ),
      const InfoCardData(
        title: 'Attendance',
        value: '92%',
        detail: 'This semester',
        icon: Icons.calendar_today_outlined,
      ),
      const InfoCardData(
        title: 'Portfolio',
        value: 'Ready',
        detail: 'Last updated today',
        icon: Icons.folder_outlined,
      ),
      const InfoCardData(
        title: 'Current week',
        value: '02',
        detail: 'Spring semester',
        icon: Icons.date_range_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('Academic Overview'),
        ),
        actions: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              ),
              const SizedBox(width: 4),
              Semantics(
                label: 'Dark mode',
                toggled: isDark,
                child: CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: 24),
              Text(
                'Your academic snapshot',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (constraints.maxWidth >= kWideBreakpoint) ...[
                Row(
                  children: [
                    Expanded(child: InfoCard(data: cards[0])),
                    const SizedBox(width: 16),
                    Expanded(child: InfoCard(data: cards[1])),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: InfoCard(data: cards[2])),
                    const SizedBox(width: 16),
                    Expanded(child: InfoCard(data: cards[3])),
                  ],
                ),
              ] else ...[
                Column(
                  children: [
                    for (final card in cards) InfoCard(data: card),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Profil Mahasiswa atas nama Raihan, Jurusan Teknik Informatika',
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                child: Text('RNP'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Raihan!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teknik Informatika  •  Semester 5',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.school_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCardData {
  const InfoCardData({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
  });
  final String title;
  final String value;
  final String detail;
  final IconData icon;
}

class InfoCard extends StatelessWidget {
  const InfoCard({required this.data, super.key});
  final InfoCardData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final cardContent = Row(
      children: [
        ExcludeSemantics(
          child: Icon(data.icon, color: colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(data.detail, style: textTheme.bodySmall),
              ],
            ),
          ),
        ),
        ExcludeSemantics(
          child: Text(data.value, style: textTheme.headlineSmall),
        ),
      ],
    );

    return Semantics(
      container: true,
      label: '${data.title}: ${data.value}. ${data.detail}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: cardContent,
        ),
      ),
    );
  }
}