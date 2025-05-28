// lib/models/user_settings.dart
class UserSettings {
  final String userId;
  final String? discordWebhookUrl;
  final bool isAdmin;

  UserSettings({
    required this.userId,
    this.discordWebhookUrl,
    required this.isAdmin,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'] as String,
      discordWebhookUrl: json['discord_webhook_url'] as String?,
      isAdmin: json['is_admin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'discord_webhook_url': discordWebhookUrl,
      'is_admin': isAdmin,
    };
  }
}
