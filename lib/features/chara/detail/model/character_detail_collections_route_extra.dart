import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 角色详情公开展示二级页路由附加数据
class CharacterDetailCollectionsRouteExtra {
  /// 创建角色详情公开展示二级页路由附加数据
  ///
  /// [controller] 一级页面共享的公开展示区控制器
  /// [header] 当前角色详情已上市头部资料
  /// [currentUserName] 当前登录用户名
  /// [userRepository] 用户仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  const CharacterDetailCollectionsRouteExtra({
    required this.controller,
    required this.header,
    required this.currentUserName,
    required this.userRepository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
  });

  /// 一级页面共享的公开展示区控制器
  final CharacterDetailCollectionsController controller;

  /// 当前角色详情已上市头部资料
  final CharacterDetailTradeHeader header;

  /// 当前登录用户名
  final String currentUserName;

  /// 用户仓库
  final UserRepository userRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;
}
