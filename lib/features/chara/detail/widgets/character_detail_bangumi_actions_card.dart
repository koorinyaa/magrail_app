import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_bangumi_related_sheet.dart';
import 'package:magrail_app/shared/widgets/paged_action_grid.dart';

/// 角色 Bangumi 关联操作卡片
class CharacterDetailBangumiActionsCard extends StatefulWidget {
  /// 创建角色 Bangumi 关联操作卡片
  ///
  /// [key] Flutter 组件标识
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [characterIcon] 角色头像地址
  /// [repository] 角色详情仓库
  /// [onCharacterSynced] 角色资料同步后的刷新回调
  const CharacterDetailBangumiActionsCard({
    super.key,
    required this.characterId,
    required this.characterName,
    required this.characterIcon,
    required this.repository,
    required this.onCharacterSynced,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 角色头像地址
  final String characterIcon;

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 角色资料同步后的刷新回调
  final Future<void> Function() onCharacterSynced;

  /// 创建角色 Bangumi 关联操作卡片状态
  @override
  State<CharacterDetailBangumiActionsCard> createState() =>
      _CharacterDetailBangumiActionsCardState();
}

/// 角色 Bangumi 关联操作卡片状态
class _CharacterDetailBangumiActionsCardState
    extends State<CharacterDetailBangumiActionsCard> {
  var _isSyncing = false;

  /// 构建角色 Bangumi 关联操作卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final actions = [
      if (_shouldShowSyncProfileAction)
        _BangumiActionEntry(
          label: '同步资料',
          icon: LucideIcons.refreshCw,
          onPressed: _isSyncing ? null : _syncCharacterProfile,
          isLoading: _isSyncing,
        ),
      _BangumiActionEntry(
        label: '关联角色',
        icon: LucideIcons.usersRound,
        onPressed: () => showCharacterBangumiRelationsSheet(
          context,
          characterId: widget.characterId,
          characterName: widget.characterName,
          characterRepository: widget.repository,
        ),
      ),
      _BangumiActionEntry(
        label: '出演作品',
        icon: LucideIcons.film,
        onPressed: () => showCharacterBangumiCastsSheet(
          context,
          characterId: widget.characterId,
          characterName: widget.characterName,
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

  /// 同步角色名称和头像
  Future<void> _syncCharacterProfile() async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: '同步资料',
      message: '该操作会从 Bangumi 同步当前角色的名称和头像。若角色名称为空、头像缺失，或页面仍显示 ID 占位，请尝试使用此功能。',
      confirmText: '同步资料',
      showCancelButton: false,
      icon: LucideIcons.refreshCw,
    );
    if (!mounted || !confirmed) {
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      final message = await widget.repository.syncCharacterProfile(
        widget.characterId,
      );
      await widget.onCharacterSynced();
      if (mounted) {
        AppToast.info(context, text: message);
      }
    } catch (error) {
      if (mounted) {
        AppToast.error(
          context,
          text: resolveUserErrorMessage(
            error,
            fallback: '同步资料失败',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  /// 是否显示角色资料同步入口
  bool get _shouldShowSyncProfileAction {
    return widget.characterName.trim().isEmpty ||
        widget.characterIcon.trim().isEmpty;
  }
}

/// 角色 Bangumi 关联操作入口
final class _BangumiActionEntry {
  /// 创建角色 Bangumi 关联操作入口
  ///
  /// [label] 操作入口文案
  /// [icon] 操作入口图标
  /// [onPressed] 点击回调
  /// [isLoading] 是否正在提交
  const _BangumiActionEntry({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  /// 操作入口文案
  final String label;

  /// 操作入口图标
  final IconData icon;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 是否正在提交
  final bool isLoading;
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
            if (action.isLoading)
              SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            else
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
