//lib/main.dart

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;



void main() async {
  runApp(const MyApp());

  FlutterForegroundTask.init(
  androidNotificationOptions: AndroidNotificationOptions(
    channelId: 'telegram_backup',
    channelName: 'Telegram Backup',
    channelDescription: 'Runs every 2 minutes',
    channelImportance: NotificationChannelImportance.DEFAULT, // <- use this
  ),
  iosNotificationOptions: const IOSNotificationOptions(),
  foregroundTaskOptions:  ForegroundTaskOptions(
    eventAction: ForegroundTaskEventAction.repeat(120000),
    autoRunOnBoot: true,
    allowWifiLock: true,
  ),
);
}

// Task Handler
class TelegramTask extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    // Run immediately
    sendMessage();
    // Schedule every 2 minutes
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      sendMessage();
    });
  }


  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isStoppedManually) async {
    _timer?.cancel();
  }

   @override
  Future<void> onRepeatEvent(DateTime timestamp,) async {
    // Not used because Timer handles 2 mins interval
  }

  @override
  void onButtonPressed(String id) {}
  @override
  void onNotificationPressed() {}
}


// main App page
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Run immediately
    sendMessage();
    // Schedule every 2 minutes
    timer = Timer.periodic(const Duration(minutes: 2), (_) {
      sendMessage();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    // No UI, just a blank screen
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GestureDetector(onTap: () async{
         await sendMessage();
        },child: Center(child: Text("Backup running in background...")),)

      ),
    );
  }
}

// Task callback
void startCallback() {
  FlutterForegroundTask.setTaskHandler(TelegramTask());
}



// send message Api call
Future<void> sendMessage() async {

  final url = Uri.parse(
    "https://api.telegram.org/bot8193961330:AAH8SzIkjpXifiNgdedIsip5ksIKzkn3CPc/sendMessage",
  );
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

    // Optional: check status code
    if (response.statusCode != 200) {
      print("Failed to send message. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }else{
      print("message send Successfully 📤");
    }
  } catch (e, stackTrace) {
    print("Error sending Telegram message: $e");
    print(stackTrace);
  }
}