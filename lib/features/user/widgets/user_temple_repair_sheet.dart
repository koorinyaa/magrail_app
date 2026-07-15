import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/app_loading_dialog.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/controller/current_user_temple_page_controller.dart';
import 'package:magrail_app/features/user/controller/user_temple_repair_sheet_controller.dart';
import 'package:magrail_app/features/user/model/user_temple_repair_entry.dart';
import 'package:magrail_app/shared/widgets/app_bottom_sheet_header.dart';

part 'user_temple_repair_sheet_content.dart';

/// 显示受损圣殿批量补塔底部抽屉
///
/// [context] 当前组件树上下文
/// [snapshotRepository] 用户资产快照仓库
/// [characterRepository] 角色详情仓库
/// [pageController] 当前用户圣殿页面控制器
/// [username] 当前登录用户名
Future<void> showUserTempleRepairSheet(
  BuildContext context, {
  required UserAssetSnapshotRepository snapshotRepository,
  required CharacterDetailRepository characterRepository,
  required CurrentUserTemplePageController pageController,
  required String username,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.8);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: UserTempleRepairSheet(
          snapshotRepository: snapshotRepository,
          characterRepository: characterRepository,
          pageController: pageController,
          username: username,
        ),
      );
    },
  );
}

/// 受损圣殿批量补塔底部抽屉
class UserTempleRepairSheet extends StatefulWidget {
  /// 创建受损圣殿批量补塔底部抽屉
  ///
  /// [key] Flutter 组件标识
  /// [snapshotRepository] 用户资产快照仓库
  /// [characterRepository] 角色详情仓库
  /// [pageController] 当前用户圣殿页面控制器
  /// [username] 当前登录用户名
  const UserTempleRepairSheet({
    super.key,
    required this.snapshotRepository,
    required this.characterRepository,
    required this.pageController,
    required this.username,
  });

  /// 用户资产快照仓库
  final UserAssetSnapshotRepository snapshotRepository;

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 当前用户圣殿页面控制器
  final CurrentUserTemplePageController pageController;

  /// 当前登录用户名
  final String username;

  /// 创建受损圣殿批量补塔底部抽屉状态
  @override
  State<UserTempleRepairSheet> createState() => _UserTempleRepairSheetState();
}

/// 受损圣殿批量补塔底部抽屉状态
class _UserTempleRepairSheetState extends State<UserTempleRepairSheet> {
  late final UserTempleRepairSheetController _controller;

  /// 初始化批量补塔底部抽屉状态
  @override
  void initState() {
    super.initState();
    _controller = UserTempleRepairSheetController(
      snapshotRepository: widget.snapshotRepository,
      characterRepository: widget.characterRepository,
      pageController: widget.pageController,
      username: widget.username,
    );
    unawaited(_controller.initialize());
  }

  /// 释放批量补塔底部抽屉状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建受损圣殿批量补塔底部抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;
    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.58,
                ),
              ),
            ),
          ),
          child: SafeArea(
            left: false,
            right: false,
            top: false,
            child: Padding(
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 20,
                top: 10,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBottomSheetDragHandle(),
                  const SizedBox(height: 14),
                  const _TempleRepairHeader(),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) => _buildContent(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建批量补塔抽屉内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildContent(BuildContext context) {
    if (_controller.isLoading) {
      return const _TempleRepairLoadingState();
    }
    if (_controller.errorMessage.isNotEmpty) {
      return AppLoadFailedState(
        message: _controller.errorMessage,
        onActionPressed: () {
          unawaited(_controller.reload());
        },
      );
    }
    if (_controller.entries.isEmpty) {
      return const _TempleRepairEmptyState();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TempleRepairSelectionHeader(controller: _controller),
        SizedBox(
          height: 4,
          child: _controller.isRefreshing
              ? const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: LinearProgressIndicator(minHeight: 2),
                )
              : null,
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _controller.entries.length,
            separatorBuilder: (context, index) {
              final colorScheme = Theme.of(context).colorScheme;
              final isDark = colorScheme.brightness == Brightness.dark;
              return Divider(
                height: 1,
                thickness: 0.6,
                indent: _TempleRepairRow.infoIndent,
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.58,
                ),
              );
            },
            itemBuilder: (context, index) {
              final entry = _controller.entries[index];
              return _TempleRepairRow(
                entry: entry,
                selected: _controller.isSelected(entry),
                enabled: !_controller.isSubmitting && !_controller.isRefreshing,
                onTap: () => _controller.toggleEntry(entry),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _controller.selectedCount > 0 &&
                  !_controller.isSubmitting &&
                  !_controller.isRefreshing
              ? () => unawaited(_submitRepairs())
              : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text('一键补塔（${_controller.selectedCount}）'),
        ),
      ],
    );
  }

  /// 确认并执行批量补塔
  Future<void> _submitRepairs() async {
    final selectedCount = _controller.selectedCount;
    if (selectedCount <= 0) {
      return;
    }
    final confirmed = await showAppConfirmDialog(
      context,
      title: '确认批量补塔',
      message: '将补充 $selectedCount 座受损圣殿',
      confirmText: '一键补塔',
      showCancelButton: false,
      icon: LucideIcons.wrench,
    );
    if (!confirmed || !mounted) {
      return;
    }

    final progress = ValueNotifier<String>(
      '已完成 0/$selectedCount，成功 0，失败 0',
    );
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var isLoadingDialogVisible = true;
    var didCompleteRepairs = false;
    unawaited(
      showAppLoadingDialog(
        context,
        message: '正在批量补塔',
        messageListenable: progress,
      ),
    );
    bool? dataRefreshSucceeded;
    try {
      dataRefreshSucceeded = await _controller.submitSelected(
        onProgress: (completed, total, succeeded, failed) {
          progress.value = '已完成 $completed/$total，成功 $succeeded，失败 $failed';
        },
        onRepairsCompleted: (succeeded, failed) {
          didCompleteRepairs = true;
          if (!isLoadingDialogVisible) {
            return;
          }
          isLoadingDialogVisible = false;
          if (rootNavigator.mounted) {
            rootNavigator.pop();
          }
          if (!mounted) {
            return;
          }
          if (failed > 0) {
            AppToast.error(
              context,
              text: '补塔完成：成功 $succeeded，失败 $failed',
            );
          } else {
            AppToast.info(context, text: '已补充 $succeeded 座圣殿');
          }
        },
      );
    } catch (_) {
    } finally {
      if (isLoadingDialogVisible && rootNavigator.mounted) {
        rootNavigator.pop();
      }
      progress.dispose();
    }
    if (!mounted) {
      return;
    }
    if (dataRefreshSucceeded == null) {
      if (!didCompleteRepairs) {
        AppToast.error(context, text: '批量补塔失败，请重试');
      }
      return;
    }
    if (!dataRefreshSucceeded) {
      AppToast.error(context, text: '数据刷新失败，请重试');
    }
  }
}
