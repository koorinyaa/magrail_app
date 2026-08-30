part of 'user_character_page.dart';

/// 用户角色二级页面操作
extension _UserCharacterPageActions on _UserCharacterPageState {
  /// 查询其他用户的角色未公开持股
  ///
  /// [item] 用户角色条目
  Future<int?> _revealCharacterHoldings(UserCharacterApiItem item) async {
    if (_isCurrentUser || widget.username.trim().isEmpty) {
      return null;
    }

    final holding = await widget.characterDetailRepository
        .fetchUserCharacterHolding(item.characterId, widget.username.trim());
    return holding?.total;
  }

  /// 打开角色详情页
  ///
  /// [item] 用户角色条目
  /// [avatarHeroTag] 入口头像转场标识
  void _openCharacterDetail(UserCharacterApiItem item, String? avatarHeroTag) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.icon,
      avatarHeroTag: avatarHeroTag,
    );
  }

  /// 显示角色数据刷新失败提示
  void _showAutomaticRefreshFailed() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    AppToast.error(context, text: '数据刷新失败');
  }

  /// 是否展示当前登录用户的本地角色快照
  bool get _isCurrentUser {
    final username = widget.username.trim().toLowerCase();
    final currentUserName = widget.currentUserName.trim().toLowerCase();
    return username.isNotEmpty && username == currentUserName;
  }

  /// 页面标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return '$nickname的角色';
    }
    if (widget.username.isNotEmpty) {
      return '${widget.username}的角色';
    }
    return '用户角色';
  }
}
