import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/app_loading_dialog.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';
import 'package:magrail_app/features/bot/controller/bot_config_controller.dart';
import 'package:magrail_app/features/bot/model/bot_models.dart';
import 'package:magrail_app/features/bot/repository/bot_repository.dart';
import 'package:magrail_app/features/bot/widgets/bot_selection_sheet.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_magic_character_search_panel.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list_layout.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'bot_config_page_content.dart';
part 'bot_config_log_widgets.dart';
part 'bot_config_log_page.dart';
part 'bot_config_page_state_methods.dart';
part 'bot_config_page_value_helpers.dart';
part 'bot_config_page_widgets.dart';

/// bot 配置二级页面
class BotConfigPage extends StatefulWidget {
  /// 创建 bot 配置二级页面
  ///
  /// [key] Flutter 组件标识
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [repository] fuyuake bot 仓库
  /// [characterRepository] Tinygrail 角色仓库
  /// [userRepository] Tinygrail 用户仓库
  const BotConfigPage({
    super.key,
    required this.authRepository,
    required this.preferences,
    required this.repository,
    required this.characterRepository,
    required this.userRepository,
  });

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 本地偏好设置
  final AppPreferences preferences;

  /// fuyuake bot 仓库
  final BotRepository repository;

  /// Tinygrail 角色仓库
  final CharacterDetailRepository characterRepository;

  /// Tinygrail 用户仓库
  final UserRepository userRepository;

  /// 创建 bot 配置二级页面状态
  @override
  State<BotConfigPage> createState() => _BotConfigPageState();
}

/// bot 配置二级页面状态
class _BotConfigPageState extends State<BotConfigPage> {
  late final BotConfigController _controller;
  final TextEditingController _icoInvestmentController =
      TextEditingController();
  final TextEditingController _icoReserveController = TextEditingController();
  BotConfig? _syncedTextConfig;
  // 页面返回保护：只比较已保存快照和当前可提交配置
  String? _savedConfigFingerprint;
  bool _allowPagePop = false;
  bool _isConfirmingLeave = false;

  /// 初始化 bot 配置二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = BotConfigController(
      authRepository: widget.authRepository,
      repository: widget.repository,
      characterRepository: widget.characterRepository,
      userRepository: widget.userRepository,
    )..initialize();
    _icoInvestmentController.addListener(_handleIcoInvestmentChanged);
    _icoReserveController.addListener(_handleIcoReserveChanged);
  }

  /// 释放 bot 配置二级页面状态
  @override
  void dispose() {
    _icoInvestmentController.removeListener(_handleIcoInvestmentChanged);
    _icoReserveController.removeListener(_handleIcoReserveChanged);
    _icoInvestmentController.dispose();
    _icoReserveController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 构建 bot 配置二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _allowPagePop,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            final config = _controller.config;
            _syncAmountControllers(config);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SecondaryPageSliverAppBar(
                    title: 'Bot配置',
                    actions: _buildAppBarActions(config),
                  ),
                  if (_controller.isLoading && config == null)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (config == null)
                    AppLoadFailedSliver(
                      message: _controller.errorMessage ?? '获取 Bot 配置失败，请稍后重试',
                      onActionPressed: _retry,
                    )
                  else
                    SliverToBoxAdapter(
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            16,
                            16,
                            24 + MediaQuery.paddingOf(context).bottom,
                          ),
                          child: _buildConfigContent(context, config),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 标记页面允许执行下一次返回
  void _markPagePopAllowed() {
    setState(() {
      _allowPagePop = true;
    });
  }
}
