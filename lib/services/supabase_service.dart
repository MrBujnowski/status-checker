// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/url_entry.dart';
import '../models/user_settings.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- PAGES TABLE OPERATIONS ---

  /// Loads public (shared) pages.
  Future<List<UrlEntry>> loadPublicPages() async {
    try {
      final List<dynamic> result = await _supabase
          .from('pages')
          .select('*')
          .eq('is_public', true);
      return result.map((json) => UrlEntry.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading public pages: $e');
      return [];
    }
  }

  /// Loads pages added by the currently authenticated user.
  Future<List<UrlEntry>> loadUserPages() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final List<dynamic> result = await _supabase
          .from('pages')
          .select('*')
          .eq('user_id', user.id);
      return result.map((json) => UrlEntry.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading user pages: $e');
      return [];
    }
  }

  /// Adds a new page to the database for the authenticated user.
  Future<void> addUserPage(String url, {String? urlName}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('User not logged in, cannot add page.');
      return;
    }

    try {
      await _supabase.from('pages').insert({
        'url': url,
        'url_name': urlName,
        'user_id': user.id,
        'is_public': false,
      });
      print('Page added successfully!');
    } catch (e) {
      print('Error adding page: $e');
    }
  }

  /// Updates an existing page for the authenticated user by its ID.
  Future<void> updateUserPage(String pageId, String newUrl, {String? newUrlName}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('User not logged in, cannot update page.');
      return;
    }

    try {
      await _supabase
          .from('pages')
          .update({
            'url': newUrl,
            'url_name': newUrlName,
          })
          .eq('id', pageId)
          .eq('user_id', user.id);
      print('Page updated successfully!');
    } catch (e) {
      print('Error updating page: $e');
    }
  }


  /// Deletes a specific page for the authenticated user by its ID.
  Future<void> deleteUserPage(String pageId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('User not logged in, cannot delete page.');
      return;
    }

    try {
      await _supabase
          .from('pages')
          .delete()
          .eq('id', pageId)
          .eq('user_id', user.id);
      print('Page deleted successfully!');
    } catch (e) {
      print('Error deleting page: $e');
    }
  }

  // --- USER_SETTINGS TABLE OPERATIONS ---

  /// Loads user settings for the currently authenticated user.
  Future<UserSettings?> loadUserSettings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final List<dynamic> result = await _supabase
          .from('user_settings')
          .select('*')
          .eq('user_id', user.id)
          .limit(1);

      if (result.isNotEmpty) {
        return UserSettings.fromJson(result.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error loading user settings: $e');
      return null;
    }
  }

  /// Upserts (inserts or updates) user settings.
  Future<void> upsertUserSettings({
    String? discordWebhookUrl,
    bool? isAdmin,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('User not logged in, cannot save settings.');
      return;
    }

    try {
      await _supabase.from('user_settings').upsert({
        'user_id': user.id,
        'discord_webhook_url': discordWebhookUrl,
        'is_admin': isAdmin,
      });
      print('User settings saved successfully!');
    } catch (e) {
      print('Error upserting user settings: $e');
    }
  }
}
