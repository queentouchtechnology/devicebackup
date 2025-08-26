// lib/firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class BackupRepository {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Backup contacts to Firestore
  static Future<void> backupContacts(
    String userId,
    List<Map<String, dynamic>> contacts,
  ) async {
    await _db
        .collection("backups")
        .doc(userId)
        .collection("contacts")
        .doc("all")
        .set({"items": contacts});
  }

  /// Backup SMS to Firestore
  static Future<void> backupSms(
    String userId,
    List<Map<String, dynamic>> sms,
  ) async {
    await _db
        .collection("backups")
        .doc(userId)
        .collection("sms")
        .doc("all")
        .set({"items": sms});
  }

  /// Backup device info to Firestore
  static Future<void> backupDeviceInfo(
    String userId,
    Map<String, dynamic> deviceInfo,
  ) async {
    await _db
        .collection("backups")
        .doc(userId)
        .collection("device")
        .doc("info")
        .set(deviceInfo);
  }
}
