part of 'character_search_page.dart';

/// 角色搜索全屏路由页
class _CharacterSearchRoutePage extends StatelessWidget {
  /// 创建角色搜索全屏路由页
  ///
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [animation] 路由动画
  const _CharacterSearchRoutePage({
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.animation,
  });

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 路由动画
  final Animation<double> animation;

  /// 构建角色搜索全屏路由页
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final pageAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return Material(
      type: MaterialType.transparency,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(pageAnimation),
        child: CharacterSearchPage(
          repository: repository,
          templeRepository: templeRepository,
          magicRepository: magicRepository,
          oosRepository: oosRepository,
          userRepository: userRepository,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
