import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';

/// 页面内容区块 sliver
class PageSectionSliver extends StatelessWidget {
  /// 创建页面内容区块 sliver
  ///
  /// [key] Flutter 组件标识
  /// [title] 区块标题
  /// [child] 区块主体
  /// [topSpacing] 区块顶部间距
  /// [titleTrailing] 标题右侧辅助组件
  /// [trailing] 右侧操作组件
  /// [onHeaderTap] 标题点击回调
  const PageSectionSliver({
    super.key,
    required this.title,
    required this.child,
    this.topSpacing = 0,
    this.titleTrailing,
    this.trailing,
    this.onHeaderTap,
  });

  /// 区块标题
  final String title;

  /// 区块主体
  final Widget child;

  /// 区块顶部间距
  final double topSpacing;

  /// 标题右侧辅助组件
  final Widget? titleTrailing;

  /// 右侧操作组件
  final Widget? trailing;

  /// 标题点击回调
  final VoidCallback? onHeaderTap;

  /// 构建页面内容区块 sliver
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: topSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 24,
                top: 0,
                right: 24,
                bottom: 0,
              ),
              child: _SectionHeader(
                title: title,
                titleTrailing: titleTrailing,
                trailing: trailing,
                onHeaderTap: onHeaderTap,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// 区块标题栏
class _SectionHeader extends StatelessWidget {
  /// 创建区块标题栏
  ///
  /// [title] 区块标题
  /// [titleTrailing] 标题右侧辅助组件
  /// [trailing] 右侧操作组件
  /// [onHeaderTap] 标题点击回调
  const _SectionHeader({
    required this.title,
    this.trailing,
    this.titleTrailing,
    this.onHeaderTap,
  });

  /// 区块标题
  final String title;

  /// 右侧操作组件
  final Widget? trailing;

  /// 标题右侧辅助组件
  final Widget? titleTrailing;

  /// 标题点击回调
  final VoidCallback? onHeaderTap;

  /// 构建区块标题栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: titleTrailing == null
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.end,
              children: [
                Flexible(child: _buildTitleAction(context, colorScheme)),
                if (titleTrailing != null) ...[
                  const SizedBox(width: 8),
                  titleTrailing!,
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  /// 构建标题点击区域
  ///
  /// [context] 当前组件树上下文
  /// [colorScheme] 当前主题色板
  Widget _buildTitleAction(BuildContext context, ColorScheme colorScheme) {
    final titleContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        if (onHeaderTap != null) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ],
      ],
    );

    if (onHeaderTap == null) {
      return titleContent;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onHeaderTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: titleContent,
        ),
      ),
    );
  }
}
