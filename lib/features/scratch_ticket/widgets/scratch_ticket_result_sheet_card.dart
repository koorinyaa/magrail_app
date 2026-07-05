part of 'scratch_ticket_result_sheet.dart';

/// 刮刮乐获得的单个角色卡片
class _ResultCard extends StatelessWidget {
  /// 创建刮刮乐获得的单个角色卡片
  ///
  /// [item] 角色卡片条目
  /// [characterRepository] 角色详情仓库
  /// [onSold] 卖出成功回调
  /// [heroTag] 图片 Hero 标识
  const _ResultCard({
    required this.item,
    required this.characterRepository,
    required this.onSold,
    required this.heroTag,
  });

  /// 角色卡片条目
  final TinygrailCharacterRewardItem item;

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 卖出成功回调
  final ValueChanged<TinygrailCharacterRewardItem> onSold;

  /// 图片 Hero 标识
  final String heroTag;

  /// 构建刮刮乐获得的单个角色卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TinygrailCharacterRewardCard(
            item: item,
            heroTag: heroTag,
            enableCoverPreview: true,
          ),
          if (item.canSell) ...[
            const SizedBox(height: 8),
            _ResultCardActions(
              item: item,
              characterRepository: characterRepository,
              onSold: onSold,
            ),
          ],
        ],
      ),
    );
  }
}

/// 刮刮乐获得角色卡片的操作按钮组
class _ResultCardActions extends StatefulWidget {
  /// 创建刮刮乐获得角色卡片的操作按钮组
  ///
  /// [item] 角色卡片条目
  /// [characterRepository] 角色详情仓库
  /// [onSold] 卖出成功回调
  const _ResultCardActions({
    required this.item,
    required this.characterRepository,
    required this.onSold,
  });

  /// 角色卡片条目
  final TinygrailCharacterRewardItem item;

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 卖出成功回调
  final ValueChanged<TinygrailCharacterRewardItem> onSold;

  /// 创建刮刮乐获得角色卡片的操作按钮组状态
  @override
  State<_ResultCardActions> createState() => _ResultCardActionsState();
}

/// 刮刮乐获得角色卡片的操作按钮组状态
class _ResultCardActionsState extends State<_ResultCardActions> {
  bool _isSelling = false;

  /// 构建刮刮乐获得角色卡片的操作按钮组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultActionButton(
          label: _isSelling
              ? '出售中'
              : '出售 ${Formatters.tinygrailCurrency(widget.item.sellPrice)}',
          onPressed: _isSelling ? null : _sell,
        ),
      ],
    );
  }

  /// 提交刮刮乐角色卖出请求
  ///
  Future<void> _sell() async {
    final item = widget.item;
    setState(() {
      _isSelling = true;
    });

    try {
      await widget.characterRepository.askCharacter(
        characterId: item.id,
        price: item.sellPrice,
        amount: item.sellAmount,
      );
      if (!mounted) {
        return;
      }

      AppToast.info(
        context,
        text:
            '出售完成：获得资金 ${Formatters.tinygrailCurrency(item.sellPrice * item.sellAmount)}',
      );
      widget.onSold(item);
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(context, text: _messageForError(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSelling = false;
        });
      }
    }
  }

  /// 解析刮刮乐角色卖出失败文案
  ///
  /// [error] 捕获到的异常
  String _messageForError(Object error) {
    return resolveUserErrorMessage(error, fallback: '出售失败');
  }
}

/// 刮刮乐获得角色卡片操作按钮
class _ResultActionButton extends StatelessWidget {
  /// 创建刮刮乐获得角色卡片操作按钮
  ///
  /// [label] 按钮文案
  /// [onPressed] 点击回调
  const _ResultActionButton({
    required this.label,
    required this.onPressed,
  });

  /// 按钮文案
  final String label;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 构建刮刮乐获得角色卡片操作按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null;

    return Material(
      color: isEnabled
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.68),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 34,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isEnabled
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
