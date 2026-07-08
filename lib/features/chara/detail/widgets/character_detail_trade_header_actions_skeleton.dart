part of 'character_detail_trade_header_card.dart';

/// 已上市头部操作入口卡片骨架
class CharacterDetailTradeHeaderActionsSkeleton extends StatelessWidget {
  /// 创建已上市头部操作入口骨架
  ///
  /// [key] Flutter 组件标识
  /// [isGameMaster] 当前用户是否为 GM
  const CharacterDetailTradeHeaderActionsSkeleton({
    super.key,
    required this.isGameMaster,
  });

  /// 当前用户是否为 GM
  final bool isGameMaster;

  /// 构建已上市头部操作入口骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Skeletonizer.zone(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.025),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: PagedActionGrid(
          itemCount: isGameMaster ? 10 : 7,
          itemBuilder: (context, index) {
            final itemWidths = isGameMaster
                ? [
                    48.0,
                    48.0,
                    48.0,
                    48.0,
                    48.0,
                    62.0,
                    48.0,
                    48.0,
                    48.0,
                    48.0,
                  ]
                : [48.0, 48.0, 48.0, 48.0, 48.0, 48.0, 48.0];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Bone(
                  width: 22,
                  height: 22,
                  borderRadius: BorderRadius.circular(11),
                ),
                const SizedBox(height: 8),
                Bone(
                  width: itemWidths[index],
                  height: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
