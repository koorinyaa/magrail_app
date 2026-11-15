import java.io.File
import java.io.FileInputStream
import java.security.KeyStore
import java.security.MessageDigest
import java.util.Properties
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import java.util.zip.ZipOutputStream

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

val releaseAbis = listOf("armeabi-v7a", "arm64-v8a", "x86_64")
val legacyApkSignature =
    Regex("""META-INF/(MANIFEST\.MF|[^/]+\.(SF|RSA|DSA|EC)|SIG-[^/]+)""", RegexOption.IGNORE_CASE)
val releaseBuildTools = androidComponents.sdkComponents.sdkDirectory.map {
    it.asFile.resolve("build-tools/${android.buildToolsVersion}")
}
val releaseJava = File(
    System.getProperty("java.home"),
    if (System.getProperty("os.name").startsWith("Windows")) "bin/java.exe" else "bin/java",
)

// 使用 JDK 执行签名工具，密码通过子进程环境传入，避免出现在命令行中
fun runReleaseTool(command: List<String>, extraEnvironment: Map<String, String> = emptyMap()): String {
    val process = ProcessBuilder(command).redirectErrorStream(true).apply {
        environment().putAll(extraEnvironment)
    }.start()
    val output = process.inputStream.bufferedReader(Charsets.UTF_8).use { it.readText() }
    if (process.waitFor() != 0) {
        throw GradleException("Android 发布工具执行失败：\n${output.takeLast(4000)}")
    }
    return output
}

// 逐条校验保留文件的字节，保证分架构处理不改变 Dart 代码、引擎或资源
fun releaseEntryHash(zip: ZipFile, entry: ZipEntry): String {
    val digest = MessageDigest.getInstance("SHA-256")
    zip.getInputStream(entry).use { input ->
        val buffer = ByteArray(64 * 1024)
        var count = input.read(buffer)
        while (count != -1) {
            digest.update(buffer, 0, count)
            count = input.read(buffer)
        }
    }
    return digest.digest().joinToString("") { "%02x".format(it) }
}

val checkReleasePackaging = tasks.register("checkReleasePackaging") {
    group = "distribution"
    description = "检查分架构发布所需的正式密钥与 Android 工具，不构建应用"
    doLast {
        if (!hasReleaseSigningConfig) {
            throw GradleException("分架构发布必须配置 android/key.properties，禁止使用 debug 签名")
        }
        val signingFile = file(keystoreProperties.getProperty("storeFile"))
        if (!signingFile.isFile) {
            throw GradleException("正式 keystore 不存在，请核对 android/key.properties")
        }
        val keyStore = KeyStore.getInstance(
            signingFile,
            keystoreProperties.getProperty("storePassword").toCharArray(),
        )
        if (!keyStore.isKeyEntry(keystoreProperties.getProperty("keyAlias"))) {
            throw GradleException("正式 keystore 中不存在配置的签名私钥")
        }
        val tools = releaseBuildTools.get()
        val suffix = if (System.getProperty("os.name").startsWith("Windows")) ".exe" else ""
        listOf(tools.resolve("zipalign$suffix"), tools.resolve("aapt2$suffix"),
            tools.resolve("lib/apksigner.jar"), releaseJava).forEach {
            if (!it.isFile) throw GradleException("缺少 Android 发布工具：${it.name}")
        }
    }
}

