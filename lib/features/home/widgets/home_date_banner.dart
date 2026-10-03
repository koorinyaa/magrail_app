import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/home/controller/home_date_controller.dart';

/// 首页服务器周历条
class HomeDateBanner extends StatefulWidget {
  /// 创建首页服务器周历条
  ///
  /// [key] Flutter 组件标识
  /// [controller] 首页日期状态控制器
  const HomeDateBanner({super.key, required this.controller});

  /// 首页日期状态控制器
  final HomeDateController controller;

  /// 创建首页周历状态
  @override
  State<HomeDateBanner> createState() => _HomeDateBannerState();
}

/// 首页周历布局与横向滚动状态
class _HomeDateBannerState extends State<HomeDateBanner> {
  static const List<String> _weekdays = ['日', '一', '二', '三', '四', '五', '六'];
  // 宽屏保持紧凑周历，日期列至少容纳默认字号的两位日期
  static const double _maxWidth = 480;
  static const double _minimumColumnWidth = 32;
  static const TextStyle _weekdayStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle _dayStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  final ScrollController _scrollController = ScrollController();
  // 仅日期或布局变化时定位当天，保留用户手动横向滚动的位置
  (DateTime, double, double, double)? _lastLayout;

  /// 更换日期控制器后重新定位当天
  ///
  /// [oldWidget] 更新前的首页周历
  @override
  void didUpdateWidget(covariant HomeDateBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) _lastLayout = null;
  }

  /// 释放周历滚动控制器
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 构建首页服务器周历
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, child) => _buildContent(context),
      ),
    );
  }

  /// 构建适配安全区与屏幕宽度的本周日期
  ///
  /// [context] 当前组件树上下文
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: AppSafeAreaInsets.primaryPageHorizontal,
        top: 4,
        right: AppSafeAreaInsets.primaryPageHorizontal,
        bottom: 8,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: LayoutBuilder(builder: _buildWeek),
        ),
      ),
    );
  }

  /// 按实际文字宽度排列七列，极窄视口改为横向滚动
  ///
  /// [context] 当前组件树上下文
  /// [constraints] 安全区与宽屏限宽后的布局约束
  Widget _buildWeek(BuildContext context, BoxConstraints constraints) {
    final dates = widget.controller.weekDates;
    final minimumWidth = _measureColumnWidth(context, dates);
    final viewportWidth = constraints.maxWidth;
    final spacing = viewportWidth < minimumWidth * 7 + 4 * 6 ? 2.0 : 4.0;
    final columnWidth = math.max(
      minimumWidth,
      (viewportWidth - spacing * 6) / 7,
    );
    final contentWidth = columnWidth * 7 + spacing * 6;
    _positionTodayAfterLayout(viewportWidth, columnWidth, spacing);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        primary: false,
        physics: contentWidth > viewportWidth + 0.5
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            for (var index = 0; index < dates.length; index++) ...[
              if (index > 0) SizedBox(width: spacing),
              SizedBox(
                width: columnWidth,
                child: _HomeWeekDay(
                  date: dates[index],
                  weekday: _weekdays[index],
                  isToday: index == widget.controller.todayIndex,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 测量系统字体缩放后的列宽，保持星期与两位日期完整显示
  ///
  /// [context] 当前组件树上下文
  /// [dates] 本周七个服务器日期
  double _measureColumnWidth(BuildContext context, List<DateTime> dates) {
    final baseStyle = DefaultTextStyle.of(context).style;
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    );
    var width = 0.0;
    for (var index = 0; index < dates.length; index++) {
      painter.text = TextSpan(
        text: '${dates[index].day}',
        style: baseStyle.merge(_dayStyle),
      );
      painter.layout();
      width = math.max(width, painter.width);
      painter.text = TextSpan(
        text: _weekdays[index],
        style: baseStyle.merge(_weekdayStyle),
      );
      painter.layout();
      width = math.max(width, painter.width);
    }
    painter.dispose();
    return math.max(_minimumColumnWidth, width.ceilToDouble() + 8);
  }

  /// 首次展示或日期、布局变化后让当天尽量位于视口中央
  ///
  /// [viewportWidth] 当前周历视口宽度
  /// [columnWidth] 每个日期列的宽度
  /// [spacing] 日期列之间的间距
  void _positionTodayAfterLayout(
    double viewportWidth,
    double columnWidth,
    double spacing,
  ) {
    final layout = (
      widget.controller.serverDate,
      viewportWidth,
      columnWidth,
      spacing,
    );
    if (_lastLayout == layout) return;
    _lastLayout = layout;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lastLayout != layout || !_scrollController.hasClients) {
        return;
      }
      final position = _scrollController.position;
      final offset =
          widget.controller.todayIndex * (columnWidth + spacing) +
          columnWidth / 2 -
          viewportWidth / 2;
      _scrollController.jumpTo(
        offset
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble(),
      );
    });
  }
}

/// 首页周历中的星期与日期列
class _HomeWeekDay extends StatelessWidget {
  /// 创建周历日期列
  ///
  /// [date] 服务器日历日期
  /// [weekday] 周日到周六的简称
  /// [isToday] 是否为服务器今天
  const _HomeWeekDay({
    required this.date,
    required this.weekday,
    required this.isToday,
  });

  /// 服务器日历日期
  final DateTime date;

  /// 周日到周六的简称
  final String weekday;

  /// 是否为服务器今天
  final bool isToday;

  /// 构建当天弱强调或普通日期列
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekday,
            maxLines: 1,
            softWrap: false,
            style: _HomeDateBannerState._weekdayStyle.copyWith(
              color: isToday ? colors.primary : colors.onSurfaceVariant,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${date.day}',
            maxLines: 1,
            softWrap: false,
            style: _HomeDateBannerState._dayStyle.copyWith(
              color: isToday ? colors.primary : colors.onSurface,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
