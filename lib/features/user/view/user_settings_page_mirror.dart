part of 'user_settings_page.dart';

/// 用户设置页镜像操作
extension _UserSettingsPageMirrorActions on _UserSettingsPageState {
  /// 构建镜像总开关与自定义地址入口
  ///
  /// [context] 当前组件树上下文
  Widget _buildMirrorSettings(BuildContext context) {
    final preferences = widget.preferences;
    return _SettingsSurface(
      child: AbsorbPointer(
        absorbing: _isUpdatingBangumiMirror,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SettingsSwitchTile(
              icon: Icons.travel_explore_rounded,
              label: '使用 ${preferences.effectiveBangumiMirrorHost} 镜像',
              value: preferences.useBangumiMirror,
              onChanged: _handleBangumiMirrorChanged,
            ),
            _SettingsValueActionTile(
              icon: Icons.dns_rounded,
              label: '自定义镜像',
              value: _bangumiMirrorHost.isEmpty ? '使用默认配置' : _bangumiMirrorHost,
              onPressed: _openBangumiMirrorEditor,
            ),
          ],
        ),
      ),
    );
  }

  /// 保存镜像总开关并同步后续请求
  ///
  /// [value] 是否启用镜像
  Future<void> _handleBangumiMirrorChanged(bool value) async {
    if (_isUpdatingBangumiMirror) {
      return;
    }
    _setMirrorUpdating(true);
    try {
      await widget.preferences.setUseBangumiMirror(value);
      if (mounted) {
        AppToast.info(context, text: value ? '已启用镜像' : '已关闭镜像');
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(context, text: '保存设置失败，请稍后重试');
      }
    } finally {
      _setMirrorUpdating(false);
    }
  }

  /// 保存自定义域名，留空时清除覆盖并恢复默认配置
  ///
  /// [input] 用户填写的镜像域名或 HTTP(S) 地址
  Future<bool> _saveBangumiMirrorHost(String input) async {
    final host = BangumiMirrorConfig.normalizeHost(input);
    if (input.trim().isNotEmpty && host == null) {
      AppToast.error(context, text: '请输入有效的镜像地址');
      return false;
    }
    try {
      await widget.preferences.setBangumiMirrorHost(host ?? '');
      return true;
    } catch (_) {
      if (mounted) {
        AppToast.error(context, text: '保存设置失败，请稍后重试');
      }
      return false;
    }
  }

  /// 打开自定义镜像编辑弹窗
  Future<void> _openBangumiMirrorEditor() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.48)
        : colorScheme.surfaceContainerLowest;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.26 : 0.58,
    );
    final editController = TextEditingController(text: _bangumiMirrorHost);

    try {
      final saved = await showAppConfirmDialog(
        context,
        title: '自定义镜像',
        message: '填写自定义镜像地址，留空使用默认配置',
        icon: Icons.dns_rounded,
        confirmText: '保存',
        showCancelButton: false,
        content: TextField(
          controller: editController,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.url,
          textCapitalization: TextCapitalization.none,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
          decoration: InputDecoration(
            labelText: '镜像地址',
            hintText: widget.preferences.defaultBangumiMirrorHost,
            labelStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            floatingLabelStyle: TextStyle(
              color: colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
          ),
        ),
        onConfirm: () => _saveBangumiMirrorHost(editController.text),
      );
      if (saved && mounted) {
        AppToast.info(
          context,
          text: _bangumiMirrorHost.isEmpty
              ? '已恢复默认镜像配置'
              : '镜像地址已更新为 $_bangumiMirrorHost',
        );
      }
    } finally {
      // 等待弹窗退出动画结束后再释放输入控制器
      await Future<void>.delayed(const Duration(milliseconds: 300));
      editController.dispose();
    }
  }
}
