import 'package:flutter/material.dart';
import 'package:magrail_app/features/user/model/user_balance_log_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list_layout.dart';
import 'package:magrail_app/features/user/widgets/user_balance_log_row.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户资金日志 sliver 列表
class UserBalanceLogSliverList extends StatelessWidget {
  /// 创建用户资金日志 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户资金日志条目
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色 ID 点击回调
  /// [showFullBalance] 是否显示完整余额
  const UserBalanceLogSliverList({
    super.key,
    required this.items,
    required this.showFullBalance,
    this.onItemBuilt,
    this.onCharacterTap,
  });

  /// 用户资金日志条目
  final List<UserBalanceLogApiItem> items;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色 ID 点击回调
  final ValueChanged<int>? onCharacterTap;

  /// 是否显示完整余额
  final bool showFullBalance;

  /// 构建用户资金日志 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        onItemBuilt?.call(index);
        return UserAssetRecordListItem(
          child: UserBalanceLogRow(
            item: items[index],
            onCharacterTap: onCharacterTap,
            showFullBalance: showFullBalance,
          ),
        );
      },
      separatorBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return UserAssetRecordListItem(
          child: Divider(
            height: 1,
            thickness: 0.6,
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.32 : 0.58,
            ),
          ),
        );
      },
      itemCount: items.length,
    );
  }
}

/// 用户资金日志骨架 sliver 列表
class UserBalanceLogSkeletonSliverList extends StatelessWidget {
  /// 创建用户资金日志骨架 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const UserBalanceLogSkeletonSliverList({
    super.key,
    this.itemCount = 12,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建用户资金日志骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return const UserAssetRecordListItem(
          child: _UserBalanceLogSkeletonRow(),
        );
      },
      separatorBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return UserAssetRecordListItem(
          child: Divider(
            height: 1,
            thickness: 0.6,
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.32 : 0.58,
            ),
          ),
        );
      },
      itemCount: itemCount,
    );
  }
}

/// 用户资金日志骨架行
class _UserBalanceLogSkeletonRow extends StatelessWidget {
  /// 创建用户资金日志骨架行
  const _UserBalanceLogSkeletonRow();

  /// 构建用户资金日志骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Bone.text(width: 128, fontSize: 14),
                      ),
                      SizedBox(width: 6),
                      Bone(
                        width: 52,
                        height: 18,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      SizedBox(width: 6),
                      Bone(
                        width: 46,
                        height: 18,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Bone.text(width: 220, fontSize: 12),
                ],
              ),
            ),
            SizedBox(width: 10),
            Padding(
              padding: EdgeInsets.only(top: 1),
              child: Bone.text(width: 54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
