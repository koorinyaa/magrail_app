part of '../temple_asset_magic_action_sheet.dart';

class _TempleAssetMagicDrawResultDialogContent extends StatelessWidget {
  /// 创建魔法道具抽取结果弹窗内容
  ///
  /// [result] 魔法道具抽取结果
  const _TempleAssetMagicDrawResultDialogContent({
    required this.result,
  });

  /// 魔法道具抽取结果
  final TinygrailCharacterRewardItem result;

  /// 构建魔法道具抽取结果弹窗内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 184),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: TinygrailCharacterRewardCard(item: result),
        ),
      ),
    );
  }
}
