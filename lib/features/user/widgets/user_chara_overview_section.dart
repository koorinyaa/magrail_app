import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_carousels.dart';
import 'package:magrail_app/features/user/widgets/user_chara_overview_states.dart';
import 'package:magrail_app/features/user/widgets/user_link_temple_overview_carousel.dart';

/// 用户角色资产预览区
class UserCharaOverviewSection extends StatelessWidget {
  /// 创建用户角色资产预览区
  ///
  /// [key] Flutter 组件标识
  /// [profile] 用户资料
  /// [links] 用户连接预览
  /// [temples] 用户圣殿预览
  /// [characters] 用户角色预览
  /// [icos] 用户 ICO 预览
  /// [linkTotalItems] 用户连接总数
  /// [templeTotalItems] 用户圣殿总数
  /// [characterTotalItems] 用户角色总数
  /// [icoTotalItems] 用户 ICO 总数
  /// [isLoading] 是否正在加载
  /// [isLoadFailed] 是否加载失败
  /// [onRetry] 重试回调
  /// [onLinksHeaderTap] 连接标题点击回调
  /// [onTemplesHeaderTap] 圣殿标题点击回调
  /// [onCharactersHeaderTap] 角色标题点击回调
  /// [onIcosHeaderTap] ICO 标题点击回调
  /// [onTempleCharacterTap] 圣殿和连接角色点击回调
  /// [onTempleAssetTap] 圣殿资产入口点击回调
  /// [onCharacterTap] 角色条目点击回调
  /// [onIcoTap] ICO 条目点击回调
  const UserCharaOverviewSection({
    super.key,
    required this.profile,
    required this.links,
    required this.temples,
    required this.characters,
    required this.icos,
    required this.linkTotalItems,
    required this.templeTotalItems,
    required this.characterTotalItems,
    required this.icoTotalItems,
    required this.isLoading,
    required this.isLoadFailed,
    required this.onRetry,
    required this.onLinksHeaderTap,
    required this.onTemplesHeaderTap,
    required this.onCharactersHeaderTap,
    required this.onIcosHeaderTap,
    this.onTempleCharacterTap,
    this.onTempleAssetTap,
    this.onCharacterTap,
    this.onIcoTap,
  });

  /// 用户资料
  final UserDetailProfile profile;

  /// 用户连接预览
  final List<UserLinkApiItem>? links;

  /// 用户圣殿预览
  final List<UserTempleApiItem>? temples;

  /// 用户角色预览
  final List<UserCharacterApiItem>? characters;

  /// 用户 ICO 预览
  final List<UserIcoApiItem>? icos;

  /// 用户连接总数
  final int? linkTotalItems;

  /// 用户圣殿总数
  final int? templeTotalItems;

  /// 用户角色总数
  final int? characterTotalItems;

  /// 用户 ICO 总数
  final int? icoTotalItems;

  /// 是否正在加载
  final bool isLoading;

  /// 是否加载失败
  final bool isLoadFailed;

  /// 重试回调
  final Future<void> Function() onRetry;

  /// 连接标题点击回调
  final VoidCallback onLinksHeaderTap;

  /// 圣殿标题点击回调
  final VoidCallback onTemplesHeaderTap;

  /// 角色标题点击回调
  final VoidCallback onCharactersHeaderTap;

  /// ICO 标题点击回调
  final VoidCallback onIcosHeaderTap;

  /// 圣殿和连接角色点击回调
  final ValueChanged<UserTempleApiItem>? onTempleCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onTempleAssetTap;

  /// 角色条目点击回调
  final void Function(UserCharacterApiItem item, String? avatarHeroTag)?
      onCharacterTap;

  /// ICO 条目点击回调
  final void Function(UserIcoApiItem item, String? avatarHeroTag)? onIcoTap;

