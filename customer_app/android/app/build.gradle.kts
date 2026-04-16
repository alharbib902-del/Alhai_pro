import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase — requires google-services.json in android/app/
    id("com.google.gms.google-services")
}

// Load signing config from android/key.properties if it exists.
// This file is gitignored and must be provided by the developer/CI for release builds.
// See android/key.properties.example for the expected format.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Google Maps API key is read from a Gradle property (e.g. from ~/.gradle/gradle.properties
// or passed via -PGOOGLE_MAPS_API_KEY=xxx). Never commit the real key to the repo.
val googleMapsApiKey: String = (project.findProperty("GOOGLE_MAPS_API_KEY") as String?) ?: ""

android {
    namespace = "com.alhai.customer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.alhai.customer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Injected into AndroidManifest.xml as ${GOOGLE_MAPS_API_KEY} for
        // com.google.android.geo.API_KEY meta-data.
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use the real release signing config when key.properties is present.
            // Otherwise fall back to debug signing so local `flutter run --release`
            // still works. CI/Play Store builds MUST provide key.properties.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "⚠️  customer_app: android/key.properties not found — " +
                    "release build will be signed with debug keys. " +
                    "Do NOT upload this build to the Play Store."
                )
                signingConfigs.getByName("debug")
            }

            // Enable code shrinking, obfuscation, and optimization
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
