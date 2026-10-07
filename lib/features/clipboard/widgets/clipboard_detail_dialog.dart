import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/clipboard/model/clipboard_detail_target.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';
import 'package:magrail_app/features/user/widgets/user_profile_card_components.dart';

/// 显示剪切板详情确认面板
///
/// [context] 当前组件树上下文
/// [target] 已精确匹配的角色或用户
/// [onShown] 确认面板首次展示时的通知
Future<bool> showClipboardDetailDialog(
  BuildContext context, {
  required ClipboardDetailTarget target,
  required VoidCallback onShown,
}) async {
  ModalRoute<dynamic>? route;
  final confirmed = await showAppConfirmDialog(
    context,
    title: '',
    message: '',
    confirmText: target.confirmText,
    showCancelButton: false,
    content: Builder(
      builder: (context) {
        if (route == null) {
          onShown();
        }
        route = ModalRoute.of(context);
        return _ClipboardDetailContent(target: target);
      },
    ),
  );
  // 确认后等待面板完整退出，由调用方继续打开详情
  await route?.completed;
  return confirmed;
}

/// 剪切板详情确认面板中的头像、名称与编号
class _ClipboardDetailContent extends StatelessWidget {
  /// 创建剪切板详情内容
  ///
  /// [target] 已精确匹配的角色或用户
  const _ClipboardDetailContent({required this.target});

  final ClipboardDetailTarget target;

  /// 构建匹配结果的三行展示
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Widget avatar;
    final Widget? badge;
    final String name;
    final String id;
    var isBanned = false;
    switch (target) {
      case ClipboardCharacterTarget(:final character):
        avatar = CharacterAvatar(
          imageUrl: TinygrailAssetUrls.normalizeAvatar(character.icon),
          size: 64,
          borderRadius: 18,
        );
        name = TinygrailFormatters.decodeHtmlEntities(character.name).trim();
        id = '#${character.characterId}';
        badge = character.pageType == CharacterDetailPageType.ico
            ? const LevelBadge.ico()
            : LevelBadge(
                level: character.tradeHeader!.level,
                zeroCount: character.tradeHeader!.zeroCount,
              );
      case ClipboardUserTarget(:final user):
        avatar = UserAvatar(
          imageUrl: user.avatar,
          isBanned: user.isBanned,
          size: 64,
        );
        name = user.nickname.trim().isEmpty ? user.name : user.nickname.trim();
        id = '@${user.name}';
        badge = user.rank > 0 ? UserProfileRankBadge(rank: user.rank) : null;
        isBanned = user.isBanned;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isBanned ? colorScheme.error : colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              // 徽标整体随字号缩放，避免内部文字撑出固定高度
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: MediaQuery.withNoTextScaling(child: badge),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          id,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
