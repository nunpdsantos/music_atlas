import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../logic/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final isDark = AppTheme.isDark(context);
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final textPrimary = AppTheme.getTextPrimary(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: scaffoldBg,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "Settings",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.tonicBlue.withOpacity(isDark ? 0.1 : 0.05),
                      scaffoldBg,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Settings Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // APPEARANCE SECTION
                _SectionHeader(title: "Appearance", isDark: isDark)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms),
                const SizedBox(height: 12),

                _PremiumSettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: "Dark Mode",
                  subtitle: "Easier on the eyes in low light",
                  isDark: isDark,
                  trailing: _PremiumSwitch(
                    value: settings.isDarkMode,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      notifier.setDarkMode(v);
                    },
                  ),
                )
                    .animate()
                    .fadeIn(delay: 50.ms, duration: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms),

                const SizedBox(height: 28),

                // INSTRUMENT SECTION
                _SectionHeader(title: "Instrument Display", isDark: isDark)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms),
                const SizedBox(height: 12),

                _PremiumSettingsTile(
                  icon: Icons.swap_horiz_rounded,
                  title: "Left-Handed View",
                  subtitle: "Headstock on the right (player's perspective)",
                  isDark: isDark,
                  trailing: _PremiumSwitch(
                    value: settings.isLeftHanded,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      notifier.setLeftHanded(v);
                    },
                  ),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms),

                const SizedBox(height: 10),

                _PremiumSettingsTile(
                  icon: Icons.piano_rounded,
                  title: "Piano Octaves",
                  subtitle: "Number of octaves to display",
                  isDark: isDark,
                  trailing: _OctaveSelector(
                    value: settings.defaultOctaves,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      notifier.setDefaultOctaves(v);
                    },
                    isDark: isDark,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms),

                const SizedBox(height: 10),

                _PremiumSettingsTile(
                  icon: Icons.label_outline_rounded,
                  title: "Show Interval Labels",
                  subtitle: "Display interval names on notes",
                  isDark: isDark,
                  trailing: _PremiumSwitch(
                    value: settings.showIntervalLabels,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      notifier.setShowIntervalLabels(v);
                    },
                  ),
                )
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms),

                const SizedBox(height: 28),

                // ABOUT SECTION
                _SectionHeader(title: "About", isDark: isDark)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms),
                const SizedBox(height: 12),

                _AboutCard(isDark: isDark)
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms),

                const SizedBox(height: 32),

                // RESET BUTTON
                _ResetButton(
                  onPressed: () => _showResetDialog(context, notifier),
                  isDark: isDark,
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 300.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.0, 1.0),
                      delay: 400.ms,
                      duration: 300.ms,
                    ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, AppSettingsNotifier notifier) {
    final isDark = AppTheme.isDark(context);

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Reset Settings?",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            "This will restore all settings to their defaults.",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                notifier.reset();
                Navigator.pop(ctx);
              },
              child: const Text(
                "Reset",
                style: TextStyle(
                  color: AppTheme.accentRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _PremiumSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool isDark;

  const _PremiumSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
    final textSecondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container with gradient
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.tonicBlue.withOpacity(0.15),
                  AppTheme.tonicBlue.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.tonicBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppTheme.tonicBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _PremiumSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PremiumSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: value
              ? const LinearGradient(
                  colors: [AppTheme.tonicBlue, Color(0xFF6366F1)],
                )
              : null,
          color: value ? null : Colors.grey.withOpacity(0.3),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppTheme.tonicBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OctaveSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _OctaveSelector({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [1, 2].map((num) {
          final isSelected = value == num;
          return GestureDetector(
            onTap: () => onChanged(num),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.tonicBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$num',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white60 : Colors.black54),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final bool isDark;
  const _AboutCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
    final textSecondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // App icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.tonicBlue,
                  const Color(0xFF6366F1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.tonicBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Music Atlas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Version 0.1.0",
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Explore music theory visually",
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const _ResetButton({required this.onPressed, required this.isDark});

  @override
  State<_ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<_ResetButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppTheme.accentRed.withOpacity(0.15)
                : (widget.isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isPressed
                  ? AppTheme.accentRed.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh_rounded,
                size: 18,
                color: _isPressed
                    ? AppTheme.accentRed
                    : (widget.isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(width: 8),
              Text(
                "Reset to Defaults",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isPressed
                      ? AppTheme.accentRed
                      : (widget.isDark ? Colors.white60 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
