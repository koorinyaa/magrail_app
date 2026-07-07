part of 'user_settings_page.dart';

/// 深色模式设置页面
class _ThemeModePage extends StatefulWidget {
  /// 创建深色模式设置页面
  ///
  /// [preferences] 本地偏好设置
  /// [initialThemeMode] 初始主题模式
  /// [onChanged] 主题模式变化回调
  const _ThemeModePage({
    required this.preferences,
    required this.initialThemeMode,
    required this.onChanged,
  });

  /// 本地偏好设置
  final AppPreferences preferences;

  /// 初始主题模式
  final ThemeMode initialThemeMode;

  /// 主题模式变化回调
  final ValueChanged<ThemeMode> onChanged;

  /// 创建深色模式设置页面状态
  @override
  State<_ThemeModePage> createState() => _ThemeModePageState();
}

/// 深色模式设置页面状态
class _ThemeModePageState extends State<_ThemeModePage> {
  late ThemeMode _themeMode;
  bool _isSaving = false;

  /// 初始化深色模式设置页面状态
  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  /// 构建深色模式设置页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          const SecondaryPageSliverAppBar(title: '深色模式'),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                child: _SettingsSurface(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ThemeModeOptionTile(
                        icon: Icons.brightness_auto_rounded,
                        label: ThemeMode.system.settingsLabel,
                        isSelected: _themeMode == ThemeMode.system,
                        isDisabled: _isSaving,
                        onPressed: () => _selectThemeMode(ThemeMode.system),
                      ),
                      _ThemeModeDivider(colorScheme: colorScheme),
                      _ThemeModeOptionTile(
                        icon: Icons.light_mode_outlined,
                        label: ThemeMode.light.settingsLabel,
                        isSelected: _themeMode == ThemeMode.light,
                        isDisabled: _isSaving,
                        onPressed: () => _selectThemeMode(ThemeMode.light),
                      ),
                      _ThemeModeDivider(colorScheme: colorScheme),
                      _ThemeModeOptionTile(
                        icon: Icons.dark_mode_outlined,
                        label: ThemeMode.dark.settingsLabel,
                        isSelected: _themeMode == ThemeMode.dark,
                        isDisabled: _isSaving,
                        onPressed: () => _selectThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 选择应用主题模式
  ///
  /// [themeMode] 目标主题模式
  Future<void> _selectThemeMode(ThemeMode themeMode) async {
    if (_isSaving || _themeMode == themeMode) {
      return;
    }

    final previousMode = _themeMode;
    setState(() {
      _themeMode = themeMode;
      _isSaving = true;
    });

    try {
      await widget.preferences.setThemeMode(themeMode);
      widget.onChanged(themeMode);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _themeMode = previousMode;
      });
      AppToast.error(
        context,
        text: '保存设置失败，请稍后重试',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

/// 深色模式选项行
class _ThemeModeOptionTile extends StatelessWidget {
  /// 创建深色模式选项行
  ///
  /// [icon] 左侧图标
  /// [label] 选项文字
  /// [isSelected] 是否为当前选项
  /// [isDisabled] 是否禁用点击
  /// [onPressed] 点击回调
  const _ThemeModeOptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onPressed,
  });

  /// 左侧图标
  final IconData icon;

  /// 选项文字
  final String label;

  /// 是否为当前选项
  final bool isSelected;

  /// 是否禁用点击
  final bool isDisabled;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建深色模式选项行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? selectedColor : colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? selectedColor : colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: selectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 深色模式选项分割线
class _ThemeModeDivider extends StatelessWidget {
  /// 创建深色模式选项分割线
  ///
  /// [colorScheme] 当前颜色方案
  const _ThemeModeDivider({required this.colorScheme});

  /// 当前颜色方案
  final ColorScheme colorScheme;

  /// 构建深色模式选项分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 50,
      endIndent: 16,
      color: colorScheme.outlineVariant.withValues(alpha: 0.72),
    );
  }
}

/// 主题模式设置文案
extension _ThemeModeSettingsLabel on ThemeMode {
  /// 设置页展示文案
  String get settingsLabel {
    return switch (this) {
      ThemeMode.system => '跟随系统',
      ThemeMode.light => '普通模式',
      ThemeMode.dark => '深色模式',
    };
  }
}
