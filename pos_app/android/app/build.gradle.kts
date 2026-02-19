plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.alhai.pos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.alhai.pos"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Multi-dex support
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Configure release signing before publishing to Play Store
            // 1. Generate keystore: keytool -genkey -v -keystore ~/alhai-pos.jks -keyalg RSA -keysize 2048 -validity 10000 -alias alhai
            // 2. Create key.properties file with storeFile, storePassword, keyAlias, keyPassword
            // 3. Reference signing config here
            signingConfig = signingConfigs.getByName("debug")

            // Enable code shrinking & obfuscation
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
