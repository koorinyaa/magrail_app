import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_participant.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';

/// 角色详情 ICO 参与者控制器
class CharacterDetailIcoParticipantsController
    extends TinygrailPagedListController<CharacterDetailIcoParticipant,
        CharacterDetailIcoParticipant> {
  /// 创建角色详情 ICO 参与者控制器
  ///
  /// [repository] 角色详情仓库
  /// [icoId] ICO 记录 ID
  /// [pageSize] 每页参与者数量
  CharacterDetailIcoParticipantsController({
    required CharacterDetailRepository repository,
    required int icoId,
    super.pageSize = defaultPageSize,
  })  : _repository = repository,
        _icoId = icoId;

  /// ICO 参与者默认分页数量
  static const int defaultPageSize = 24;

  final CharacterDetailRepository _repository;
  final int _icoId;
  int _totalItems = 0;

  /// 接口返回的参与者总数
  int get totalItems => _totalItems;

  /// 校验 ICO 参与者分页请求
  @override
  Object? validatePageRequest() {
    if (_icoId <= 0) {
      return StateError('ICO ID 不能为空');
    }

    return null;
  }

  /// 请求 ICO 参与者分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页参与者数量
  @override
  Future<TinygrailPage<CharacterDetailIcoParticipant>> requestPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repository.fetchCharacterIcoParticipantPage(
      icoId: _icoId,
      page: page,
      pageSize: pageSize,
    );

    if (_totalItems != result.totalItems) {
      _totalItems = result.totalItems;
      notifyListeners();
    }

    return result;
  }

  /// 转换 ICO 参与者展示条目
  ///
  /// [items] 接口返回参与者条目
  @override
  List<CharacterDetailIcoParticipant> convertPageItems(
    List<CharacterDetailIcoParticipant> items,
  ) {
    return items;
  }
}
