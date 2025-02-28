import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'theme_toggle_button.dart';

class AppScreenAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppScreenAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: const Text(
        'My Favorite Words',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 0,
      actions: [
        // Theme toggle button
        ThemeToggleButton(isDarkMode: isDarkMode, colorScheme: colorScheme),
        // Logout button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authProvider.notifier).signOut(),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
