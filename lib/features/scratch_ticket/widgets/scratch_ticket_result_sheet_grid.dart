part of 'scratch_ticket_result_sheet.dart';

/// 刮刮乐获得角色卡片网格
class _ResultGrid extends StatelessWidget {
  /// 创建刮刮乐获得角色卡片网格
  ///
  /// [items] 角色卡片条目
  /// [characterRepository] 角色详情仓库
  /// [onSold] 卖出成功回调
  const _ResultGrid({
    required this.items,
    required this.characterRepository,
    required this.onSold,
  });

  /// 角色卡片条目
  final List<TinygrailCharacterRewardItem> items;

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 卖出成功回调
  final ValueChanged<TinygrailCharacterRewardItem> onSold;

  /// 构建刮刮乐获得角色卡片网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyResult();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        const minCardWidth = 142.0;
        final columnCount =
            (constraints.maxWidth / minCardWidth).floor().clamp(1, 4).toInt();
        final cardWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var index = 0; index < items.length; index += 1)
              SizedBox(
                width: cardWidth,
                child: _ResultCard(
                  item: items[index],
                  characterRepository: characterRepository,
                  onSold: onSold,
                  heroTag: _heroTag(items[index], index),
                ),
              ),
          ],
        );
      },
    );
  }

  /// 解析刮刮乐角色封面 Hero 标识
  ///
  /// [item] 角色卡片条目
  /// [index] 结果列表位置
  String _heroTag(TinygrailCharacterRewardItem item, int index) {
    return 'scratch-ticket-result-cover-${item.id}-$index';
  }
}

/// 刮刮乐没有获得角色卡片时的空状态
class _EmptyResult extends StatelessWidget {
  /// 创建刮刮乐没有获得角色卡片时的空状态
  const _EmptyResult();

  /// 构建刮刮乐没有获得角色卡片时的空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Text(
        '没有获得角色',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
