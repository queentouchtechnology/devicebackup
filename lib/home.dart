import 'package:device_backup_1989/appBackupservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'backup_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver  {

  bool isLoading = true;

@override
void initState(){
_startBackup();
  getDeviceInfo();
  super.initState();
  WidgetsBinding.instance.addObserver(this);

}


 Future<void> _startBackup() async {
    // Replace with Firebase UID after authentication
    String? userId = await getFirebaseUid();
    if (userId != null) {
      await Appbackupservice.requestPermissionsAndFetchData(userId);
      await BackupService.backupData(userId);
    }
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








 @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 👇 User returned from settings, check location again
      getLocation();
    }
  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: Text("Backup running in background...")),
      );
  }
}
