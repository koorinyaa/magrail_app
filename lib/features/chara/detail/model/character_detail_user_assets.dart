import 'package:magrail_app/features/chara/detail/model/character_detail_user_character.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 角色详情当前用户资产加载状态
enum CharacterDetailUserAssetsStatus {
  /// 当前没有可用于查询资产的登录用户
  signedOut,

  /// 当前用户资产正在加载
  loading,

  /// 当前用户资产已完成加载
  ready,

  /// 当前用户资产加载失败
  failure,
}

/// 角色详情当前用户资产展示状态
final class CharacterDetailUserAssets {
  /// 创建角色详情当前用户资产展示状态
  ///
  /// [status] 当前资产加载状态
  /// [character] 当前用户持股资料
  /// [temple] 当前用户圣殿资料
  /// [errorMessage] 资产加载失败文案
  const CharacterDetailUserAssets({
    required this.status,
    this.character,
    this.temple,
    this.errorMessage,
  });

  /// 创建未登录的角色详情当前用户资产状态
  const CharacterDetailUserAssets.signedOut()
      : status = CharacterDetailUserAssetsStatus.signedOut,
        character = null,
        temple = null,
        errorMessage = null;

  /// 创建加载中的角色详情当前用户资产状态
  const CharacterDetailUserAssets.loading()
      : status = CharacterDetailUserAssetsStatus.loading,
        character = null,
        temple = null,
        errorMessage = null;

  /// 创建加载完成的角色详情当前用户资产状态
  ///
  /// [character] 当前用户持股资料
  /// [temple] 当前用户圣殿资料
  const CharacterDetailUserAssets.ready({
    required CharacterDetailUserCharacter this.character,
    required this.temple,
  })  : status = CharacterDetailUserAssetsStatus.ready,
        errorMessage = null;

  /// 创建加载失败的角色详情当前用户资产状态
  ///
  /// [errorMessage] 资产加载失败文案
  const CharacterDetailUserAssets.failure({
    this.errorMessage,
  })  : status = CharacterDetailUserAssetsStatus.failure,
        character = null,
        temple = null;

  /// 当前资产加载状态
  final CharacterDetailUserAssetsStatus status;

  /// 当前用户持股资料
  final CharacterDetailUserCharacter? character;

  /// 当前用户圣殿资料
  final UserTempleApiItem? temple;

  /// 资产加载失败文案
  final String? errorMessage;
}
