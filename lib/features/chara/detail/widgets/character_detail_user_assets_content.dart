part of 'character_detail_user_assets_section.dart';

/// 当前用户资产列表内容
class _UserAssetsListContent extends StatelessWidget {
  /// 创建当前用户资产列表内容
  ///
  /// [key] Flutter 组件标识
  /// [header] 已上市角色头部资料
  /// [character] 当前用户持股资料
  /// [temple] 当前用户圣殿资料
  /// [currentUserDisplayName] 当前登录用户显示名称
  /// [currentUserName] 当前登录用户名
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [onActionCompleted] 操作成功后的刷新回调
  const _UserAssetsListContent({
    super.key,
    required this.header,
    required this.character,
    required this.temple,
    required this.currentUserDisplayName,
    required this.currentUserName,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.onActionCompleted,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 当前用户持股资料
  final CharacterDetailUserCharacter character;

  /// 当前用户圣殿资料
  final UserTempleApiItem? temple;

  /// 当前登录用户显示名称
  final String currentUserDisplayName;

  /// 当前登录用户名
  final String currentUserName;

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

  /// 操作成功后的刷新回调
  final Future<void> Function() onActionCompleted;

  /// 构建当前用户资产列表内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final temple = this.temple;
    final templeDividend = temple == null
        ? null
        : _calculateTempleDividend(header: header, temple: temple);
    final templeTotalDividend = temple == null || templeDividend == null
        ? null
        : templeDividend * temple.assets;
    final activeDividend = header.dividend * character.amount;
    final showAvailableSeparately = character.amount != character.total;
    final availableText = Formatters.groupedNumber(character.amount);
    final totalText = Formatters.groupedNumber(character.total);

    return TempleAssetCard(
      data: TempleAssetCardData(
        templeId: temple?.id,
        userId: temple?.userId ?? 0,
        characterId: temple?.characterId ?? header.characterId,
        characterName: temple?.name ?? header.name,
        avatar: temple?.avatar ?? header.icon,
        cover: temple?.cover ?? '',
        line: temple?.line ?? '',
        hasLink: temple?.link != null,
        linkCover: temple?.link?.cover ?? '',
        linkAvatar: temple?.link?.avatar ?? '',
        assets: temple?.assets ?? 0,
        sacrifices: temple?.sacrifices ?? 0,
        characterLevel: temple?.characterLevel ?? header.level,
        zeroCount: temple?.zeroCount ?? header.zeroCount,
        level: temple?.level ?? 0,
        starForces: temple?.starForces ?? 0,
        refine: temple?.refine ?? 0,
        primaryValue:
            showAvailableSeparately ? '$availableText / $totalText' : totalText,
        primaryLabel: showAvailableSeparately ? '可用 / 持股' : '持股',
        tags: [
          TempleAssetCardTagData(
            label: '活股总息',
            value: Formatters.tinygrailCompactValue(
              activeDividend,
              prefix: '₵',
            ),
            muted: character.amount <= 0,
          ),
          TempleAssetCardTagData(
            label: '圣殿股息',
            value: templeDividend == null
                ? '--'
                : Formatters.tinygrailCurrency(templeDividend),
            muted: templeDividend == null,
          ),
          TempleAssetCardTagData(
            label: '圣殿总息',
            value: templeTotalDividend == null
                ? '--'
                : Formatters.tinygrailCompactValue(
                    templeTotalDividend,
                    prefix: '₵',
                  ),
            muted: templeTotalDividend == null,
          ),
          TempleAssetCardTagData(
            label: '星之力',
            value: temple == null
                ? '--'
                : Formatters.tinygrailCompactValue(
                    temple.starForces,
                  ),
            muted: temple == null,
            showStarIcon: true,
            starHighlighted: (temple?.starForces ?? 0) >= 10000,
          ),
        ],
        watermarkText: currentUserDisplayName,
        showActions: true,
        hasTemple: temple != null,
        canResetCover: temple != null,
        actionContext: temple == null
            ? null
            : TempleAssetCardActionContext(
                characterRepository: repository,
                templeRepository: templeRepository,
                magicRepository: magicRepository,
                oosRepository: oosRepository,
                userRepository: userRepository,
                currentUserName: currentUserName,
                availableAmount: character.amount,
                onActionCompleted: onActionCompleted,
              ),
        heroTag: temple == null
            ? null
            : 'character-detail-user-temple-${temple.id}-${temple.characterId}',
      ),
    );
  }

  /// 计算圣殿单期股息
  ///
  /// [header] 已上市角色头部资料
  /// [temple] 当前用户圣殿资料
  double _calculateTempleDividend({
    required CharacterDetailTradeHeader header,
    required UserTempleApiItem temple,
  }) {
    if (_isTowerTop500(header.rank)) {
      final characterLevel =
          temple.characterLevel > 0 ? temple.characterLevel : header.level;
      final levelCoefficient = 2 * characterLevel + 1;
      if (levelCoefficient <= 0) {
        return 0;
      }

      final baseRate = header.rate * (601 - header.rank) * 0.005;
      final refineCoefficient = 2 * (characterLevel + temple.refine) + 1;
      return baseRate / levelCoefficient * refineCoefficient;
    }

    return header.dividend;
  }

  /// 判断角色是否处于通天塔前 500 名
  ///
  /// [rank] 通天塔排名
  bool _isTowerTop500(int rank) {
    return rank > 0 && rank <= 500;
  }
}
