part of 'character_detail_page_body.dart';

/// 角色详情 ICO 启动主体
class _CharacterDetailInitialBody extends StatelessWidget {
  /// 创建角色详情 ICO 启动主体
  ///
  /// [key] Flutter 组件标识
  /// [item] 当前角色资料
  /// [repository] 角色详情仓库
  /// [isAuthorized] 当前 Tinygrail 会话是否可用
  /// [showAuthGuide] 是否显示授权引导
  /// [currentUserBalance] 当前登录用户余额
  /// [onAuthorize] 打开 Tinygrail 授权页回调
  /// [onIcoStarted] ICO 启动成功回调
  const _CharacterDetailInitialBody({
    super.key,
    required this.item,
    required this.repository,
    required this.isAuthorized,
    required this.showAuthGuide,
    required this.currentUserBalance,
    required this.onAuthorize,
    required this.onIcoStarted,
  });

  /// 当前角色资料
  final CharacterDetailHistoryItem item;

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 当前 Tinygrail 会话是否可用
  final bool isAuthorized;

  /// 是否显示授权引导
  final bool showAuthGuide;

  /// 当前登录用户余额
  final double? currentUserBalance;

  /// 打开 Tinygrail 授权页回调
  final Future<void> Function() onAuthorize;

  /// ICO 启动成功回调
  final Future<void> Function() onIcoStarted;

  /// 构建角色详情 ICO 启动主体
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      sliver: SliverList.list(
        children: [
          CharacterDetailIcoStartSection(
            characterId: item.characterId,
            displayName: item.displayName,
            repository: repository,
            isAuthorized: isAuthorized,
            showAuthGuide: showAuthGuide,
            userBalance: currentUserBalance,
            onAuthorize: onAuthorize,
            onStarted: onIcoStarted,
          ),
        ],
      ),
    );
  }
}
