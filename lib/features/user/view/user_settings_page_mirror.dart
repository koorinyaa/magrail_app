part of 'user_settings_page.dart';

/// 用户设置页镜像操作
extension _UserSettingsPageMirrorActions on _UserSettingsPageState {
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
        message: '请输入镜像地址，例如 bangumi.pro',
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
            hintText: BangumiMirrorConfig.defaultHost,
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
        AppToast.info(context, text: '镜像地址已更新为 $_bangumiMirrorHost');
      }
    } finally {
      // 等待弹窗退出动画结束后再释放输入控制器
      await Future<void>.delayed(const Duration(milliseconds: 300));
      editController.dispose();
    }
  }
}
