part of 'user_settings_page.dart';

/// 关于二级页面
class _AboutPage extends StatefulWidget {
  /// 创建关于二级页面
  ///
  /// [preferences] 本地偏好设置
  /// [updateController] 应用更新控制器
  /// [onHiddenFeaturesChanged] 隐藏功能状态变化回调
  const _AboutPage({
    required this.preferences,
    required this.updateController,
    required this.onHiddenFeaturesChanged,
  });

  /// 本地偏好设置
  final AppPreferences preferences;

  /// 应用更新控制器
  final AppUpdateController updateController;

  /// 隐藏功能状态变化回调
  final ValueChanged<bool> onHiddenFeaturesChanged;

  /// 创建关于二级页面状态
  @override
  State<_AboutPage> createState() => _AboutPageState();
}

/// 关于二级页面状态
class _AboutPageState extends State<_AboutPage> {
  bool _isCheckingUpdate = false;
  int _appIconTapCount = 0;
  double _appIconTurns = 0;
  bool _hiddenFeaturesEnabled = false;
  bool _isTogglingHiddenFeatures = false;

  /// 初始化关于二级页面状态
  @override
  void initState() {
    super.initState();
    unawaited(widget.updateController.loadInstalledVersion());
    unawaited(widget.updateController.refreshPatchState());
    _hiddenFeaturesEnabled = widget.preferences.hiddenFeaturesEnabled;
    _appIconTurns = _hiddenFeaturesEnabled ? 0.5 : 0;
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
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: SvgPicture.asset(
                            _appIconAsset,
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          ),
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
                    AnimatedBuilder(
                      animation: widget.updateController,
                      builder: (context, child) {
                        final version = widget.updateController.currentVersion;

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
                        final controller = widget.updateController;
                        final installedVersion = controller.installedVersion;
                        final patch = controller.currentPatch;
                        final status = controller.rollbackPending
                            ? '更新已撤回，请完全退出后重新打开'
                            : controller.restartRequired
                                ? '更新已准备好，下次启动生效'
                                : controller.isPreparingPatch
                                    ? '正在后台准备更新'
                                    : null;

                        return Column(
                          children: [
                            if (installedVersion != null)
                              Text(
                                '基础包 $installedVersion'
                                '${patch == null ? '' : ' · 补丁 $patch'}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            if (status != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  status,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: widget.updateController,
                      builder: (context, child) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextButton.icon(
                            onPressed: _openLatestReleasePage,
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: Text(widget.updateController.hasUpdate
                                ? '下载最新版本'
                                : '下载安装包'),
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
  Future<void> _handleAppIconPressed() async {
    if (_isTogglingHiddenFeatures) {
      return;
    }

    _appIconTapCount += 1;
    if (_appIconTapCount < 10) {
      return;
    }

    final nextValue = !_hiddenFeaturesEnabled;
    setState(() {
      _appIconTapCount = 0;
      _isTogglingHiddenFeatures = true;
    });

    try {
      if (!nextValue) {
        await widget.preferences.setRevealPrivateUserHoldingsEnabled(false);
      }
      await widget.preferences.setHiddenFeaturesEnabled(nextValue);
      if (!mounted) {
        return;
      }

      setState(() {
        _hiddenFeaturesEnabled = nextValue;
        _appIconTurns = nextValue ? 0.5 : 0;
      });
      widget.onHiddenFeaturesChanged(nextValue);
      AppToast.info(context, text: nextValue ? '隐藏功能已开启' : '隐藏功能已关闭');
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppToast.error(context, text: '保存设置失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingHiddenFeatures = false;
        });
      }
    }
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
        await showAppUpdateDialog(context, controller: widget.updateController);
      } else if (widget.updateController.restartRequired) {
        AppToast.info(context, text: widget.updateController.rollbackPending
            ? '更新已撤回，请完全退出后重新打开'
            : '更新已准备好，下次启动生效');
      } else if (result.checkFailed) {
        AppToast.error(context, text: '检查未完成，请稍后重试或下载安装包');
      } else if (widget.updateController.isPreparingPatch) {
        AppToast.info(context, text: '后台更新尚未完成，请稍后再试');
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
