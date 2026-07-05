part of 'character_detail_trade_header_card.dart';

/// 角色详情已上市头部骨架
class CharacterDetailTradeHeaderSkeleton extends StatelessWidget {
  /// 创建角色详情已上市头部骨架
  ///
  /// [key] Flutter 组件标识
  const CharacterDetailTradeHeaderSkeleton({super.key});

  /// 构建角色详情已上市头部骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: _TradeHeaderShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Bone(
                      width: 112,
                      height: 18,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    const SizedBox(width: 7),
                    Bone(
                      width: 44,
                      height: 17,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Bone(
                  width: 72,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 7),
                Bone(
                  width: 76,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final width in [
                  98.0,
                  98.0,
                  38.0,
                  74.0,
                  80.0,
                  86.0,
                  86.0,
                  68.0,
                  74.0,
                ])
                  Bone(
                    width: width,
                    height: 22,
                    borderRadius: BorderRadius.circular(999),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
