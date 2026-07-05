import 'dart:math' as math;

import 'package:magrail_app/features/chara/model/tinygrail_character_reward_item.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_data.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 圣殿资产魔法道具操作进度回调
///
/// [remainingAmount] 剩余需要处理的活股数量
typedef TempleAssetMagicProgressCallback = void Function(int remainingAmount);

/// 闪光结晶确认弹窗刷新结果
final class TempleAssetMagicStarbreakRefreshResult {
  /// 创建闪光结晶确认弹窗刷新结果
  ///
  /// [data] 刷新后的圣殿资产卡片数据
  /// [target] 刷新后的目标角色数据
  const TempleAssetMagicStarbreakRefreshResult({
    this.data,
    this.target,
  });

  /// 刷新后的圣殿资产卡片数据
  final TempleAssetCardData? data;

  /// 刷新后的目标角色数据
  final UserCharacterApiItem? target;
}

/// 圣殿资产魔法道具操作流程控制器
final class TempleAssetMagicActionController {
  /// 创建圣殿资产魔法道具操作流程控制器
  const TempleAssetMagicActionController();

  /// 提交混沌魔方并返回抽取结果
  ///
  /// [data] 当前圣殿资产卡片数据
  Future<TinygrailCharacterRewardItem> submitChaosCubeDraw(
    TempleAssetCardData data,
  ) {
    return data.actionContext!.magicRepository.useChaosCube(
      consumeCharacterId: data.characterId,
    );
  }

  /// 提交虚空道标
  ///
  /// [data] 当前圣殿资产卡片数据
  /// [targetCharacterId] 目标角色 ID
  Future<TinygrailCharacterRewardItem> submitGuidepost({
    required TempleAssetCardData data,
    required int targetCharacterId,
  }) {
    return data.actionContext!.magicRepository.useGuidepost(
      consumeCharacterId: data.characterId,
      targetCharacterId: targetCharacterId,
    );
  }

  /// 提交指定目标的鲤鱼之眼
  ///
  /// [data] 当前圣殿资产卡片数据
  /// [consumeCharacterId] 消耗固定资产的角色 ID
  /// [targetCharacterId] 目标角色 ID
  Future<String> submitFisheyeForTarget({
    required TempleAssetCardData data,
    required int consumeCharacterId,
    required int targetCharacterId,
  }) {
    return data.actionContext!.magicRepository.useFisheye(
      consumeCharacterId: consumeCharacterId,
      targetCharacterId: targetCharacterId,
    );
  }

  /// 提交星光碎片
  ///
  /// [data] 当前圣殿资产卡片数据
  /// [sourceCharacterId] 消耗活股的角色 ID
  /// [amount] 消耗数量
  /// [isDownSacrifices] 是否降低固定资产上限
  Future<String> submitStardust({
    required TempleAssetCardData data,
    required int sourceCharacterId,
    required int amount,
    required bool isDownSacrifices,
  }) {
    return data.actionContext!.magicRepository.useStardust(
      consumeCharacterId: sourceCharacterId,
      targetCharacterId: data.characterId,
      amount: amount,
      isDownSacrifices: isDownSacrifices,
    );
  }

  /// 提交闪光结晶
  ///
  /// [data] 当前圣殿资产卡片数据
  /// [targetCharacterId] 目标角色 ID
  Future<String> submitStarbreak({
    required TempleAssetCardData data,
    required int targetCharacterId,
  }) {
    return data.actionContext!.magicRepository.useStarbreak(
      consumeCharacterId: data.characterId,
      targetCharacterId: targetCharacterId,
    );
  }

  /// 提交星之力转化或冲星
  ///
  /// [data] 当前圣殿资产卡片数据
  /// [amount] 手动转化数量
  /// [isFillStar] 是否执行冲星流程
  /// [onFillProgress] 冲星过程进度回调
  Future<String> submitStarForces({
    required TempleAssetCardData data,
    required int amount,
    required bool isFillStar,
    TempleAssetMagicProgressCallback? onFillProgress,
  }) {
    if (isFillStar) {
      return fillStarForces(data: data, onProgress: onFillProgress);
    }

    return data.actionContext!.magicRepository.convertStarForces(
      characterId: data.characterId,
      amount: amount,
    );
  }

