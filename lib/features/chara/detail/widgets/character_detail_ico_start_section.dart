import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_kill_vote.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';

/// 角色详情 ICO 启动区
class CharacterDetailIcoStartSection extends StatefulWidget {
  /// 创建角色详情 ICO 启动区
  ///
  /// [key] Flutter 组件标识
  /// [characterId] 角色 ID
  /// [repository] 角色详情仓库
  /// [isAuthorized] 当前 Tinygrail 会话是否可用
  /// [showAuthGuide] 是否显示授权引导
  /// [userBalance] 当前用户余额
  /// [onAuthorize] 打开 Tinygrail 授权页回调
  /// [onStarted] 启动成功后的刷新回调
  const CharacterDetailIcoStartSection({
    super.key,
    required this.characterId,
    required this.repository,
    required this.isAuthorized,
    required this.showAuthGuide,
    required this.userBalance,
    required this.onAuthorize,
    required this.onStarted,
  });

  /// 角色 ID
  final int characterId;

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 当前 Tinygrail 会话是否可用
  final bool isAuthorized;

  /// 是否显示授权引导
  final bool showAuthGuide;

  /// 当前用户余额
  final double? userBalance;

  /// 打开 Tinygrail 授权页回调
  final Future<void> Function() onAuthorize;

  /// 启动成功后的刷新回调
  final Future<void> Function() onStarted;

  /// 创建角色详情 ICO 启动区状态
  @override
  State<CharacterDetailIcoStartSection> createState() =>
      _CharacterDetailIcoStartSectionState();
}

/// 角色详情 ICO 启动区状态
class _CharacterDetailIcoStartSectionState
    extends State<CharacterDetailIcoStartSection> {
  static const double _minimumAmount = 10000;

  final TextEditingController _amountController =
      TextEditingController(text: '10000');
  List<CharacterDetailKillVote>? _killVotes;
  bool _isSubmitting = false;

  /// 初始化角色详情 ICO 启动区状态
  @override
  void initState() {
    super.initState();
    _loadKillVotes();
  }

  /// 更新角色详情 ICO 启动区状态
  ///
  /// [oldWidget] 更新前的 ICO 启动区
  @override
  void didUpdateWidget(covariant CharacterDetailIcoStartSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.characterId != widget.characterId ||
        oldWidget.repository != widget.repository) {
      _killVotes = null;
      _loadKillVotes();
    }
  }

  /// 释放角色详情 ICO 启动区状态
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// 构建角色详情 ICO 启动区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final killVotes = _killVotes;
    final hasRequiredKillVotes = killVotes != null &&
        killVotes.length >= CharacterDetailTradeHeader.requiredKillVoteCount;

    return _IcoStartShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IcoStartHeader(characterId: widget.characterId),
          const SizedBox(height: 16),
          if (killVotes == null)
            const _IcoStartStatus(text: '正在检查删除投票状态')
          else if (hasRequiredKillVotes)
            const _IcoStartWarning(text: '此角色因违规被强制删除，无法启动 ICO')
          else if (!widget.isAuthorized)
            _IcoStartAuthPrompt(
              showAuthGuide: widget.showAuthGuide,
              onAuthorize: widget.onAuthorize,
            )
          else
            _IcoStartForm(
              controller: _amountController,
              balance: widget.userBalance,
              isSubmitting: _isSubmitting,
              onSubmit: _handleSubmit,
            ),
        ],
      ),
    );
  }

  /// 加载角色删除投票
  void _loadKillVotes() {
    unawaited(_resolveKillVotes());
  }

  /// 请求角色删除投票
  Future<void> _resolveKillVotes() async {
    final characterId = widget.characterId;
    final killVotes = await widget.repository.fetchKillVotes(characterId);
    if (!mounted || widget.characterId != characterId) {
      return;
    }

    setState(() {
      _killVotes = killVotes;
    });
  }

  /// 提交 ICO 启动
  Future<void> _handleSubmit() async {
    if (_isSubmitting) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount < _minimumAmount) {
      AppToast.error(context, text: '请输入有效金额，启动 ICO 至少需要 10000cc');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    final confirmed = await showAppConfirmDialog(
      context,
      title: '启动 ICO',
      message: '项目启动之后将不能主动退回资金直到 ICO 结束，确定要启动 ICO？',
      confirmText: '启动',
      showCancelButton: false,
      icon: Icons.token_outlined,
    );
    if (!confirmed || !mounted) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }

    await _submitAmount(amount);
  }

  /// 执行 ICO 启动请求
  ///
  /// [amount] 初始注资金额
  Future<void> _submitAmount(double amount) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final message = await widget.repository.initCharacterIco(
        characterId: widget.characterId,
        amount: amount,
      );
      if (!mounted) {
        return;
      }

      AppToast.info(context, text: message);
      await widget.onStarted();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(context, text: _errorText(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 解析启动失败文案
  ///
  /// [error] 异常对象
  String _errorText(Object error) {
    return resolveUserErrorMessage(error, fallback: '启动 ICO 失败');
  }
}

/// ICO 启动卡片外壳
class _IcoStartShell extends StatelessWidget {
  /// 创建 ICO 启动卡片外壳
  ///
  /// [child] 卡片内容
  const _IcoStartShell({
    required this.child,
  });

  /// 卡片内容
  final Widget child;

  /// 构建 ICO 启动卡片外壳
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.76)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.28 : 0.66,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}

