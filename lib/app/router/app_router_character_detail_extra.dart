part of 'app_router.dart';

/// 从路由附加数据读取角色详情公开展示区控制器
///
/// [extra] 路由附加数据
CharacterDetailCollectionsController?
    _characterDetailCollectionsControllerFromExtra(Object? extra) {
  if (extra is CharacterDetailCollectionsRouteExtra) {
    return extra.controller;
  }

  if (extra is CharacterDetailCollectionsController) {
    return extra;
  }

  return null;
}

/// 从路由附加数据读取角色详情公开展示区上下文
///
/// [extra] 路由附加数据
CharacterDetailCollectionsRouteExtra?
    _characterDetailCollectionsRouteExtraFromExtra(Object? extra) {
  if (extra is CharacterDetailCollectionsRouteExtra) {
    return extra;
  }

  return null;
}
