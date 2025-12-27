import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../logic/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final majorLight = AppTheme.getMajorLight(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: scaffoldBg,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Customize your experience",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Appearance Section
                _SectionHeader(title: "Appearance"),
                const SizedBox(height: 12),

                _ModernSettingsTile(
                  icon: Icons.dark_mode_rounded,
                  iconBg: const Color(0xFF1E293B),
                  iconColor: Colors.white,
                  title: "Dark Mode",
                  subtitle: "Switch between light and dark themes",
                  trailing: _ModernSwitch(
                    value: settings.isDarkMode,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      notifier.setDarkMode(v);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Instrument Section
                _SectionHeader(title: "Instrument Display"),
                const SizedBox(height: 12),

                _ModernSettingsTile(
                  icon: Icons.flip_rounded,
                  iconBg: majorLight,
                  iconColor: AppTheme.tonicBlue,
                  title: "Left-Handed View",
                  subtitle: "Mirror the fretboard for left-handed players",
                  trailing: _ModernSwitch(
                    value: settings.isLeftHanded,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      notifier.setLeftHanded(v);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                _ModernSettingsTile(
                  icon: Icons.piano_rounded,
                  iconBg: majorLight,
                  iconColor: AppTheme.tonicBlue,
                  title: "Piano Octaves",
                  subtitle: "Number of octaves to display",
                  trailing: _OctaveSelector(
                    value: settings.defaultOctaves,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      notifier.setDefaultOctaves(v);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                _ModernSettingsTile(
                  icon: Icons.label_outline_rounded,
                  iconBg: majorLight,
                  iconColor: AppTheme.tonicBlue,
                  title: "Interval Labels",
                  subtitle: "Show interval names on notes",
                  trailing: _ModernSwitch(
                    value: settings.showIntervalLabels,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      notifier.setShowIntervalLabels(v);
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // About Section
                _SectionHeader(title: "About"),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.tonicBlue,
                              AppTheme.tonicBlue.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Version 1.0.0",
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Reset Button
                Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      showDialog(
                        context: context,
                        builder: (ctx) => _ResetDialog(
                          onReset: () {
                            notifier.reset();
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Reset to Defaults",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.getTextSecondary(context),
        letterSpacing: 1,
      ),
    );
  }
}

class _ModernSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _ModernSettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.getShadow(context, size: 'sm'),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _ModernSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ModernSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        curve: AppTheme.curveEaseOut,
        width: 52,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppTheme.tonicBlue : AppTheme.getBorderColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedAlign(
          duration: AppTheme.durationFast,
          curve: AppTheme.curveEaseOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
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

  const _OctaveSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = AppTheme.getScaffoldBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scaffoldBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [1, 2].map((octave) {
          final isActive = value == octave;
          return GestureDetector(
            onTap: () => onChanged(octave),
            child: AnimatedContainer(
              duration: AppTheme.durationFast,
              curve: AppTheme.curveEaseOut,
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? cardBg : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                boxShadow: isActive ? AppTheme.shadowSm : [],
              ),
              child: Text(
                "$octave",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppTheme.tonicBlue : textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ResetDialog extends StatelessWidget {
  final VoidCallback onReset;

  const _ResetDialog({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final cardBg = AppTheme.getCardBg(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final borderColor = AppTheme.getBorderColor(context);

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppTheme.accentRed,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Reset Settings?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This will restore all settings to their default values.",
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: borderColor),
                      ),
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onReset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRed,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Center(
                        child: Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
