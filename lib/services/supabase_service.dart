// Communicates with Supabase for database and authentication operations.

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

class SupabaseService {
  Future<void> addUrl(String url) async {
    // TODO: Store new URL in Supabase
  }

  Future<void> removeUrl(String urlId) async {
    // TODO: Remove URL from Supabase
  }

  Future<void> incrementCheckCount() async {
    // TODO: Record that a check was performed (without storing the result)
  }

  Future<void> saveDiscordWebhook(String url) async {
    // TODO: Save Discord webhook URL to user settings
  }
}
