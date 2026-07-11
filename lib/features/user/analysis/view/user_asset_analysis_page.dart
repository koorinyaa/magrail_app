import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/analysis/controller/user_asset_analysis_controller.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis.dart';
import 'package:magrail_app/features/user/analysis/repository/user_asset_analysis_database.dart';
import 'package:magrail_app/features/user/analysis/repository/user_asset_analysis_repository.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_character_packing_section.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_core_background.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_core_header.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_dividend_composition_section.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_level_distribution_section.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_share_overlay.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

part 'user_asset_analysis_page_navigation.dart';

/// 用户资产分析二级页
class UserAssetAnalysisPage extends StatefulWidget {
  /// 创建用户资产分析二级页
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [characterDetailRepository] 角色详情仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  const UserAssetAnalysisPage({
    super.key,
    required this.repository,
    required this.characterDetailRepository,
    required this.username,
    this.nickname,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetailRepository;

  /// 用户名
  final String username;

  /// 用户昵称
  final String? nickname;

  /// 创建用户资产分析二级页状态
  @override
  State<UserAssetAnalysisPage> createState() => _UserAssetAnalysisPageState();
}

/// 用户资产分析二级页状态
class _UserAssetAnalysisPageState extends State<UserAssetAnalysisPage> {
  late final UserAssetSnapshotDatabase _snapshotDatabase;
  late final UserAssetAnalysisDatabase _analysisDatabase;
  late final UserAssetAnalysisController _controller;
  UserAssetAnalysisAssetProportionMode _assetProportionMode =
      UserAssetAnalysisAssetProportionMode.dividend;
  UserAssetAnalysisLevelDistributionMode _levelDistributionMode =
      UserAssetAnalysisLevelDistributionMode.dividend;

  /// 初始化用户资产分析二级页状态
  @override
  void initState() {
    super.initState();
    _snapshotDatabase = UserAssetSnapshotDatabase();
    _analysisDatabase = UserAssetAnalysisDatabase();
    _controller = UserAssetAnalysisController(
      repository: UserAssetAnalysisRepository(
        snapshotRepository: UserAssetSnapshotRepository(
          userRepository: widget.repository,
          characterDetailRepository: widget.characterDetailRepository,
          database: _snapshotDatabase,
        ),
        database: _analysisDatabase,
      ),
      username: widget.username,
      nickname: widget.nickname ?? '',
    );
    unawaited(_controller.initialize());
  }

  /// 释放用户资产分析二级页状态
  @override
  void dispose() {
    _controller.dispose();
    unawaited(_closeDatabasesAfterOperations());
    super.dispose();
  }

  /// 等待资产任务结束后关闭页面数据库
  Future<void> _closeDatabasesAfterOperations() async {
    try {
      await _controller.waitForPendingOperations();
    } catch (_) {
      // 页面销毁后的任务异常已由刷新流程处理，清理阶段只负责释放数据库
    }

    try {
      await _snapshotDatabase.close();
    } catch (_) {
      // 页面销毁阶段不再向用户展示数据库关闭错误
    }
    try {
      await _analysisDatabase.close();
    } catch (_) {
      // 页面销毁阶段不再向用户展示数据库关闭错误
    }
  }

  /// 构建用户资产分析二级页
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _darkPageBottom : _lightPageBottom,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [_darkPageTop, _darkPageMiddle, _darkPageBottom]
                : const [_lightPageTop, _lightPageMiddle, _lightPageBottom],
            stops: const [0, 0.46, 1],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                ..._buildBodySlivers(context),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建资产分析沉浸式顶部栏
  ///
  /// [context] 当前组件树上下文
  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final analysis = _controller.analysis;
    final width = MediaQuery.sizeOf(context).width;
    final expandedHeight = width >= 600 ? 410.0 : 382.0;
    final foregroundColor = isDark ? Colors.white : const Color(0xFF07161B);
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return SliverAppBar(
      pinned: true,
      stretch: analysis != null,
      expandedHeight: analysis == null ? null : expandedHeight,
      toolbarHeight: 54,
      backgroundColor:
          isDark ? const Color(0xFF07111A) : const Color(0xFFEAF7F4),
      foregroundColor: foregroundColor,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: systemOverlayStyle,
      leadingWidth: 52,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(LucideIcons.chevronLeft, size: 25),
      ),
      titleSpacing: 0,
      title: Text(
        '资产分析',
        style: TextStyle(
          color: foregroundColor,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      actions: [
        if (analysis != null)
          IconButton(
            onPressed: _openSharePreview,
            icon: const Icon(LucideIcons.share2, size: 20),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: _RefreshAction(
            isBusy: _controller.isRefreshing || _controller.isInitialLoading,
            onPressed: _handleRefreshPressed,
          ),
        ),
      ],
      flexibleSpace: analysis == null
          ? UserAssetAnalysisCoreBackground(
              isDark: isDark,
              intensity: 0,
            )
          : FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: const [StretchMode.zoomBackground],
              background: UserAssetAnalysisCoreHeader(
                analysis: analysis,
                nickname: widget.nickname ?? '',
                analysisAgeLabel: _controller.analysisAgeLabel,
                isRefreshing: _controller.isRefreshing,
                progressLabel: _controller.progressLabel,
                hasRefreshError: !_controller.isRefreshing &&
                    _controller.errorMessage != null,
                onCharactersTap: _openUserCharacters,
                onTemplesTap: _openUserTemples,
                onStarlightTemplesTap: _openUserStarlightTemples,
              ),
            ),
    );
  }

  /// 构建页面主体 Sliver
  ///
  /// [context] 当前组件树上下文
  List<Widget> _buildBodySlivers(BuildContext context) {
    final analysis = _controller.analysis;
    if (analysis == null && _controller.isInitialLoading) {
      return [
        _UserAssetAnalysisLoadingSliver(
          progressLabel: _controller.progressLabel,
          progress: _controller.progress,
        ),
      ];
    }

    if (analysis == null) {
      return [
        _UserAssetAnalysisFailureSliver(
          message: _controller.errorMessage ?? '暂无资产分析缓存',
          onRetry: () => unawaited(_refresh(showToast: false)),
        ),
      ];
    }

    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 600 ? 28.0 : 16.0;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    Widget dividendSection = UserAssetAnalysisDividendCompositionSection(
      segments: analysis.dividendSegments,
    );
    Widget packingSection = UserAssetAnalysisCharacterPackingSection(
      analysis: analysis,
      mode: _assetProportionMode,
      onModeChanged: (mode) {
        setState(() {
          _assetProportionMode = mode;
        });
      },
      onCharacterTap: _openCharacterDetail,
    );
    Widget levelSection = UserAssetAnalysisLevelDistributionSection(
      buckets: analysis.levelBuckets,
      mode: _levelDistributionMode,
      onModeChanged: (mode) {
        setState(() {
          _levelDistributionMode = mode;
        });
      },
    );
    if (!disableAnimations) {
      dividendSection = dividendSection
          .animate(delay: 60.ms)
          .fadeIn(duration: 360.ms, curve: Curves.easeOutCubic)
          .slideY(
            begin: 0.06,
            end: 0,
            duration: 420.ms,
            curve: Curves.easeOutCubic,
          );
      packingSection = packingSection
          .animate(delay: 150.ms)
          .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
          .slideY(
            begin: 0.08,
            end: 0,
            duration: 460.ms,
            curve: Curves.easeOutCubic,
          );
      levelSection = levelSection
          .animate(delay: 240.ms)
          .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
          .slideY(
            begin: 0.08,
            end: 0,
            duration: 460.ms,
            curve: Curves.easeOutCubic,
          );
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          34,
          horizontalPadding,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  dividendSection,
                  const SizedBox(height: 46),
                  packingSection,
                  const SizedBox(height: 46),
                  levelSection,
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  /// 处理刷新按钮点击
  void _handleRefreshPressed() {
    unawaited(_refresh());
  }

  /// 打开资产分析分享预览
  void _openSharePreview() {
    final analysis = _controller.analysis;
    if (analysis == null) {
      return;
    }

    unawaited(
      showUserAssetAnalysisSharePreview(
        context,
        analysis: analysis,
        nickname: widget.nickname ?? '',
        analysisAgeLabel: _controller.analysisAgeLabel,
        assetMode: _assetProportionMode,
        levelMode: _levelDistributionMode,
      ),
    );
  }

  /// 刷新资产分析数据
  ///
  /// [showToast] 失败时是否展示轻提示
  Future<void> _refresh({bool showToast = true}) async {
    final success = await _controller.refresh();
    if (!mounted || success || !showToast) {
      return;
    }

    AppToast.error(
      context,
      text: _controller.errorMessage ?? '刷新资产分析失败',
    );
  }

}

/// 用户资产分析刷新按钮
class _RefreshAction extends StatelessWidget {
  /// 创建用户资产分析刷新按钮
  ///
  /// [isBusy] 是否正在加载
  /// [onPressed] 刷新按钮点击回调
  const _RefreshAction({
    required this.isBusy,
    required this.onPressed,
  });

  /// 是否正在加载
  final bool isBusy;

  /// 刷新按钮点击回调
  final VoidCallback onPressed;

  /// 构建用户资产分析刷新按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isBusy ? null : onPressed,
      icon: isBusy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(LucideIcons.refreshCw, size: 20),
    );
  }
}

/// 用户资产分析加载 Sliver
class _UserAssetAnalysisLoadingSliver extends StatelessWidget {
  /// 创建用户资产分析加载 Sliver
  ///
  /// [progressLabel] 加载状态文案
  /// [progress] 加载进度
  const _UserAssetAnalysisLoadingSliver({
    required this.progressLabel,
    required this.progress,
  });

