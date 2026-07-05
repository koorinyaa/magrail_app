import 'package:flutter/material.dart';
import 'package:magrail_app/features/user/model/user_trade_log_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list_layout.dart';
import 'package:magrail_app/features/user/widgets/user_trade_log_row.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户交易记录 sliver 列表
class UserTradeLogSliverList extends StatelessWidget {
  /// 创建用户交易记录 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户交易记录条目
  /// [ownerUsername] 当前记录归属用户名
  /// [onItemBuilt] 条目构建回调
  /// [onUserTap] 用户点击回调
  /// [onCharacterTap] 角色点击回调
  const UserTradeLogSliverList({
    super.key,
    required this.items,
    required this.ownerUsername,
    this.onItemBuilt,
    this.onUserTap,
    this.onCharacterTap,
  });

  /// 用户交易记录条目
  final List<UserTradeLogApiItem> items;

  /// 当前记录归属用户名
  final String ownerUsername;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 用户点击回调
  final ValueChanged<String>? onUserTap;

  /// 角色点击回调
  final ValueChanged<int>? onCharacterTap;

  /// 构建用户交易记录 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        onItemBuilt?.call(index);
        return UserAssetRecordListItem(
          child: UserTradeLogRow(
            item: items[index],
            ownerUsername: ownerUsername,
            onUserTap: onUserTap,
            onCharacterTap: onCharacterTap,
          ),
        );
      },
      separatorBuilder: (context, index) => const _UserTradeLogDivider(),
      itemCount: items.length,
    );
  }
}

/// 用户交易记录骨架 sliver 列表
class UserTradeLogSkeletonSliverList extends StatelessWidget {
  /// 创建用户交易记录骨架 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const UserTradeLogSkeletonSliverList({
    super.key,
    this.itemCount = 12,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建用户交易记录骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return const UserAssetRecordListItem(
          child: _UserTradeLogSkeletonRow(),
        );
      },
      separatorBuilder: (context, index) => const _UserTradeLogDivider(),
      itemCount: itemCount,
    );
  }
}

/// 用户交易记录分割线
class _UserTradeLogDivider extends StatelessWidget {
  /// 创建用户交易记录分割线
  const _UserTradeLogDivider();

  /// 构建用户交易记录分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
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
  }
}

/// 用户交易记录骨架行
class _UserTradeLogSkeletonRow extends StatelessWidget {
  /// 创建用户交易记录骨架行
  const _UserTradeLogSkeletonRow();

  /// 构建用户交易记录骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Bone.text(width: 168, fontSize: 15),
                      ),
                      SizedBox(width: 6),
                      Bone(
                        width: 42,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Bone.text(width: 54, fontSize: 11),
              ],
            ),
            SizedBox(height: 7),
            Row(
              children: [
                Bone.text(width: 116, fontSize: 12),
                SizedBox(width: 6),
                Bone(
                  width: 14,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                SizedBox(width: 6),
                Bone.text(width: 116, fontSize: 12),
              ],
            ),
            SizedBox(height: 6),
            Bone.text(width: 132, fontSize: 12),
          ],
        ),
      ),
    );
  }
}
