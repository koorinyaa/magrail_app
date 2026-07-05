import 'package:flutter/material.dart';
import 'package:magrail_app/features/user/model/user_item_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list_layout.dart';
import 'package:magrail_app/features/user/widgets/user_item_row.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户道具 sliver 列表
class UserItemSliverList extends StatelessWidget {
  /// 创建用户道具 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户道具条目
  const UserItemSliverList({
    super.key,
    required this.items,
  });

  /// 用户道具条目
  final List<UserItemApiItem> items;

  /// 构建用户道具 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return UserAssetRecordListItem(
          child: UserItemRow(item: items[index]),
        );
      },
      separatorBuilder: (context, index) => const _UserItemDivider(),
      itemCount: items.length,
    );
  }
}

/// 用户道具骨架 sliver 列表
class UserItemSkeletonSliverList extends StatelessWidget {
  /// 创建用户道具骨架 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const UserItemSkeletonSliverList({
    super.key,
    this.itemCount = 9,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建用户道具骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return const UserAssetRecordListItem(
          child: _UserItemSkeletonRow(),
        );
      },
      separatorBuilder: (context, index) => const _UserItemDivider(),
      itemCount: itemCount,
    );
  }
}

/// 用户道具分割线
class _UserItemDivider extends StatelessWidget {
  /// 创建用户道具分割线
  const _UserItemDivider();

  /// 构建用户道具分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return UserAssetRecordListItem(
      child: Padding(
        padding: const EdgeInsets.only(
          left: UserAssetRecordListMetrics.textIndent,
        ),
        child: Divider(
          height: 1,
          thickness: 0.6,
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.32 : 0.58,
          ),
        ),
      ),
    );
  }
}

/// 用户道具骨架行
class _UserItemSkeletonRow extends StatelessWidget {
  /// 创建用户道具骨架行
  const _UserItemSkeletonRow();

  /// 构建用户道具骨架行
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
            Bone(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Bone.text(width: 132, fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Bone.text(width: 220, fontSize: 12),
                  SizedBox(height: 5),
                  Bone.text(width: 160, fontSize: 12),
                ],
              ),
            ),
            SizedBox(width: 10),
            Padding(
              padding: EdgeInsets.only(top: 14),
              child: Bone(
                width: 50,
                height: 18,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
