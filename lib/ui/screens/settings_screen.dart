import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../logic/providers.dart';
import '../components/animated_entrance.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // APPEARANCE SECTION
          AnimatedEntrance(
            child: const _SectionHeader(title: "Appearance"),
          ),
          const SizedBox(height: 12),

          AnimatedEntrance(
            delay: const Duration(milliseconds: 50),
            child: _SettingsTile(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              subtitle: "Easier on the eyes in low light",
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: notifier.setDarkMode,
                activeColor: AppTheme.tonicBlue,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // INSTRUMENT SECTION
          AnimatedEntrance(
            delay: const Duration(milliseconds: 100),
            child: const _SectionHeader(title: "Instrument Display"),
          ),
          const SizedBox(height: 12),

          AnimatedEntrance(
            delay: const Duration(milliseconds: 150),
            child: _SettingsTile(
              icon: Icons.swap_horiz,
              title: "Left-Handed View",
              subtitle: "Headstock on the right (player's perspective)",
              trailing: Switch(
                value: settings.isLeftHanded,
                onChanged: notifier.setLeftHanded,
                activeColor: AppTheme.tonicBlue,
              ),
            ),
          ),

          const SizedBox(height: 8),

          AnimatedEntrance(
            delay: const Duration(milliseconds: 200),
            child: _SettingsTile(
              icon: Icons.piano,
              title: "Piano Octaves",
              subtitle: "Number of octaves to display",
              trailing: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text("1")),
                  ButtonSegment(value: 2, label: Text("2")),
                ],
                selected: {settings.defaultOctaves},
                onSelectionChanged: (set) => notifier.setDefaultOctaves(set.first),
              ),
            ),
          ),

          const SizedBox(height: 8),

          AnimatedEntrance(
            delay: const Duration(milliseconds: 250),
            child: _SettingsTile(
              icon: Icons.label_outline,
              title: "Show Interval Labels",
              subtitle: "Display interval names on notes",
              trailing: Switch(
                value: settings.showIntervalLabels,
                onChanged: notifier.setShowIntervalLabels,
                activeColor: AppTheme.tonicBlue,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ABOUT SECTION
          AnimatedEntrance(
            delay: const Duration(milliseconds: 300),
            child: const _SectionHeader(title: "About"),
          ),
          const SizedBox(height: 12),

          AnimatedEntrance(
            delay: const Duration(milliseconds: 350),
            child: const _SettingsTile(
              icon: Icons.info_outline,
              title: "Music Atlas",
              subtitle: "Version 0.1.0",
              trailing: SizedBox.shrink(),
            ),
          ),

          const SizedBox(height: 32),

          // RESET BUTTON
          AnimatedEntrance(
            delay: const Duration(milliseconds: 400),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Reset Settings?"),
                      content: const Text(
                        "This will restore all settings to their defaults.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            notifier.reset();
                            Navigator.pop(ctx);
                          },
                          child: const Text("Reset"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Reset to Defaults"),
              ),
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
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSecondary,
        letterSpacing: 1,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.majorLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.tonicBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
