import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/user/controller/user_share_bonus_forecast_controller.dart';
import 'package:magrail_app/features/user/model/user_share_bonus_forecast.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

part 'user_share_bonus_forecast_sheet_chart.dart';
part 'user_share_bonus_forecast_sheet_content.dart';
part 'user_share_bonus_forecast_sheet_states.dart';

/// 显示用户股息预测底部抽屉
///
/// [context] 当前组件树上下文
/// [repository] 用户仓库
/// [username] 目标用户名
/// [nickname] 目标用户昵称
Future<void> showUserShareBonusForecastSheet(
  BuildContext context, {
  required UserRepository repository,
  required String username,
  String? nickname,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final maxHeight =
          availableHeight.clamp(0.0, mediaQuery.size.height).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: UserShareBonusForecastSheet(
          repository: repository,
          username: username,
          nickname: nickname,
        ),
      );
    },
  );
}

/// 用户股息预测底部抽屉
class UserShareBonusForecastSheet extends StatefulWidget {
  /// 创建用户股息预测底部抽屉
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [username] 目标用户名
  /// [nickname] 目标用户昵称
  const UserShareBonusForecastSheet({
    super.key,
    required this.repository,
    required this.username,
    this.nickname,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 目标用户名
  final String username;

  /// 目标用户昵称
  final String? nickname;

  /// 创建用户股息预测底部抽屉状态
  @override
  State<UserShareBonusForecastSheet> createState() =>
      _UserShareBonusForecastSheetState();
}

/// 用户股息预测底部抽屉状态
class _UserShareBonusForecastSheetState
    extends State<UserShareBonusForecastSheet> {
  late final UserShareBonusForecastController _controller;

  /// 初始化用户股息预测底部抽屉状态
  @override
  void initState() {
    super.initState();
    _controller = UserShareBonusForecastController(
      repository: widget.repository,
      username: widget.username,
    );
    unawaited(_controller.initialize());
  }

  /// 释放用户股息预测底部抽屉状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户股息预测底部抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.58,
                ),
              ),
            ),
          ),
          child: SafeArea(
            left: false,
            right: false,
            top: false,
            child: Padding(
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 20,
                top: 10,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBottomSheetDragHandle(),
                  const SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ShareBonusForecastHeader(
                                displayName: _displayName,
                              ),
                              const SizedBox(height: 16),
                              _buildContent(context),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建股息预测内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildContent(BuildContext context) {
    final forecast = _controller.forecast;
    if (_controller.isLoading && forecast == null) {
      return const _ShareBonusForecastSkeleton();
    }

    if (forecast == null) {
      return _ShareBonusForecastError(
        message: _controller.errorMessage ?? '获取股息预测失败',
        onRetry: _controller.load,
      );
    }

    return _ShareBonusForecastContent(forecast: forecast);
  }

  /// 目标用户展示名称
  String get _displayName {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return nickname;
    }

    return widget.username;
  }
}
