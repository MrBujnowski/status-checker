// Data model representing a tracked URL and its status code.

class UrlEntry {
  final String id;
  final String url;
  final int? lastStatusCode;

  UrlEntry({
    required this.id,
    required this.url,
    this.lastStatusCode,
  });
}
