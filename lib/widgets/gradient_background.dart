import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final bool isDarkMode;
  final ColorScheme colorScheme;
  final Widget child;

  const GradientBackground({
    super.key,
    required this.isDarkMode,
    required this.colorScheme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
      child: child,
    );
  }
}
