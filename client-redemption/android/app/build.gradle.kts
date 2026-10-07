plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

val ciAbiFilters = providers.gradleProperty("otclient.android.abis")
    .orElse(providers.environmentVariable("OTCLIENT_ANDROID_ABIS"))
    .orNull
    ?.split(",")
    ?.map { it.trim() }
    ?.filter { it.isNotEmpty() }
    ?: listOf("arm64-v8a", "armeabi-v7a", "x86_64", "x86")

android {
    namespace = "com.github.otclient"
    compileSdk = 36

    defaultConfig {
        // Development builds install as their own app; staging/production get their own ids later.
        applicationId = System.getenv("POKEVERSE_ANDROID_APP_ID") ?: "com.pokeverse.client.dev"
        minSdk = 21
        targetSdk = 36
        // CI passes the run number so each build installs over the previous one.
        versionCode = (System.getenv("POKEVERSE_VERSION_CODE") ?: "1").toInt()
        versionName = System.getenv("POKEVERSE_VERSION_NAME") ?: "0.0.0-dev"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        ndk {
            abiFilters += ciAbiFilters
        }

        externalNativeBuild {
            cmake {
                cppFlags += listOf("-std=c++20")

                arguments += listOf(
                    "-DVCPKG_TARGET_ANDROID=ON",
                    "-DANDROID_STL=c++_shared",
                    "-DVCPKG_MANIFEST_INSTALL=ON",
                    "-DVCPKG_INSTALL_OPTIONS=--allow-unsupported"
                )
            }
        }
    }

    signingConfigs {
        create("release") {
            // Use env vars for custom release signing; otherwise use Gradle's debug signing config
            storeFile = file(System.getenv("RELEASE_KEYSTORE")
                ?: System.getProperty("user.home") + "/.android/debug.keystore")
            storePassword = System.getenv("RELEASE_KEYSTORE_PASSWORD") ?: "android"
            keyAlias = System.getenv("RELEASE_KEY_ALIAS") ?: "androiddebugkey"
            keyPassword = System.getenv("RELEASE_KEY_PASSWORD") ?: "android"
        }
    }

    externalNativeBuild {
        cmake {
            path = file("../../CMakeLists.txt")
            version = "3.22.1"
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName(
                if (System.getenv("RELEASE_KEYSTORE") == null) "debug" else "release"
            )
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                file("proguard-rules.pro")
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        viewBinding = true
        prefab = true
    }

    ndkVersion = "29.0.13599879"
}

dependencies {
    implementation("androidx.core:core-ktx:1.17.0")
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.games:games-activity:1.2.1")
    implementation("com.google.android.material:material:1.13.0")
}
