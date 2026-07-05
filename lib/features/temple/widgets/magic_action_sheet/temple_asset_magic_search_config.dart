part of '../temple_asset_magic_action_sheet.dart';

extension _TempleAssetMagicSearchConfig on _TempleAssetMagicActionSheetState {
  /// 构建魔法角色搜索面板
  Widget _buildCharacterSearchPanel() {
    final actionContext = _data.actionContext!;
    return TempleAssetMagicCharacterSearchPanel(
      key: _searchPanelKey,
      header: _TempleAssetMagicSheetHeader(
        action: widget.action,
        characterName: _TempleAssetMagicStateQueries(this)._characterName,
        characterId: _data.characterId,
      ),
      hintText: _TempleAssetMagicStateQueries(this)._searchHint,
      currentUserName: actionContext.currentUserName,
      recentStorageKeyPrefix: _recentMagicCharacterIdsKeyPrefix,
      characterRepository: actionContext.characterRepository,
      userRepository: actionContext.userRepository,
      secondaryTextBuilder: _searchSecondaryTextFor,
      supplementLoader: widget.action == TempleAssetMagicAction.fisheye
          ? _loadFisheyeGensokyoAmounts
          : null,
      onSelected: _selectCharacter,
    );
  }

  /// 加载鲤鱼之眼幻想乡持股
  ///
  /// [items] 当前批次搜索条目
  Future<Map<int, int>> _loadFisheyeGensokyoAmounts(
    List<TempleAssetMagicCharacterSearchItem> items,
  ) async {
    final characterIds = items
        .map((item) => item.characterId)
        .where((characterId) => characterId > 0)
        .toSet()
        .toList(growable: false);
    if (characterIds.isEmpty) {
      return const <int, int>{};
    }

    final page =
        await _data.actionContext!.userRepository.fetchUserCharacterPage(
      username: 'blueleaf',
      page: 1,
      pageSize: characterIds.length,
      characterIds: characterIds,
    );
    return <int, int>{
      for (final item in page.items) item.characterId: item.userTotal,
    };
  }

  /// 获取搜索结果第二行文案
  ///
  /// [item] 搜索条目

  /// [supplementValue] 附加数值
  String _searchSecondaryTextFor(
    TempleAssetMagicCharacterSearchItem item,
    int? supplementValue,
  ) {
    if (widget.action == TempleAssetMagicAction.fisheye) {
      final amountText = supplementValue == null
          ? '???'
          : Formatters.groupedNumber(supplementValue);
      return '幻想乡 $amountText';
    }
    if (widget.action == TempleAssetMagicAction.stardust) {
      return '可用 ${Formatters.groupedNumber(math.max(0, item.userAmount))} 股';
    }
    if (widget.action == TempleAssetMagicAction.starbreak) {
      return '星之力 ${Formatters.groupedNumber(math.max(0, item.starForces))}';
    }

    return TempleAssetMagicCharacterSearchPanel.defaultSecondaryText(
      item,
      supplementValue,
    );
  }

  /// 生成最近使用缓存键前缀
  String get _recentMagicCharacterIdsKeyPrefix {
    return switch (widget.action) {
      TempleAssetMagicAction.fisheye =>
        _TempleAssetMagicActionSheetState._fisheyeRecentCharacterIdsKeyPrefix,
      TempleAssetMagicAction.stardust =>
        _TempleAssetMagicActionSheetState._stardustRecentCharacterIdsKeyPrefix,
      TempleAssetMagicAction.starbreak =>
        _TempleAssetMagicActionSheetState._starbreakRecentCharacterIdsKeyPrefix,
      _ =>
        _TempleAssetMagicActionSheetState._guidepostRecentCharacterIdsKeyPrefix,
    };
  }
}
