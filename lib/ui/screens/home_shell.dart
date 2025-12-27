import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnimations;

  final List<Widget> _screens = [
    const CircleScreen(),
    const SearchScreen(),
    const TransposerScreen(),
    const ModesScreen(),
    const SettingsScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.blur_circular, activeIcon: Icons.blur_circular, label: 'Circle'),
    _NavItem(icon: Icons.search_rounded, activeIcon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.compare_arrows_rounded, activeIcon: Icons.compare_arrows_rounded, label: 'Transpose'),
    _NavItem(icon: Icons.piano_rounded, activeIcon: Icons.piano_rounded, label: 'Modes'),
    _NavItem(icon: Icons.tune_rounded, activeIcon: Icons.tune_rounded, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: AppTheme.durationNormal,
        vsync: this,
      ),
    );
    _scaleAnimations = _controllers.map((c) =>
      Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: c, curve: AppTheme.curveEaseOut),
      ),
    ).toList();

    // Trigger initial animation
    _controllers[_selectedIndex].forward();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    HapticFeedback.lightImpact();

    // Animate out old, animate in new
    _controllers[_selectedIndex].reverse();
    setState(() => _selectedIndex = index);
    _controllers[index].forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppTheme.durationNormal,
        switchInCurve: AppTheme.curveEaseOut,
        switchOutCurve: AppTheme.curveEaseIn,
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(
            top: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;

                return _NavBarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _onItemTapped(index),
                  scaleAnimation: _scaleAnimations[index],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double> scaleAnimation;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        curve: AppTheme.curveEaseOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.tonicBlue.withOpacity(isDark ? 0.15 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppTheme.durationFast,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 22,
                color: isSelected ? AppTheme.tonicBlue : textSecondary,
              ),
            ),
            AnimatedSize(
              duration: AppTheme.durationNormal,
              curve: AppTheme.curveEaseOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.tonicBlue,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
