import 'dart:io';
import 'package:device_backup_1989/firebase.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
  ].request();

  bool contactsGranted = statuses[Permission.contacts]?.isGranted ?? false;
  bool smsGranted = statuses[Permission.sms]?.isGranted ?? false;
  bool locationGranted = await Geolocator.isLocationServiceEnabled();

  if (!contactsGranted) {
    print("❌Contacts permission denied");
  }
  if (!smsGranted) {
    print("❌SMS permission denied");
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
   await fetchSms();
  }

   

   await getLocation();
  
}
}






/// contact info
 Future<void> requestAndFetchContacts(String userId) async {
    // 1️⃣ Request permission using permission_handler
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }

    if (!status.isGranted) {
      print("Permission denied to access contacts");
      return;
    }

    // 2️⃣ Permission granted, fetch contacts
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
    Future<void> fetchSms() async {
    // 1️⃣ Request SMS permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }

    if (!status.isGranted) {
      print("❌SMS permission denied");
      return;
    }

    // 2️⃣ Fetch all inbox messages
    List<SmsMessage> messages = await _query.getAllSms;

  
    print("SMS DATA 📩 $messages");
//     _smsList.forEach((sms) {
//   print("${sms.address}: ${sms.body}");
// });
  }



// get Device info
Future<void> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print("Device📍: ${androidInfo.model}");
    print("Manufacturer📍: ${androidInfo.manufacturer}");
    print("Android Version: ${androidInfo.version.release}");
    print("Device ID: ${androidInfo.id}");
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    print("Device: ${iosInfo.name}");
    print("System Name: ${iosInfo.systemName}");
    print("iOS Version: ${iosInfo.systemVersion}");
    print("Device ID: ${iosInfo.identifierForVendor}");
  }
}




// get User Location inro
Future<void> getLocation() async {
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

  print("✅ Latitude: ${position.latitude}");
  print("✅ Longitude: ${position.longitude}");
}
