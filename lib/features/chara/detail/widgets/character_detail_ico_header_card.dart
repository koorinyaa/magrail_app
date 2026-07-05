import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_prediction.dart';

part 'character_detail_ico_header_card_sections.dart';
part 'character_detail_ico_header_card_countdown.dart';

/// 角色详情 ICO 信息卡片
class CharacterDetailIcoHeaderCard extends StatefulWidget {
  /// 创建角色详情 ICO 信息卡片
  ///
  /// [key] Flutter 组件标识
  /// [info] ICO 头部资料
  const CharacterDetailIcoHeaderCard({
    super.key,
    required this.info,
  });

  /// ICO 头部资料
  final CharacterDetailIcoInfo info;

  /// 创建角色详情 ICO 信息卡片状态
  @override
  State<CharacterDetailIcoHeaderCard> createState() =>
      _CharacterDetailIcoHeaderCardState();
}

/// 角色详情 ICO 信息卡片状态
class _CharacterDetailIcoHeaderCardState
    extends State<CharacterDetailIcoHeaderCard> {
  Timer? _countdownTimer;

  /// 初始化角色详情 ICO 信息卡片状态
  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  /// 更新角色详情 ICO 信息卡片状态
  ///
  /// [oldWidget] 更新前的 ICO 信息卡片
  @override
  void didUpdateWidget(covariant CharacterDetailIcoHeaderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.info.end != widget.info.end) {
      _startCountdownTimer();
    }
  }

  /// 释放角色详情 ICO 信息卡片状态
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// 构建角色详情 ICO 信息卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final prediction = CharacterDetailIcoPrediction.fromInfo(widget.info);
    final countdown = _CharacterDetailIcoCountdown.fromEnd(widget.info.end);

    return _IcoHeaderShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IcoHeaderTitle(info: widget.info, prediction: prediction),
          const SizedBox(height: 10),
          _IcoHeaderChips(info: widget.info, prediction: prediction),
          const SizedBox(height: 12),
          _IcoHeaderProgress(info: widget.info, prediction: prediction),
          const SizedBox(height: 10),
          _IcoHeaderCountdown(countdown: countdown),
        ],
      ),
    );
  }

  /// 启动 ICO 结束倒计时
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    final endTime = TinygrailFormatters.parseServerFutureTime(widget.info.end);
    if (endTime == null || !endTime.toLocal().isAfter(DateTime.now())) {
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final resolvedEndTime =
          TinygrailFormatters.parseServerFutureTime(widget.info.end);
      if (resolvedEndTime == null ||
          !resolvedEndTime.toLocal().isAfter(DateTime.now())) {
        _countdownTimer?.cancel();
      }

      if (mounted) {
        setState(() {});
      }
    });
  }
}
