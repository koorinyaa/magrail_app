part of 'character_detail_ico_header_card.dart';

/// 角色详情 ICO 倒计时数据
class _CharacterDetailIcoCountdown {
  /// 创建角色详情 ICO 倒计时数据
  ///
  /// [remainingText] 剩余时间文案
  /// [endTimeText] 结束时间文案
  /// [isEndingSoon] 是否小于一小时结束
  const _CharacterDetailIcoCountdown({
    required this.remainingText,
    required this.endTimeText,
    required this.isEndingSoon,
  });

  /// 剩余时间文案
  final String remainingText;

  /// 结束时间文案
  final String endTimeText;

  /// 是否小于一小时结束
  final bool isEndingSoon;

  /// 从结束时间创建倒计时数据
  ///
  /// [value] Tinygrail 服务端结束时间
  factory _CharacterDetailIcoCountdown.fromEnd(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return const _CharacterDetailIcoCountdown(
        remainingText: '未知',
        endTimeText: '结束时间未知',
        isEndingSoon: false,
      );
    }

    final endTime = TinygrailFormatters.parseServerFutureTime(text);
    final formattedEndTime = TinygrailFormatters.dateTime(text);
    if (endTime == null) {
      return _CharacterDetailIcoCountdown(
        remainingText: '未知',
        endTimeText: formattedEndTime,
        isEndingSoon: false,
      );
    }

    final difference = endTime.toLocal().difference(DateTime.now());
    if (difference.inMilliseconds <= 0) {
      return _CharacterDetailIcoCountdown(
        remainingText: '已结束',
        endTimeText: formattedEndTime,
        isEndingSoon: false,
      );
    }

    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    return _CharacterDetailIcoCountdown(
      remainingText: '${_padCountdownNumber(days)}天 '
          '${_padCountdownNumber(hours)}时 '
          '${_padCountdownNumber(minutes)}分 '
          '${_padCountdownNumber(seconds)}秒',
      endTimeText: formattedEndTime,
      isEndingSoon: difference.inHours < 1,
    );
  }

  /// 格式化倒计时数字
  ///
  /// [value] 原始倒计时数值
  static String _padCountdownNumber(int value) {
    return value < 10 ? '0$value' : '$value';
  }
}
