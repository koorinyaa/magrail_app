import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/features/user/model/user_balance_log_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_pill.dart';

/// 用户资金日志行
class UserBalanceLogRow extends StatelessWidget {
  /// 创建用户资金日志行
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户资金日志条目
  /// [onCharacterTap] 角色 ID 点击回调
  const UserBalanceLogRow({
    super.key,
    required this.item,
    this.onCharacterTap,
  });

  /// 用户资金日志条目
  final UserBalanceLogApiItem item;

  /// 角色 ID 点击回调
  final ValueChanged<int>? onCharacterTap;

  static const Color _increaseColor = Color(0xFFFF5A91);
  static const Color _decreaseColor = Color(0xFF38A8E8);
  static const Color _shareIncreaseColor = Color(0xFF45D216);
  // 变动胶囊超过 1w 时改用 w/e 缩略避免挤占余额
  static const int _compactChangeThreshold = 10000;

  /// 构建用户资金日志行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        Formatters.tinygrailCurrency(item.balance),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (item.change != 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: UserAssetRecordPill(
                          text: _formatCurrencyChange(item.change),
                          accentColor:
                              item.change > 0 ? _increaseColor : _decreaseColor,
                        ),
                      ),
                    if (item.amount != 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: UserAssetRecordPill(
                          text: _formatShareChange(item.amount),
                          accentColor: item.amount > 0
                              ? _shareIncreaseColor
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                _BalanceLogDescription(
                  text: TinygrailFormatters.decodeHtmlEntities(
                    item.description,
                  ),
                  onCharacterTap: onCharacterTap,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              TinygrailFormatters.relativeTime(item.logTime),
              maxLines: 1,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化资金变动
  ///
  /// [value] 资金变动数值
  String _formatCurrencyChange(double value) {
    final sign = value > 0 ? '+' : '-';
    if (value.abs() >= _compactChangeThreshold) {
      return '$sign${Formatters.tinygrailCompactValue(
        value.abs(),
        prefix: '₵',
      )}';
    }

    return '$sign${Formatters.tinygrailCurrency(value.abs())}';
  }

  /// 格式化股份变动
  ///
  /// [value] 股份变动数量
  String _formatShareChange(int value) {
    final sign = value > 0 ? '+' : '';
    return Formatters.tinygrailCompactValue(value, prefix: sign);
  }
}

/// 用户资金日志描述
class _BalanceLogDescription extends StatelessWidget {
  /// 创建用户资金日志描述
  ///
  /// [text] 描述文本
  /// [onCharacterTap] 角色 ID 点击回调
  const _BalanceLogDescription({
    required this.text,
    this.onCharacterTap,
  });

  /// 描述文本
  final String text;

  /// 角色 ID 点击回调
  final ValueChanged<int>? onCharacterTap;

  /// 构建用户资金日志描述
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.25,
    );

    if (text.isEmpty) {
      return Text('--', style: textStyle);
    }

    final spans = _parseDescriptionParts();
    return Wrap(
      spacing: 0,
      runSpacing: 2,
      children: [
        for (final part in spans)
          if (part.characterId == null)
            Text(part.text, style: textStyle)
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCharacterTap?.call(part.characterId!),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Text(
                    part.text,
                    style: textStyle.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  /// 拆分描述文本中的角色 ID 片段
  List<_BalanceLogDescriptionPart> _parseDescriptionParts() {
    final regex = RegExp(r'#(\d+)');
    final parts = <_BalanceLogDescriptionPart>[];
    var lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        parts.add(
          _BalanceLogDescriptionPart(
            text: text.substring(lastIndex, match.start),
          ),
        );
      }

      final characterId = int.tryParse(match.group(1) ?? '');
      parts.add(
        _BalanceLogDescriptionPart(
          text: match.group(0) ?? '',
          characterId: characterId,
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      parts.add(
        _BalanceLogDescriptionPart(
          text: text.substring(lastIndex),
        ),
      );
    }

    return parts;
  }
}

/// 用户资金日志描述片段
final class _BalanceLogDescriptionPart {
  /// 创建用户资金日志描述片段
  ///
  /// [text] 片段文本
  /// [characterId] 角色 ID
  const _BalanceLogDescriptionPart({
    required this.text,
    this.characterId,
  });

  /// 片段文本
  final String text;

  /// 角色 ID
  final int? characterId;
}
