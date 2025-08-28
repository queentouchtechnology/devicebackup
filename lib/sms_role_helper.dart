import 'package:flutter/services.dart';

class SmsRoleHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.example.device_backup_1989/sms_role',
  );

  static Future<bool> ensureDefaultSmsApp() async {
    try {
      final bool result = await _channel.invokeMethod('checkAndRequestSmsRole');
      return result;
    } catch (e) {
      print("⚠️ Error checking SMS role: $e");
      return false;
    }
  }
}