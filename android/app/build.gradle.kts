import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val releaseSigningKeys = listOf(
    "keyAlias",
    "keyPassword",
    "storeFile",
    "storePassword",
)
val missingReleaseSigningKeys = releaseSigningKeys.filter {
    keystoreProperties.getProperty(it).isNullOrBlank()
}
val hasReleaseSigningConfig =
    keystorePropertiesFile.exists() && missingReleaseSigningKeys.isEmpty()
if (keystorePropertiesFile.exists() && missingReleaseSigningKeys.isNotEmpty()) {
    throw GradleException(
        "android/key.properties 缺少 release 签名字段：${missingReleaseSigningKeys.joinToString()}",
    )
}

android {
    namespace = "moe.magrail.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "moe.magrail.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigningConfig) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigningConfig) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "未找到 android/key.properties，release 构建将临时使用 debug 签名，不适合正式发布",
                )
                signingConfigs.getByName("debug")
            }
        }
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

gradle.projectsEvaluated {
    tasks.named("assembleRelease").configure {
        doLast {
            val outputDirectory = layout.buildDirectory.dir("outputs/flutter-apk").get().asFile
            if (!outputDirectory.exists()) {
                return@doLast
            }

            val releaseVersion = "${flutter.versionName}+${flutter.versionCode}"
            val splitPerAbi =
                project.findProperty("split-per-abi")?.toString()?.toBoolean() == true
            val splitApkPattern =
                Regex("""app-(armeabi-v7a|arm64-v8a|x86_64)-release\.apk""")
            val brandedApkPattern = Regex("""magrail_.*\.apk""", RegexOption.IGNORE_CASE)

            // Flutter 需要保留默认产物名用于构建结果校验，另行生成发布用文件
            outputDirectory
                .listFiles { file ->
                    file.isFile && brandedApkPattern.matches(file.name)
                }.orEmpty()
                .forEach { it.delete() }

            if (splitPerAbi) {
                outputDirectory.listFiles().orEmpty().forEach { sourceFile ->
                    val splitMatch = splitApkPattern.matchEntire(sourceFile.name)
                    if (splitMatch != null) {
                        sourceFile.copyTo(
                            outputDirectory.resolve(
                                "Magrail_${releaseVersion}_${splitMatch.groupValues[1]}.apk",
                            ),
                            overwrite = true,
                        )
                    }
                }
            } else {
                val universalApk = outputDirectory.resolve("app-release.apk")
                if (universalApk.exists()) {
                    universalApk.copyTo(
                        outputDirectory.resolve("Magrail_${releaseVersion}_universal.apk"),
                        overwrite = true,
                    )
                }
            }
        }
    }
}
