import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';
import 'package:magrail_app/features/user/widgets/user_profile_card_components.dart';

/// 用户资料卡片
class UserProfileCard extends StatefulWidget {
  /// 创建用户资料卡片
  ///
  /// [key] Flutter 组件标识
  /// [profile] 用户详情页资料
  /// [onRecordPressed] 红包记录按钮点击回调
  /// [onSendPressed] 发送红包按钮点击回调
  /// [onCopyPressed] 复制 ID 按钮点击回调
  /// [isCurrentUser] 是否为当前登录用户
  /// [hideBalanceAndAssets] 是否隐藏余额和资产
  const UserProfileCard({
    super.key,
    required this.profile,
    required this.onRecordPressed,
    required this.onSendPressed,
    required this.onCopyPressed,
    required this.isCurrentUser,
    required this.hideBalanceAndAssets,
  });

  /// 用户详情页资料
  final UserDetailProfile profile;

  /// 红包记录按钮点击回调
  final VoidCallback onRecordPressed;

  /// 发送红包按钮点击回调
  final VoidCallback onSendPressed;

  /// 复制 ID 按钮点击回调
  final VoidCallback onCopyPressed;

  /// 是否为当前登录用户
  final bool isCurrentUser;

  /// 是否隐藏余额和资产
  final bool hideBalanceAndAssets;

  /// 创建用户资料卡片状态
  @override
  State<UserProfileCard> createState() => _UserProfileCardState();
}

/// 用户资料卡片状态
class _UserProfileCardState extends State<UserProfileCard> {
  bool _showFullBalanceAndAssets = false;

  /// 处理用户资料变化
  ///
  /// [oldWidget] 更新前的用户资料卡片
  @override
  void didUpdateWidget(covariant UserProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.userId != widget.profile.userId) {
      _showFullBalanceAndAssets = false;
    }
  }

  /// 构建用户资料卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardColor =
        isDark ? colorScheme.surfaceContainerLow : colorScheme.surface;
    final nickname = widget.profile.nickname.trim();
    final displayName = nickname.isEmpty ? widget.profile.name : nickname;
    final balanceText = widget.hideBalanceAndAssets
        ? '******'
        : _formatBalanceAndAssets(widget.profile.balance);
    final assetsText = widget.hideBalanceAndAssets
        ? '******'
        : _formatBalanceAndAssets(widget.profile.assets);
    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 186),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.025),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: UserProfileCardActions(
                          isCurrentUser: widget.isCurrentUser,
                          onRecordPressed: widget.onRecordPressed,
                          onSendPressed: widget.onSendPressed,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: widget.profile.isBanned
                                          ? const Color(0xFFEF4444)
                                          : colorScheme.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                if (widget.profile.rank > 0) ...[
                                  const SizedBox(width: 9),
                                  UserProfileRankBadge(
                                    rank: widget.profile.rank,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      UserProfileIdRow(
                        userId: widget.profile.userId,
                        onCopyPressed: widget.onCopyPressed,
                      ),
                      if (widget.profile.isBanned) ...[
                        const SizedBox(height: 5),
                        const UserBannedLabel(),
                      ],
                      SizedBox(height: widget.profile.isBanned ? 14 : 20),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: isDark ? 0.34 : 0.55,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _toggleBalanceAndAssetsDisplayMode,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: UserProfileMetric(
                                  value: balanceText,
                                  label: '余额',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: UserProfileMetric(
                                  value: assetsText,
                                  label: '资产',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 18,
          top: -20,
          child: UserAvatar(
            imageUrl: widget.profile.avatar,
            isBanned: widget.profile.isBanned,
          ),
        ),
      ],
    );

    return content;
  }

  /// 切换余额和资产显示模式
  void _toggleBalanceAndAssetsDisplayMode() {
    setState(() {
      _showFullBalanceAndAssets = !_showFullBalanceAndAssets;
    });
  }

  /// 格式化余额和资产文本
  ///
  /// [value] 余额或资产数值
  String _formatBalanceAndAssets(num value) {
    if (_showFullBalanceAndAssets) {
      return Formatters.tinygrailCurrency(value);
    }

    return Formatters.tinygrailCompactValue(value, prefix: '₵');
  }
}
