part of 'character_detail_trade_header_card.dart';

/// 已上市头部股息 Chip
class _TradeHeaderDividendChip extends StatelessWidget {
  /// 创建已上市头部股息 Chip
  ///
  /// [header] 已上市角色头部资料
  const _TradeHeaderDividendChip({required this.header});

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建已上市头部股息 Chip
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _TradeHeaderInfoChip(
      icon: LucideIcons.coins,
      text: Formatters.tinygrailCurrency(header.dividend),
      onPressed: () => _showDividendFormulaDialog(context),
    );
  }

  /// 显示股息计算说明弹窗
  ///
  /// [context] 当前组件树上下文
  Future<void> _showDividendFormulaDialog(BuildContext context) async {
    final dividendText = Formatters.tinygrailCurrency(header.dividend);
    final perStarDividendText = Formatters.tinygrailCurrency(2);
    final rankFormulaText =
        '${Formatters.tinygrailCurrency(header.rate)} × '
        '0.005 × (601 - ${header.rank})';
    final starFormulaText = '${header.stars} × $perStarDividendText';
    final usesTowerFormula = header.rank > 0 && header.rank <= 500;
    final appliedFormulaText = usesTowerFormula
        ? '$rankFormulaText = $dividendText'
        : '$starFormulaText = $dividendText';
    final message =
        '在通天塔前 500 名时：\n'
        '基础股息 × 0.005 × (601 - 排名)\n'
        '\n'
        '不在通天塔前 500 名时：\n'
        '星级 × $perStarDividendText\n'
        '\n'
        '当前使用：$appliedFormulaText';

    await _showTradeHeaderInfoDialog(
      context,
      title: '股息',
      message: message,
      icon: LucideIcons.coins,
    );
  }
}

/// 显示已上市角色胶囊说明
///
/// [context] 当前组件树上下文
/// [title] 数据名称
/// [message] 数据说明
/// [icon] 标题图标
/// [iconWidget] 自定义标题图标，包含所需背景
Future<void> _showTradeHeaderInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData? icon,
  Widget? iconWidget,
}) async {
  await showAppConfirmDialog(
    context,
    title: title,
    message: message,
    confirmText: '知道了',
    showCancelButton: false,
    icon: icon,
    iconWidget: iconWidget,
  );
}
