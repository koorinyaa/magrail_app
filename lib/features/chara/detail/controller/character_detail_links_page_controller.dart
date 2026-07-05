import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';

/// 角色 LINK 二级页面控制器
class CharacterDetailLinksPageController extends ChangeNotifier {
  /// 创建角色 LINK 二级页面控制器
  ///
  /// [collectionsController] 一级页面共享的公开展示区控制器
  CharacterDetailLinksPageController({
    CharacterDetailCollectionsController? collectionsController,
  }) : _collectionsController = collectionsController {
    _collectionsController?.addListener(notifyListeners);
  }

  final CharacterDetailCollectionsController? _collectionsController;

  /// 有效 LINK 原始列表
  List<CharacterDetailTempleItem> get items {
    return _collectionsController?.validLinks ??
        const <CharacterDetailTempleItem>[];
  }

  /// 按 LINK 目标角色分组后的列表
  List<CharacterDetailLinkGroup> get groups {
    final grouped = <int, List<CharacterDetailTempleItem>>{};
    for (final item in items) {
      final groupKey =
          item.linkId == 0 ? item.link?.characterId ?? 0 : item.linkId;
      grouped
          .putIfAbsent(groupKey, () => <CharacterDetailTempleItem>[])
          .add(item);
    }

    final result = [
      for (final entry in grouped.entries)
        CharacterDetailLinkGroup(
          linkId: entry.key,
          items: List.unmodifiable(entry.value),
        ),
    ];
    result.sort(
      (left, right) => right.items.length.compareTo(left.items.length),
    );
    return result;
  }

  /// 释放角色 LINK 二级页面控制器
  @override
  void dispose() {
    _collectionsController?.removeListener(notifyListeners);
    super.dispose();
  }
}

/// 角色 LINK 分组
class CharacterDetailLinkGroup {
  /// 创建角色 LINK 分组
  ///
  /// [linkId] LINK 目标角色 ID
  /// [items] 分组内 LINK 条目
  const CharacterDetailLinkGroup({
    required this.linkId,
    required this.items,
  });

  /// LINK 目标角色 ID
  final int linkId;

  /// 分组内 LINK 条目
  final List<CharacterDetailTempleItem> items;

  /// 分组内条目数量
  int get count => items.length;

  /// LINK 目标角色名称
  String linkedCharacterName(String fallback) {
    for (final item in items) {
      final linked = item.link;
      if (linked == null) {
        continue;
      }

      final name = linked.displayCharacterName(fallback).trim();
      if (name.isNotEmpty) {
        return name;
      }
    }

    return fallback;
  }
}
