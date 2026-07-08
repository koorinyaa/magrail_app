part of 'character_detail_ico_start_section.dart';

/// ICO 启动警告
class _IcoStartWarning extends StatelessWidget {
  /// 创建 ICO 启动警告
  ///
  /// [text] 警告文案
  const _IcoStartWarning({
    required this.text,
  });

  /// 警告文案
  final String text;

  /// 构建 ICO 启动警告
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _IcoStartNotice(
      icon: LucideIcons.triangleAlert,
      text: text,
      color: colorScheme.error,
    );
  }
}

/// ICO 启动状态
class _IcoStartStatus extends StatelessWidget {
  /// 创建 ICO 启动状态
  ///
  /// [text] 状态文案
  const _IcoStartStatus({
    required this.text,
  });

  /// 状态文案
  final String text;

  /// 构建 ICO 启动状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _IcoStartNotice(
      icon: LucideIcons.loaderCircle,
      text: text,
      color: colorScheme.onSurfaceVariant,
    );
  }
}

/// ICO 启动提示行
class _IcoStartNotice extends StatelessWidget {
  /// 创建 ICO 启动提示行
  ///
  /// [icon] 提示图标
  /// [text] 提示文案
  /// [color] 提示颜色
  const _IcoStartNotice({
    required this.icon,
    required this.text,
    required this.color,
  });

  /// 提示图标
  final IconData icon;

  /// 提示文案
  final String text;

  /// 提示颜色
  final Color color;

  /// 构建 ICO 启动提示行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
