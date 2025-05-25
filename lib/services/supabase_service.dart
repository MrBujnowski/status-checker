// supabase_service.dart
// WebAssembly-safe: Communicates with Supabase for public and user-specific page management.

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Loads public (shared) pages.
  Future<List<String>> loadPublicPages() async {
    final result = await _supabase
        .from('pages')
        .select('url')
        .eq('is_public', true);

    if (result is List) {
      return result.map((e) => e['url'] as String).toList();
    } else {
      return [];
    }
  }

  /// Loads pages added by the currently authenticated user.
  Future<List<String>> loadUserPages() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final result = await _supabase
        .from('pages')
        .select('url')
        .eq('user_id', user.id);

    if (result is List) {
      return result.map((e) => e['url'] as String).toList();
    } else {
      return [];
    }
  }

  /// Adds a new page to the database for the authenticated user.
  Future<void> addUserPage(String url) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('pages').insert({
      'url': url,
      'user_id': user.id,
      'is_public': false,
    });
  }

  /// Deletes a specific page for the authenticated user.
  Future<void> deleteUserPage(String url) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('pages')
        .delete()
        .eq('url', url)
        .eq('user_id', user.id);
  }
}
