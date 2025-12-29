import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'core/size_config.dart';
import 'logic/providers.dart';
import 'ui/screens/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MusicAtlasApp()));
}

class MusicAtlasApp extends ConsumerWidget {
  const MusicAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the initialization status
    final initStatus = ref.watch(appInitProvider);
    // Watch settings for theme mode
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: 'Music Atlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // We use a Builder here to get a context that has access to MediaQuery
      builder: (context, child) {
        // Limit text scaling to prevent UI from getting too large on some devices
        final mediaQuery = MediaQuery.of(context);
        final constrainedTextScaleFactor = mediaQuery.textScaleFactor.clamp(0.85, 1.15);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaleFactor: constrainedTextScaleFactor,
          ),
          child: child!,
        );
      },
      home: Builder(
        builder: (context) {
          // INITIALIZE THE SCALER HERE
          SizeConfig.init(context);

          return initStatus.when(
            data: (_) => const HomeShell(),
            loading: () => const LoadingScreen(),
            error: (err, stack) => ErrorScreen(error: err.toString()),
          );
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textSecondary = AppTheme.getTextSecondary(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.tonicBlue),
            const SizedBox(height: 20),
            Text("Loading Music Atlas...", style: TextStyle(color: textSecondary)),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("Error: $error", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
