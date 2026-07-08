import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_calculations.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/auction/widgets/auction_bid_sheet.dart';
import 'package:magrail_app/features/chara/auction/widgets/auction_history_sheet.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_kill_vote.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_sacrifice_result.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_avatar_update_sheet.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_sacrifice_sheet.dart';
import 'package:magrail_app/features/chara/trade_history/repository/character_trade_history_repository.dart';
import 'package:magrail_app/features/chara/trade_history/widgets/character_trade_history_sheet.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_badges.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/shared/widgets/paged_action_grid.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'character_detail_trade_header_badges.dart';
part 'character_detail_trade_header_badge_dialog_chips.dart';
part 'character_detail_trade_header_actions.dart';
part 'character_detail_trade_header_actions_skeleton.dart';
part 'character_detail_trade_header_kill_vote_list.dart';
part 'character_detail_trade_header_vote_kill_sheet.dart';
part 'character_detail_trade_header_skeleton.dart';

/// 角色详情已上市头部资料区
class CharacterDetailTradeHeaderSection extends StatelessWidget {
  /// 创建角色详情已上市头部资料区
  ///
  /// [key] Flutter 组件标识
  /// [header] 已上市角色头部资料
  const CharacterDetailTradeHeaderSection({
    super.key,
    required this.header,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建角色详情已上市头部资料区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _TradeHeaderShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TradeHeaderTitleRow(header: header),
          const SizedBox(height: 8),
          _TradeHeaderBadges(header: header),
        ],
      ),
    );
  }
}

/// 已上市头部卡片外壳
class _TradeHeaderShell extends StatelessWidget {
  /// 创建已上市头部卡片外壳
  ///
  /// [child] 头部主体内容
  const _TradeHeaderShell({
    required this.child,
  });

  /// 头部主体内容
  final Widget child;

  /// 构建已上市头部宽度约束外壳
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardColor =
        isDark ? colorScheme.surfaceContainerLow : colorScheme.surface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 已上市头部标题行
class _TradeHeaderTitleRow extends StatelessWidget {
  /// 创建已上市头部标题行
  ///
  /// [header] 已上市角色头部资料
  const _TradeHeaderTitleRow({
    required this.header,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建已上市头部标题行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                _displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
            ),
            const SizedBox(width: 7),
            LevelBadge(
              level: header.level,
              zeroCount: header.zeroCount,
            ),
          ],
        ),
        const SizedBox(height: 5),
        _TradeHeaderCharacterIdRow(
          characterId: header.characterId,
        ),
        if (header.hasKillVotes) ...[
          const SizedBox(height: 6),
          _TradeHeaderKillVoteStatus(header: header),
        ],
        const SizedBox(height: 7),
        TowerStarsRow(
          stars: header.stars,
          iconSize: 16,
          spacing: 3,
          runSpacing: 2,
        ),
      ],
    );
  }

  /// 角色展示名称
  String get _displayName {
    final name = TinygrailFormatters.decodeHtmlEntities(header.name).trim();
    if (name.isEmpty) {
      return '#${header.characterId}';
    }

    return name;
  }
}

/// 已上市头部角色 ID 行
class _TradeHeaderCharacterIdRow extends StatelessWidget {
  /// 创建已上市头部角色 ID 行
  ///
  /// [characterId] 角色 ID
  const _TradeHeaderCharacterIdRow({
    required this.characterId,
  });

  /// 角色 ID
  final int characterId;

  /// 构建已上市头部角色 ID 行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            await _copyCharacterId(context);
          },
          borderRadius: BorderRadius.circular(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#$characterId',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.copy_rounded,
                size: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 复制角色 ID
  ///
  /// [context] 当前组件树上下文
  Future<void> _copyCharacterId(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: '#$characterId'),
    );
    if (!context.mounted) {
      return;
    }

    AppToast.info(
      context,
      text: '已复制角色ID',
    );
  }
}

/// 已上市头部删除投票状态
class _TradeHeaderKillVoteStatus extends StatelessWidget {
  /// 创建已上市头部删除投票状态
  ///
  /// [header] 已上市角色头部资料
  const _TradeHeaderKillVoteStatus({
    required this.header,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建已上市头部删除投票状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const warningColor = Color(0xFFF5A524);
    final isDark = colorScheme.brightness == Brightness.dark;
    final foregroundColor = isDark ? const Color(0xFFFFD58A) : warningColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: foregroundColor.withValues(alpha: isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              LucideIcons.triangleAlert,
              size: 13,
              color: foregroundColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '此角色正在被投票删除（${header.killVoteCount} / '
                '${CharacterDetailTradeHeader.requiredKillVoteCount}），请谨慎投资',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
