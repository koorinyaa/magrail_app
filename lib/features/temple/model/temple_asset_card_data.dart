import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 圣殿资产卡片展示数据
class TempleAssetCardData {
  /// 创建圣殿资产卡片展示数据
  ///
  /// [templeId] 圣殿 ID
  /// [userId] 圣殿所属用户 ID
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [avatar] 角色头像地址
  /// [cover] 圣殿封面地址
  /// [hasLink] 是否携带 LINK 圣殿数据
  /// [linkCover] LINK 圣殿封面地址
  /// [linkAvatar] LINK 圣殿头像地址
  /// [assets] 圣殿资产值
  /// [sacrifices] 圣殿资产上限
  /// [characterLevel] 角色等级
  /// [zeroCount] ST 等级
  /// [level] 圣殿等级
  /// [starForces] 圣殿星之力
  /// [refine] 精炼等级
  /// [primaryValue] 顶部主数值或主文案
  /// [primaryLabel] 顶部说明文案
  /// [showPrimaryLevelBadge] 是否在主文案后显示角色等级标签
  /// [tags] 底部数据标签
  /// [watermarkText] 卡片右上角水印
  /// [showActions] 是否显示完整圣殿操作按钮
  /// [canResetCover] 是否允许重置圣殿图片
  /// [hasTemple] 是否存在圣殿
  /// [actionContext] 圣殿操作所需上下文
  /// [heroTag] 圣殿封面 Hero 标识
  /// [line] 角色台词
  const TempleAssetCardData({
    required this.templeId,
    required this.userId,
    required this.characterId,
    required this.characterName,
    required this.avatar,
    required this.cover,
    required this.line,
    this.hasLink = false,
    this.linkCover = '',
    this.linkAvatar = '',
    required this.assets,
    required this.sacrifices,
    required this.characterLevel,
    required this.zeroCount,
    required this.level,
    required this.starForces,
    required this.refine,
    required this.primaryValue,
    required this.primaryLabel,
    this.showPrimaryLevelBadge = false,
    this.tags = const <TempleAssetCardTagData>[],
    this.watermarkText = '',
    this.showActions = false,
    this.canResetCover = false,
    this.hasTemple = true,
    this.actionContext,
    this.heroTag,
  });

  /// 圣殿 ID
  final int? templeId;

  /// 圣殿所属用户 ID
  final int userId;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 角色头像地址
  final String avatar;

  /// 圣殿封面地址
  final String cover;

  /// 角色台词
  final String line;

  /// 是否携带 LINK 圣殿数据
  final bool hasLink;

  /// LINK 圣殿封面地址
  final String linkCover;

  /// LINK 圣殿头像地址
  final String linkAvatar;

  /// 圣殿资产值
  final int assets;

  /// 圣殿资产上限
  final int sacrifices;

  /// 角色等级
  final int characterLevel;

  /// ST 等级
  final int zeroCount;

  /// 圣殿等级
  final int level;

  /// 圣殿星之力
  final int starForces;

  /// 精炼等级
  final int refine;

  /// 顶部主数值或主文案
  final String primaryValue;

  /// 顶部说明文案
  final String primaryLabel;

  /// 是否在主文案后显示角色等级标签
  final bool showPrimaryLevelBadge;

  /// 底部数据标签
  final List<TempleAssetCardTagData> tags;

  /// 卡片右上角水印
  final String watermarkText;

  /// 是否显示完整圣殿操作按钮
  final bool showActions;

  /// 是否允许重置圣殿图片
  final bool canResetCover;

  /// 是否存在圣殿
  final bool hasTemple;

  /// 圣殿操作所需上下文
  final TempleAssetCardActionContext? actionContext;

  /// 圣殿封面 Hero 标识
  final String? heroTag;

  /// 是否存在可展示的圣殿操作按钮
  bool get hasVisibleActions {
    return hasTemple && (showActions || canResetCover);
  }
}

/// 圣殿资产卡片操作上下文
final class TempleAssetCardActionContext {
  /// 创建圣殿资产卡片操作上下文
  ///
  /// [characterRepository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [currentUserName] 当前登录用户名
  /// [availableAmount] 当前角色可用活股
  /// [onActionCompleted] 操作成功后的刷新回调
  const TempleAssetCardActionContext({
    required this.characterRepository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.currentUserName,
    required this.availableAmount,
    this.onActionCompleted,
  });

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 当前登录用户名
  final String currentUserName;

  /// 当前角色可用活股
  final int availableAmount;

  /// 操作成功后的刷新回调
  final AsyncCallback? onActionCompleted;
}

/// 圣殿资产卡片数据标签
class TempleAssetCardTagData {
  /// 创建圣殿资产卡片数据标签
  ///
  /// [label] 标签名称
  /// [value] 标签数值
  /// [muted] 是否降低强调
  /// [showStarIcon] 是否显示星之力图标
  /// [starHighlighted] 星之力图标是否高亮
  const TempleAssetCardTagData({
    required this.label,
    required this.value,
    this.muted = false,
    this.showStarIcon = false,
    this.starHighlighted = false,
  });

  /// 标签名称
  final String label;

  /// 标签数值
  final String value;

  /// 是否降低强调
  final bool muted;

  /// 是否显示星之力图标
  final bool showStarIcon;

  /// 星之力图标是否高亮
  final bool starHighlighted;
}
