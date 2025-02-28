import 'package:flutter/material.dart';

class AuthModeToggle extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final VoidCallback onToggle;
  final ColorScheme colorScheme;

  const AuthModeToggle({
    super.key,
    required this.isLogin,
    required this.isLoading,
    required this.onToggle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onToggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          isLogin
              ? 'Don\'t have an account? Sign Up'
              : 'Already have an account? Sign In',
          key: ValueKey<bool>(isLogin),
          style: TextStyle(color: colorScheme.primary),
        ),
      ),
    );
  }
}
