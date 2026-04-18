import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase (Google Services) plugin applied conditionally below — requires
    // android/app/google-services.json. See `if (googleServicesFile.exists())`.
}

// Apply Firebase/Google Services plugin only if google-services.json is present.
// Rationale: lets `flutter build apk --debug` succeed on fresh checkouts that
// haven't yet run `flutterfire configure`. Push notifications will NOT work at
// runtime without the file — the warning below makes that explicit.
//
// To enable FCM:
//   1. Create a Firebase project
//   2. `dart pub global activate flutterfire_cli`
//   3. `flutterfire configure --project=<firebase-project-id>`
//      → generates android/app/google-services.json + ios/Runner/GoogleService-Info.plist
//        + lib/firebase_options.dart
val googleServicesFile = file("google-services.json")
if (googleServicesFile.exists()) {
    apply(plugin = "com.google.gms.google-services")
} else {
    logger.warn(
        "⚠️  customer_app: android/app/google-services.json not found — " +
            "Firebase plugin skipped. FCM / push notifications will not work " +
            "at runtime until the file is generated via `flutterfire configure`."
    )
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
            // Only fail configuration when actually building a release artifact;
            // evaluating this closure for debug tasks (e.g. assembleDebug) must not throw.
            val isBuildingRelease = gradle.startParameter.taskNames.any { name ->
                name.contains("Release", ignoreCase = true) ||
                name.contains("Bundle", ignoreCase = true) ||
                name.endsWith(":assemble") ||
                name == "assemble"
            }
            if (isBuildingRelease && !hasReleaseKeystore) {
                throw GradleException(
                    "Release build requires android/key.properties with upload keystore. " +
                    "See docs/android-release.md."
                )
            }
            signingConfig = if (hasReleaseKeystore)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")

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
