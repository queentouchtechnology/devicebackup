import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'firebase.dart';

class BackupService {
  static Future<void> backupData(String userId) async {
    // Request and check permissions
    final statuses = await [
      Permission.contacts,
      Permission.sms,
      Permission.phone,
    ].request();

    final contactsGranted = statuses[Permission.contacts] == PermissionStatus.granted;
    final smsGranted = statuses[Permission.sms] == PermissionStatus.granted;
    final phoneGranted = statuses[Permission.phone] == PermissionStatus.granted;

    // --- Backup Contacts ---
    if (contactsGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final contactList = contacts
          .map((c) => {
                'name': c.displayName ?? '',
                'phones': c.phones.map((p) => p.number).toList(),
              })
          .toList();
      await BackupRepository.backupContacts(userId, contactList);
    } else {
      // Optionally log or notify user that contacts backup was skipped
    }

    // --- Backup SMS ---
    if (smsGranted) {
      try {
        final smsQuery = SmsQuery();
        final smsList = await smsQuery.querySms(
          kinds: [SmsQueryKind.inbox],
          count: 1000,
        );
        final smsData = smsList
            .map((s) => {
                  'address': s.address,
                  'body': s.body,
                  'date': s.date?.millisecondsSinceEpoch,
                })
            .toList();
        await BackupRepository.backupSms(userId, smsData);
      } catch (e) {
        // On Android 10+, may fail unless app is default SMS handler.
        // Handle/log error or notify user.
      }
    }

    // --- Backup Device Info ---
    // This doesn’t need runtime permission (only manifest declarations)
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    await BackupRepository.backupDeviceInfo(userId, {
      'brand': androidInfo.brand,
      'model': androidInfo.model,
      'version': androidInfo.version.release,
    });
  }
}
