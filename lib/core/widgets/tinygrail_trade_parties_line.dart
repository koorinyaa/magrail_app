import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 小圣杯交易双方文本行
class TinygrailTradePartiesLine extends StatefulWidget {
  /// 创建小圣杯交易双方文本行
  ///
  /// [key] Flutter 组件标识
  /// [sellerUsername] 卖方用户名
  /// [sellerLabel] 卖方展示文案
  /// [buyerUsername] 买方用户名
  /// [buyerLabel] 买方展示文案
  /// [color] 用户文案颜色
  /// [arrowColor] 箭头文案颜色
  /// [onUserTap] 用户点击回调
  const TinygrailTradePartiesLine({
    super.key,
    required this.sellerUsername,
    required this.sellerLabel,
    required this.buyerUsername,
    required this.buyerLabel,
    required this.color,
    required this.arrowColor,
    this.onUserTap,
  });

  /// 卖方用户名
  final String sellerUsername;

  /// 卖方展示文案
  final String sellerLabel;

  /// 买方用户名
  final String buyerUsername;

  /// 买方展示文案
  final String buyerLabel;

  /// 用户文案颜色
  final Color color;

  /// 箭头文案颜色
  final Color arrowColor;

  /// 用户点击回调
  final ValueChanged<String>? onUserTap;

  /// 创建小圣杯交易双方文本行状态
  @override
  State<TinygrailTradePartiesLine> createState() =>
      _TinygrailTradePartiesLineState();
}

/// 小圣杯交易双方文本行状态
class _TinygrailTradePartiesLineState extends State<TinygrailTradePartiesLine> {
  TapGestureRecognizer? _sellerRecognizer;
  TapGestureRecognizer? _buyerRecognizer;

  /// 初始化小圣杯交易双方文本行状态
  @override
  void initState() {
    super.initState();
    _syncRecognizers();
  }

  /// 同步小圣杯交易双方文本行点击识别器
  ///
  /// [oldWidget] 更新前的小圣杯交易双方文本行
  @override
  void didUpdateWidget(TinygrailTradePartiesLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sellerUsername != widget.sellerUsername ||
        oldWidget.buyerUsername != widget.buyerUsername ||
        oldWidget.onUserTap != widget.onUserTap) {
      _syncRecognizers();
    }
  }

  /// 释放小圣杯交易双方文本行状态
  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  /// 构建小圣杯交易双方文本行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final userStyle = TextStyle(
      color: widget.color,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.15,
    );

    return Text.rich(
      TextSpan(
        style: userStyle,
        children: [
          TextSpan(
            text: widget.sellerLabel,
            recognizer: _sellerRecognizer,
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: widget.arrowColor,
              ),
            ),
          ),
          TextSpan(
            text: widget.buyerLabel,
            recognizer: _buyerRecognizer,
          ),
        ],
      ),
      softWrap: true,
    );
  }

  /// 同步用户点击识别器
  void _syncRecognizers() {
    _disposeRecognizers();
    final onUserTap = widget.onUserTap;
    if (onUserTap == null) {
      return;
    }

    final sellerUsername = widget.sellerUsername.trim();
    if (sellerUsername.isNotEmpty) {
      _sellerRecognizer = TapGestureRecognizer()
        ..onTap = () => onUserTap(sellerUsername);
    }

    final buyerUsername = widget.buyerUsername.trim();
    if (buyerUsername.isNotEmpty) {
      _buyerRecognizer = TapGestureRecognizer()
        ..onTap = () => onUserTap(buyerUsername);
    }
  }

  /// 释放用户点击识别器
  void _disposeRecognizers() {
    _sellerRecognizer?.dispose();
    _sellerRecognizer = null;
    _buyerRecognizer?.dispose();
    _buyerRecognizer = null;
  }
}
