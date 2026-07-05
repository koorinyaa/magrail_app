import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_board_member.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_board_member_row.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 角色董事会 sliver 列表
class CharacterDetailBoardSliverList extends StatelessWidget {
  /// 创建角色董事会 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 董事会成员
  /// [totalShares] 角色流通股份
  /// [templeFor] 成员圣殿查询回调
  /// [onItemBuilt] 条目构建回调
  /// [onMemberTap] 成员点击回调
  /// [onTempleTap] 圣殿数据点击回调
  const CharacterDetailBoardSliverList({
    super.key,
    required this.items,
    required this.totalShares,
    required this.templeFor,
    this.onItemBuilt,
    this.onMemberTap,
    this.onTempleTap,
  });

  /// 董事会成员
  final List<CharacterDetailBoardMember> items;

  /// 角色流通股份
  final int totalShares;

  /// 成员圣殿查询回调
  final CharacterDetailTempleItem? Function(CharacterDetailBoardMember member)
      templeFor;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 成员点击回调
  final ValueChanged<CharacterDetailBoardMember>? onMemberTap;

  /// 圣殿数据点击回调
  final ValueChanged<CharacterDetailTempleItem>? onTempleTap;

  /// 构建角色董事会 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _BoardSliverListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          final temple = templeFor(item);

          onItemBuilt?.call(index);
          return _BoardSliverListItem(
            child: CharacterDetailBoardMemberRow(
              member: item,
              serialNumber: index + 1,
              totalShares: totalShares,
              temple: temple,
              onTap: onMemberTap == null ? null : () => onMemberTap!(item),
              onTempleTap: temple == null || onTempleTap == null
                  ? null
                  : () => onTempleTap!(temple),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

/// 角色董事会骨架 sliver 列表
class CharacterDetailBoardSkeletonSliverList extends StatelessWidget {
  /// 创建角色董事会骨架 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const CharacterDetailBoardSkeletonSliverList({
    super.key,
    this.itemCount = 20,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建角色董事会骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _BoardSliverListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const _BoardSliverListItem(
            child: _BoardMemberRowSkeleton(),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}

/// 董事会成员行骨架
class _BoardMemberRowSkeleton extends StatelessWidget {
  /// 创建董事会成员行骨架
  const _BoardMemberRowSkeleton();

  /// 构建董事会成员行骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Bone(
                width: 26,
                height: 18,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(width: 13),
              Bone(
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Bone(
                            width: 92,
                            height: 14,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Bone(
                          width: 34,
                          height: 13,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const Spacer(),
                        Bone(
                          width: 54,
                          height: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Bone(
                      width: 118,
                      height: 9,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 3),
                    Bone(
                      width: 96,
                      height: 9,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 董事会列表条目外层
class _BoardSliverListItem extends StatelessWidget {
  /// 创建董事会列表条目外层
  ///
  /// [child] 条目主体
  const _BoardSliverListItem({
    required this.child,
  });

  /// 条目主体
  final Widget child;

  /// 构建董事会列表条目外层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 12,
        top: 0,
        right: 12,
        bottom: 4,
      ),
      child: child,
    );
  }
}

/// 董事会 sliver 列表尺寸
final class _BoardSliverListMetrics {
  /// 禁止创建董事会 sliver 列表尺寸实例
  const _BoardSliverListMetrics._();

  /// 列表条目高度
  static const double itemExtent = 68;
}
