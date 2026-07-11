part of 'user_asset_analysis_character_packing_section.dart';

/// 用户资产分析角色圆图布局
class _PackedBubbleLayout {
  /// 构建用户资产分析角色圆图布局
  ///
  /// [bubbles] 角色圆图气泡数据
  /// [side] 正方形画布边长
  /// [mode] 资产占比统计模式
  static List<_PackedBubbleLayoutItem> build({
    required List<UserAssetAnalysisCharacterBubble> bubbles,
    required double side,
    required UserAssetAnalysisAssetProportionMode mode,
  }) {
    if (bubbles.isEmpty) {
      return const [];
    }

    final center = Offset(side / 2, side / 2);
    final outerRadius = side / 2 - 4;
    final maxValue = _characterBubbleValue(bubbles.first, mode);
    final countScale = math
        .sqrt(24 / math.max(24, bubbles.length))
        .clamp(0.82, 1.0)
        .toDouble();
    final minRadius = math.max(13.0, side * 0.042) * countScale;
    final maxRadius = math.min(50.0, side * 0.145) * countScale;
    final circles = [
      for (final bubble in bubbles)
        _PackingCircle(
          bubble: bubble,
          visualRadius: _radiusForValue(
            value: _characterBubbleValue(bubble, mode),
            maxValue: maxValue,
            minRadius: minRadius,
            maxRadius: maxRadius,
          ),
          ratio: maxValue <= 0
              ? 0
              : (_characterBubbleValue(bubble, mode) / maxValue)
                  .clamp(0, 1)
                  .toDouble(),
        ),
    ];
    _packSiblings(circles);

    final anchor = circles.first;
    final maxExtent = _maxExtentFromAnchor(circles, anchor);
    final scale = maxExtent <= 0
        ? 1.0
        : (outerRadius / maxExtent).clamp(0.1, 1.32).toDouble();
    final placed = [
      for (var index = 0; index < circles.length; index += 1)
        _PackedBubbleLayoutItem(
          bubble: circles[index].bubble,
          center: center +
              Offset(
                (circles[index].x - anchor.x) * scale,
                (circles[index].y - anchor.y) * scale,
              ),
          radius: circles[index].visualRadius * scale,
          ratio: circles[index].ratio,
          rank: index,
        ),
    ];

    return List<_PackedBubbleLayoutItem>.unmodifiable(placed);
  }

  /// 按数值计算气泡半径
  ///
  /// [value] 气泡数值
  /// [maxValue] 最大气泡数值
  /// [minRadius] 最小气泡半径
  /// [maxRadius] 最大气泡半径
  static double _radiusForValue({
    required double value,
    required double maxValue,
    required double minRadius,
    required double maxRadius,
  }) {
    if (maxValue <= 0) {
      return minRadius;
    }

    final ratio = math.sqrt((value / maxValue).clamp(0, 1));
    return minRadius + ratio * (maxRadius - minRadius);
  }

  /// 排列相切圆
  ///
  /// [circles] 待排列圆列表
  static void _packSiblings(List<_PackingCircle> circles) {
    if (circles.isEmpty) {
      return;
    }

    final first = circles[0]
      ..x = 0
      ..y = 0;
    if (circles.length == 1) {
      return;
    }

    final second = circles[1]
      ..x = first.layoutRadius
      ..y = 0;
    first.x = -second.layoutRadius;
    if (circles.length == 2) {
      return;
    }

    final third = circles[2];
    _placeTangent(second, first, third);

    var a = _FrontChainNode(first);
    var b = _FrontChainNode(second);
    var c = _FrontChainNode(third);
    a.next = b;
    a.previous = c;
    b.next = c;
    b.previous = a;
    c.next = a;
    c.previous = b;

    packing:
    for (var index = 3; index < circles.length; index += 1) {
      final circle = circles[index];
      _placeTangent(a.circle, b.circle, circle);
      c = _FrontChainNode(circle);

      var forward = b.next!;
      var backward = a.previous!;
      var forwardRadius = b.circle.layoutRadius;
      var backwardRadius = a.circle.layoutRadius;

      while (true) {
        if (forwardRadius <= backwardRadius) {
          if (_intersects(forward.circle, c.circle)) {
            b = forward;
            a.next = b;
            b.previous = a;
            index -= 1;
            continue packing;
          }
          forwardRadius += forward.circle.layoutRadius;
          forward = forward.next!;
        } else {
          if (_intersects(backward.circle, c.circle)) {
            a = backward;
            a.next = b;
            b.previous = a;
            index -= 1;
            continue packing;
          }
          backwardRadius += backward.circle.layoutRadius;
          backward = backward.previous!;
        }

        if (identical(forward, backward.next)) {
          break;
        }
      }

      c.previous = a;
      c.next = b;
      a.next = c;
      b.previous = c;
      b = c;

      var best = a;
      var bestScore = _frontChainScore(a);
      var current = a.next!;
      while (!identical(current, b)) {
        final score = _frontChainScore(current);
        if (score < bestScore) {
          best = current;
          bestScore = score;
        }
        current = current.next!;
      }
      a = best;
      b = a.next!;
    }
  }

