import 'package:device_backup_1989/appBackupservice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // only this line
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

  Future<void> testFirebaseSetup() async {
    try {
      // Write dummy data
      await FirebaseFirestore.instance
          .collection('testCollection')
          .doc('testDoc')
          .set({
        'message': 'Hello Firebase!',
        'timestamp': DateTime.now().toIso8601String()
      });
      print("✅ Dummy data written successfully!");

      // Read the same data back
      final snapshot = await FirebaseFirestore.instance
          .collection('testCollection')
          .doc('testDoc')
          .get();

      if (snapshot.exists) {
        print("✅ Dummy data read successfully: ${snapshot.data()}");
      } else {
        print("❌ Document does not exist after writing!");
      }
    } catch (e) {
      print("❌ Firebase setup error: $e");
    }
  }

  Future<String?> getFirebaseUid() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print("🎯 ${user.uid}");
      return user.uid;
    } else {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      print("📍 ${userCredential.user?.uid}");
      return userCredential.user?.uid;
    }
  }

  Future<void> _startBackup() async {
    String? userId = await getFirebaseUid();
    if (userId != null) {
      await testFirebaseSetup(); // Call test
      await Appbackupservice.requestPermissionsAndFetchData(userId);
    } else {
      print("user Id is Null❌");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text("Backup running in background...")),
      ),
    );
  }
}
