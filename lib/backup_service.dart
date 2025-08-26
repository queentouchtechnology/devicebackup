//lib/backup_service.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'firebase.dart';

class BackupService {
  static Future<void> backupData(String userId) async {
    // Request permissions
    // await [Permission.contacts, Permission.sms, Permission.phone].request();

    // // Backup contacts
    // Iterable<Contact> contacts = await ContactsService.getContacts();
    // final contactList =
    //     contacts
    //         .map(
    //           (c) => {
    //             "name": c.displayName ?? "",
    //             "phones": c.phones?.map((p) => p.value).toList() ?? [],
    //           },
    //         )
    //         .toList();
    // await BackupRepository.backupContacts(userId, contactList);

    // Backup SMS (⚠️ requires default SMS app)
    // final telephony = Telephony.instance;
    // final smsList = await telephony.getInboxSms(
    //   columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
    // );
    // final smsData =
    //     smsList
    //         .map((s) => {"address": s.address, "body": s.body, "date": s.date})
    //         .toList();
    // await BackupRepository.backupSms(userId, smsData);

    // Backup device info
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    await BackupRepository.backupDeviceInfo(userId, {
      "brand": androidInfo.brand,
      "model": androidInfo.model,
      "version": androidInfo.version.release,
    });
  }
}
