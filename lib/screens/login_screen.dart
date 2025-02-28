import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../app_router.gr.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/login_app_bar.dart';
import '../widgets/login_form.dart';
import '../widgets/gradient_background.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Store router for navigation
  late StackRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      // Store router reference to avoid using context across async gaps
      _router = context.router;

      final authState = ref.read(authProvider);

      // Redirect to app screen if already authenticated
      if (authState.isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _router.replace(const AppRoute());
          }
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final themeMode = ref.watch(themeModeProvider);
      final isDarkMode = themeMode == ThemeMode.dark;
      final colorScheme = Theme.of(context).colorScheme;

      return Scaffold(
        appBar: const LoginAppBar(),
        body: SafeArea(
          child: GradientBackground(
            isDarkMode: isDarkMode,
            colorScheme: colorScheme,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuint,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withAlpha(66) // 26% opacity
                              : Colors.black.withAlpha(25), // 10% opacity
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const LoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return const Scaffold(
        body: Center(
          child: Text("Error loading login screen"),
        ),
      );
    }
  }
}
