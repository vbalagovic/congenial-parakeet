import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  debugPrint("Starting app initialization");
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Flutter binding initialized");

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    debugPrint("Environment variables loaded");
  } catch (e) {
    debugPrint("Error loading environment variables: $e");
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    debugPrint("Supabase initialized");
  } catch (e) {
    debugPrint("Error initializing Supabase: $e");
  }

  debugPrint("Running app");
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building MyApp widget");

    try {
      // Watch auth state to rebuild when it changes
      final authState = ref.watch(authProvider);
      debugPrint(
          "Auth state: isAuthenticated=${authState.isAuthenticated}, user=${authState.user}");

      final themeMode = ref.watch(themeModeProvider);
      debugPrint("Theme mode retrieved: $themeMode");

      // Create the router instance
      final appRouter = AppRouter(ref: ref);

      // Use MaterialApp.router with Auto Router
      return MaterialApp.router(
        title: 'RealSocial App',
        theme: getLightTheme(),
        darkTheme: getDarkTheme(),
        themeMode: themeMode,
        debugShowCheckedModeBanner: true,
        routerConfig: appRouter.config(),
      );
    } catch (e) {
      debugPrint("Error building MyApp: $e");
      // Return a fallback UI in case of error
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text("Error initializing app: $e"),
          ),
        ),
      );
    }
  }
}
