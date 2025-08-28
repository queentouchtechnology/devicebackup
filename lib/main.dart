//lib/main.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';



void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
     final timestamp = DateTime.now();
    print("⏰ WorkManager executed: $task at $timestamp");
    print("⏰ WorkManager task running: $task");
    await sendMessage(); // your Telegram API call
    return Future.value(true);
  });
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // Run every 15 minutes (minimum allowed on Android)
  Workmanager().registerPeriodicTask(
    "telegramBackup",
    "sendTelegramMessage",
    frequency: const Duration(minutes: 15),
  );

    // one-off test (after 5s)
  Workmanager().registerOneOffTask(
    "testBackup",
    "testSend",
    initialDelay: const Duration(seconds: 5),
  );


  runApp(const MyApp());
}


// main App page
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();


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