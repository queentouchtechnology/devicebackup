//lib/main.dart

import 'package:device_backup_1989/appBackupservice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
      WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
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
    _startBackup();
  }

  Future<String?> getFirebaseUid() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
       print("🎯 ${user.uid}");
      return user.uid; // This is the Firebase UID
    } else {
      // If not signed in, you can sign in anonymously
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
          print("📍 ${userCredential.user?.uid}");
      return userCredential.user?.uid;
    }
  }

  Future<void> _startBackup() async {
    // Replace with Firebase UID after authentication
    String? userId = await getFirebaseUid();
    if (userId != null) {
      await Appbackupservice.requestPermissionsAndFetchData(userId);
     // await BackupService.backupData(userId);
     print(" userID $userId");
    }else{
      print("user Id is Null❌");
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
