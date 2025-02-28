import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../app_router.gr.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // Toggle between login and register
  bool _isPasswordVisible = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitEmailAuth() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Reset previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate inputs
    bool isValid = true;

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      isValid = false;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      isValid = false;
    }

    if (!isValid) return;

    if (_isLogin) {
      ref.read(authProvider.notifier).signInWithEmail(email, password);
    } else {
      ref.read(authProvider.notifier).signUpWithEmail(email, password);
    }
  }

  // Store router for navigation
  late StackRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("LoginScreen.didChangeDependencies called");

    try {
      // Store router reference to avoid using context across async gaps
      _router = context.router;
      debugPrint("Router stored: $_router");

      debugPrint("Reading auth state from provider");
      final authState = ref.read(authProvider);
      debugPrint(
          "Auth state: isAuthenticated=${authState.isAuthenticated}, user=${authState.user}");

      // Redirect to app screen if already authenticated
      if (authState.isAuthenticated) {
        debugPrint("User is authenticated, redirecting to app screen");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            debugPrint("Replacing current route with AppRoute");
            _router.replace(const AppRoute());
          }
        });
      } else {
        debugPrint("User is not authenticated, staying on login screen");
      }
    } catch (e) {
      debugPrint("Error in LoginScreen.didChangeDependencies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("LoginScreen.build called");

    try {
      debugPrint("Reading auth state from provider");
      final authState = ref.watch(authProvider);
      debugPrint(
          "Auth state: isAuthenticated=${authState.isAuthenticated}, user=${authState.user}");

      final themeMode = ref.watch(themeModeProvider);
      final isDarkMode = themeMode == ThemeMode.dark;
      final colorScheme = Theme.of(context).colorScheme;

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'RealSocial Login',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            // Theme toggle button
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
              ),
              onPressed: () =>
                  ref.read(themeModeProvider.notifier).toggleTheme(),
              tooltip:
                  isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        colorScheme.surface,
                        colorScheme.surface,
                      ]
                    : [
                        colorScheme.primary.withAlpha(13), // 5% opacity
                        colorScheme.surface,
                      ],
              ),
            ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: Text(
                            'Welcome to RealSocial',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email input with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.email),
                                  filled: true,
                                  errorText: _emailError,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                enabled: !authState.isLoading,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password input with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.lock),
                                  filled: true,
                                  errorText: _passwordError,
                                  suffixIcon: IconButton(
                                    icon: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (Widget child,
                                          Animation<double> animation) {
                                        return ScaleTransition(
                                            scale: animation, child: child);
                                      },
                                      child: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        key: ValueKey<bool>(_isPasswordVisible),
                                      ),
                                    ),
                                    onPressed: _togglePasswordVisibility,
                                  ),
                                ),
                                obscureText: !_isPasswordVisible,
                                enabled: !authState.isLoading,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email login/register button with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            );
                          },
                          child: ElevatedButton(
                            onPressed:
                                authState.isLoading ? null : _submitEmailAuth,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: authState.isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    colorScheme.onPrimary),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Loading...',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onPrimary),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      _isLogin ? 'Sign In' : 'Sign Up',
                                      key: ValueKey<String>(
                                          _isLogin ? 'signin' : 'signup'),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ),

                        // Toggle between login and register
                        TextButton(
                          onPressed:
                              authState.isLoading ? null : _toggleAuthMode,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _isLogin
                                  ? 'Don\'t have an account? Sign Up'
                                  : 'Already have an account? Sign In',
                              key: ValueKey<bool>(_isLogin),
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        ),

                        const Divider(height: 40),
                        const Text('OR',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),

                        // Google sign in button with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            );
                          },
                          child: ElevatedButton.icon(
                            onPressed: authState.isLoading
                                ? null
                                : () => ref
                                    .read(authProvider.notifier)
                                    .signInWithGoogle(),
                            icon: Image.asset(
                              'assets/google_logo.png',
                              height: 24,
                            ),
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                        // Error message without animation
                        if (authState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha(25), // 10% opacity
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.red
                                        .withAlpha(77)), // 30% opacity
                              ),
                              child: Text(
                                authState.error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error in LoginScreen.build: $e");
      return const Scaffold(
        body: Center(
          child: Text("Error loading login screen"),
        ),
      );
    }
  }
}
