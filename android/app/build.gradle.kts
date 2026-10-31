plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sportik.player"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions { sourceCompatibility = JavaVersion.VERSION_11; targetCompatibility = JavaVersion.VERSION_11 }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }
    defaultConfig { applicationId = "com.sportik.player"; minSdk = 24; targetSdk = flutter.targetSdkVersion; versionCode = flutter.versionCode; versionName = flutter.versionName }
    buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        isMinifyEnabled = false
        isShrinkResources = false
    }
}
flutter { source = "../.." }
