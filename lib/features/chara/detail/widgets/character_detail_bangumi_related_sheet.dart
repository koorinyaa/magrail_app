import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/pagination_footer.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_character.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_search_item.dart';
import 'package:magrail_app/features/bangumi/next/next_bangumi_subject_navigation.dart';
import 'package:magrail_app/features/bangumi/next/repository/next_bangumi_repository.dart';
import 'package:magrail_app/features/bangumi/next/widgets/next_bangumi_character_grid_item.dart';
import 'package:magrail_app/features/bangumi/next/widgets/next_bangumi_subject_search_row.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'character_detail_bangumi_related_sheet_relations.dart';
part 'character_detail_bangumi_related_sheet_casts.dart';

// Next Bangumi 角色关联接口固定按 20 条分页
const int _characterBangumiRelatedPageSize = 20;

/// 显示角色关联角色底部抽屉
///
/// [context] 当前组件树上下文
/// [characterId] 角色 ID
/// [characterName] 角色名称
/// [characterRepository] 角色详情仓库
Future<void> showCharacterBangumiRelationsSheet(
  BuildContext context, {
  required int characterId,
  required String characterName,
  required CharacterDetailRepository characterRepository,
}) {
  return _showCharacterBangumiRelatedSheet(
    context,
    child: _CharacterBangumiRelationsSheet(
      characterId: characterId,
      characterName: characterName,
      characterRepository: characterRepository,
    ),
  );
}

/// 显示角色出演作品底部抽屉
///
/// [context] 当前组件树上下文
/// [characterId] 角色 ID
/// [characterName] 角色名称
Future<void> showCharacterBangumiCastsSheet(
  BuildContext context, {
  required int characterId,
  required String characterName,
}) {
  return _showCharacterBangumiRelatedSheet(
    context,
    child: _CharacterBangumiCastsSheet(
      characterId: characterId,
      characterName: characterName,
    ),
  );
}

/// 显示角色 Bangumi 关联底部抽屉
///
/// [context] 当前组件树上下文
/// [child] 抽屉内容
Future<void> _showCharacterBangumiRelatedSheet(
  BuildContext context, {
  required Widget child,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.72);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: child,
      );
    },
  );
}

/// 角色 Bangumi 关联抽屉外壳
class _CharacterBangumiRelatedSheetSurface extends StatelessWidget {
  /// 创建角色 Bangumi 关联抽屉外壳
  ///
  /// [title] 抽屉标题
  /// [subtitle] 抽屉副标题
  /// [icon] 标题图标
  /// [child] 抽屉主体
  const _CharacterBangumiRelatedSheetSurface({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  /// 抽屉标题
  final String title;

  /// 抽屉副标题
  final String subtitle;

  /// 标题图标
  final IconData icon;

  /// 抽屉主体
  final Widget child;

  /// 构建角色 Bangumi 关联抽屉外壳
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
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
                  const SizedBox(height: 14),
                  _CharacterBangumiRelatedSheetHeader(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                  ),
                  const SizedBox(height: 12),
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色 Bangumi 关联抽屉标题
class _CharacterBangumiRelatedSheetHeader extends StatelessWidget {
  /// 创建角色 Bangumi 关联抽屉标题
  ///
  /// [title] 标题文本
  /// [subtitle] 副标题文本
  /// [icon] 标题图标
  const _CharacterBangumiRelatedSheetHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  /// 标题文本
  final String title;

  /// 副标题文本
  final String subtitle;

  /// 标题图标
  final IconData icon;

  /// 构建角色 Bangumi 关联抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
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
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
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

/// 角色 Bangumi 关联空状态
class _CharacterBangumiRelatedEmptyState extends StatelessWidget {
  /// 创建角色 Bangumi 关联空状态
  ///
  /// [title] 空态标题
  /// [description] 空态说明
  const _CharacterBangumiRelatedEmptyState({
    required this.title,
    required this.description,
  });

  /// 空态标题
  final String title;

  /// 空态说明
  final String description;

  /// 构建角色 Bangumi 关联空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 28,
              color: colorScheme.primary.withValues(alpha: 0.86),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 生成角色 Bangumi 关联抽屉副标题
///
/// [characterId] 角色 ID
/// [characterName] 角色名称
String _characterBangumiRelatedSubtitle(
  int characterId,
  String characterName,
) {
  final name = TinygrailFormatters.decodeHtmlEntities(characterName).trim();
  return '#$characterId 「${name.isEmpty ? '角色' : name}」';
}

/// 关闭角色 Bangumi 关联抽屉后执行页面跳转
///
/// [context] 抽屉组件树上下文
/// [navigate] 使用导航器上下文执行的跳转
void _closeCharacterBangumiRelatedSheetAndNavigate(
  BuildContext context,
  ValueChanged<BuildContext> navigate,
) {
  final navigator = Navigator.of(context);
  final navigationContext = navigator.context;
  navigator.pop();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigationContext.mounted) {
      navigate(navigationContext);
    }
  });
}