tasks.register("packageReleaseAbis") {
    group = "distribution"
    description = "将现有 Shorebird APK 打包为正式签名的 ARM32、ARM64 和 x86_64 独立安装包"
    dependsOn(checkReleasePackaging)
    doLast {
        val version = providers.gradleProperty("magrail-release-version").orNull
        if (version == null || !Regex("""\d+\.\d+\.\d+\+[1-9]\d*""").matches(version)) {
            throw GradleException("请使用 dart tool/release.dart package-android 指定发布版本")
        }
        val (versionName, versionCode) = version.split('+')
        val outputDirectory = layout.buildDirectory.dir("outputs/flutter-apk").get().asFile
        val sourceFile = outputDirectory.resolve("app-release.apk")
        val bundleFile = layout.buildDirectory.file("outputs/bundle/release/app-release.aab").get().asFile
        if (!sourceFile.isFile || !bundleFile.isFile) {
            throw GradleException("缺少本次 Shorebird APK 或 AAB，请保留成功发布时的完整构建产物")
        }
        val tools = releaseBuildTools.get()
        val suffix = if (System.getProperty("os.name").startsWith("Windows")) ".exe" else ""
        val signer = listOf(releaseJava.path, "-jar", tools.resolve("lib/apksigner.jar").path)
        val aligner = tools.resolve("zipalign$suffix").path
        val aapt = tools.resolve("aapt2$suffix").path
        val keyAlias = keystoreProperties.getProperty("keyAlias")
        val signingFile = file(keystoreProperties.getProperty("storeFile"))
        val keyStore = KeyStore.getInstance(
            signingFile,
            keystoreProperties.getProperty("storePassword").toCharArray(),
        )
        val certificateHash = MessageDigest.getInstance("SHA-256")
            .digest(keyStore.getCertificate(keyAlias).encoded)
            .joinToString("") { "%02x".format(it) }
        val signingEnvironment = mapOf(
            "MAGRAIL_APK_STORE_PASSWORD" to keystoreProperties.getProperty("storePassword"),
            "MAGRAIL_APK_KEY_PASSWORD" to keystoreProperties.getProperty("keyPassword"),
        )
        val packagePattern = Regex("""(?m)^package: name='moe\.magrail\.app' versionCode='$versionCode' versionName='${Regex.escape(versionName)}'(?: |$)""")
        fun verifyApk(apk: File) {
            if (!packagePattern.containsMatchIn(runReleaseTool(listOf(aapt, "dump", "badging", apk.path)))) {
                throw GradleException("APK 应用 ID 或版本与 $version 不符：${apk.name}")
            }
            val certificates = runReleaseTool(signer + listOf("verify", "--print-certs", apk.path))
            val fingerprints = Regex("""(?m)^Signer #\d+ certificate SHA-256 digest: ([0-9a-fA-F]+)\s*$""")
                .findAll(certificates).map { it.groupValues[1].lowercase() }.toList()
            if (fingerprints != listOf(certificateHash)) {
                throw GradleException("APK 未使用配置的唯一正式签名：${apk.name}")
            }
        }
        verifyApk(sourceFile)
        ZipFile(sourceFile).use { source ->
            val entries = source.entries().asSequence().toList()
            if (entries.map { it.name }.toSet().size != entries.size) {
                throw GradleException("来源 APK 含重复文件，停止分架构打包")
            }
            val shorebirdPath = "assets/flutter_assets/shorebird.yaml"
            val shorebirdEntry = source.getEntry(shorebirdPath)
                ?: throw GradleException("来源 APK 缺少 Shorebird 配置")
            val appIdPattern = Regex("""(?m)^app_id:\s*(\S+)\s*$""")
            val expectedAppId = appIdPattern.find(rootProject.file("../shorebird.yaml").readText())?.groupValues?.get(1)
            val config = source.getInputStream(shorebirdEntry).bufferedReader().use { it.readText() }
            if (expectedAppId == null || appIdPattern.find(config)?.groupValues?.get(1) != expectedAppId ||
                !Regex("""(?m)^patch_public_key:\s*\S+""").containsMatchIn(config)) {
                throw GradleException("来源 APK 的 Shorebird 应用或补丁公钥无效")
            }
            ZipFile(bundleFile).use { bundle ->
                val bundleConfig = bundle.getEntry("base/$shorebirdPath")
                    ?: throw GradleException("AAB 缺少 Shorebird 配置")
                if (releaseEntryHash(source, shorebirdEntry) != releaseEntryHash(bundle, bundleConfig)) {
                    throw GradleException("APK 与 AAB 的 Shorebird 配置不一致")
                }
                releaseAbis.forEach { abi ->
                    listOf("libapp.so", "libflutter.so").forEach { library ->
                        val path = "lib/$abi/$library"
                        val apkEntry = source.getEntry(path) ?: throw GradleException("APK 缺少 $path")
                        val aabEntry = bundle.getEntry("base/$path") ?: throw GradleException("AAB 缺少 $path")
                        if (releaseEntryHash(source, apkEntry) != releaseEntryHash(bundle, aabEntry)) {
                            throw GradleException("APK 与 AAB 的 $path 不一致，不能作为同一基础版本分发")
                        }
                    }
                }
            }
            val sourceHashes = entries.filterNot { it.isDirectory || legacyApkSignature.matches(it.name) }
                .associate { it.name to releaseEntryHash(source, it) }
            val packagedFiles = releaseAbis.map { abi ->
                // 临时产物保留在 build 下，失败时不会留下冒充成功的新发布文件
                val workingDirectory = temporaryDir.resolve(version).resolve(abi).apply { mkdirs() }
                val unsigned = workingDirectory.resolve("unsigned.apk")
                val aligned = workingDirectory.resolve("aligned.apk")
                val signed = workingDirectory.resolve("signed.apk")
                val retained = entries.filter { entry ->
                    !legacyApkSignature.matches(entry.name) &&
                        (!entry.name.startsWith("lib/") || entry.name == "lib/" ||
                            entry.name.startsWith("lib/$abi/"))
                }
                ZipOutputStream(unsigned.outputStream().buffered()).use { output ->
                    retained.forEach { entry ->
                        val copy = ZipEntry(entry.name).apply {
                            time = entry.time
                            method = entry.method
                            if (method == ZipEntry.STORED) {
                                size = entry.size
                                compressedSize = entry.size
                                crc = entry.crc
                            }
                        }
                        output.putNextEntry(copy)
                        if (!entry.isDirectory) source.getInputStream(entry).use { it.copyTo(output) }
                        output.closeEntry()
                    }
                }
                runReleaseTool(listOf(aligner, "-f", "-P", "16", "4", unsigned.path, aligned.path))
                runReleaseTool(signer + listOf(
                    "sign", "--ks", signingFile.path, "--ks-key-alias", keyAlias,
                    "--ks-pass", "env:MAGRAIL_APK_STORE_PASSWORD", "--key-pass", "env:MAGRAIL_APK_KEY_PASSWORD",
                    "--out", signed.path, aligned.path,
                ), signingEnvironment)
                verifyApk(signed)
                runReleaseTool(listOf(aligner, "-c", "-P", "16", "4", signed.path))
                ZipFile(signed).use { packaged ->
                    val actual = packaged.entries().asSequence()
                        .filterNot { it.isDirectory || legacyApkSignature.matches(it.name) }
                        .associate { it.name to releaseEntryHash(packaged, it) }
                    val expected = retained.filterNot { it.isDirectory }.associate { it.name to sourceHashes.getValue(it.name) }
                    if (actual != expected) throw GradleException("$abi 打包后文件内容不一致")
                }
                signed to outputDirectory.resolve("Magrail_${version}_$abi.apk")
            }
            // 三种架构全部通过校验后再输出固定发布文件名
            packagedFiles.forEach { (source, target) ->
                source.copyTo(target, overwrite = true)
                val hash = MessageDigest.getInstance("SHA-256").digest(target.readBytes())
                    .joinToString("") { "%02x".format(it) }
                logger.lifecycle("发布文件：${target.absolutePath}\nSHA-256：$hash")
            }
        }
    }
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
