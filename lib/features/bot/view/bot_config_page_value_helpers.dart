part of 'bot_config_page.dart';

/// bot 配置页面展示值和快照辅助方法
extension _BotConfigPageValueHelpers on _BotConfigPageState {
  /// 生成圣殿选择展示文案
  ///
  /// [characterId] 圣殿角色 ID
  String _templeLabel(int? characterId) {
    final option = _controller.templeOptionFor(characterId);
    if (option != null) {
      return '${option.name} (#${option.characterId})';
    }

    return characterId == null ? '未选择' : '#$characterId';
  }

  /// 构建圣殿选择展示内容
  ///
  /// [characterId] 圣殿角色 ID
  Widget? _templeValueWidget(int? characterId) {
    if (characterId == null) {
      return null;
    }

    final option = _controller.templeOptionFor(characterId);
    final name = option == null || option.name.trim().isEmpty
        ? '#$characterId'
        : option.name.trim();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 16,
            height: 22,
            child: TempleCoverImage(
              coverUrl: TinygrailAssetUrls.getSmallCover(option?.cover ?? ''),
              avatarUrl: '',
              placeholderIconSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// 生成角色选择展示文案
  ///
  /// [characterId] 角色 ID
  String _characterLabel(int? characterId) {
    final option = _controller.characterOptionFor(characterId);
    if (option != null) {
      return '${option.name} (#${option.characterId})';
    }

    return characterId == null ? '未选择' : '#$characterId';
  }

  /// 构建角色选择展示内容
  ///
  /// [characterId] 角色 ID
  Widget? _characterValueWidget(int? characterId) {
    if (characterId == null) {
      return null;
    }

    final option = _controller.characterOptionFor(characterId);
    final name = option == null || option.name.trim().isEmpty
        ? '#$characterId'
        : option.name.trim();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CharacterAvatar(
          imageUrl: TinygrailAssetUrls.normalizeAvatar(option?.icon ?? ''),
          size: 20,
          borderRadius: 10,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// 按角色 ID 读取圣殿选择项
  ///
  /// [characterId] 圣殿角色 ID
  BotTempleOption? _templeOptionFromId(int characterId) {
    return _controller.templeOptionFor(characterId) ??
        BotTempleOption(
          characterId: characterId,
          name: '#$characterId',
          assets: 0,
          sacrifices: 0,
          level: 0,
        );
  }

  /// 记录当前配置快照
  ///
  /// [config] 当前 bot 配置
  void _recordConfigSnapshot(BotConfig config) {
    _savedConfigFingerprint = _configFingerprint(config);
  }

  /// 生成配置对比快照
  ///
  /// [config] 当前 bot 配置
  String _configFingerprint(BotConfig config) {
    final fields = config
        .toFormFields()
        .map((entry) => '${entry.key}=${entry.value}')
        .toList()
      ..sort();
    return fields.join('&');
  }
}
