import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backup_service.dart';
import 'package:workmanager/workmanager.dart';

void backupDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      user = (await FirebaseAuth.instance.signInAnonymously()).user;
    }

    final userId = user?.uid;
    if (userId != null) {
      await UnifiedBackupService.backupAll(userId);
    }

    return Future.value(true);
  });
}
