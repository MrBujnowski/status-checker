// Handles sending and verifying magic links via Supabase Auth.

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

class MagicLinkService {
  Future<void> sendMagicLink(String email) async {
    // TODO: Send magic link email using Supabase
  }

  Future<void> handleMagicLink(String uri) async {
    // TODO: Handle redirect and login from magic link
  }
}
