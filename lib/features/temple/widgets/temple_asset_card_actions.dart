part of 'temple_asset_card.dart';

/// 圣殿资产操作按钮行
class _TempleAssetActions extends StatelessWidget {
  /// 创建圣殿资产操作按钮行
  ///
  /// [data] 圣殿资产卡片展示数据
  const _TempleAssetActions({
    required this.data,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建圣殿资产操作按钮行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final actions = _visibleActions;
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              if (index > 0) const SizedBox(width: 6),
              _TempleAssetActionButton(
                action: actions[index],
                data: data,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 按圣殿状态筛选当前可展示操作
  List<_TempleAssetActionData> get _visibleActions {
    if (!data.hasTemple) {
      return const [];
    }

    const resetCoverAction = _TempleAssetActionData(
      label: '重置',
      toastLabel: '重置圣殿图片',
      icon: LucideIcons.rotateCcw,
      resetsCover: true,
    );
    if (!data.showActions) {
      return data.canResetCover
          ? const <_TempleAssetActionData>[resetCoverAction]
          : const <_TempleAssetActionData>[];
    }

    return [
      const _TempleAssetActionData(
        label: '虚空道标',
        toastLabel: '虚空道标',
        magicAction: TempleAssetMagicAction.guidepost,
        imageAsset: TempleAssetMagicAssets.guidepostIcon,
      ),
      const _TempleAssetActionData(
        label: '混沌魔方',
        toastLabel: '混沌魔方',
        magicAction: TempleAssetMagicAction.chaosCube,
        imageAsset: TempleAssetMagicAssets.chaosCubeIcon,
      ),
      const _TempleAssetActionData(
        label: '鲤鱼之眼',
        toastLabel: '鲤鱼之眼',
        magicAction: TempleAssetMagicAction.fisheye,
        imageAsset: TempleAssetMagicAssets.fisheyeIcon,
      ),
      const _TempleAssetActionData(
        label: '星光碎片',
        toastLabel: '星光碎片',
        magicAction: TempleAssetMagicAction.stardust,
        imageAsset: TempleAssetMagicAssets.stardustIcon,
      ),
      const _TempleAssetActionData(
        label: '闪光结晶',
        toastLabel: '闪光结晶',
        magicAction: TempleAssetMagicAction.starbreak,
        imageAsset: TempleAssetMagicAssets.starbreakIcon,
      ),
      const _TempleAssetActionData(
        label: '星之力',
        toastLabel: '星之力',
        magicAction: TempleAssetMagicAction.starForces,
        usesStarPowerIcon: true,
      ),
      const _TempleAssetActionData(
        label: '精炼',
        toastLabel: '精炼',
        icon: LucideIcons.sparkles,
        opensRefineSheet: true,
      ),
      const _TempleAssetActionData(
        label: '修改',
        toastLabel: '修改圣殿图片',
        icon: LucideIcons.imageUp,
        updatesCover: true,
      ),
      resetCoverAction,
      const _TempleAssetActionData(
        label: 'LINK',
        toastLabel: 'LINK',
        icon: LucideIcons.link,
        opensLinkSheet: true,
      ),
      const _TempleAssetActionData(
        label: '台词',
        toastLabel: '台词',
        icon: LucideIcons.messageSquareQuote,
        opensLineEditor: true,
      ),
      if (data.sacrifices == data.assets)
        const _TempleAssetActionData(
          label: '拆除',
          toastLabel: '拆除圣殿',
          icon: LucideIcons.trash2,
          destroysTemple: true,
          isDestructive: true,
        ),
    ];
  }
}

/// 圣殿资产操作小按钮
class _TempleAssetActionButton extends StatelessWidget {
  /// 创建圣殿资产操作小按钮
  ///
  /// [action] 圣殿操作配置
  /// [data] 圣殿资产卡片展示数据
  const _TempleAssetActionButton({
    required this.action,
    required this.data,
  });

  /// 圣殿操作配置
  final _TempleAssetActionData action;

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建圣殿资产操作小按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.20 : 0.38,
    );
    final foregroundColor =
        action.isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => _handleTap(context),
        child: Container(
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TempleAssetActionIcon(
                action: action,
                color: foregroundColor,
              ),
              const SizedBox(width: 4),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理操作点击
  ///
  /// [context] 当前组件树上下文
  void _handleTap(BuildContext context) {
    final magicAction = action.magicAction;
    if (action.opensRefineSheet) {
      if (data.actionContext == null) {
        AppToast.error(context, text: '缺少操作上下文');
        return;
      }

      showTempleAssetRefineSheet(context, data: data);
      return;
    }

    if (action.updatesCover) {
      if (data.actionContext == null) {
        AppToast.error(context, text: '缺少操作上下文');
        return;
      }

      unawaited(updateTempleAssetCover(context, data: data));
      return;
    }

    if (action.resetsCover) {
      if (data.actionContext == null) {
        AppToast.error(context, text: '缺少操作上下文');
        return;
      }

      unawaited(resetTempleAssetCover(context, data: data));
      return;
    }

    if (action.opensLinkSheet) {
      if (data.actionContext == null) {
        AppToast.error(context, text: '缺少操作上下文');
        return;
      }

      showTempleAssetLinkSheet(context, data: data);
      return;
    }

    if (action.opensLineEditor) {
      if (data.actionContext == null) {
        AppToast.error(context, text: '缺少操作上下文');
        return;
      }

      unawaited(updateTempleAssetLine(context, data: data));
      return;
    }

    if (action.destroysTemple) {
      if (data.actionContext == null) {
        AppToast.error(context, text: '缺少操作上下文');
        return;
      }

      unawaited(destroyTempleAsset(context, data: data));
      return;
    }

    if (magicAction != null) {
      if (data.actionContext == null) {
        AppToast.error(context, text: '缺少操作上下文');
        return;
      }

      showTempleAssetMagicActionSheet(
        context,
        action: magicAction,
        data: data,
      );
      return;
    }

    AppToast.info(
      context,
      text: '${action.toastLabel}后续接入',
    );
  }
}

/// 圣殿资产操作图标
class _TempleAssetActionIcon extends StatelessWidget {
  /// 创建圣殿资产操作图标
  ///
  /// [action] 圣殿操作配置
  /// [color] 图标颜色
  const _TempleAssetActionIcon({
    required this.action,
    required this.color,
  });

  /// 圣殿操作配置
  final _TempleAssetActionData action;

  /// 图标颜色
  final Color color;

  /// 构建圣殿资产操作图标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final imageAsset = action.imageAsset;
    if (imageAsset != null) {
      return ClipOval(
        child: SizedBox.square(
          dimension: 13,
          child: Transform.scale(
            scale: 1.24,
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                LucideIcons.imageOff,
                size: 13,
                color: color,
              ),
            ),
          ),
        ),
      );
    }

    if (action.usesStarPowerIcon) {
      return Icon(
        Symbols.auto_awesome,
        size: 13,
        fill: 0,
        color: color,
      );
    }

    return Icon(
      action.icon ?? Icons.circle_outlined,
      size: 13,
      color: color,
    );
  }
}

