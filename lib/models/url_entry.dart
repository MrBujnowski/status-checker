class UrlEntry {
  final String id; // UUID from Supabase
  final String? userId;
  final String url;
  final String? urlName;
  final String? webhook;
  final bool isPublic;
  final DateTime createdAt;

  UrlEntry({
    required this.id,
    this.userId,
    required this.url,
    this.urlName,
    this.webhook,
    required this.isPublic,
    required this.createdAt,
  });

  factory UrlEntry.fromJson(Map<String, dynamic> json) {
    return UrlEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      url: json['url'] as String,
      urlName: json['url_name'] as String?,
      webhook: json['webhook'] as String?,
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'url': url,
      'url_name': urlName,
      'webhook': webhook,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
