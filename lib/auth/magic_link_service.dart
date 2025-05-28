// lib/auth/magic_link_service.dart
// Handles sending and verifying magic links via Supabase Auth.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:status_checker/constants.dart';

class MagicLinkService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String?> sendMagicLink(String email) async {
    try {
      await supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kEmailRedirectUrl,
      );
      return null; // success
    } catch (e) {
      return 'Chyba přihlášení: ${e.toString()}';
    }
  }
}
