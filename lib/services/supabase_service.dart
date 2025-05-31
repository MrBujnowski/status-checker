// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/url_entry.dart';
import '../models/user_settings.dart';
import '../models/page_status.dart';

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

  /// Vrátí statusy za posledních 30 dní (UTC nebo Prague)
  Future<List<PageStatus>> loadPageDailyStatuses(String pageId, {String timezone = 'UTC'}) async {
    try {
      final List<dynamic> result = await _supabase
          .from('page_daily_status')
          .select('status, day, timezone')
          .eq('page_id', pageId)
          .eq('timezone', timezone)
          .order('day', ascending: false)
          .limit(30);

      return result.map((json) => PageStatus.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading daily statuses: $e');
      return [];
    }
  }

  /// Vrátí poslední status (dnešní den) pro konkrétní stránku a zónu
  Future<PageStatus?> loadPageLatestStatus(String pageId, {String timezone = 'UTC'}) async {
    try {
      // Zjisti začátek a konec dne v požadovaném časovém pásmu
      DateTime now = DateTime.now().toUtc();
      DateTime startOfDay;
      DateTime endOfDay;

      if (timezone == 'Europe/Prague') {
        // Najdi dnesní půlnoc v Praze v UTC (i při letním/zimním čase)
        final localNow = DateTime.now();
        startOfDay = DateTime(localNow.year, localNow.month, localNow.day).toUtc().subtract(localNow.timeZoneOffset);
        endOfDay = startOfDay.add(const Duration(hours: 24));
      } else {
        // UTC midnight to midnight
        startOfDay = DateTime.utc(now.year, now.month, now.day);
        endOfDay = startOfDay.add(const Duration(hours: 24));
      }

      // Filtrování logů podle období
      final String startIso = DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(startOfDay);
      final String endIso = DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(endOfDay);

      final List<dynamic> result = await _supabase
          .from('pages_logs')
          .select('checked_at, error')
          .eq('page_id', pageId)
          .gte('checked_at', startIso)
          .lt('checked_at', endIso);

      int errorCount = 0;
      if (result.isNotEmpty) {
        for (var log in result) {
          if (log['error'] != null && (log['error'] as String).isNotEmpty) {
            errorCount++;
          }
        }
      }

      String status = "grey";
      if (result.isNotEmpty) {
        if (errorCount >= 12) {
          status = "red";
        } else if (errorCount > 0) {
          status = "orange";
        } else {
          status = "green";
        }
      }

      final String dayStr = DateFormat("yyyy-MM-dd").format(startOfDay.toLocal());
      return PageStatus(
        status: status,
        day: dayStr,
        timezone: timezone,
      );
    } catch (e) {
      print('Error loading latest status from logs: $e');
      return null;
    }
  }
}
