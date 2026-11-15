part of 'temple_cover_image.dart';

/// 为封面及其按钮共享播放状态，嵌套卡片沿用外层 LINK 状态
class TempleCoverPlayback extends StatefulWidget {
  /// 创建封面播放区域
  ///
  /// [key] Flutter 组件标识
  /// [coverUrls] 当前封面地址，变化时恢复为静止状态
  /// [child] 包含封面与播放按钮的卡片
  const TempleCoverPlayback({
    super.key,
    required this.coverUrls,
    required this.child,
  });

  /// 当前封面地址
  final List<String> coverUrls;

  /// 包含封面与播放按钮的卡片
  final Widget child;

  /// 创建并管理卡片的播放状态
  @override
  State<TempleCoverPlayback> createState() => _TempleCoverPlaybackState();
}

/// 随卡片创建、替换和释放播放状态
class _TempleCoverPlaybackState extends State<TempleCoverPlayback> {
  _TempleCoverPlaybackController _controller = _TempleCoverPlaybackController();

  /// 封面变化后废弃原播放状态和加载回调
  ///
  /// [oldWidget] 上一次的封面配置
  @override
  void didUpdateWidget(TempleCoverPlayback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.coverUrls, oldWidget.coverUrls)) {
      _controller.dispose();
      _controller = _TempleCoverPlaybackController();
    }
  }

  /// 复用外层 LINK 状态，单独卡片建立自己的播放区域
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (_TempleCoverPlaybackScope.maybeOf(context) != null) return widget.child;
    return _TempleCoverPlaybackScope(
      controller: _controller,
      child: widget.child,
    );
  }

  /// 释放播放状态并忽略尚未执行的加载通知
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 记录当前卡片内 GIF 加载结果与共享播放状态
class _TempleCoverPlaybackController extends ChangeNotifier {
  final Set<String> _ready = {};
  final Map<String, bool> _pendingReady = {};
  bool _disposed = false;
  bool _isPlaying = false;

  /// 当前卡片是否请求播放
  bool get isPlaying => _isPlaying;

  /// 判断指定 GIF 或当前 LINK 是否已有可播放封面
  ///
  /// [coverUrl] 指定封面地址，空值表示当前播放区域的任意 GIF
  bool isReady(String? coverUrl) =>
      coverUrl == null ? _ready.isNotEmpty : _ready.contains(coverUrl);

  /// 延迟合并图片构建期间的加载结果，避免在构建中刷新其他组件
  ///
  /// [coverUrl] 加载结果所属封面
  /// [ready] 是否已成功加载图片帧
  void updateReady(String coverUrl, bool ready) {
    if (_disposed ||
        (_pendingReady[coverUrl] ?? _ready.contains(coverUrl)) == ready) {
      return;
    }
    final scheduled = _pendingReady.isNotEmpty;
    _pendingReady[coverUrl] = ready;
    if (scheduled) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      for (final entry in _pendingReady.entries) {
        if (entry.value) {
          _ready.add(entry.key);
        } else {
          _ready.remove(entry.key);
        }
      }
      _pendingReady.clear();
      if (_ready.isEmpty) _isPlaying = false;
      notifyListeners();
    });
  }

  /// 同步切换当前卡片内所有 GIF 的播放与暂停
  void toggle() {
    if (_disposed || _ready.isEmpty) return;
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  /// 忽略已经离开卡片的图片加载结果
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// 向同一卡片的图片与独立操作按钮提供播放状态
class _TempleCoverPlaybackScope
    extends InheritedNotifier<_TempleCoverPlaybackController> {
  /// 创建卡片播放状态作用域
  ///
  /// [controller] 当前卡片共享的播放状态
  /// [child] 卡片内容
  const _TempleCoverPlaybackScope({
    required _TempleCoverPlaybackController controller,
    required super.child,
  }) : super(notifier: controller);

  /// 读取最近的卡片播放状态并监听变化
  ///
  /// [context] 当前组件树上下文
  static _TempleCoverPlaybackController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TempleCoverPlaybackScope>()
        ?.notifier;
  }
}

/// 仅在 GIF 加载成功后显示的独立播放按钮
class TempleCoverPlaybackButton extends StatelessWidget {
  /// 创建封面播放按钮
  ///
  /// [key] Flutter 组件标识
  /// [coverUrl] 指定 GIF 地址，空值控制当前区域的任意 GIF
  /// [padding] 按钮显示时占用的外侧留白
  /// [dimension] 圆形按钮直径
  const TempleCoverPlaybackButton({
    super.key,
    this.coverUrl,
    this.padding = EdgeInsets.zero,
    this.dimension = 28,
  });

  /// 指定 GIF 地址，空值控制当前区域的任意 GIF
  final String? coverUrl;

  /// 按钮显示时占用的外侧留白
  final EdgeInsetsGeometry padding;

  /// 圆形按钮直径
  final double dimension;

  /// 构建位于卡片点击层上方的播放入口
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final playback = _TempleCoverPlaybackScope.maybeOf(context);
    if (playback == null || !playback.isReady(coverUrl)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: padding,
      child: Material(
        color: Colors.black.withValues(alpha: 0.28),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: playback.toggle,
          customBorder: const CircleBorder(),
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: SizedBox.square(
            dimension: dimension,
            child: Icon(
              playback.isPlaying ? LucideIcons.pause : LucideIcons.play,
              size: dimension / 2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
