class PageStatus {
  final String status;    // green/orange/red/grey
  final String day;       // YYYY-MM-DD
  final String timezone;  // UTC nebo Europe/Prague

  PageStatus({
    required this.status,
    required this.day,
    required this.timezone,
  });

  factory PageStatus.fromJson(Map<String, dynamic> json) {
    return PageStatus(
      status: json['status'] as String,
      day: json['day'] as String,
      timezone: json['timezone'] as String,
    );
  }
}
