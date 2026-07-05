import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/model/tinygrail_character_reward_item.dart';
import 'package:magrail_app/features/chara/widgets/tinygrail_character_reward_card.dart';

part 'scratch_ticket_result_sheet_card.dart';
part 'scratch_ticket_result_sheet_grid.dart';

/// 显示刮刮乐角色卡片结果弹层
///
/// [context] 当前组件树上下文
/// [characterRepository] 角色详情仓库
/// [title] 弹层标题
/// [items] 角色卡片条目
Future<void> showScratchTicketResultSheet(
  BuildContext context, {
  required CharacterDetailRepository characterRepository,
  required String title,
  required List<TinygrailCharacterRewardItem> items,
}) {
  final view = View.of(context);
  final topSafePadding = view.padding.top / view.devicePixelRatio;
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ScratchTicketResultSheetRoutePage(
          characterRepository: characterRepository,
          title: title,
          items: items,
          topSafePadding: topSafePadding,
          animation: animation,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ),
  );
}

/// 刮刮乐角色卡片结果路由页
class _ScratchTicketResultSheetRoutePage extends StatefulWidget {
  /// 创建刮刮乐角色卡片结果路由页
  ///
  /// [characterRepository] 角色详情仓库
  /// [title] 弹层标题
  /// [items] 角色卡片条目
  /// [topSafePadding] 顶部系统安全距离
  /// [animation] 路由动画
  const _ScratchTicketResultSheetRoutePage({
    required this.characterRepository,
    required this.title,
    required this.items,
    required this.topSafePadding,
    required this.animation,
  });

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 弹层标题
  final String title;

  /// 角色卡片条目
  final List<TinygrailCharacterRewardItem> items;

  /// 顶部系统安全距离
  final double topSafePadding;

  /// 路由动画
  final Animation<double> animation;

  /// 创建刮刮乐角色卡片结果路由页状态
  @override
  State<_ScratchTicketResultSheetRoutePage> createState() =>
      _ScratchTicketResultSheetRoutePageState();
}

/// 刮刮乐角色卡片结果路由页状态
class _ScratchTicketResultSheetRoutePageState
    extends State<_ScratchTicketResultSheetRoutePage>
    with SingleTickerProviderStateMixin {
  static const _dismissDistance = 120.0;
  static const _dismissVelocity = 700.0;

  late final AnimationController _resetController;
  Animation<double>? _resetAnimation;
  double _dragOffset = 0;

  /// 初始化刮刮乐角色卡片结果路由页状态
  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(_handleResetTick);
  }

  /// 释放刮刮乐角色卡片结果路由页状态
  @override
  void dispose() {
    _resetController
      ..removeListener(_handleResetTick)
      ..dispose();
    super.dispose();
  }

  /// 构建刮刮乐角色卡片结果路由页
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    const topGap = 32.0;
    final maxHeight = (mediaQuery.size.height - widget.topSafePadding - topGap)
        .clamp(0.0, mediaQuery.size.height)
        .toDouble();
    final sheetAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final barrierOpacity =
        (1 - (_dragOffset / maxHeight).clamp(0.0, 0.45)).toDouble();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: widget.animation,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.48 * barrierOpacity,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(sheetAnimation),
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: GestureDetector(
                  onVerticalDragUpdate: _handleDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: ScratchTicketResultSheet(
                      characterRepository: widget.characterRepository,
                      title: widget.title,
                      items: widget.items,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理回弹动画帧
  void _handleResetTick() {
    final animation = _resetAnimation;
    if (animation == null || !mounted) {
      return;
    }

    setState(() {
      _dragOffset = animation.value;
    });
  }

  /// 处理抽屉拖拽位移
  ///
  /// [details] 拖拽更新详情
  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    if (delta == 0) {
      return;
    }

    _resetController.stop();
    setState(() {
      _dragOffset = (_dragOffset + delta).clamp(0.0, double.infinity);
    });
  }

  /// 处理抽屉拖拽结束
  ///
  /// [details] 拖拽结束详情
  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_dragOffset >= _dismissDistance || velocity >= _dismissVelocity) {
      Navigator.of(context).pop();
      return;
    }

    _resetAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _resetController,
        curve: Curves.easeOutCubic,
      ),
    );
    _resetController.forward(from: 0);
  }
}

/// 刮刮乐角色卡片结果弹层
class ScratchTicketResultSheet extends StatefulWidget {
  /// 创建刮刮乐角色卡片结果弹层
  ///
  /// [key] Flutter 组件标识
  /// [characterRepository] 角色详情仓库
  /// [title] 弹层标题
  /// [items] 角色卡片条目
  const ScratchTicketResultSheet({
    super.key,
    required this.characterRepository,
    required this.title,
    required this.items,
  });

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 弹层标题
  final String title;

  /// 角色卡片条目
  final List<TinygrailCharacterRewardItem> items;

  /// 创建刮刮乐角色卡片结果弹层状态
  @override
  State<ScratchTicketResultSheet> createState() =>
      _ScratchTicketResultSheetState();
}

/// 刮刮乐角色卡片结果弹层状态
class _ScratchTicketResultSheetState extends State<ScratchTicketResultSheet> {
  late List<TinygrailCharacterRewardItem> _items;

  /// 初始化刮刮乐角色卡片结果弹层状态
  @override
  void initState() {
    super.initState();
    _items = List<TinygrailCharacterRewardItem>.of(widget.items);
  }

  /// 构建刮刮乐角色卡片结果弹层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerLow
              : colorScheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.32 : 0.58,
              ),
            ),
          ),
        ),
        child: SafeArea(
          left: false,
          right: false,
          top: false,
          child: Padding(
            padding: AppSafeAreaInsets.fromLTRB(
              context,
              left: 16,
              top: 10,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppBottomSheetDragHandle(),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '获得 ${_items.length} 个角色',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: SingleChildScrollView(
                    child: _ResultGrid(
                      items: _items,
                      characterRepository: widget.characterRepository,
                      onSold: _handleSold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 标记刮刮乐角色已卖出
  ///
  /// [item] 已卖出的角色卡片条目
  void _handleSold(TinygrailCharacterRewardItem item) {
    setState(() {
      _items = [
        for (final current in _items)
          if (identical(current, item))
            current.copyWith(
              amount: current.amount > current.sellAmount
                  ? current.amount - current.sellAmount
                  : 0,
              sellPrice: 0,
              sellAmount: 0,
            )
          else
            current,
      ];
    });
  }
}
