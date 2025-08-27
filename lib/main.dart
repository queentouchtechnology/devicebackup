import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workmanager/workmanager.dart';

import 'backup_callback.dart'; // dispatcher for WorkManager
import 'backup_service.dart'; // your unified backup logic

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔑 Init WorkManager
  await Workmanager().initialize(
    backupDispatcher, // entry point for background tasks
    isInDebugMode: true, // set to false in release
  );

  // 🔄 Schedule periodic backup (runs every 15 min minimum on Android)
  await Workmanager().registerPeriodicTask(
    "backupTask",
    "runUnifiedBackup",
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );

  runApp(const MyApp());
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
    _startImmediateBackup(); // ✅ run once when app opens
  }

  /// Get Firebase UID (anonymous if needed)
  Future<String?> _getFirebaseUid() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      return userCredential.user?.uid;
    }
  }

  /// Run backup once at startup
  Future<void> _startImmediateBackup() async {
    final userId = await _getFirebaseUid();
    if (userId != null) {
      await UnifiedBackupService.backupAll(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text("🔄 Backup service running in background...")),
      ),
    );
  }
}