/// 圣殿资产操作骨架行
class _TempleAssetActionsSkeleton extends StatelessWidget {
  /// 创建圣殿资产操作骨架行
  ///
  /// [showResetAction] 是否只显示重置圣殿图片骨架
  const _TempleAssetActionsSkeleton({
    this.showResetAction = false,
  });

  /// 是否只显示重置圣殿图片骨架
  final bool showResetAction;

  /// 构建圣殿资产操作骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (showResetAction) {
      return const ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.hardEdge,
          child: Row(
            children: [
              Bone(
                width: 58,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            ],
          ),
        ),
      );
    }

    return const ClipRect(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Bone(
              width: 76,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SizedBox(width: 6),
            Bone(
              width: 76,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SizedBox(width: 6),
            Bone(
              width: 76,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SizedBox(width: 6),
            Bone(
              width: 76,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SizedBox(width: 6),
            Bone(
              width: 76,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SizedBox(width: 6),
            Bone(
              width: 58,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SizedBox(width: 6),
            Bone(
              width: 58,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SizedBox(width: 6),
            Bone(
              width: 58,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 圣殿资产操作配置
class _TempleAssetActionData {
  /// 创建圣殿资产操作配置
  ///
  /// [label] 按钮展示文案
  /// [toastLabel] 操作反馈文案
  /// [icon] 本地图标
  /// [imageAsset] 本地图标资源
  /// [magicAction] 魔法道具操作类型
  /// [usesStarPowerIcon] 是否使用星之力图标
  /// [opensRefineSheet] 是否打开精炼抽屉
  /// [updatesCover] 是否更新圣殿封面
  /// [resetsCover] 是否重置圣殿图片
  /// [opensLinkSheet] 是否打开圣殿 LINK 抽屉
  /// [opensLineEditor] 是否打开圣殿台词编辑面板
  /// [destroysTemple] 是否拆除圣殿
  /// [isDestructive] 是否为危险操作
  const _TempleAssetActionData({
    required this.label,
    required this.toastLabel,
    this.icon,
    this.imageAsset,
    this.magicAction,
    this.usesStarPowerIcon = false,
    this.opensRefineSheet = false,
    this.updatesCover = false,
    this.resetsCover = false,
    this.opensLinkSheet = false,
    this.opensLineEditor = false,
    this.destroysTemple = false,
    this.isDestructive = false,
  });

  /// 按钮展示文案
  final String label;

  /// 操作反馈文案
  final String toastLabel;

  /// 本地图标
  final IconData? icon;

  /// 本地图标资源
  final String? imageAsset;

  /// 魔法道具操作类型
  final TempleAssetMagicAction? magicAction;

  /// 是否使用星之力图标
  final bool usesStarPowerIcon;

  /// 是否打开精炼抽屉
  final bool opensRefineSheet;

  /// 是否更新圣殿封面
  final bool updatesCover;

  /// 是否重置圣殿图片
  final bool resetsCover;

  /// 是否打开圣殿 LINK 抽屉
  final bool opensLinkSheet;

  /// 是否打开圣殿台词编辑面板
  final bool opensLineEditor;

  /// 是否拆除圣殿
  final bool destroysTemple;

  /// 是否为危险操作
  final bool isDestructive;
}
