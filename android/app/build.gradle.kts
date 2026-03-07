import java.util.Properties
import java.io.FileInputStream

val keyStoreProperties = Properties()
val keyStorePropertiesFile = rootProject.file("key.properties")

if (keyStorePropertiesFile.exists()) {
    keyStoreProperties.load(FileInputStream(keyStorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.shivilo.journalapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 3
        versionName = "1.4"
    }

    signingConfigs {
        if (keyStorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keyStoreProperties["keyAlias"] as String
                keyPassword = keyStoreProperties["keyPassword"] as String
                storeFile = file(keyStoreProperties["storeFile"] as String)
                storePassword = keyStoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            if (keyStorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}


flutter {
    source = "../.."
}
