part of 'user_temple_page.dart';

// 圣殿筛选输入防抖，避免每次输入都重建分页窗口
const Duration _userTempleSearchDebounceDelay = Duration(milliseconds: 450);

/// 用户圣殿二级页面搜索交互
extension _UserTemplePageSearch on _UserTemplePageState {
  /// 处理圣殿筛选输入变化
  ///
  /// [keyword] 角色 ID 或名称筛选词
  void _handleTempleSearchChanged(String keyword) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_userTempleSearchDebounceDelay, () {
      unawaited(_applyTempleSearch(keyword));
    });
  }

  /// 提交圣殿筛选输入
  ///
  /// [keyword] 角色 ID 或名称筛选词
  void _submitTempleSearch(String keyword) {
    _searchDebounce?.cancel();
    unawaited(_applyTempleSearch(keyword));
  }

  /// 应用圣殿筛选并回到页面顶部
  ///
  /// [keyword] 角色 ID 或名称筛选词
  Future<void> _applyTempleSearch(String keyword) async {
    final controller = _currentUserController;
    if (controller == null) {
      return;
    }
    final adjustmentGeneration = ++_scrollAdjustmentGeneration;
    _levelJumpGeneration += 1;
    _isProgrammaticLevelJump = false;
    _isLoadingPreviousPage = false;
    final success = await controller.applySearchFilter(keyword);
    if (!mounted || adjustmentGeneration != _scrollAdjustmentGeneration) {
      return;
    }
    if (!success) {
      _restoreTempleSearchInput();
      AppToast.error(context, text: '搜索失败，请重试');
      return;
    }
    _scrollToTopAfterLayout();
  }

  /// 恢复控制器已提交的圣殿筛选词
  void _restoreTempleSearchInput() {
    final keyword = _currentUserController?.searchKeyword ?? '';
    _searchController.value = TextEditingValue(
      text: keyword,
      selection: TextSelection.collapsed(offset: keyword.length),
    );
  }
}
