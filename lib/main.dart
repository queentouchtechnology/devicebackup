//lib/main.dart

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startCallback() {
    print("🚀 startCallback called, setting TelegramTask handler");
  FlutterForegroundTask.setTaskHandler(TelegramTask());
  print("✅ TelegramTask handler set");
}

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  
  FlutterForegroundTask.init(
  androidNotificationOptions: AndroidNotificationOptions(
    channelId: 'telegram_backup',
    channelName: 'Telegram Backup',
    channelDescription: 'Runs every 2 minutes',
    channelImportance: NotificationChannelImportance.LOW, // <- use this
    priority: NotificationPriority.LOW, 
    showBadge :true
    
  ),
  iosNotificationOptions: const IOSNotificationOptions(),
  foregroundTaskOptions:  ForegroundTaskOptions(
    eventAction: ForegroundTaskEventAction.repeat(120000),
    autoRunOnBoot: true,
    allowWifiLock: true,
  ),
);
runApp(const MyApp());
}




// Task Handler
class TelegramTask extends TaskHandler {

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    // Run immediately
     print("🔥 TelegramTask onStart called at $timestamp");
   await  sendMessage();
   
    
  }


  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isStoppedManually) async {
    print("💀 TelegramTask onDestroy called at $timestamp, stoppedManually=$isStoppedManually");
  }

   @override
  Future<void> onRepeatEvent(DateTime timestamp,) async {
     print("⏰ TelegramTask onRepeatEvent called at $timestamp");
       try {
    await sendMessage();
    print("Task repeated successfully");
  } catch (e) {
    print("Error in onRepeatEvent: $e");
  }
  }

  @override
  void onButtonPressed(String id) {
        print("🔘 Notification button pressed: $id");
  }
  @override
  void onNotificationPressed() {
        print("🔔 Notification clicked");
  }
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
      // Send immediately when app is open
  //sendMessage();
  Future.delayed(const Duration(seconds: 2), () {
    startService();
  });


  }

Future<void> startService()async {
final  ServiceRequestResult result = await FlutterForegroundTask.startService(
  notificationTitle: 'Telegram Backup Running',
  notificationText: 'Sending every 2 minutes...',
  callback: startCallback,
);
   if (result is ServiceRequestSuccess) {
    print("✅ Foreground service started successfully");
  } else if (result is ServiceRequestFailure) {
    print("❌ Failed: ${result.error}");
    // Retry after short delay
    Future.delayed(const Duration(seconds: 5), () {
      print("🔄 Retrying foreground service...");
      startService();
    });
  }
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
        "text": "Hi there! 👋 This message come from Backup App.",
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