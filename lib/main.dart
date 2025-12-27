import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/theme.dart';
import 'core/size_config.dart';
import 'logic/providers.dart';
import 'ui/screens/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: MusicAtlasApp()));
}

class MusicAtlasApp extends ConsumerWidget {
  const MusicAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initStatus = ref.watch(appInitProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: 'Music Atlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Builder(
        builder: (context) {
          SizeConfig.init(context);

          return initStatus.when(
            data: (_) => const HomeShell(),
            loading: () => const SplashScreen(),
            error: (err, stack) => ErrorScreen(error: err.toString()),
          );
        },
      ),
    );
  }
}

/// Premium animated splash screen with musical theme
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkScaffoldBg : AppTheme.scaffoldBg;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
    final subtitleColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Circle of Fifths logo
            SizedBox(
              width: 140,
              height: 140,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SplashCirclePainter(
                      progress: _controller.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 40),

            // App name with gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  AppTheme.tonicBlue,
                  AppTheme.tonicBlue.withOpacity(0.7),
                  const Color(0xFF6366F1),
                ],
              ).createShader(bounds),
              child: Text(
                'Music Atlas',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: textColor,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 600.ms),

            const SizedBox(height: 12),

            Text(
              'Explore Music Theory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 600.ms),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.tonicBlue.withOpacity(0.7),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for animated splash circle logo
class _SplashCirclePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SplashCirclePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide * 0.45;
    final innerRadius = size.shortestSide * 0.28;

    // Rotating glow effect
    final glowPaint = Paint()
      ..shader = SweepGradient(
        startAngle: progress * 2 * math.pi,
        endAngle: progress * 2 * math.pi + math.pi * 2,
        colors: [
          AppTheme.tonicBlue.withOpacity(0.0),
          AppTheme.tonicBlue.withOpacity(0.6),
          const Color(0xFF6366F1).withOpacity(0.6),
          AppTheme.tonicBlue.withOpacity(0.0),
        ],
        stops: const [0.0, 0.25, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, outerRadius, glowPaint);

    // Outer ring
    final outerPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.15)
          : Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, outerRadius - 8, outerPaint);

    // Inner ring
    canvas.drawCircle(center, innerRadius, outerPaint);

    // Draw 12 note indicators with staggered animation
    final noteCount = 12;
    for (int i = 0; i < noteCount; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / noteCount);
      final noteProgress = ((progress * noteCount) % noteCount - i).abs();
      final isActive = noteProgress < 1.5;

      final dotRadius = isActive ? 6.0 : 4.0;
      final opacity = isActive ? 1.0 : 0.3;

      final x = center.dx + (outerRadius - 20) * math.cos(angle);
      final y = center.dy + (outerRadius - 20) * math.sin(angle);

      final dotPaint = Paint()
        ..color = (i == 0 ? AppTheme.tonicBlue : const Color(0xFF6366F1))
            .withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashCirclePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkScaffoldBg : AppTheme.scaffoldBg;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.accentRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: AppTheme.accentRed,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
