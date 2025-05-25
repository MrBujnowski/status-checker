// Communicates with Supabase for database and authentication operations.

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Load public pages (shared demo content)
  Future<List<String>> loadPublicPages() async {
  final response = await supabase
      .from('pages')
      .select('url')
      .eq('is_public', true);

  if (response == null) return [];
  
  final data = response as List<dynamic>;
  return data.map((e) => e['url'] as String).toList();
}


  // Load user's own tracked pages
  Future<List<String>> loadUserPages() async {
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  final response = await supabase
      .from('pages')
      .select('url')
      .eq('user_id', user.id);

  if (response == null) return [];

  final data = response as List<dynamic>;
  return data.map((e) => e['url'] as String).toList();
}

}
