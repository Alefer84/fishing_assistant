import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/hatch_screen.dart';
import 'screens/home_screen.dart';
import 'screens/log_screen.dart';
import 'screens/moon_screen.dart';
import 'theme.dart';
import 'widgets/responsive.dart';

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

  static const _destinations = [
    _NavItem('Home', Icons.home_outlined, Icons.home),
    _NavItem('Hatches', Icons.bug_report_outlined, Icons.bug_report),
    _NavItem('Moon', Icons.nightlight_outlined, Icons.nightlight_round),
    _NavItem('Log', Icons.menu_book_outlined, Icons.menu_book),
  ];

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(index: _index, children: _screens);

    if (isWideLayout(context)) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
