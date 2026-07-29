plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.triplog.triplog"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.triplog.triplog"
        // Foreground service types + notification runtime permission need
        // modern APIs; 26 is the floor that still covers ~95% of devices.
        minSdk = maxOf(26, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Stable test-distribution key committed to the repo so every CI
        // build carries the SAME signature — without this, each CI runner
        // generated a fresh debug key and Android refused to install the
        // new APK over the old one (users had to uninstall and lost data).
        // This key is for test builds only; a Play Store release must use
        // its own private keystore.
        create("stable") {
            storeFile = file("ruteku-ci.jks")
            storePassword = "rutekudebug"
            keyAlias = "ruteku"
            keyPassword = "rutekudebug"
        }
    }

    buildTypes {
        getByName("debug") { signingConfig = signingConfigs.getByName("stable") }
        release { signingConfig = signingConfigs.getByName("stable") }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Fused Location Provider + Activity Recognition Transition API.
    implementation("com.google.android.gms:play-services-location:21.3.0")
}
