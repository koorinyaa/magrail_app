import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/trade_history/model/character_gm_trade_history_item.dart';
import 'package:magrail_app/features/chara/trade_history/repository/character_trade_history_repository.dart';

/// 角色 GM 交易记录二级页面控制器
class CharacterGmTradeHistoryPageController
    extends TinygrailPagedListController<CharacterGmTradeHistoryItem,
        CharacterGmTradeHistoryItem> {
  /// 创建角色 GM 交易记录二级页面控制器
  ///
  /// [repository] 角色交易记录仓库
  /// [characterId] 角色 ID
  /// [pageSize] 每页记录数量
  CharacterGmTradeHistoryPageController({
    required CharacterTradeHistoryRepository repository,
    required int characterId,
    super.pageSize = defaultPageSize,
  })  : _repository = repository,
        _characterId = characterId;

  /// GM 交易记录默认分页数量
  static const int defaultPageSize = 50;

  final CharacterTradeHistoryRepository _repository;
  final int _characterId;

  /// 校验 GM 交易记录分页请求边界
  @override
  Object? validatePageRequest() {
    if (_characterId <= 0) {
      return StateError('缺少角色 ID');
    }

    return null;
  }

  /// 请求角色 GM 交易记录分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页记录数量
  @override
  Future<TinygrailPage<CharacterGmTradeHistoryItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchCharacterGmTradeHistory(
      characterId: _characterId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换角色 GM 交易记录展示条目
  ///
  /// [items] 接口返回记录条目
  @override
  List<CharacterGmTradeHistoryItem> convertPageItems(
    List<CharacterGmTradeHistoryItem> items,
  ) {
    return items;
  }
}