  /// 构建用户角色资产预览区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final resolvedLinks = links ?? const <UserLinkApiItem>[];
    final resolvedTemples = temples ?? const <UserTempleApiItem>[];
    final resolvedCharacters = characters ?? const <UserCharacterApiItem>[];
    final resolvedIcos = icos ?? const <UserIcoApiItem>[];
    final hasAnyVisibleContent = resolvedLinks.isNotEmpty ||
        resolvedTemples.isNotEmpty ||
        resolvedCharacters.isNotEmpty ||
        resolvedIcos.isNotEmpty;
    final showSkeleton = (isLoading && !hasAnyVisibleContent) ||
        links == null ||
        temples == null ||
        characters == null ||
        icos == null;
    final linksTitle = showSkeleton
        ? '连接'
        : '${_resolveSectionCount(
            totalItems: linkTotalItems,
            visibleCount: resolvedLinks.length,
          )}组连接';
    final templesTitle = showSkeleton
        ? '圣殿'
        : '${_resolveSectionCount(
            totalItems: templeTotalItems,
            visibleCount: resolvedTemples.length,
          )}座圣殿';
    final charactersTitle = showSkeleton
        ? '角色'
        : '${_resolveSectionCount(
            totalItems: characterTotalItems,
            visibleCount: resolvedCharacters.length,
          )}个角色';
    final icosTitle = showSkeleton
        ? 'ICO'
        : '${_resolveSectionCount(
            totalItems: icoTotalItems,
            visibleCount: resolvedIcos.length,
          )}个ICO';

    if (isLoadFailed && !showSkeleton && _isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: 24,
            top: 18,
            right: 24,
            bottom: 0,
          ),
          child: UserOverviewMessage(
            message: '角色资产加载失败',
            onRetry: onRetry,
          ),
        ),
      );
    }

    if (!showSkeleton && _isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: 10,
            top: 18,
            right: 10,
            bottom: 0,
          ),
          child: const UserOverviewMessage(message: '暂无角色资产'),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: showSkeleton
          ? [
              PageSectionSliver(
                topSpacing: 12,
                title: linksTitle,
                onHeaderTap: onLinksHeaderTap,
                child: UserLinkOverviewCarousel(
                  links: links,
                  isLoading: true,
                  onCharacterTap: onTempleCharacterTap,
                  onAssetTap: onTempleAssetTap,
                ),
              ),
              PageSectionSliver(
                topSpacing: 22,
                title: templesTitle,
                onHeaderTap: onTemplesHeaderTap,
                child: UserTempleOverviewCarousel(
                  profile: profile,
                  temples: temples,
                  isLoading: true,
                  onCharacterTap: onTempleCharacterTap,
                  onAssetTap: onTempleAssetTap,
                ),
              ),
              PageSectionSliver(
                topSpacing: 22,
                title: charactersTitle,
                onHeaderTap: onCharactersHeaderTap,
                child: UserCharacterAssetCarousel(
                  characters: characters,
                  isLoading: true,
                  onCharacterTap: onCharacterTap,
                ),
              ),
              PageSectionSliver(
                topSpacing: 22,
                title: icosTitle,
                onHeaderTap: onIcosHeaderTap,
                child: UserIcoAssetCarousel(
                  icos: icos,
                  isLoading: true,
                  onIcoTap: onIcoTap,
                ),
              ),
            ]
          : _buildVisibleContentSlivers(
              linksTitle: linksTitle,
              templesTitle: templesTitle,
              charactersTitle: charactersTitle,
              icosTitle: icosTitle,
              links: resolvedLinks,
              temples: resolvedTemples,
              characters: resolvedCharacters,
              icos: resolvedIcos,
            ),
    );
  }

  /// 构建已加载状态下的可见资产区块
  ///
  /// [linksTitle] 连接区标题
  /// [templesTitle] 圣殿区标题
  /// [charactersTitle] 角色区标题
  /// [icosTitle] ICO 区标题
  /// [links] 实际可显示连接列表
  /// [temples] 实际可显示圣殿列表
  /// [characters] 实际可显示角色列表
  /// [icos] 实际可显示 ICO 列表
  List<Widget> _buildVisibleContentSlivers({
    required String linksTitle,
    required String templesTitle,
    required String charactersTitle,
    required String icosTitle,
    required List<UserLinkApiItem> links,
    required List<UserTempleApiItem> temples,
    required List<UserCharacterApiItem> characters,
    required List<UserIcoApiItem> icos,
  }) {
    final slivers = <Widget>[];

    if (links.isNotEmpty) {
      slivers.add(
        PageSectionSliver(
          topSpacing: _resolveTopSpacing(slivers),
          title: linksTitle,
          onHeaderTap: onLinksHeaderTap,
          child: UserLinkOverviewCarousel(
            links: links,
            isLoading: false,
            onCharacterTap: onTempleCharacterTap,
            onAssetTap: onTempleAssetTap,
          ),
        ),
      );
    }

    if (temples.isNotEmpty) {
      slivers.add(
        PageSectionSliver(
          topSpacing: _resolveTopSpacing(slivers),
          title: templesTitle,
          onHeaderTap: onTemplesHeaderTap,
          child: UserTempleOverviewCarousel(
            profile: profile,
            temples: temples,
            isLoading: false,
            onCharacterTap: onTempleCharacterTap,
            onAssetTap: onTempleAssetTap,
          ),
        ),
      );
    }

    if (characters.isNotEmpty) {
      slivers.add(
        PageSectionSliver(
          topSpacing: _resolveTopSpacing(slivers),
          title: charactersTitle,
          onHeaderTap: onCharactersHeaderTap,
          child: UserCharacterAssetCarousel(
            characters: characters,
            isLoading: false,
            onCharacterTap: onCharacterTap,
          ),
        ),
      );
    }

    if (icos.isNotEmpty) {
      slivers.add(
        PageSectionSliver(
          topSpacing: _resolveTopSpacing(slivers),
          title: icosTitle,
          onHeaderTap: onIcosHeaderTap,
          child: UserIcoAssetCarousel(
            icos: icos,
            isLoading: false,
            onIcoTap: onIcoTap,
          ),
        ),
      );
    }

    return slivers;
  }

  /// 解析区块标题数量
  ///
  /// [totalItems] 接口返回总数
  /// [visibleCount] 实际可显示数量
  int _resolveSectionCount({
    required int? totalItems,
    required int visibleCount,
  }) {
    if (totalItems != null && totalItems > 0) {
      return totalItems;
    }

    return visibleCount;
  }

  /// 解析动态资产区块顶部间距
  ///
  /// [slivers] 已构建区块
  double _resolveTopSpacing(List<Widget> slivers) {
    return slivers.isEmpty ? 12 : 22;
  }

  /// 是否没有可展示内容
  bool get _isEmpty {
    return (links?.isEmpty ?? true) &&
        (temples?.isEmpty ?? true) &&
        (characters?.isEmpty ?? true) &&
        (icos?.isEmpty ?? true);
  }
}
