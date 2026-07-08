import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_bangumi_related_sheet.dart';
import 'package:magrail_app/shared/widgets/paged_action_grid.dart';

/// 角色 Bangumi 关联操作卡片
class CharacterDetailBangumiActionsCard extends StatelessWidget {
  /// 创建角色 Bangumi 关联操作卡片
  ///
  /// [key] Flutter 组件标识
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [repository] 角色详情仓库
  const CharacterDetailBangumiActionsCard({
    super.key,
    required this.characterId,
    required this.characterName,
    required this.repository,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 构建角色 Bangumi 关联操作卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final actions = [
      _BangumiActionEntry(
        label: '关联角色',
        icon: LucideIcons.usersRound,
        onPressed: () => showCharacterBangumiRelationsSheet(
          context,
          characterId: characterId,
          characterName: characterName,
          characterRepository: repository,
        ),
      ),
      _BangumiActionEntry(
        label: '出演作品',
        icon: LucideIcons.film,
        onPressed: () => showCharacterBangumiCastsSheet(
          context,
          characterId: characterId,
          characterName: characterName,
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
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
      child: PagedActionGrid(
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _BangumiActionButton(action: action);
        },
      ),
    );
  }
}

/// 角色 Bangumi 关联操作入口
final class _BangumiActionEntry {
  /// 创建角色 Bangumi 关联操作入口
  ///
  /// [label] 操作入口文案
  /// [icon] 操作入口图标
  /// [onPressed] 点击回调
  const _BangumiActionEntry({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  /// 操作入口文案
  final String label;

  /// 操作入口图标
  final IconData icon;

  /// 点击回调
  final VoidCallback onPressed;
}

/// 角色 Bangumi 关联操作按钮
class _BangumiActionButton extends StatelessWidget {
  /// 创建角色 Bangumi 关联操作按钮
  ///
  /// [action] 操作入口
  const _BangumiActionButton({
    required this.action,
  });

  /// 操作入口
  final _BangumiActionEntry action;

  /// 构建角色 Bangumi 关联操作按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.icon,
              size: 22,
              color: colorScheme.onSurface,
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
