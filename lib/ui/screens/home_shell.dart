import 'package:flutter/material.dart';
import 'circle_screen.dart';
import 'search_screen.dart';
import 'transposer_screen.dart';
import 'modes_screen.dart';
import 'settings_screen.dart';
import '../../core/theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  // The 5 Screens
  final List<Widget> _screens = [
    const CircleScreen(),
    const SearchScreen(),
    const TransposerScreen(),
    const ModesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors
    final cardBg = AppTheme.getCardBg(context);
    final majorLight = AppTheme.getMajorLight(context);
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: cardBg,
        indicatorColor: majorLight,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.circle_outlined), label: 'Circle'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Transpose'),
          NavigationDestination(icon: Icon(Icons.graphic_eq), label: 'Modes'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
