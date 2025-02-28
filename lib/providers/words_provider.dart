import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_social/providers/auth_provider.dart';
import '../models/word_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart' as auth;

final wordsServiceProvider = Provider<WordsService>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return WordsService(supabaseClient);
});

final wordsProvider = StateNotifierProvider<WordsNotifier, WordsState>((ref) {
  final wordsService = ref.read(wordsServiceProvider);
  final authState = ref.watch(authProvider);

  return WordsNotifier(wordsService, authState);
});

class WordsNotifier extends StateNotifier<WordsState> {
  final WordsService _wordsService;
  final auth.AuthState _authState;
  RealtimeChannel? _subscription;

  WordsNotifier(this._wordsService, this._authState) : super(WordsState()) {
    if (_authState.isAuthenticated) {
      fetchWords();
      _subscribeToRealtimeUpdates();
    }
  }

  Future<void> fetchWords() async {
    if (!_authState.isAuthenticated) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final words = await _wordsService.getWords(_authState.user!.id);
      state = state.copyWith(words: words);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addWord(String text) async {
    if (!_authState.isAuthenticated || text.trim().isEmpty) return;

    try {
      state = state.copyWith(isAdding: true, error: null);

      // Optimistic update
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final newWord = Word(
        id: tempId,
        text: text,
        userId: _authState.user!.id,
        createdAt: DateTime.now(),
      );

      // Add to local state immediately
      state = state.copyWith(
        words: [...state.words, newWord],
      );

      // Add to database (the real-time subscription will update the list later)
      await _wordsService.addWord(text, _authState.user!.id);
    } catch (e) {
      // Revert optimistic update in case of error
      await fetchWords();
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isAdding: false);
    }
  }

  void _subscribeToRealtimeUpdates() {
    if (!_authState.isAuthenticated) return;

    _subscription = _wordsService.subscribeToWords(
      _authState.user!.id,
      onInsert: (word) {
        // Replace the optimistic entry or add the new word
        final existingIndex = state.words.indexWhere((w) => w.text == word.text);
        if (existingIndex >= 0) {
          final updatedWords = [...state.words];
          updatedWords[existingIndex] = word;
          state = state.copyWith(words: updatedWords);
        } else {
          state = state.copyWith(
            words: [...state.words, word],
          );
        }
      },
    );
  }

  void unsubscribe() {
    _subscription?.unsubscribe();
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}

class WordsState {
  final List<Word> words;
  final bool isLoading;
  final bool isAdding;
  final String? error;

  WordsState({
    this.words = const [],
    this.isLoading = false,
    this.isAdding = false,
    this.error,
  });

  WordsState copyWith({
    List<Word>? words,
    bool? isLoading,
    bool? isAdding,
    String? error,
  }) {
    return WordsState(
      words: words ?? this.words,
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      error: error,
    );
  }
}
