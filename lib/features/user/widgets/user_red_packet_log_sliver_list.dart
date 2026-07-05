import 'package:flutter/material.dart';
import 'package:magrail_app/features/user/model/user_red_packet_log_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list_layout.dart';
import 'package:magrail_app/features/user/widgets/user_red_packet_log_row.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户红包记录 sliver 列表
class UserRedPacketLogSliverList extends StatelessWidget {
  /// 创建用户红包记录 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 红包记录条目
  /// [onItemBuilt] 条目构建回调
  /// [onUserTap] 关联用户整行点击回调
  const UserRedPacketLogSliverList({
    super.key,
    required this.items,
    this.onItemBuilt,
    this.onUserTap,
  });

  /// 红包记录条目
  final List<UserRedPacketLogApiItem> items;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 关联用户整行点击回调
  final ValueChanged<String>? onUserTap;

  /// 构建用户红包记录 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        onItemBuilt?.call(index);
        final item = items[index];
        final username = item.relatedName.trim();
        final onTap = username.isEmpty || onUserTap == null
            ? null
            : () => onUserTap?.call(username);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: UserAssetRecordListItem(
              child: UserRedPacketLogRow(item: item),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const _RedPacketLogDivider(),
      itemCount: items.length,
    );
  }
}

/// 用户红包记录骨架 sliver 列表
class UserRedPacketLogSkeletonSliverList extends StatelessWidget {
  /// 创建用户红包记录骨架 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const UserRedPacketLogSkeletonSliverList({
    super.key,
    this.itemCount = 12,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建用户红包记录骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return const UserAssetRecordListItem(
          child: _RedPacketLogSkeletonRow(),
        );
      },
      separatorBuilder: (context, index) => const _RedPacketLogDivider(),
      itemCount: itemCount,
    );
  }
}

/// 用户红包记录分割线
class _RedPacketLogDivider extends StatelessWidget {
  /// 创建用户红包记录分割线
  const _RedPacketLogDivider();

  /// 构建用户红包记录分割线
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

/// 用户红包记录骨架行
class _RedPacketLogSkeletonRow extends StatelessWidget {
  /// 创建用户红包记录骨架行
  const _RedPacketLogSkeletonRow();

  /// 构建用户红包记录骨架行
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
                        child: Bone.text(width: 92, fontSize: 14),
                      ),
                      SizedBox(width: 6),
                      Bone(
                        width: 54,
                        height: 16,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Bone.text(width: 230, fontSize: 12),
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
