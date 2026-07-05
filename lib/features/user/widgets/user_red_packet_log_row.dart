import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/features/user/model/user_red_packet_log_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_pill.dart';

/// 用户红包记录行
class UserRedPacketLogRow extends StatelessWidget {
  /// 创建用户红包记录行
  ///
  /// [key] Flutter 组件标识
  /// [item] 红包记录条目
  const UserRedPacketLogRow({
    super.key,
    required this.item,
  });

  /// 红包记录条目
  final UserRedPacketLogApiItem item;

  static const Color _sentColor = Color(0xFF38A8E8);
  static const Color _receivedColor = Color(0xFFFF5A91);

  /// 构建用户红包记录行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReceived = item.change > 0;
    final accentColor = isReceived ? _receivedColor : _sentColor;

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
                        _amountText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    UserAssetRecordPill(
                      text: item.typeName,
                      accentColor: accentColor,
                      isCompact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                _RedPacketDescription(
                  text: TinygrailFormatters.decodeHtmlEntities(
                    item.description,
                  ),
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

  /// 红包金额文案
  String get _amountText {
    final sign = item.change > 0
        ? '+'
        : item.change < 0
            ? '-'
            : '';
    return '$sign${Formatters.tinygrailCurrency(item.change.abs())}';
  }
}

/// 用户红包记录描述
class _RedPacketDescription extends StatelessWidget {
  /// 创建用户红包记录描述
  ///
  /// [text] 描述文本
  const _RedPacketDescription({
    required this.text,
  });

  /// 描述文本
  final String text;

  /// 构建用户红包记录描述
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
    final resolvedText = text.trim().isEmpty ? '--' : text.trim();

    return Text(
      resolvedText,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
  }
}
