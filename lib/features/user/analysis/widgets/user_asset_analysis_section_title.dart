import 'package:flutter/material.dart';

/// 用户资产分析区块标题
class UserAssetAnalysisSectionTitle extends StatelessWidget {
  /// 创建用户资产分析区块标题
  ///
  /// [key] Flutter 组件标识
  /// [title] 标题文案
  /// [leadingIcon] 标题图标
  /// [accentColor] 标题强调色
  /// [trailing] 标题右侧组件
  const UserAssetAnalysisSectionTitle({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.accentColor,
    this.trailing,
  });

  /// 标题文案
  final String title;

  /// 标题图标
  final IconData leadingIcon;

  /// 标题强调色
  final Color accentColor;

  /// 标题右侧组件
  final Widget? trailing;

  /// 构建用户资产分析区块标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trailing = this.trailing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          leadingIcon,
          size: 18,
          color: accentColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing,
        ],
      ],
    );
  }
}
