import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户详情页骨架屏
class UserDetailSkeleton extends StatelessWidget {
  /// 创建用户详情页骨架屏
  ///
  /// [key] Flutter 组件标识
  const UserDetailSkeleton({super.key});

  /// 构建用户详情页骨架屏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardColor =
        isDark ? colorScheme.surfaceContainerLow : colorScheme.surface;

    return Skeletonizer.zone(
      child: Column(
        children: [
          _buildProfileCard(cardColor),
          const SizedBox(height: 12),
          _buildActionGridCard(cardColor),
        ],
      ),
    );
  }

  /// 构建用户资料卡骨架
  ///
  /// [cardColor] 卡片背景色
  Widget _buildProfileCard(Color cardColor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 186),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Bone(
                      width: 82,
                      height: 30,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    const SizedBox(width: 6),
                    Bone(
                      width: 82,
                      height: 30,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Bone(
                    width: 96,
                    height: 20,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(width: 9),
                  Bone(
                    width: 46,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Bone(
                width: 86,
                height: 14,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 22),
              Bone(
                width: double.infinity,
                height: 1,
                borderRadius: BorderRadius.circular(1),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: _UserMetricSkeleton()),
                  Expanded(child: _UserMetricSkeleton()),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 18,
          top: -20,
          child: Bone(
            width: 72,
            height: 72,
            borderRadius: BorderRadius.circular(36),
          ),
        ),
      ],
    );
  }

  /// 构建用户操作区骨架
  ///
  /// [cardColor] 卡片背景色
  Widget _buildActionGridCard(Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const minItemWidth = 88.0;
          final rawColumnCount = (constraints.maxWidth / minItemWidth).floor();
          final columnCount = switch (rawColumnCount) {
            < 1 => 1,
            > 6 => 6,
            _ => rawColumnCount,
          };
          final itemWidth = constraints.maxWidth / columnCount;

          return Wrap(
            alignment: WrapAlignment.start,
            runSpacing: 8,
            spacing: 0,
            children: [
              for (var index = 0; index < 9; index += 1)
                SizedBox(
                  width: itemWidth,
                  height: 56,
                  child: const _UserActionItemSkeleton(),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// 用户资产指标骨架
class _UserMetricSkeleton extends StatelessWidget {
  /// 创建用户资产指标骨架
  const _UserMetricSkeleton();

  /// 构建用户资产指标骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone(
          width: 96,
          height: 18,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 4),
        Bone(
          width: 30,
          height: 10,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

/// 用户菜单入口骨架
class _UserActionItemSkeleton extends StatelessWidget {
  /// 创建用户菜单入口骨架
  const _UserActionItemSkeleton();

  /// 构建用户菜单入口骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Bone(
          width: 22,
          height: 22,
          borderRadius: BorderRadius.circular(11),
        ),
        const SizedBox(height: 6),
        Bone(
          width: 48,
          height: 12,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}

/// 用户详情页错误状态
class UserDetailErrorState extends StatelessWidget {
  /// 创建用户详情页错误状态
  ///
  /// [key] Flutter 组件标识
  /// [title] 错误状态标题
  /// [icon] 错误状态图标
  /// [message] 错误文案
  /// [actionLabel] 操作按钮文案
  /// [onActionPressed] 操作按钮点击回调
  const UserDetailErrorState({
    super.key,
    this.title = '加载失败',
    this.icon = Icons.wifi_off_rounded,
    required this.message,
    this.actionLabel = '重试',
    required this.onActionPressed,
  });

  /// 错误状态标题
  final String title;

  /// 错误状态图标
  final IconData icon;

  /// 错误文案
  final String message;

  /// 操作按钮文案
  final String actionLabel;

  /// 操作按钮点击回调
  final VoidCallback onActionPressed;

  /// 构建用户详情页错误状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppLoadFailedState(
        title: title,
        message: message,
        icon: icon,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      ),
    );
  }
}
