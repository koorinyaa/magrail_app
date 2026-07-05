import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_board_member.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';
import 'package:magrail_app/features/user/widgets/user_profile_card_components.dart';

/// 角色董事会成员持股查询回调
typedef CharacterDetailBoardMemberStockResolver = Future<int?> Function(
  CharacterDetailBoardMember member,
);

/// 角色董事会成员行
class CharacterDetailBoardMemberRow extends StatefulWidget {
  /// 创建角色董事会成员行
  ///
  /// [key] Flutter 组件标识
  /// [member] 董事会成员
  /// [serialNumber] 当前成员序列号
  /// [totalShares] 角色流通股份
  /// [temple] 成员对应圣殿
  /// [onTap] 点击成员回调
  /// [onTempleTap] 点击圣殿数据回调
  /// [onRevealStock] 未公开持股查询回调
  const CharacterDetailBoardMemberRow({
    super.key,
    required this.member,
    required this.serialNumber,
    required this.totalShares,
    this.temple,
    this.onTap,
    this.onTempleTap,
    this.onRevealStock,
  });

  /// 董事会成员
  final CharacterDetailBoardMember member;

  /// 当前成员序列号
  final int serialNumber;

  /// 角色流通股份
  final int totalShares;

  /// 成员对应圣殿
  final CharacterDetailTempleItem? temple;

  /// 点击成员回调
  final VoidCallback? onTap;

  /// 点击圣殿数据回调
  final VoidCallback? onTempleTap;

  /// 未公开持股查询回调
  final CharacterDetailBoardMemberStockResolver? onRevealStock;

  /// 创建角色董事会成员行状态
  @override
  State<CharacterDetailBoardMemberRow> createState() =>
      _CharacterDetailBoardMemberRowState();
}

