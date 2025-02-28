import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../app_router.gr.dart';
import '../providers/auth_provider.dart';
import '../providers/words_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/word_list.dart';
import '../widgets/word_input.dart';
import '../widgets/toast_notification.dart';
import '../constants.dart';

// Extracted AppBar widget
class _AppScreenAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _AppScreenAppBar();

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

// Extracted Theme Toggle Button
class ThemeToggleButton extends ConsumerWidget {
  final bool isDarkMode;
  final ColorScheme colorScheme;

  const ThemeToggleButton({
    super.key,
    required this.isDarkMode,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: isDarkMode ? Colors.white : colorScheme.onPrimary,
          key: ValueKey<bool>(isDarkMode),
        ),
      ),
      onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}

// Extracted Background Container
class _GradientBackground extends StatelessWidget {
  final bool isDarkMode;
  final ColorScheme colorScheme;
  final Widget child;

  const _GradientBackground({
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

@RoutePage()
class AppScreen extends ConsumerStatefulWidget {
  const AppScreen({super.key});

  @override
  ConsumerState<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends ConsumerState<AppScreen> {
  int _previousWordCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("AppScreen.didChangeDependencies called");

    try {
      debugPrint("Reading auth state from provider");
      final authState = ref.read(authProvider);
      debugPrint(
          "Auth state: isAuthenticated=${authState.isAuthenticated}, user=${authState.user}");

      // Redirect to login if not authenticated
      if (!authState.isAuthenticated) {
        debugPrint("User is not authenticated, redirecting to login");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            debugPrint("Replacing current route with LoginRoute");
            context.router.replace(const LoginRoute());
          }
        });
      } else {
        debugPrint("User is authenticated, staying on app screen");
      }
    } catch (e) {
      debugPrint("Error in AppScreen.didChangeDependencies: $e");
    }
  }

  void _checkForMilestones(int currentWordCount) {
    if (currentWordCount != _previousWordCount) {
      debugPrint(
          "Word count changed: $currentWordCount (previous: $_previousWordCount)");
      // Check for milestone counts
      if (Constants.toastMessages.containsKey(currentWordCount)) {
        debugPrint("Showing toast for milestone: $currentWordCount");
        Future.microtask(() {
          if (mounted) {
            ToastNotification.show(
              context,
              Constants.toastMessages[currentWordCount]!,
            );
          }
        });
      }
      _previousWordCount = currentWordCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("AppScreen.build called");

    try {
      debugPrint("Reading providers");
      final authState = ref.watch(authProvider);
      debugPrint(
          "Auth state: isAuthenticated=${authState.isAuthenticated}, user=${authState.user}");

      final wordsState = ref.watch(wordsProvider);
      debugPrint(
          "Words state: count=${wordsState.words.length}, isLoading=${wordsState.isLoading}");

      // Check if we need to show a toast notification
      _checkForMilestones(wordsState.words.length);

      final themeMode = ref.watch(themeModeProvider);
      final isDarkMode = themeMode == ThemeMode.dark;
      final colorScheme = Theme.of(context).colorScheme;
      debugPrint("Theme: isDarkMode=$isDarkMode");

      return Scaffold(
        appBar: const _AppScreenAppBar(),
        body: SafeArea(
          child: _GradientBackground(
            isDarkMode: isDarkMode,
            colorScheme: colorScheme,
            child: Column(
              children: [
                // Words list with Expanded to take available space
                Expanded(
                  child: WordList(
                    words: wordsState.words,
                    isLoading: wordsState.isLoading,
                    error: wordsState.error,
                  ),
                ),

                // Word input form at the bottom
                Hero(
                  tag: 'wordInput',
                  child: WordInput(
                    onSubmit: (text) {
                      // Add the word
                      ref.read(wordsProvider.notifier).addWord(text);
                    },
                    isAdding: wordsState.isAdding,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error in AppScreen.build: $e");
      return const Scaffold(
        body: Center(
          child: Text("Error loading app screen"),
        ),
      );
    }
  }
}
