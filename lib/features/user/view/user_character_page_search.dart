part of 'user_character_page.dart';

// 角色筛选输入防抖，避免每次输入都重建分页窗口
const Duration _userCharacterSearchDebounceDelay = Duration(milliseconds: 450);

/// 用户角色二级页面搜索交互
extension _UserCharacterPageSearch on _UserCharacterPageState {
  /// 处理角色筛选输入变化
  ///
  /// [keyword] 角色 ID 或名称筛选词
  void _handleCharacterSearchChanged(String keyword) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_userCharacterSearchDebounceDelay, () {
      unawaited(_applyCharacterSearch(keyword));
    });
  }

  /// 提交角色筛选输入
  ///
  /// [keyword] 角色 ID 或名称筛选词
  void _submitCharacterSearch(String keyword) {
    _searchDebounce?.cancel();
    unawaited(_applyCharacterSearch(keyword));
  }

  /// 应用角色筛选并回到列表顶部
  ///
  /// [keyword] 角色 ID 或名称筛选词
  Future<void> _applyCharacterSearch(String keyword) async {
    final controller = _currentUserController;
    if (controller == null) {
      return;
    }
    final adjustmentGeneration = ++_scrollAdjustmentGeneration;
    _isLoadingPreviousPage = false;
    final success = await controller.applySearchFilter(keyword);
    if (!mounted || adjustmentGeneration != _scrollAdjustmentGeneration) {
      return;
    }
    if (!success) {
      _restoreCharacterSearchInput();
      AppToast.error(context, text: '搜索失败，请重试');
      return;
    }
    _scrollToTopAfterLayout();
  }

  /// 恢复控制器已提交的角色筛选词
  void _restoreCharacterSearchInput() {
    final keyword = _currentUserController?.searchKeyword ?? '';
    _searchController.value = TextEditingValue(
      text: keyword,
      selection: TextSelection.collapsed(offset: keyword.length),
    );
  }
}