  /// 将圆放到两个已排圆的切点上
  ///
  /// [a] 第一个已排圆
  /// [b] 第二个已排圆
  /// [c] 待排列圆
  static void _placeTangent(
    _PackingCircle a,
    _PackingCircle b,
    _PackingCircle c,
  ) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final distanceSquared = dx * dx + dy * dy;
    if (distanceSquared <= 0) {
      c.x = a.x + a.layoutRadius + c.layoutRadius;
      c.y = a.y;
      return;
    }

    final ac = a.layoutRadius + c.layoutRadius;
    final bc = b.layoutRadius + c.layoutRadius;
    final acSquared = ac * ac;
    final bcSquared = bc * bc;
    if (acSquared > bcSquared) {
      final x =
          (distanceSquared + bcSquared - acSquared) / (2 * distanceSquared);
      final y = math.sqrt(math.max(0, bcSquared / distanceSquared - x * x));
      c.x = b.x - x * dx - y * dy;
      c.y = b.y - x * dy + y * dx;
      return;
    }

    final x = (distanceSquared + acSquared - bcSquared) / (2 * distanceSquared);
    final y = math.sqrt(math.max(0, acSquared / distanceSquared - x * x));
    c.x = a.x + x * dx - y * dy;
    c.y = a.y + x * dy + y * dx;
  }

  /// 判断两个排列圆是否相交
  ///
  /// [a] 第一个排列圆
  /// [b] 第二个排列圆
  static bool _intersects(_PackingCircle a, _PackingCircle b) {
    final distance = a.layoutRadius + b.layoutRadius - _collisionEpsilon;
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    return distance > 0 && distance * distance > dx * dx + dy * dy;
  }

  /// 计算前链节点靠近原点的分数
  ///
  /// [node] 前链节点
  static double _frontChainScore(_FrontChainNode node) {
    final next = node.next ?? node;
    final a = node.circle;
    final b = next.circle;
    final radiusSum = a.layoutRadius + b.layoutRadius;
    final x = (a.x * b.layoutRadius + b.x * a.layoutRadius) / radiusSum;
    final y = (a.y * b.layoutRadius + b.y * a.layoutRadius) / radiusSum;
    return x * x + y * y;
  }

  /// 计算从锚点覆盖全部圆的最大半径
  ///
  /// [circles] 已排列圆列表
  /// [anchor] 锚点圆
  static double _maxExtentFromAnchor(
    List<_PackingCircle> circles,
    _PackingCircle anchor,
  ) {
    var maxExtent = anchor.visualRadius;
    for (final circle in circles) {
      final dx = circle.x - anchor.x;
      final dy = circle.y - anchor.y;
      final extent = math.sqrt(dx * dx + dy * dy) + circle.visualRadius;
      maxExtent = math.max(maxExtent, extent);
    }
    return maxExtent;
  }
}

/// 用户资产分析圆图排列圆
class _PackingCircle {
  /// 创建用户资产分析圆图排列圆
  ///
  /// [bubble] 角色圆图气泡数据
  /// [visualRadius] 气泡展示半径
  /// [ratio] 气泡数值占最大值比例
  _PackingCircle({
    required this.bubble,
    required this.visualRadius,
    required this.ratio,
  });

  /// 角色圆图气泡数据
  final UserAssetAnalysisCharacterBubble bubble;

  /// 气泡展示半径
  final double visualRadius;

  /// 气泡数值占最大值比例
  final double ratio;

  double x = 0;
  double y = 0;

  /// 参与碰撞检测的布局半径
  double get layoutRadius => visualRadius + _packingGap;
}

/// 用户资产分析圆图前链节点
class _FrontChainNode {
  /// 创建用户资产分析圆图前链节点
  ///
  /// [circle] 前链圆
  _FrontChainNode(this.circle);

  /// 前链圆
  final _PackingCircle circle;

  _FrontChainNode? next;
  _FrontChainNode? previous;
}

/// 用户资产分析角色圆图布局项
class _PackedBubbleLayoutItem {
  /// 创建用户资产分析角色圆图布局项
  ///
  /// [bubble] 角色圆图气泡数据
  /// [center] 气泡圆心
  /// [radius] 气泡半径
  /// [ratio] 气泡数值占最大值比例
  /// [rank] 当前统计模式排名序号
  const _PackedBubbleLayoutItem({
    required this.bubble,
    required this.center,
    required this.radius,
    required this.ratio,
    required this.rank,
  });

  /// 角色圆图气泡数据
  final UserAssetAnalysisCharacterBubble bubble;

  /// 气泡圆心
  final Offset center;

  /// 气泡半径
  final double radius;

  /// 气泡数值占最大值比例
  final double ratio;

  /// 当前统计模式排名序号
  final int rank;
}