  /// 加载状态文案
  final String progressLabel;

  /// 加载进度
  final double progress;

  /// 构建用户资产分析加载 Sliver
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 82,
                height: 82,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress <= 0 ? null : progress,
                      strokeWidth: 2.5,
                      backgroundColor: colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.08 : 0.06,
                      ),
                      color: _activeColor,
                    ),
                    Center(
                      child: Image.asset(
                        _appIconAsset,
                        width: 38,
                        height: 38,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                progressLabel.trim().isEmpty ? '正在准备资产分析' : progressLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析失败 Sliver
class _UserAssetAnalysisFailureSliver extends StatelessWidget {
  /// 创建用户资产分析失败 Sliver
  ///
  /// [message] 失败文案
  /// [onRetry] 重试按钮点击回调
  const _UserAssetAnalysisFailureSliver({
    required this.message,
    required this.onRetry,
  });

  /// 失败文案
  final String message;

  /// 重试按钮点击回调
  final VoidCallback onRetry;

  /// 构建用户资产分析失败 Sliver
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.chartArea,
                  size: 42,
                  color: _templeColor,
                ),
                const SizedBox(height: 18),
                Text(
                  '资产分析不可用',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  label: const Text('重新加载'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _appIconAsset = 'assets/icons/app_icon_cropped.png';
const _activeColor = Color(0xFF20B8D8);
const _templeColor = Color(0xFFD9A441);
const _lightPageTop = Color(0xFFEAF7F4);
const _lightPageMiddle = Color(0xFFF7FAF9);
const _lightPageBottom = Color(0xFFFFFBF4);
const _darkPageTop = Color(0xFF07111A);
const _darkPageMiddle = Color(0xFF071014);
const _darkPageBottom = Color(0xFF050A0D);
