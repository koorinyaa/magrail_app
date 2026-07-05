import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// 松手后吸附动画时长，保持横向列滚动反馈轻量
const Duration _snapAnimationDuration = Duration(milliseconds: 220);
// 滚动停止判定延迟，等待惯性滚动真正停稳后再贴边
const Duration _snapDebounceDuration = Duration(milliseconds: 90);

/// 横向按列吸附列表
class SnappingHorizontalListView extends StatefulWidget {
  /// 创建横向按列吸附列表
  ///
  /// [key] Flutter 组件标识
  /// [height] 列表高度
  /// [itemCount] 条目数量
  /// [itemExtent] 条目横向宽度
  /// [separatorExtent] 条目间隔宽度
  /// [padding] 列表内边距
  /// [itemBuilder] 条目构建器
  /// [clipBehavior] 裁剪方式
  const SnappingHorizontalListView({
    super.key,
    required this.height,
    required this.itemCount,
    required this.itemExtent,
    required this.separatorExtent,
    required this.padding,
    required this.itemBuilder,
    this.clipBehavior = Clip.hardEdge,
  });

  /// 列表高度
  final double height;

  /// 条目数量
  final int itemCount;

  /// 条目横向宽度
  final double itemExtent;

  /// 条目间隔宽度
  final double separatorExtent;

  /// 列表内边距
  final EdgeInsetsGeometry padding;

  /// 条目构建器
  final IndexedWidgetBuilder itemBuilder;

  /// 裁剪方式
  final Clip clipBehavior;

  /// 创建横向按列吸附列表状态
  @override
  State<SnappingHorizontalListView> createState() =>
      _SnappingHorizontalListViewState();
}

/// 横向按列吸附列表状态
class _SnappingHorizontalListViewState
    extends State<SnappingHorizontalListView> {
  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;
  double? _lastContentWidth;
  Timer? _snapDebounceTimer;
  bool _isPointerDown = false;
  bool _isSnapping = false;

  /// 初始化横向按列吸附列表状态
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScrollOffsetChanged);
  }

  /// 处理条目数量变化后的吸附边界
  ///
  /// [oldWidget] 更新前的横向按列吸附列表
  @override
  void didUpdateWidget(covariant SnappingHorizontalListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentIndex = _clampIndex(_currentIndex);

    if (widget.itemCount != oldWidget.itemCount ||
        widget.itemExtent != oldWidget.itemExtent ||
        widget.separatorExtent != oldWidget.separatorExtent) {
      _jumpToCurrentIndexAfterLayout();
    }
  }

  /// 释放横向按列吸附列表状态
  @override
  void dispose() {
    _snapDebounceTimer?.cancel();
    _scrollController.removeListener(_handleScrollOffsetChanged);
    _scrollController.dispose();
    super.dispose();
  }

  /// 构建横向按列吸附列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = widget.padding.resolve(Directionality.of(context));
        final viewportWidth = _resolveViewportWidth(context, constraints);
        final contentWidth =
            math.max(1.0, viewportWidth - padding.left - padding.right);
        _handleContentWidthChanged(contentWidth);
        final resolvedPadding = EdgeInsetsDirectional.only(
          start: padding.left,
          end: padding.right + math.max(0.0, contentWidth - widget.itemExtent),
          top: padding.top,
          bottom: padding.bottom,
        );

        return SizedBox(
          height: widget.height,
          child: Listener(
            onPointerDown: (_) => _handlePointerDown(),
            onPointerCancel: (_) => _handlePointerReleased(),
            onPointerUp: (_) => _handlePointerReleased(),
            child: ListView.separated(
              controller: _scrollController,
              clipBehavior: widget.clipBehavior,
              padding: resolvedPadding,
              physics: const ClampingScrollPhysics(),
              primary: false,
              scrollDirection: Axis.horizontal,
              itemCount: widget.itemCount,
              separatorBuilder: (context, index) =>
                  SizedBox(width: widget.separatorExtent),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: widget.itemExtent,
                  child: widget.itemBuilder(context, index),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 根据滚动偏移记录当前稳定列
  void _handleScrollOffsetChanged() {
    if (!_scrollController.hasClients) {
      return;
    }

    _currentIndex = _clampIndex(
      (_scrollController.offset / _itemStepExtent).round(),
    );

    if (!_isPointerDown && !_isSnapping) {
      _scheduleSnapToNearestItem();
    }
  }

  /// 处理手指按下横向列表
  void _handlePointerDown() {
    _isPointerDown = true;
    _snapDebounceTimer?.cancel();
  }

  /// 处理手指离开横向列表
  void _handlePointerReleased() {
    _isPointerDown = false;
    _scheduleSnapToNearestItem();
  }

  /// 延迟吸附到最近列
  void _scheduleSnapToNearestItem() {
    _snapDebounceTimer?.cancel();
    _snapDebounceTimer = Timer(_snapDebounceDuration, () {
      if (!mounted || _isPointerDown || _isSnapping) {
        return;
      }

      unawaited(_snapToNearestItem());
    });
  }

  /// 处理内容视口宽度变化
  ///
  /// [contentWidth] 当前可展示内容宽度
  void _handleContentWidthChanged(double contentWidth) {
    final previousContentWidth = _lastContentWidth;
    _lastContentWidth = contentWidth;
    if (previousContentWidth == null ||
        (previousContentWidth - contentWidth).abs() < 0.5) {
      return;
    }

    _jumpToCurrentIndexAfterLayout();
  }

  /// 读取当前列表视口宽度
  ///
  /// [context] 当前组件树上下文
  /// [constraints] 当前布局约束
  double _resolveViewportWidth(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (constraints.maxWidth.isFinite) {
      return constraints.maxWidth;
    }

    return MediaQuery.sizeOf(context).width;
  }

  /// 在布局完成后回到当前列起点
  void _jumpToCurrentIndexAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.jumpTo(
        _clampOffset(_targetOffsetForIndex(_currentIndex)),
      );
    });
  }

  /// 滚动结束后吸附到最近列
  Future<void> _snapToNearestItem() async {
    if (_isSnapping || !_scrollController.hasClients || widget.itemCount <= 1) {
      return;
    }

    _snapDebounceTimer?.cancel();
    final position = _scrollController.position;
    if (position.outOfRange) {
      return;
    }

    final targetIndex = _clampIndex(
      (_scrollController.offset / _itemStepExtent).round(),
    );
    final targetOffset = _clampOffset(_targetOffsetForIndex(targetIndex));
    _currentIndex = targetIndex;

    if ((targetOffset - _scrollController.offset).abs() < 0.5) {
      return;
    }

    _isSnapping = true;
    try {
      await _scrollController.animateTo(
        targetOffset,
        duration: _snapAnimationDuration,
        curve: Curves.easeOutCubic,
      );
    } finally {
      _isSnapping = false;
    }
  }

  /// 解析列起点偏移
  ///
  /// [index] 列索引
  double _targetOffsetForIndex(int index) {
    return index * _itemStepExtent;
  }

  /// 限制列索引范围
  ///
  /// [index] 原始列索引
  int _clampIndex(int index) {
    final maxIndex = math.max(0, widget.itemCount - 1);
    return index.clamp(0, maxIndex).toInt();
  }

  /// 限制横向滚动偏移
  ///
  /// [offset] 原始滚动偏移
  double _clampOffset(double offset) {
    if (!_scrollController.hasClients) {
      return offset;
    }

    final position = _scrollController.position;
    return offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
  }

  /// 单列滚动步长
  double get _itemStepExtent => widget.itemExtent + widget.separatorExtent;
}
