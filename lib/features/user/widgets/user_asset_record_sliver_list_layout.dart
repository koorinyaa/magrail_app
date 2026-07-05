import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';

/// 用户资产记录列表布局尺寸
abstract final class UserAssetRecordListMetrics {
  /// 头像宽度与文本间距合计的分割线缩进
  static const double textIndent = 58;

  /// 列表内容水平边距
  static const double horizontalPadding = 12;
}

/// 用户资产记录列表条目外层
class UserAssetRecordListItem extends StatelessWidget {
  /// 创建用户资产记录列表条目外层
  ///
  /// [child] 条目主体
  const UserAssetRecordListItem({
    super.key,
    required this.child,
  });

  /// 条目主体
  final Widget child;

  /// 构建用户资产记录列表条目外层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: UserAssetRecordListMetrics.horizontalPadding,
      ),
      child: child,
    );
  }
}
