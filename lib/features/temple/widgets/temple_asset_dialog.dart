import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_data.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_card.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 通过入口数据显示圣殿资产弹窗
///
/// [context] 当前组件树上下文
/// [source] 圣殿资产弹窗入口数据
/// [characterRepository] 角色详情仓库
/// [templeRepository] 圣殿仓库
/// [magicRepository] 圣殿资产魔法道具仓库
/// [oosRepository] Tinygrail OOS 仓库
/// [userRepository] 用户仓库
/// [currentUserName] 当前登录用户名
Future<void> showTempleAssetCardDialogFromSource(
  BuildContext context, {
  required TempleAssetDialogSource source,
  required CharacterDetailRepository characterRepository,
  required TempleRepository templeRepository,
  required TempleAssetMagicRepository magicRepository,
  required TinygrailOosRepository oosRepository,
  required UserRepository userRepository,
  required String currentUserName,
}) {
  final ownerName = source.ownerName.trim();
  if (ownerName.isEmpty) {
    AppToast.error(context, text: '缺少圣殿所属用户');
    return Future<void>.value();
  }

  if (source.characterId <= 0) {
    AppToast.error(context, text: '缺少圣殿角色 ID');
    return Future<void>.value();
  }

  final colorScheme = Theme.of(context).colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;
  final screenWidth = MediaQuery.sizeOf(context).width;
  final dialogWidth = (screenWidth - 32).clamp(0.0, 380.0).toDouble();

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: isDark ? 0.38 : 0.22),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) {
      return BackdropFilter(
        filter: AppBlurStyle.filter,
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {},
                    child: SizedBox(
                      width: dialogWidth,
                      child: _TempleAssetSourceDialogContent(
                        source: source,
                        characterRepository: characterRepository,
                        templeRepository: templeRepository,
                        magicRepository: magicRepository,
                        oosRepository: oosRepository,
                        userRepository: userRepository,
                        currentUserName: currentUserName,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = animation.drive(
        CurveTween(curve: Curves.easeOutCubic),
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.98, end: 1).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

/// 圣殿资产弹窗加载内容
class _TempleAssetSourceDialogContent extends StatefulWidget {
  /// 创建圣殿资产弹窗加载内容
  ///
  /// [source] 圣殿资产弹窗入口数据
  /// [characterRepository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [currentUserName] 当前登录用户名
  const _TempleAssetSourceDialogContent({
    required this.source,
    required this.characterRepository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.currentUserName,
  });

  /// 圣殿资产弹窗入口数据
  final TempleAssetDialogSource source;

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 当前登录用户名
  final String currentUserName;

  /// 创建圣殿资产弹窗加载内容状态
  @override
  State<_TempleAssetSourceDialogContent> createState() =>
      _TempleAssetSourceDialogContentState();
}

/// 圣殿资产弹窗加载内容状态
class _TempleAssetSourceDialogContentState
    extends State<_TempleAssetSourceDialogContent> {
  late Future<TempleAssetCardData> _future;

  /// 初始化圣殿资产弹窗加载内容状态
  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  /// 构建圣殿资产弹窗加载内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TempleAssetCardData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null) {
          return TempleAssetCard(
            data: data,
            enableCoverPreview: false,
          );
        }

        if (snapshot.hasError) {
          return _TempleAssetDialogFailedPanel(
            message: _messageForError(snapshot.error),
            onRetry: _retry,
          );
        }

        return TempleAssetCardSkeleton(
          showActions: _shouldShowActions,
          showResetAction: _canResetCover && !_shouldShowActions,
        );
      },
    );
  }

  /// 是否显示完整圣殿操作区
  bool get _shouldShowActions {
    return _isCurrentUserTemple;
  }

  /// 是否显示任意圣殿操作区
  bool get _hasVisibleActions {
    return _shouldShowActions || _canResetCover;
  }

  /// 是否允许重置圣殿图片
  bool get _canResetCover {
    return _isCurrentUserTemple ||
        (widget.userRepository.readCachedCurrentUserAssets()?.isGameMaster ??
            false);
  }

  /// 是否为当前用户自己的圣殿
  bool get _isCurrentUserTemple {
    final ownerName = widget.source.ownerName.trim();
    final currentUserName = _resolvedCurrentUserName;
    return ownerName.isNotEmpty && ownerName == currentUserName;
  }

  /// 当前登录用户名
  String get _resolvedCurrentUserName {
    final currentUserName = widget.currentUserName.trim();
    if (currentUserName.isNotEmpty) {
      return currentUserName;
    }

    return widget.userRepository.readCachedCurrentUserAssets()?.name.trim() ??
        '';
  }

  /// 重新加载圣殿资产弹窗数据
  void _retry() {
    setState(() {
      _future = _loadData();
    });
  }

  /// 加载圣殿资产弹窗数据
  Future<TempleAssetCardData> _loadData() async {
    final results = await Future.wait<Object?>([
      widget.characterRepository
          .fetchCharacterBasicInfo(widget.source.characterId),
      widget.userRepository.fetchUserTemplePage(
        username: widget.source.ownerName.trim(),
        page: 1,
        pageSize: 1,
        characterIds: [widget.source.characterId],
      ),
      if (_shouldShowActions)
        widget.characterRepository
            .fetchCurrentUserTrading(widget.source.characterId)
      else
        Future<CharacterDetailUserTrading?>.value(),
    ]);
    final info = results[0] as CharacterDetailBasicInfo;
    final templePage = results[1] as TinygrailPage<UserTempleApiItem>;
    final trading = results[2] as CharacterDetailUserTrading?;
    final header = info.tradeHeader;
    if (header == null) {
      throw StateError('角色未上市，无法计算圣殿资产');
    }

    final temple = _findTemple(templePage.items);
    return _buildData(
      header: header,
      temple: temple,
      trading: trading,
    );
  }

  /// 查找当前角色对应的圣殿
  ///
  /// [items] 用户圣殿分页条目
  UserTempleApiItem? _findTemple(List<UserTempleApiItem> items) {
    for (final item in items) {
      if (item.characterId == widget.source.characterId) {
        return item;
      }
    }

    return null;
  }

  /// 构建圣殿资产卡片数据
  ///
  /// [header] 角色详情已上市头部资料
  /// [temple] 用户圣殿接口条目，未创建圣殿时为空
  TempleAssetCardData _buildData({
    required CharacterDetailTradeHeader header,
    required UserTempleApiItem? temple,
    required CharacterDetailUserTrading? trading,
  }) {
    final characterName = TinygrailFormatters.decodeHtmlEntities(header.name);
    final templeDividend = temple == null
        ? null
        : _calculateTempleDividend(
            header: header,
            temple: temple,
          );
    final templeTotalDividend = temple == null || templeDividend == null
        ? null
        : templeDividend * temple.assets;
    final ownerNickname = TinygrailFormatters.decodeHtmlEntities(
      widget.source.ownerNickname.trim(),
    );
    final ownerName = widget.source.ownerName.trim();
    final watermarkText = ownerNickname.isNotEmpty ? ownerNickname : ownerName;

    return TempleAssetCardData(
      templeId: temple?.id,
      userId: temple?.userId ?? 0,
      characterId: header.characterId,
      characterName: characterName,
      avatar: header.icon,
      cover: temple?.cover ?? '',
      line: temple?.line ?? '',
      hasLink: temple?.link != null,
      linkCover: temple?.link?.cover ?? '',
      linkAvatar: temple?.link?.avatar ?? '',
      assets: temple?.assets ?? 0,
      sacrifices: temple?.sacrifices ?? 0,
      characterLevel: header.level,
      zeroCount: header.zeroCount,
      level: temple?.level ?? 0,
      starForces: temple?.starForces ?? 0,
      refine: temple?.refine ?? 0,
      primaryValue: characterName,
      primaryLabel: '#${header.characterId}',
      showPrimaryLevelBadge: true,
      tags: [
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
              : Formatters.tinygrailCompactValue(temple.starForces),
          muted: temple == null,
          showStarIcon: true,
          starHighlighted: (temple?.starForces ?? 0) >= 10000,
        ),
      ],
      watermarkText: watermarkText,
      showActions: _shouldShowActions && temple != null,
      hasTemple: temple != null,
      canResetCover: temple != null && _canResetCover,
      actionContext: temple != null && _hasVisibleActions
          ? TempleAssetCardActionContext(
              characterRepository: widget.characterRepository,
              templeRepository: widget.templeRepository,
              magicRepository: widget.magicRepository,
              oosRepository: widget.oosRepository,
              userRepository: widget.userRepository,
              currentUserName: _resolvedCurrentUserName,
              availableAmount: trading?.amount ?? 0,
              onActionCompleted: _reloadAfterAction,
            )
          : null,
      heroTag: temple == null
          ? null
          : 'temple-asset-source-dialog-${temple.id}-${header.characterId}',
    );
  }

  /// 操作成功后重新加载弹窗数据
  Future<void> _reloadAfterAction() async {
    if (!mounted) {
      return;
    }

    final data = await _loadData();
    if (!mounted) {
      return;
    }

    setState(() {
      _future = Future<TempleAssetCardData>.value(data);
    });
  }

  /// 转换异常为失败文案
  ///
  /// [error] 加载异常
  String _messageForError(Object? error) {
    return resolveUserErrorMessage(error, fallback: '圣殿资产加载失败');
  }

  /// 计算圣殿单期股息
  ///
  /// [header] 角色详情已上市头部资料
  /// [temple] 用户圣殿接口条目
  double _calculateTempleDividend({
    required CharacterDetailTradeHeader header,
    required UserTempleApiItem temple,
  }) {
    if (header.rank > 0 && header.rank <= 500) {
      final characterLevel = header.level;
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
}

/// 圣殿资产弹窗失败面板
class _TempleAssetDialogFailedPanel extends StatelessWidget {
  /// 创建圣殿资产弹窗失败面板
  ///
  /// [message] 失败说明
  /// [onRetry] 重试回调
  const _TempleAssetDialogFailedPanel({
    required this.message,
    required this.onRetry,
  });

  /// 失败说明
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建圣殿资产弹窗失败面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AppLoadFailedState(
        message: message,
        onActionPressed: onRetry,
      ),
    );
  }
}
