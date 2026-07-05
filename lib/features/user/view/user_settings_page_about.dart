part of 'user_settings_page.dart';

/// 关于二级页面
class _AboutPage extends StatefulWidget {
  /// 创建关于二级页面
  ///
  /// [updateController] 应用更新控制器
  const _AboutPage({
    required this.updateController,
  });

  /// 应用更新控制器
  final AppUpdateController updateController;

  /// 创建关于二级页面状态
  @override
  State<_AboutPage> createState() => _AboutPageState();
}

/// 关于二级页面状态
class _AboutPageState extends State<_AboutPage> {
  late final Future<PackageInfo> _packageInfoFuture;
  bool _isCheckingUpdate = false;
  int _appIconTapCount = 0;
  double _appIconTurns = 0;

  /// 初始化关于二级页面状态
  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  /// 构建关于二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          const SecondaryPageSliverAppBar(title: '关于'),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  56,
                  24,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _handleAppIconPressed,
                      child: AnimatedRotation(
                        turns: _appIconTurns,
                        duration: const Duration(milliseconds: 520),
                        curve: Curves.easeInOutCubic,
                        child: Image.asset(
                          _appIconAsset,
                          width: 112,
                          height: 112,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<PackageInfo>(
                      future: _packageInfoFuture,
                      builder: (context, snapshot) {
                        final version = switch (snapshot) {
                          AsyncSnapshot(hasError: true) => '获取失败',
                          AsyncSnapshot(hasData: true, data: final data?) =>
                            _formatPackageVersion(data),
                          _ => '读取中',
                        };

                        return Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: _isCheckingUpdate
                                ? null
                                : _handleVersionPressed,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Text(
                                _isCheckingUpdate ? '正在检查更新' : '版本 $version',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: widget.updateController,
                      builder: (context, child) {
                        if (!widget.updateController.hasUpdate) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: FilledButton.icon(
                            onPressed: _openLatestReleasePage,
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('下载最新版本'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: _SettingsSurface(
                        child: _SettingsActionTile(
                          leadingIcon: SvgPicture.asset(
                            _githubIconAsset,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: _projectGithubLabel,
                          trailingIcon: Icons.open_in_new_rounded,
                          onPressed: _openProjectGithubPage,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理应用图标彩蛋点击
  void _handleAppIconPressed() {
    _appIconTapCount += 1;
    if (_appIconTapCount < 10) {
      return;
    }

    setState(() {
      _appIconTapCount = 0;
      _appIconTurns += 0.5;
    });
  }

  /// 格式化平台包版本号
  ///
  /// [packageInfo] 平台包信息
  String _formatPackageVersion(PackageInfo packageInfo) {
    final buildNumber = packageInfo.buildNumber;

    if (buildNumber.isEmpty) {
      return packageInfo.version;
    }

    return '${packageInfo.version}+$buildNumber';
  }

  /// 处理版本号点击
  Future<void> _handleVersionPressed() async {
    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final result = await widget.updateController.checkForUpdate();
      if (!mounted) {
        return;
      }

      if (result.hasUpdate) {
        await showAppUpdateDialog(
          context,
          controller: widget.updateController,
        );
      } else {
        AppToast.info(context, text: '已是最新版本');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppToast.error(context, text: '检查更新失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  /// 打开项目 GitHub 页面
  Future<void> _openProjectGithubPage() async {
    final opened = await launchUrl(
      _projectGithubUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      AppToast.error(context, text: '无法打开 GitHub 页面，请稍后重试');
    }
  }

  /// 打开最新版本下载页面
  Future<void> _openLatestReleasePage() async {
    final opened = await widget.updateController.openLatestReleasePage();
    if (!opened && mounted) {
      AppToast.error(context, text: '无法打开下载页面，请稍后重试');
    }
  }
}
