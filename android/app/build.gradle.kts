//android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ fixed style
}

android {
    namespace = "com.example.device_backup_1989"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // <-- manually override

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.device_backup_1989"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.firebase:firebase-firestore-ktx:24.6.0")
    implementation("com.google.firebase:firebase-auth-ktx:22.1.0") // optional
    coreLibraryDesugaring ("com.android.tools:desugar_jdk_libs:2.1.4")
}
