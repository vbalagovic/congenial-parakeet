import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_social/widgets/toast_notification.dart';
import '../providers/auth_provider.dart';
import 'login_form_components/welcome_header.dart';
import 'login_form_components/email_input.dart';
import 'login_form_components/password_input.dart';
import 'login_form_components/submit_button.dart';
import 'login_form_components/auth_mode_toggle.dart';
import 'login_form_components/divider_with_text.dart';
import 'login_form_components/google_signin_button.dart';
import 'login_form_components/error_message.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // Toggle between login and register
  bool _isPasswordVisible = false;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

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

  Future<void> _submitEmailAuth() async {
    // Don't submit if already loading
    if (ref.read(authProvider).isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Reset previous errors
    if (mounted) {
      setState(() {
        _emailError = null;
        _passwordError = null;
      });
    }

    // Validate inputs
    bool isValid = true;

    if (email.isEmpty) {
      if (mounted) {
        setState(() {
          _emailError = 'Email is required';
        });
      }
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      if (mounted) {
        setState(() {
          _emailError = 'Please enter a valid email';
        });
      }
      isValid = false;
    }

    if (password.isEmpty) {
      if (mounted) {
        setState(() {
          _passwordError = 'Password is required';
        });
      }
      isValid = false;
    } else if (password.length < 6) {
      if (mounted) {
        setState(() {
          _passwordError = 'Password must be at least 6 characters';
        });
      }
      isValid = false;
    }

    if (!isValid) return;

    try {
      setState(() {
        _isLoading = true;
      });
      if (_isLogin) {
        await ref
            .read(authProvider.notifier)
            .signInWithEmail(email, password)
            .then((onValue) {
          setState(() {
            _isLoading = false;
          });
        }).catchError((onError) {
          log(onError.toString());
          setState(() {
            _passwordError = onError.toString();
            _isLoading = false;
          });
        });
      } else {
        await ref
            .read(authProvider.notifier)
            .signUpWithEmail(email, password)
            .then((onValue) {
          if (mounted) {
            ToastNotification.show(
                context, "Please confirm your email address before login.");
          }
          _toggleAuthMode();
          setState(() {
            _isLoading = false;
            _emailController.clear();
            _passwordController.clear();
            _isLoading = false;
          });
        }).catchError((onError) {
          log(onError.toString());
          setState(() {
            _passwordError = onError.toString();
            _isLoading = false;
          });
        });
      }

      // Check if we're still mounted after the auth operation
      if (mounted) {
        // Get the state after the operation
        final afterState = ref.read(authProvider);

        // If there's an error, display it in the appropriate field
        if (afterState.error != null) {
          final error = afterState.error!.toLowerCase();
          setState(() {
            if (error.contains('password')) {
              _passwordError = afterState.error;
            } else if (error.contains('email')) {
              _emailError = afterState.error;
            }
            // General error will be shown by the error message component
          });
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        setState(() {
          _passwordError = 'An unexpected error occurred. Please try again.';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Welcome header
        WelcomeHeader(colorScheme: colorScheme),
        const SizedBox(height: 40),

        // Email input
        EmailInput(
          controller: _emailController,
          errorText: _emailError,
          isEnabled: !authState.isLoading,
        ),
        const SizedBox(height: 16),

        // Password input
        PasswordInput(
          controller: _passwordController,
          errorText: _passwordError,
          isEnabled: !authState.isLoading,
          isPasswordVisible: _isPasswordVisible,
          toggleVisibility: _togglePasswordVisibility,
        ),
        const SizedBox(height: 24),

        // Submit button
        SubmitButton(
          isLoading: _isLoading,
          isLogin: _isLogin,
          onPressed: _submitEmailAuth,
          colorScheme: colorScheme,
        ),

        // Auth mode toggle
        AuthModeToggle(
          isLogin: _isLogin,
          isLoading: authState.isLoading,
          onToggle: _toggleAuthMode,
          colorScheme: colorScheme,
        ),

        // Divider
        const DividerWithText(text: 'OR'),

        // Google sign in button
        GoogleSignInButton(
          isLoading: authState.isLoading,
          onPressed: () async {
            // Don't submit if already loading
            if (ref.read(authProvider).isLoading) return;

            try {
              await ref.read(authProvider.notifier).signInWithGoogle();

              // Check if we're still mounted after the auth operation
              if (mounted) {
                // Get the state after the operation
                final afterState = ref.read(authProvider);

                // If there's an error, display it in the appropriate field
                if (afterState.error != null) {
                  final error = afterState.error!.toLowerCase();
                  setState(() {
                    if (error.contains('password')) {
                      _passwordError = afterState.error;
                    } else if (error.contains('email')) {
                      _emailError = afterState.error;
                    }
                    // General error will be shown by the error message component
                  });
                }
              }
            } catch (e) {
              // Handle any unexpected errors
              if (mounted) {
                setState(() {
                  _passwordError =
                      'An unexpected error occurred. Please try again.';
                });
              }
            }
          },
        ),

        // Error message
        if (authState.error != null &&
            (_emailError == null && _passwordError == null))
          ErrorMessage(message: authState.error!),
      ],
    );
  }
}
