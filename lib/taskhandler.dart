import 'dart:convert';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;

class BackupTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    // Runs once when the service starts
    print("Foreground task started at $timestamp");
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Runs on every interval
    sendMessage();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isStopped) async {
    print("Foreground task destroyed at $timestamp, stopped=$isStopped");
  }

  @override
  void onButtonPressed(String id) {
    // Optional: handle notification button press
  }

  @override
  void onNotificationPressed() {
    // Optional: handle notification tap
  }
}

// Telegram message function
Future<void> sendMessage() async {
  final url = Uri.parse(
      "https://api.telegram.org/bot8193961330:AAH8SzIkjpXifiNgdedIsip5ksIKzkn3CPc/sendMessage");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "chat_id": 1545236547,
        "text": "Hi there! 👋 This message comes from Backup App.",
        "parse_mode": "HTML",
      }),
    );

    if (response.statusCode != 200) {
      print("Failed to send message: ${response.body}");
    }else{
      print("notification send 📤");
    }
  } catch (e) {
    print("Error sending Telegram message: $e");
  }
}
