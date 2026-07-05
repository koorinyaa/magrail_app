part of 'character_detail_page_body.dart';

/// 角色详情无效状态
class _CharacterDetailInvalidState extends StatelessWidget {
  /// 创建角色详情无效状态
  const _CharacterDetailInvalidState();

  /// 构建角色详情无效状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const _CharacterDetailCenteredMessage(
      icon: Icons.hourglass_empty_rounded,
      title: '角色无效',
      message: '缺少可打开的角色 ID',
    );
  }
}

/// 角色详情居中状态文案
class _CharacterDetailCenteredMessage extends StatelessWidget {
  /// 创建角色详情居中状态文案
  ///
  /// [icon] 状态图标
  /// [title] 状态标题
  /// [message] 状态说明
  const _CharacterDetailCenteredMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  /// 状态图标
  final IconData icon;

  /// 状态标题
  final String title;

  /// 状态说明
  final String message;

  /// 构建角色详情居中状态文案
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 38,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
