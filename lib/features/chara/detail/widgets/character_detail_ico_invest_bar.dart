import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_prediction.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_user_info.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';

part 'character_detail_ico_invest_bar_content.dart';

/// 角色详情 ICO 底部注资栏
class CharacterDetailIcoInvestBar extends StatefulWidget {
  /// 创建角色详情 ICO 底部注资栏
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色详情仓库
  /// [icoInfo] ICO 头部资料
  /// [userBalance] 当前登录用户余额
  /// [onInvested] 注资成功后的刷新回调
  const CharacterDetailIcoInvestBar({
    super.key,
    required this.repository,
    required this.icoInfo,
    required this.userBalance,
    required this.onInvested,
  });

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// ICO 头部资料
  final CharacterDetailIcoInfo icoInfo;

  /// 当前登录用户余额
  final double? userBalance;

  /// 注资成功后的刷新回调
  final Future<void> Function() onInvested;

  /// 创建角色详情 ICO 底部注资栏状态
  @override
  State<CharacterDetailIcoInvestBar> createState() =>
      _CharacterDetailIcoInvestBarState();
}

/// 角色详情 ICO 底部注资栏状态
class _CharacterDetailIcoInvestBarState
    extends State<CharacterDetailIcoInvestBar> {
  static const double _minimumAmount = 5000;

  final TextEditingController _amountController = TextEditingController(
    text: '5000',
  );
  CharacterDetailIcoUserInfo? _userInfo;
  Object? _loadError;
  double? _localBalance;
  bool _isLoading = false;
  bool _isSubmitting = false;
  int _loadGeneration = 0;

  /// 初始化角色详情 ICO 底部注资栏状态
  @override
  void initState() {
    super.initState();
    _localBalance = widget.userBalance;
    _loadUserInfoIfNeeded();
  }

  /// 处理角色详情 ICO 底部注资栏配置变化
  ///
  /// [oldWidget] 更新前的注资栏配置
  @override
  void didUpdateWidget(covariant CharacterDetailIcoInvestBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userBalance != widget.userBalance && !_isSubmitting) {
      _localBalance = widget.userBalance;
    }

    if (oldWidget.icoInfo.id != widget.icoInfo.id ||
        oldWidget.repository != widget.repository) {
      _userInfo = null;
      _loadError = null;
      _loadUserInfoIfNeeded();
    }
  }

  /// 释放角色详情 ICO 底部注资栏状态
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// 构建角色详情 ICO 底部注资栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: _IcoInvestSurface(
          child: _buildContent(context),
        ),
      ),
    );
  }

  /// 构建注资栏内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const _IcoInvestStatusText(text: '正在加载注资信息');
    }

    final loadError = _loadError;
    if (loadError != null) {
      return _IcoInvestLoadFailedContent(
        message: _errorText(loadError, fallback: '注资信息加载失败'),
        onRetry: _loadUserInfoIfNeeded,
      );
    }

    return _IcoInvestForm(
      amountController: _amountController,
      icoInfo: widget.icoInfo,
      userInfo: _userInfo ?? const CharacterDetailIcoUserInfo.empty(),
      balance: _localBalance,
      isSubmitting: _isSubmitting,
      onFillNextLevel: _fillNextLevelAmount,
      onSubmit: _handleSubmit,
    );
  }

  /// 按需加载当前用户 ICO 注资信息
  void _loadUserInfoIfNeeded() {
    unawaited(_loadUserInfo());
  }

  /// 加载当前用户 ICO 注资信息
  Future<void> _loadUserInfo() async {
    final generation = ++_loadGeneration;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final userInfo = await widget.repository.fetchCharacterIcoUserInfo(
        icoId: widget.icoInfo.id,
      );
      if (!mounted || generation != _loadGeneration) {
        return;
      }

      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || generation != _loadGeneration) {
        return;
      }

      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  /// 填入下一等级所需金额
  void _fillNextLevelAmount() {
    final prediction = CharacterDetailIcoPrediction.fromInfo(widget.icoInfo);
    final amount = prediction.next - widget.icoInfo.total;
    if (amount <= 0) {
      AppToast.info(context, text: '已达到当前目标');
      return;
    }

    _amountController.text = Formatters.plainDecimal(amount);
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
    );
  }

  /// 提交 ICO 注资
  Future<void> _handleSubmit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount < _minimumAmount) {
      AppToast.error(context, text: '请输入有效金额，参与 ICO 至少需要 5000cc');
      return;
    }

    final prediction = CharacterDetailIcoPrediction.fromInfo(widget.icoInfo);
    final newTotal = widget.icoInfo.total + amount;
    if (amount > 1000000 &&
        newTotal >= prediction.next &&
        prediction.users > 0) {
      final shouldContinue = await showAppConfirmDialog(
        context,
        title: '注资提示',
        message: '当前参与人数不足，继续注资可能会导致高于正常发行价，是否继续？',
        confirmText: '继续',
        showCancelButton: false,
        icon: LucideIcons.triangleAlert,
      );
      if (!shouldContinue || !mounted) {
        return;
      }
    }

    final confirmed = await showAppConfirmDialog(
      context,
      title: '确认注资',
      message: '除非 ICO 启动失败，注资将不能退回，确定参与 ICO？',
      confirmText: '注资',
      showCancelButton: false,
      icon: LucideIcons.badgeCent,
    );
    if (!confirmed || !mounted) {
      return;
    }

    await _submitAmount(amount);
  }

  /// 执行 ICO 注资请求
  ///
  /// [amount] 注资金额
  Future<void> _submitAmount(double amount) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.repository.joinCharacterIco(
        icoId: widget.icoInfo.id,
        amount: amount,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        final currentAmount =
            _userInfo ?? const CharacterDetailIcoUserInfo.empty();
        _userInfo = CharacterDetailIcoUserInfo(
          amount: currentAmount.amount + amount,
        );
        final balance = _localBalance;
        if (balance != null) {
          _localBalance = math.max(0, balance - amount);
        }
      });
      AppToast.info(context, text: '注资成功');

      try {
        await widget.onInvested();
      } catch (_) {
        if (mounted) {
          AppToast.error(context, text: '注资成功，刷新角色数据失败');
        }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });
      AppToast.error(
        context,
        text: _errorText(error, fallback: '注资失败'),
      );
    }
  }

  /// 转换错误为展示文案
  ///
  /// [error] 捕获到的错误
  /// [fallback] 兜底文案
  String _errorText(Object error, {required String fallback}) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }
}
