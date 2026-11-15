import 'dart:io';

const _operations = {
  'prepare',
  'package-android',
  'check-release',
  'release',
  'check-patch',
  'patch',
};
const _usage = '''
用法：
  dart tool/release.dart prepare
  dart tool/release.dart package-android
  dart tool/release.dart check-release android|ios
  dart tool/release.dart release android|ios
  dart tool/release.dart check-patch android|ios --release-version=1.3.1+4006
  dart tool/release.dart patch android|ios --release-version=1.3.1+4006

prepare 仅同步内容版本，不构建或上传
package-android 仅将现有 Shorebird APK 打包为三个正式签名的分架构包
check-release 和 check-patch 仅构建预检查，不上传
release 上传基础版本，Android 成功后自动生成分架构包
patch 仅上传 staging 测试通道
''';

/// 从项目版本生成内容版本，并统一调用整包或测试补丁发布命令
///
/// [arguments] 操作、目标平台及补丁基础版本，支持 --help 查看用法
Future<void> main(List<String> arguments) async {
  try {
    if (arguments.length == 1 && arguments.single == '--help') {
      stdout.write(_usage);
      return;
    }
    if (arguments.isEmpty || !_operations.contains(arguments.first)) {
      throw const FormatException('请指定有效操作');
    }

    final operation = arguments.first;
    final prepareOnly = operation == 'prepare';
    final packageOnly = operation == 'package-android';
    final isPatch = operation == 'patch' || operation == 'check-patch';
    final expectedLength = prepareOnly || packageOnly ? 1 : (isPatch ? 3 : 2);
    if (arguments.length != expectedLength) {
      throw const FormatException('命令参数数量不正确');
    }
    final platform = prepareOnly ? null : (packageOnly ? 'android' : arguments[1]);
    if (!prepareOnly && platform != 'android' && platform != 'ios') {
      throw const FormatException('平台仅支持 android 或 ios');
    }

    String? releaseVersion;
    if (isPatch) {
      final match = RegExp(
        r'^--release-version=(\d+\.\d+\.\d+\+[1-9]\d*)$',
      ).firstMatch(arguments[2]);
      if (match == null) {
        throw const FormatException('补丁必须指定完整基础版本，例如 --release-version=1.3.1+4006');
      }
      releaseVersion = match.group(1)!;
    }
    if (platform == 'ios' && !Platform.isMacOS) {
      throw const FormatException('iOS 构建须在 macOS 或对应 GitHub Actions 中执行');
    }

    // 按脚本位置定位项目，避免从其他目录执行时修改无关文件
    final root = File.fromUri(Platform.script).parent.parent;
    final packageFile = File.fromUri(root.uri.resolve('pubspec.yaml'));
    final version = _readVersion(packageFile);
    if (!prepareOnly &&
        !File.fromUri(root.uri.resolve('shorebird.yaml')).existsSync()) {
      throw const FormatException('缺少 shorebird.yaml，请先在项目目录执行 shorebird init');
    }

    if (!packageOnly) _writeContentVersion(root, version.split('+').first);
    stdout.writeln('项目版本：$version');
    if (prepareOnly) return;
    if (platform == 'android' && !isPatch) {
      exitCode = await _runAndroidTask(
        root,
        version,
        packageOnly ? 'packageReleaseAbis' : 'checkReleasePackaging',
      );
      if (packageOnly || exitCode != 0) return;
    }

    final command = <String>[
      isPatch ? 'patch' : 'release',
      platform!,
      if (isPatch) ...[
        '--release-version=$releaseVersion',
        '--track=staging',
      ] else ...[
        if (platform == 'android') ...['--artifact', 'apk'],
        '--flutter-version=3.47.9',
      ],
      if (platform == 'ios') '--no-codesign',
      '--no-tree-shake-icons',
      if (operation.startsWith('check-')) '--dry-run',
    ];
    stdout.writeln('执行：shorebird ${command.join(' ')}');
    // 保留终端输入输出与退出码，正式上传仍由 Shorebird 显示目标并确认
    final process = await Process.start(
      Platform.isWindows ? 'shorebird.bat' : 'shorebird',
      command,
      workingDirectory: root.path,
      mode: ProcessStartMode.inheritStdio,
      runInShell: Platform.isWindows,
    );
    exitCode = await process.exitCode;
    if (exitCode == 0 && operation == 'release' && platform == 'android') {
      exitCode = await _runAndroidTask(root, version, 'packageReleaseAbis');
      if (exitCode != 0) {
        stderr.writeln(
          'Shorebird 基础版本已上传，但分架构打包失败；保留本次 APK 和 AAB，'
          '修复后执行 dart tool/release.dart package-android，不要重复上传同一基础版本',
        );
      }
    }
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.write(_usage);
    exitCode = 64;
  } on ProcessException catch (error) {
    stderr.writeln('无法启动发布工具：${error.message}，请核对 Shorebird、JDK 和 Gradle 环境');
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('无法读取项目或生成内容版本：${error.message}');
    exitCode = 1;
  }
}

/// 调用仅检查签名工具或处理现有 APK 的 Gradle 任务，不编译应用
///
/// [root] 项目根目录
/// [version] 本次发布的完整版本，用于核对来源 APK
/// [task] 签名工具检查或分架构打包任务名
Future<int> _runAndroidTask(Directory root, String version, String task) async {
  stdout.writeln('执行 Android 发布任务：$task');
  final process = await Process.start(
    Platform.isWindows ? 'gradlew.bat' : './gradlew',
    [':app:$task', '-Pmagrail-release-version=$version', '--console=plain'],
    workingDirectory: Directory.fromUri(root.uri.resolve('android/')).path,
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  return await process.exitCode;
}

/// 读取标准三段版本名和正整数构建号，拒绝缺失或重复版本声明
///
/// [file] 项目根目录的 pubspec.yaml
String _readVersion(File file) {
  final declarations = RegExp(
    r'^version\s*:\s*(.*?)\s*$',
    multiLine: true,
  ).allMatches(file.readAsStringSync());
  if (declarations.length != 1) {
    throw const FormatException('pubspec.yaml 必须且只能声明一个 version');
  }
  final value = declarations.single.group(1)!.split('#').first.trim();
  var version = value;
  if (value.startsWith("'") || value.startsWith('"')) {
    if (value.length < 2 || !value.endsWith(value[0])) {
      throw const FormatException('version 的引号必须成对');
    }
    version = value.substring(1, value.length - 1);
  }
  if (!RegExp(r'^\d+\.\d+\.\d+\+[1-9]\d*$').hasMatch(version)) {
    throw const FormatException('version 必须使用 1.3.1+4006 形式，构建号须为正整数');
  }
  return version;
}

/// 生成参与 Dart 补丁的内容版本，仅在内容变化时写入
///
/// [root] 项目根目录
/// [version] 不含构建号的版本名
void _writeContentVersion(Directory root, String version) {
  final file = File.fromUri(
    root.uri.resolve('lib/core/update/app_content_version.dart'),
  );
  final source = '// 由 tool/release.dart 根据 pubspec.yaml 自动生成，请勿手动修改\n'
      '\n'
      '/// 当前运行代码提供的完整内容版本，与对应 GitHub Release 标签保持一致\n'
      "const appContentVersion = '$version';\n";
  if (!file.existsSync() || file.readAsStringSync() != source) {
    file.writeAsStringSync(source);
    stdout.writeln('已同步内容版本：$version');
  }
}
