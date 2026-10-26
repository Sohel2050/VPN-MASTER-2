import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: reads android/key.properties (see key.properties.example).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.albonik.vpnapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.albonik.vpnapp"
        // Unity LevelPlay SDK 9 needs Android API 24 or higher.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    packaging {
        jniLibs {
            // OpenVPN core runs native binaries from nativeLibraryDir, so the
            // libs must be extracted on install (needed for Play Store AAB installs).
            useLegacyPackaging = true
        }
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Uses key.properties when present, otherwise falls back to the debug key
            // so `flutter run --release` still works on a fresh checkout.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    dependencies {
        // Required by the Unity LevelPlay Flutter plugin.
        // The LevelPlay SDK itself comes with the plugin (no mediation adapters are used).
        implementation("com.google.android.gms:play-services-appset:16.0.2")
        implementation("com.google.android.gms:play-services-ads-identifier:18.0.1")
        implementation("com.google.android.gms:play-services-basement:18.3.0")
        // Newer WireGuard tunnel library: its native libs support 16 KB memory pages.
        implementation("com.wireguard.android:tunnel:1.0.20260102")
    }
}

flutter {
    source = "../.."
}
