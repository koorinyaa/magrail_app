part of 'bot_config_page.dart';

/// bot 操作日志二级页面
class _BotLogPage extends StatefulWidget {
  /// 创建 bot 操作日志二级页面
  ///
  /// [controller] bot 配置页控制器
  const _BotLogPage({
    required this.controller,
  });

  /// bot 配置页控制器
  final BotConfigController controller;

  /// 创建 bot 操作日志二级页面状态
  @override
  State<_BotLogPage> createState() => _BotLogPageState();
}

/// bot 操作日志二级页面状态
class _BotLogPageState extends State<_BotLogPage> {
  /// 初始化 bot 操作日志二级页面状态
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(widget.controller.refreshLogs());
      }
    });
  }

  /// 构建 bot 操作日志二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, child) {
          return CustomScrollView(
            slivers: [
              const SecondaryPageSliverAppBar(title: '操作日志'),
              ..._buildLogSlivers(),
            ],
          );
        },
      ),
    );
  }

  /// 构建日志列表区域
  List<Widget> _buildLogSlivers() {
    final controller = widget.controller;
    if (controller.isLoadingLogs && controller.logs.isEmpty) {
      return const [_BotLogSkeletonSliverList()];
    }

    final error = controller.logErrorMessage;
    if (error != null && error.isNotEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _BotLogSliverState(
            icon: Icons.wifi_off_rounded,
            text: error,
          ),
        ),
      ];
    }

    if (controller.logs.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _BotLogSliverState(
            icon: Icons.receipt_long_outlined,
            text: '暂无操作日志',
          ),
        ),
      ];
    }

    return [
      SliverSafeArea(
        top: false,
        minimum: EdgeInsets.only(
          bottom: 24 + MediaQuery.paddingOf(context).bottom,
        ),
        sliver: _BotLogSliverList(
          logs: controller.logs,
          onCharacterTap: _handleCharacterTap,
        ),
      ),
    ];
  }

  /// 处理日志角色 ID 点击
  ///
  /// [characterId] 角色 ID
  void _handleCharacterTap(int characterId) {
    openCharacterDetail(
      context,
      characterId: characterId,
    );
  }
}
