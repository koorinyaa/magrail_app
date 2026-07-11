part of 'user_asset_analysis_page.dart';

/// 用户资产分析页面导航
extension _UserAssetAnalysisPageNavigation on _UserAssetAnalysisPageState {
  /// 打开登录用户角色二级页面
  void _openUserCharacters() {
    context.pushNamed(
      'userCharacters',
      queryParameters: {
        'username': widget.username,
        'nickname': widget.nickname ?? '',
      },
    );
  }

  /// 打开登录用户圣殿二级页面
  void _openUserTemples() {
    context.pushNamed(
      'userTemples',
      queryParameters: {
        'username': widget.username,
        'nickname': widget.nickname ?? '',
        'currentUserName': widget.username,
      },
    );
  }

  /// 打开登录用户星光圣殿二级页面
  void _openUserStarlightTemples() {
    context.pushNamed(
      'userStarlightTemples',
      queryParameters: {
        'username': widget.username,
        'nickname': widget.nickname ?? '',
        'currentUserName': widget.username,
      },
    );
  }

  /// 打开角色详情页
  ///
  /// [bubble] 角色圆图气泡
  void _openCharacterDetail(UserAssetAnalysisCharacterBubble bubble) {
    if (bubble.characterId <= 0) {
      return;
    }

    openCharacterDetail(
      context,
      characterId: bubble.characterId,
      name: bubble.name,
      avatarUrl: bubble.avatarUrl,
      avatarHeroTag: createCharacterDetailAvatarHeroTag(
        characterId: bubble.characterId,
        avatarUrl: bubble.avatarUrl,
        source: bubble,
      ),
    );
  }
}
