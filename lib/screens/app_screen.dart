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
import '../widgets/app_screen_app_bar.dart';
import '../widgets/gradient_background.dart';
import '../constants.dart';

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

    try {
      final authState = ref.read(authProvider);

      // Redirect to login if not authenticated
      if (!authState.isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.router.replace(const LoginRoute());
          }
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _checkForMilestones(int currentWordCount) {
    if (currentWordCount != _previousWordCount) {
      // Check for milestone counts
      if (Constants.toastMessages.containsKey(currentWordCount)) {
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
    try {
      final wordsState = ref.watch(wordsProvider);

      // Check if we need to show a toast notification
      _checkForMilestones(wordsState.words.length);

      final themeMode = ref.watch(themeModeProvider);
      final isDarkMode = themeMode == ThemeMode.dark;
      final colorScheme = Theme.of(context).colorScheme;

      return Scaffold(
        appBar: const AppScreenAppBar(),
        body: SafeArea(
          child: GradientBackground(
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
      return const Scaffold(
        body: Center(
          child: Text("Error loading app screen"),
        ),
      );
    }
  }
}
