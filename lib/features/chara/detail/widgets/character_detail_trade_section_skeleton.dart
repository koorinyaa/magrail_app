part of 'character_detail_trade_section.dart';

/// 角色详情交易区骨架
class CharacterDetailTradeSectionSkeleton extends StatelessWidget {
  /// 创建角色详情交易区骨架
  ///
  /// [key] Flutter 组件标识
  const CharacterDetailTradeSectionSkeleton({super.key});

  /// 构建角色详情交易区骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: _TradeSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TradeHeaderSkeleton(),
            SizedBox(height: 12),
            _TradeDepthSkeleton(),
            SizedBox(height: 8),
            Bone(
              height: 26,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 角色详情交易区标题骨架
class _TradeHeaderSkeleton extends StatelessWidget {
  /// 创建角色详情交易区标题骨架
  const _TradeHeaderSkeleton();

  /// 构建角色详情交易区标题骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Bone(
          width: 42,
          height: 16,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        Spacer(),
        Bone(
          width: 78,
          height: 26,
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
      ],
    );
  }
}

/// 角色详情当前买卖单骨架
class _TradeDepthSkeleton extends StatelessWidget {
  /// 创建角色详情当前买卖单骨架
  const _TradeDepthSkeleton();

  /// 构建角色详情当前买卖单骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _TradeDepthColumnSkeleton()),
        SizedBox(width: 8),
        Expanded(child: _TradeDepthColumnSkeleton()),
      ],
    );
  }
}

/// 角色详情单侧当前买卖单骨架
class _TradeDepthColumnSkeleton extends StatelessWidget {
  /// 创建角色详情单侧当前买卖单骨架
  const _TradeDepthColumnSkeleton();

  /// 构建角色详情单侧当前买卖单骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < 6; index += 1)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Bone(
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
          ),
      ],
    );
  }
}