/// 角色董事会成员行状态
class _CharacterDetailBoardMemberRowState
    extends State<CharacterDetailBoardMemberRow> {
  int? _revealedBalance;
  bool _isRevealingStock = false;

  /// 处理角色董事会成员行配置变化
  ///
  /// [oldWidget] 更新前的董事会成员行
  @override
  void didUpdateWidget(covariant CharacterDetailBoardMemberRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.member.id == oldWidget.member.id &&
        widget.member.name == oldWidget.member.name) {
      if (widget.member.balance != oldWidget.member.balance ||
          widget.totalShares != oldWidget.totalShares ||
          widget.onRevealStock == null && oldWidget.onRevealStock != null) {
        _revealedBalance = null;
        _isRevealingStock = false;
      }
      return;
    }

    _revealedBalance = null;
    _isRevealingStock = false;
  }

  /// 构建角色董事会成员行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeTimeLabel = _activeTimeLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                _BoardMemberSerialText(serialNumber: widget.serialNumber),
                const SizedBox(width: 5),
                UserAvatar(
                  imageUrl: widget.member.avatar,
                  isBanned: widget.member.isBanned,
                  size: 44,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.member.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: widget.member.isBanned
                                          ? colorScheme.error
                                          : colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                                if (widget.member.lastIndex > 0) ...[
                                  const SizedBox(width: 5),
                                  UserProfileRankBadge(
                                    rank: widget.member.lastIndex,
                                    isCompact: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _BoardMemberStockPill(
                        text: _stockLabel,
                        backgroundColor: _stockPillColor(context),
                        isEnabled: _canRevealStock,
                        onPressed: _canRevealStock
                            ? _handleRevealStockPressed
                            : null,
                      ),
                      const SizedBox(height: 2),
                      _BoardMemberTempleLine(
                        text: _templeLabel,
                        color: _templeColor(context),
                        isEnabled:
                            widget.temple != null && widget.onTempleTap != null,
                        onTap: widget.onTempleTap,
                      ),
                    ],
                  ),
                ),
                if (activeTimeLabel.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: Text(
                      activeTimeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.62,
                        ),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 持股展示文案
  String get _stockLabel {
    if (_isRevealingStock) {
      return '查询中';
    }

    if (_canRevealStock) {
      return '点击查看';
    }

    final balance = _formatCount(_resolvedBalance, emptyText: '???');
    final percent = _stockPercentLabel;
    if (percent.isEmpty) {
      return balance;
    }

    return '$balance ($percent)';
  }

  /// 持股百分比文案
  String get _stockPercentLabel {
    final balance = _resolvedBalance;
    if (balance <= 0 || widget.totalShares <= 0) {
      return '';
    }

    final percent = balance / widget.totalShares * 100;
    return '${percent.toStringAsFixed(2)}%';
  }

  /// 圣殿展示文案
  String get _templeLabel {
    final resolvedTemple = widget.temple;
    if (resolvedTemple != null) {
      return '${_formatCount(resolvedTemple.assets)} / '
          '${_formatCount(resolvedTemple.sacrifices)}';
    }

    return '--';
  }

  /// 活跃时间文案
  String get _activeTimeLabel {
    final value = widget.member.lastActiveDate.trim();
    if (value.isEmpty) {
      return '';
    }

    return TinygrailFormatters.relativeTime(value);
  }

  /// 持股胶囊背景色
  ///
  /// [context] 当前组件树上下文
  Color _stockPillColor(BuildContext context) {
    final parsed = TinygrailFormatters.parseServerTime(
      widget.member.lastActiveDate,
    );
    final isInactive = parsed != null &&
        DateTime.now().difference(parsed.toLocal()) >= const Duration(days: 5);
    if (isInactive) {
      final isDark =
          Theme.of(context).colorScheme.brightness == Brightness.dark;
      return isDark ? const Color(0xFF6B7280) : const Color(0xFFD2D2D2);
    }

    if (widget.serialNumber == 1) {
      return const Color(0xFFFFC107);
    }

    if (widget.serialNumber >= 2 && widget.serialNumber <= 9) {
      return const Color(0xFFD965FF);
    }

    return const Color(0xFF45D216);
  }

  /// 圣殿数字颜色
  ///
  /// [context] 当前组件树上下文
  Color? _templeColor(BuildContext context) {
    final resolvedTemple = widget.temple;
    if (resolvedTemple == null) {
      return null;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final themeColor = switch (resolvedTemple.level) {
      2 => const Color(0xFFEAB308),
      3 => const Color(0xFFA855F7),
      _ => const Color(0xFF9CA3AF),
    };
    return themeColor.withValues(alpha: isDark ? 0.92 : 0.86);
  }

  /// 格式化数量
  ///
  /// [value] 原始数量
  /// [emptyText] 空值文案
  String _formatCount(int value, {String emptyText = '--'}) {
    if (value <= 0) {
      return emptyText;
    }

    return Formatters.groupedNumber(value);
  }

  /// 当前用于展示的持股数量
  int get _resolvedBalance {
    return _revealedBalance ?? widget.member.balance;
  }

  /// 是否允许查询未公开持股
  bool get _canRevealStock {
    return widget.member.balance <= 0 &&
        _revealedBalance == null &&
        !_isRevealingStock &&
        widget.onRevealStock != null;
  }

  /// 处理未公开持股点击
  Future<void> _handleRevealStockPressed() async {
    final onRevealStock = widget.onRevealStock;
    if (onRevealStock == null || _isRevealingStock) {
      return;
    }

    setState(() {
      _isRevealingStock = true;
    });

    try {
      final balance = await onRevealStock(widget.member);
      if (!mounted) {
        return;
      }

      if (balance == null || balance <= 0) {
        AppToast.error(context, text: '获取用户持股失败，请稍后重试');
        return;
      }

      setState(() {
        _revealedBalance = balance;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppToast.error(context, text: '获取用户持股失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() {
          _isRevealingStock = false;
        });
      }
    }
  }
}

/// 董事会成员持股胶囊
class _BoardMemberStockPill extends StatelessWidget {
  /// 创建董事会成员持股胶囊
  ///
  /// [text] 展示文本
  /// [backgroundColor] 胶囊背景色
  /// [isEnabled] 是否允许点击
  /// [onPressed] 点击回调
  const _BoardMemberStockPill({
    required this.text,
    required this.backgroundColor,
    required this.isEnabled,
    this.onPressed,
  });

  /// 展示文本
  final String text;

  /// 胶囊背景色
  final Color backgroundColor;

  /// 是否允许点击
  final bool isEnabled;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 构建董事会成员持股胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(999);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: borderRadius,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// 董事会成员序列号文本
class _BoardMemberSerialText extends StatelessWidget {
  /// 创建董事会成员序列号文本
  ///
  /// [serialNumber] 成员序列号
  const _BoardMemberSerialText({
    required this.serialNumber,
  });

  /// 成员序列号
  final int serialNumber;

  /// 构建董事会成员序列号文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isChairman = serialNumber == 1;
    final color = isChairman
        ? const Color(0xFFFFC107)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.82);

    return SizedBox(
      width: 34,
      child: Text(
        isChairman ? '主席' : '$serialNumber',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: _fontSize,
          fontWeight: isChairman ? FontWeight.w800 : FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }

  /// 序号字体大小
  double get _fontSize {
    if (serialNumber == 1) {
      return 12;
    }

    if (serialNumber >= 1000) {
      return 13;
    }

    if (serialNumber >= 100) {
      return 16;
    }

    return 22;
  }
}

/// 董事会成员圣殿说明行
class _BoardMemberTempleLine extends StatelessWidget {
  /// 创建董事会成员圣殿说明行
  ///
  /// [text] 展示文本
  /// [color] 自定义文本颜色
  /// [isEnabled] 是否显示点击反馈
  /// [onTap] 点击回调
  const _BoardMemberTempleLine({
    required this.text,
    this.color,
    this.isEnabled = false,
    this.onTap,
  });

  /// 展示文本
  final String text;

  /// 自定义文本颜色
  final Color? color;

  /// 是否显示点击反馈
  final bool isEnabled;

  /// 点击回调
  final VoidCallback? onTap;

  /// 构建董事会成员圣殿说明行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedColor =
        color ?? colorScheme.onSurfaceVariant.withValues(alpha: 0.70);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: resolvedColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        if (isEnabled) ...[
          const SizedBox(width: 2),
          Icon(
            Icons.chevron_right_rounded,
            size: 13,
            color: resolvedColor,
          ),
        ],
      ],
    );

    if (!isEnabled) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.only(top: 2, right: 3, bottom: 2),
          child: content,
        ),
      ),
    );
  }
}
