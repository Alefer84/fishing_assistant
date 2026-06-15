import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/hatch_screen.dart';
import 'screens/home_screen.dart';
import 'screens/log_screen.dart';
import 'screens/moon_screen.dart';
import 'theme.dart';

void main() {
  runApp(const FishingAssistantApp());
}

class FishingAssistantApp extends StatelessWidget {
  const FishingAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'Fishing Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const RootNav(),
      ),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    HatchScreen(),
    MoonScreen(),
    LogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.bug_report_outlined),
              selectedIcon: Icon(Icons.bug_report),
              label: 'Hatches'),
          NavigationDestination(
              icon: Icon(Icons.nightlight_outlined),
              selectedIcon: Icon(Icons.nightlight_round),
              label: 'Moon'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Log'),
        ],
      ),
    );
  }
}
