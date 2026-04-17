import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
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

android {
    namespace = "com.alhai.cashier"
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
        applicationId = "com.alhai.cashier"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
            // Release builds MUST be signed with a real keystore.
            // Provide android/key.properties (see key.properties.example).
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
                    "cashier: android/key.properties not found. " +
                    "Release builds require a signing key. " +
                    "See android/key.properties.example for the expected format."
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
        // Debug builds use the auto-generated debug keystore.
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Fix: sqlcipher_flutter_libs & sqlite3_flutter_libs both define
// eu.simonbinder.sqlite3_flutter_libs.Sqlite3FlutterLibsPlugin, causing
// "Type ... is defined multiple times" during dexing. drift_flutter brings
// in sqlite3_flutter_libs as a transitive dependency, but we use
// sqlcipher_flutter_libs (encryption). Substitute the project so only the
// sqlcipher variant is compiled.
configurations.configureEach {
    resolutionStrategy.dependencySubstitution {
        substitute(project(":sqlite3_flutter_libs"))
            .using(project(":sqlcipher_flutter_libs"))
    }
}

flutter {
    source = "../.."
}
