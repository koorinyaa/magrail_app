part of 'bot_selection_sheet.dart';

/// bot 魔法道具目标角色抽屉
class _BotMagicCharacterSearchSheet extends StatelessWidget {
  /// 创建 bot 魔法道具目标角色抽屉
  ///
  /// [title] 抽屉标题
  /// [description] 抽屉说明文案
  /// [currentUserName] 当前登录用户名
  /// [recentStorageKeyPrefix] 最近使用缓存键前缀
  /// [characterRepository] 角色仓库
  /// [userRepository] 用户仓库
  /// [imageAsset] 标题图片资源
  /// [fallbackIcon] 标题图片失败图标
  /// [secondaryTextBuilder] 第二行文案构造器
  /// [supplementLoader] 静默附加数值加载器
  const _BotMagicCharacterSearchSheet({
    required this.title,
    required this.description,
    required this.currentUserName,
    required this.recentStorageKeyPrefix,
    required this.characterRepository,
    required this.userRepository,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.secondaryTextBuilder,
    required this.supplementLoader,
  });

  /// 抽屉标题
  final String title;

  /// 抽屉说明文案
  final String description;

  /// 当前登录用户名
  final String currentUserName;

  /// 最近使用缓存键前缀
  final String recentStorageKeyPrefix;

  /// 角色仓库
  final CharacterDetailRepository characterRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 标题图片资源
  final String imageAsset;

  /// 标题图片失败图标
  final IconData fallbackIcon;

  /// 第二行文案构造器
  final TempleAssetMagicSearchSecondaryTextBuilder secondaryTextBuilder;

  /// 静默附加数值加载器
  final TempleAssetMagicSearchSupplementLoader? supplementLoader;

  /// 构建 bot 魔法道具目标角色抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.58,
                ),
              ),
            ),
          ),
          child: SafeArea(
            left: false,
            right: false,
            top: false,
            child: Padding(
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 20,
                top: 10,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBottomSheetDragHandle(),
                  const SizedBox(height: 10),
                  Flexible(
                    child: TempleAssetMagicCharacterSearchPanel(
                      header: _BotMagicCharacterSearchHeader(
                        title: title,
                        imageAsset: imageAsset,
                        fallbackIcon: fallbackIcon,
                      ),
                      hintText: description,
                      currentUserName: currentUserName,
                      recentStorageKeyPrefix: recentStorageKeyPrefix,
                      characterRepository: characterRepository,
                      userRepository: userRepository,
                      secondaryTextBuilder: secondaryTextBuilder,
                      supplementLoader: supplementLoader,
                      onSelected: (item, _) {
                        unawaited(
                          saveTempleAssetMagicRecentCharacterId(
                            storageKeyPrefix: recentStorageKeyPrefix,
                            username: currentUserName,
                            characterId: item.characterId,
                          ).catchError((_) {}),
                        );
                        Navigator.of(context).pop(
                          BotCharacterOption(
                            characterId: item.characterId,
                            name: item.name,
                            level: item.level,
                            icon: item.icon,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// bot 魔法道具目标角色抽屉标题
class _BotMagicCharacterSearchHeader extends StatelessWidget {
  /// 创建 bot 魔法道具目标角色抽屉标题
  ///
  /// [title] 标题文案
  /// [imageAsset] 标题图片资源
  /// [fallbackIcon] 标题图片失败图标
  const _BotMagicCharacterSearchHeader({
    required this.title,
    required this.imageAsset,
    required this.fallbackIcon,
  });

  /// 标题文案
  final String title;

  /// 标题图片资源
  final String imageAsset;

  /// 标题图片失败图标
  final IconData fallbackIcon;

  /// 构建 bot 魔法道具目标角色抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox.square(
            dimension: 40,
            child: Transform.scale(
              scale: 1.24,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      fallbackIcon,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '选择目标角色',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
