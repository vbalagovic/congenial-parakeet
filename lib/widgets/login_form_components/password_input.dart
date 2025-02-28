import 'package:flutter/material.dart';

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool isEnabled;
  final bool isPasswordVisible;
  final VoidCallback toggleVisibility;

  const PasswordInput({
    super.key,
    required this.controller,
    this.errorText,
    required this.isEnabled,
    required this.isPasswordVisible,
    required this.toggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
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
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock),
              filled: true,
              errorText: errorText,
              suffixIcon: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    key: ValueKey<bool>(isPasswordVisible),
                  ),
                ),
                onPressed: toggleVisibility,
              ),
            ),
            obscureText: !isPasswordVisible,
            enabled: isEnabled,
          ),
        ],
      ),
    );
  }
}
