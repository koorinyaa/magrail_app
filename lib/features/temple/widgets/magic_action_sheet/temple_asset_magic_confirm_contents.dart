part of '../temple_asset_magic_action_sheet.dart';

class _TempleAssetChaosConfirmContent extends StatelessWidget {
  /// 创建混沌魔方确认内容
  ///
  /// [data] 当前圣殿资产卡片展示数据
  const _TempleAssetChaosConfirmContent({
    required this.data,
  });

  /// 当前圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建混沌魔方确认内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentName = TinygrailFormatters.decodeHtmlEntities(
      data.characterName,
    );

    return _TempleAssetMagicConfirmTransferLayout(
      left: _TempleAssetMagicTemplePreview(data: data),
      right: _TempleAssetMagicUnknownTargetPreview(
        imageUrl: TinygrailAssetUrls.normalizeAvatar(''),
      ),
      arrowColor: colorScheme.onSurfaceVariant,
      description: '消耗「$currentName」10点固定资产，获得随机角色活股',
    );
  }
}

/// 魔法道具确认转移布局
class _TempleAssetMagicConfirmTransferLayout extends StatelessWidget {
  /// 创建魔法道具确认转移布局
  ///
  /// [left] 左侧圣殿或角色预览
  /// [right] 右侧圣殿或角色预览
  /// [description] 底部说明文案
  /// [arrowColor] 箭头颜色
  const _TempleAssetMagicConfirmTransferLayout({
    required this.left,
    required this.right,
    required this.description,
    required this.arrowColor,
  });

  /// 左侧圣殿或角色预览
  final Widget left;

  /// 右侧圣殿或角色预览
  final Widget right;

  /// 底部说明文案
  final String description;

  /// 箭头颜色
  final Color arrowColor;

  /// 构建魔法道具确认转移布局
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: left),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 30,
                color: arrowColor,
              ),
            ),
            Expanded(child: right),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.38,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 魔法道具抽取确认中的未知目标角色
class _TempleAssetMagicUnknownTargetPreview extends StatelessWidget {
  /// 创建魔法道具抽取确认中的未知目标角色
  ///
  /// [imageUrl] 预览角色头像地址
  const _TempleAssetMagicUnknownTargetPreview({
    required this.imageUrl,
  });

  /// 预览角色头像地址
  final String imageUrl;

  /// 构建魔法道具抽取确认中的未知目标角色
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.center,
          child: CharacterAvatar(
            imageUrl: imageUrl,
            size: 56,
            borderRadius: 18,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: colorScheme.brightness == Brightness.dark ? 0.32 : 0.68,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              child: Text(
                '？？？',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 虚空道标确认内容
class _TempleAssetGuidepostConfirmContent extends StatelessWidget {
  /// 创建虚空道标确认内容
  ///
  /// [data] 当前圣殿资产卡片展示数据
  /// [target] 已选择的目标角色
  const _TempleAssetGuidepostConfirmContent({
    required this.data,
    required this.target,
  });

  /// 当前圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 已选择的目标角色
  final CharacterDetailSearchItem target;

  /// 构建虚空道标确认内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentName = TinygrailFormatters.decodeHtmlEntities(
      data.characterName,
    );
    final targetName = TinygrailFormatters.decodeHtmlEntities(target.name);

    return _TempleAssetMagicConfirmTransferLayout(
      left: _TempleAssetMagicTemplePreview(data: data),
      right: _TempleAssetMagicTargetPreview(target: target),
      arrowColor: colorScheme.onSurfaceVariant,
      description: '消耗「$currentName」100点固定资产，获得「$targetName」随机数量活股',
    );
  }
}

/// 鲤鱼之眼确认内容
class _TempleAssetFisheyeConfirmContent extends StatelessWidget {
  /// 创建鲤鱼之眼确认内容
  ///
  /// [data] 当前圣殿资产卡片展示数据
  /// [target] 已选择的目标角色
  /// [gensokyoAmount] 幻想乡持股数量
  const _TempleAssetFisheyeConfirmContent({
    required this.data,
    required this.target,
    required this.gensokyoAmount,
  });

  /// 当前圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 已选择的目标角色
  final CharacterDetailSearchItem target;

  /// 幻想乡持股数量
  final int gensokyoAmount;

  /// 构建鲤鱼之眼确认内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentName = TinygrailFormatters.decodeHtmlEntities(
      data.characterName,
    );
    final targetName = TinygrailFormatters.decodeHtmlEntities(target.name);

    return _TempleAssetMagicConfirmTransferLayout(
      left: _TempleAssetMagicTemplePreview(data: data),
      right: _TempleAssetMagicTargetPreview(
        target: target,
        stockText: '幻想乡 ${Formatters.groupedNumber(gensokyoAmount)}',
      ),
      arrowColor: colorScheme.onSurfaceVariant,
      description: '消耗「$currentName」100点固定资产，将「$targetName」部分股份从幻想乡移至英灵殿',
    );
  }
}
