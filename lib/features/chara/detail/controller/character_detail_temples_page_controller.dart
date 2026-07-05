import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';

/// 角色固定资产二级页面控制器
class CharacterDetailTemplesPageController extends ChangeNotifier {
  /// 创建角色固定资产二级页面控制器
  ///
  /// [collectionsController] 一级页面共享的公开展示区控制器
  CharacterDetailTemplesPageController({
    CharacterDetailCollectionsController? collectionsController,
  }) : _collectionsController = collectionsController {
    _collectionsController?.addListener(notifyListeners);
  }

  final CharacterDetailCollectionsController? _collectionsController;

  /// 固定资产完整合并列表
  List<CharacterDetailTempleItem> get items {
    return _collectionsController?.mergedTemples ??
        const <CharacterDetailTempleItem>[];
  }

  /// 释放角色固定资产二级页面控制器
  @override
  void dispose() {
    _collectionsController?.removeListener(notifyListeners);
    super.dispose();
  }
}
