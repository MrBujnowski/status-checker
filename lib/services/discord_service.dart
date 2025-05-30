// lib/services/discord_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class DiscordService {
  String? _lastCode;

  Future<bool> sendVerificationCode(String webhookUrl) async {
    final code = (1000 + Random().nextInt(9000)).toString();
    _lastCode = code;

    final response = await http.post(
      Uri.parse(webhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': 'Your Narrativva Labs Status Checker verification code: **$code**'}),
    );

    return response.statusCode == 204 || response.statusCode == 200;
  }

  bool verifyCode(String entered) => entered == _lastCode;
}