/// ICO 启动标题区
class _IcoStartHeader extends StatelessWidget {
  /// 创建 ICO 启动标题区
  ///
  /// [characterId] 角色 ID
  const _IcoStartHeader({
    required this.characterId,
  });

  /// 角色 ID
  final int characterId;

  /// 构建 ICO 启动标题区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.token_outlined,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '#$characterId 已做好准备',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '点击启动按钮，加入“小圣杯”的争夺',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// ICO 启动表单
class _IcoStartForm extends StatelessWidget {
  /// 创建 ICO 启动表单
  ///
  /// [controller] 金额输入控制器
  /// [balance] 当前用户余额
  /// [isSubmitting] 是否正在提交
  /// [onSubmit] 启动提交回调
  const _IcoStartForm({
    required this.controller,
    required this.balance,
    required this.isSubmitting,
    required this.onSubmit,
  });

  /// 金额输入控制器
  final TextEditingController controller;

  /// 当前用户余额
  final double? balance;

  /// 是否正在提交
  final bool isSubmitting;

  /// 启动提交回调
  final Future<void> Function() onSubmit;

  /// 构建 ICO 启动表单
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (balance != null)
          Text(
            '账户余额：${Formatters.tinygrailCurrency(balance!)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 10),
        _IcoStartAmountField(controller: controller),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: isSubmitting ? null : () => unawaited(onSubmit()),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text(isSubmitting ? '启动中' : '启动 ICO'),
        ),
      ],
    );
  }
}

/// ICO 启动金额输入框
class _IcoStartAmountField extends StatelessWidget {
  /// 创建 ICO 启动金额输入框
  ///
  /// [controller] 金额输入控制器
  const _IcoStartAmountField({
    required this.controller,
  });

  /// 金额输入控制器
  final TextEditingController controller;

  /// 构建 ICO 启动金额输入框
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.48)
        : colorScheme.surfaceContainerLowest;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.26 : 0.58,
    );

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      decoration: InputDecoration(
        labelText: '启动金额',
        hintText: '至少 10000',
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
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// ICO 启动授权提示
class _IcoStartAuthPrompt extends StatelessWidget {
  /// 创建 ICO 启动授权提示
  ///
  /// [showAuthGuide] 是否已经确认需要授权
  /// [onAuthorize] 打开 Tinygrail 授权页回调
  const _IcoStartAuthPrompt({
    required this.showAuthGuide,
    required this.onAuthorize,
  });

  /// 是否已经确认需要授权
  final bool showAuthGuide;

  /// 打开 Tinygrail 授权页回调
  final Future<void> Function() onAuthorize;

  /// 构建 ICO 启动授权提示
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!showAuthGuide) {
      return const _IcoStartStatus(text: '正在检查登录状态');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '授权后可以启动 ICO',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => unawaited(onAuthorize()),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          icon: const Icon(Icons.open_in_new_rounded, size: 17),
          label: const Text('点击授权'),
        ),
      ],
    );
  }
}

/// ICO 启动警告
class _IcoStartWarning extends StatelessWidget {
  /// 创建 ICO 启动警告
  ///
  /// [text] 警告文案
  const _IcoStartWarning({
    required this.text,
  });

  /// 警告文案
  final String text;

  /// 构建 ICO 启动警告
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _IcoStartNotice(
      icon: LucideIcons.triangleAlert,
      text: text,
      color: colorScheme.error,
    );
  }
}

/// ICO 启动状态
class _IcoStartStatus extends StatelessWidget {
  /// 创建 ICO 启动状态
  ///
  /// [text] 状态文案
  const _IcoStartStatus({
    required this.text,
  });

  /// 状态文案
  final String text;

  /// 构建 ICO 启动状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _IcoStartNotice(
      icon: LucideIcons.loaderCircle,
      text: text,
      color: colorScheme.onSurfaceVariant,
    );
  }
}

/// ICO 启动提示行
class _IcoStartNotice extends StatelessWidget {
  /// 创建 ICO 启动提示行
  ///
  /// [icon] 提示图标
  /// [text] 提示文案
  /// [color] 提示颜色
  const _IcoStartNotice({
    required this.icon,
    required this.text,
    required this.color,
  });

  /// 提示图标
  final IconData icon;

  /// 提示文案
  final String text;

  /// 提示颜色
  final Color color;

  /// 构建 ICO 启动提示行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
