import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_board_member.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';

/// 角色董事会二级页面控制器
class CharacterDetailBoardPageController extends TinygrailPagedListController<
    CharacterDetailBoardMember, CharacterDetailBoardMember> {
  /// 创建角色董事会二级页面控制器
  ///
  /// [repository] 角色详情仓库
  /// [characterId] 角色 ID
  /// [collectionsController] 一级页面共享的公开展示区控制器
  /// [pageSize] 每页董事会成员数量
  CharacterDetailBoardPageController({
    required CharacterDetailRepository repository,
    required int characterId,
    CharacterDetailCollectionsController? collectionsController,
    super.pageSize = defaultPageSize,
  })  : _repository = repository,
        _characterId = characterId,
        _collectionsController = collectionsController {
    _collectionsController?.addListener(notifyListeners);
  }

  /// 角色董事会默认分页数量
  static const int defaultPageSize = 20;

  final CharacterDetailRepository _repository;
  final int _characterId;
  final CharacterDetailCollectionsController? _collectionsController;

  /// 查找用户对应的圣殿条目
  ///
  /// [member] 董事会成员
  CharacterDetailTempleItem? templeFor(CharacterDetailBoardMember member) {
    final username = member.name.trim();
    if (username.isEmpty) {
      return null;
    }

    return _collectionsController?.templeForOwnerName(username);
  }

  /// 校验角色董事会分页请求
  @override
  Object? validatePageRequest() {
    if (_characterId <= 0) {
      return StateError('角色 ID 不能为空');
    }

    return null;
  }

  /// 请求角色董事会分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页董事会成员数量
  @override
  Future<TinygrailPage<CharacterDetailBoardMember>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchCharacterBoardMemberPage(
      characterId: _characterId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换角色董事会展示条目
  ///
  /// [items] 接口返回董事会条目
  @override
  List<CharacterDetailBoardMember> convertPageItems(
    List<CharacterDetailBoardMember> items,
  ) {
    return items;
  }

  /// 释放角色董事会二级页面控制器
  @override
  void dispose() {
    _collectionsController?.removeListener(notifyListeners);
    super.dispose();
  }
}