  /// 补足 10000 星之力
  ///
  /// [data] 当前圣殿资产卡片数据
  /// [onProgress] 剩余活股进度回调
  Future<String> fillStarForces({
    required TempleAssetCardData data,
    TempleAssetMagicProgressCallback? onProgress,
  }) async {
    final requiredStarForces = math.max(0, 10000 - data.starForces);
    final requiredTempleAmount = math.min(data.assets, requiredStarForces);
    var remainingStockAmount =
        ((requiredStarForces - requiredTempleAmount) / 2).ceil();

    if (requiredTempleAmount > 0) {
      await data.actionContext!.magicRepository.convertStarForces(
        characterId: data.characterId,
        amount: requiredTempleAmount,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    final singleMaxAmount = math.max(1, data.sacrifices ~/ 2);
    while (remainingStockAmount > 0) {
      final amount = math.min(singleMaxAmount, remainingStockAmount);
      onProgress?.call(remainingStockAmount);
      await data.actionContext!.characterRepository.sacrificeCharacter(
        characterId: data.characterId,
        amount: amount,
        isFinancing: false,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await data.actionContext!.magicRepository.convertStarForces(
        characterId: data.characterId,
        amount: amount * 2,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      remainingStockAmount -= amount;
    }

    return '冲星成功';
  }

  /// 刷新当前圣殿资产卡片数据
  ///
  /// [data] 当前圣殿资产卡片数据
  Future<TempleAssetCardData?> refreshActionSheetData(
    TempleAssetCardData data,
  ) async {
    final actionContext = data.actionContext;
    final username = actionContext?.currentUserName.trim() ?? '';
    if (actionContext == null || username.isEmpty) {
      return null;
    }

    final templePageFuture = actionContext.userRepository.fetchUserTemplePage(
      username: username,
      page: 1,
      pageSize: 1,
      characterIds: [data.characterId],
    );
    final tradingFuture = actionContext.characterRepository
        .fetchCurrentUserTrading(data.characterId);
    final templePage = await templePageFuture;
    final trading = await tradingFuture;
    UserTempleApiItem? temple;
    for (final item in templePage.items) {
      if (item.characterId == data.characterId) {
        temple = item;
        break;
      }
    }

    if (temple == null) {
      return null;
    }

    return mergeTempleData(data: data, temple: temple, trading: trading);
  }

  /// 合并刷新后的圣殿资产数据
  ///
  /// [data] 当前圣殿资产卡片数据
  /// [temple] 当前角色圣殿数据
  /// [trading] 当前用户交易数据
  TempleAssetCardData mergeTempleData({
    required TempleAssetCardData data,
    required UserTempleApiItem temple,
    CharacterDetailUserTrading? trading,
  }) {
    final actionContext = data.actionContext;
    return TempleAssetCardData(
      templeId: temple.id,
      userId: temple.userId,
      characterId: data.characterId,
      characterName: data.characterName,
      avatar: data.avatar,
      cover: temple.cover,
      line: temple.line,
      hasLink: temple.link != null,
      linkCover: temple.link?.cover ?? '',
      linkAvatar: temple.link?.avatar ?? '',
      assets: temple.assets,
      sacrifices: temple.sacrifices,
      characterLevel: data.characterLevel,
      zeroCount: data.zeroCount,
      level: temple.level,
      starForces: temple.starForces,
      refine: temple.refine,
      primaryValue: data.primaryValue,
      primaryLabel: data.primaryLabel,
      showPrimaryLevelBadge: data.showPrimaryLevelBadge,
      tags: data.tags,
      watermarkText: data.watermarkText,
      showActions: data.showActions,
      hasTemple: data.hasTemple,
      canResetCover: data.canResetCover,
      actionContext: actionContext == null
          ? null
          : TempleAssetCardActionContext(
              characterRepository: actionContext.characterRepository,
              templeRepository: actionContext.templeRepository,
              magicRepository: actionContext.magicRepository,
              oosRepository: actionContext.oosRepository,
              userRepository: actionContext.userRepository,
              currentUserName: actionContext.currentUserName,
              availableAmount: trading?.amount ?? actionContext.availableAmount,
              onActionCompleted: actionContext.onActionCompleted,
            ),
      heroTag: data.heroTag,
    );
  }

  /// 刷新闪光结晶独立确认弹窗数据
  ///
  /// [data] 当前圣殿资产卡片数据
  /// [targetCharacterId] 目标角色 ID
  Future<TempleAssetMagicStarbreakRefreshResult>
      refreshDetachedStarbreakDialogData({
    required TempleAssetCardData data,
    required int targetCharacterId,
  }) async {
    final actionContext = data.actionContext;
    final username = actionContext?.currentUserName.trim() ?? '';
    if (actionContext == null || username.isEmpty) {
      return const TempleAssetMagicStarbreakRefreshResult();
    }

    try {
      await actionContext.onActionCompleted?.call();
    } catch (_) {
      // 外层刷新失败时保留确认框当前展示数据
    }

    TempleAssetCardData? refreshedData;
    try {
      final templePage = await actionContext.userRepository.fetchUserTemplePage(
        username: username,
        page: 1,
        pageSize: 1,
        characterIds: [data.characterId],
      );
      for (final item in templePage.items) {
        if (item.characterId == data.characterId) {
          refreshedData = mergeTempleData(data: data, temple: item);
          break;
        }
      }
    } catch (_) {
      // 圣殿数据刷新失败时保留确认框当前展示数据
    }

    UserCharacterApiItem? refreshedTarget;
    try {
      final page = await actionContext.userRepository.fetchUserCharacterPage(
        username: username,
        page: 1,
        pageSize: 1,
        characterIds: [targetCharacterId],
      );
      for (final item in page.items) {
        if (item.characterId == targetCharacterId) {
          refreshedTarget = item;
          break;
        }
      }
    } catch (_) {
      // 目标角色刷新失败时保留确认框当前展示数据
    }

    return TempleAssetMagicStarbreakRefreshResult(
      data: refreshedData,
      target: refreshedTarget,
    );
  }
}
