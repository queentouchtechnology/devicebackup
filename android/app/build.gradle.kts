plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // ✅ use the modern plugin name
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase plugin
}

android {
    namespace = "com.example.device_backup_1989"
    compileSdk = flutter.targetSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.device_backup_1989"
        minSdk = 24 // ✅ WorkManager requires 24+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Needed when methods exceed 65k
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // ✅ match Gradle 8.7
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17" // ✅ should match JavaVersion above
    }

    buildTypes {
        release {
            // Shrink resources + obfuscate
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // ⚠️ Replace with your actual keystore later
            signingConfig = signingConfigs.getByName("debug")
        }

        debug {
            isMinifyEnabled = false
        }
    }

    // Build only universal APK (disable splits)
    splits {
        abi {
            isEnable = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase
    implementation("com.google.firebase:firebase-firestore-ktx:25.1.0")
    implementation("com.google.firebase:firebase-auth-ktx:23.1.0")

    // Kotlin coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

    // MultiDex
    implementation("androidx.multidex:multidex:2.0.1")

    // ✅ Required: latest WorkManager runtime
    implementation("androidx.work:work-runtime-ktx:2.9.1")
}
