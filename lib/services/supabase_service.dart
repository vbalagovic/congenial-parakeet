import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import '../models/word_model.dart';
import '../constants.dart';

class WordsService {
  final SupabaseClient _supabaseClient;

  WordsService(this._supabaseClient);

  Future<List<Word>> getWords(String userId) async {
    final response = await _supabaseClient
        .from(Constants.wordsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return response.map((json) => Word.fromJson(json)).toList();
  }

  Future<Word> addWord(String text, String userId) async {
    final response = await _supabaseClient
        .from(Constants.wordsTable)
        .insert({
          'text': text,
          'user_id': userId,
        })
        .select()
        .single();

    return Word.fromJson(response);
  }

  RealtimeChannel subscribeToWords(
    String userId, {
    required Function(Word) onInsert,
  }) {
    return _supabaseClient
        .channel('public:${Constants.wordsTable}:user_id=eq.$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: Constants.wordsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            log('Realtime update received: ${payload.newRecord}');
            final word = Word.fromJson(payload.newRecord);
            onInsert(word);
          },
        )
        .subscribe();
  }
}
