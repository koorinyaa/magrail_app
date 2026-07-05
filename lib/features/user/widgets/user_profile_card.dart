import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';
import 'package:magrail_app/features/user/widgets/user_profile_card_components.dart';

/// 用户资料卡片
class UserProfileCard extends StatelessWidget {
  /// 创建用户资料卡片
  ///
  /// [key] Flutter 组件标识
  /// [profile] 用户详情页资料
  /// [onRecordPressed] 红包记录按钮点击回调
  /// [onSendPressed] 发送红包按钮点击回调
  /// [onCopyPressed] 复制 ID 按钮点击回调
  /// [onProfilePressed] 资料卡片点击回调
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
    this.onProfilePressed,
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

  /// 资料卡片点击回调
  final VoidCallback? onProfilePressed;

  /// 构建用户资料卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardColor =
        isDark ? colorScheme.surfaceContainerLow : colorScheme.surface;
    final nickname = profile.nickname.trim();
    final displayName = nickname.isEmpty ? profile.name : nickname;
    final balanceText = hideBalanceAndAssets
        ? '******'
        : Formatters.tinygrailCurrency(profile.balance);
    final assetsText = hideBalanceAndAssets
        ? '******'
        : Formatters.tinygrailCurrency(profile.assets);
    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 186),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: UserProfileCardActions(
                  isCurrentUser: isCurrentUser,
                  onRecordPressed: onRecordPressed,
                  onSendPressed: onSendPressed,
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
                              color: profile.isBanned
                                  ? const Color(0xFFEF4444)
                                  : colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        if (profile.rank > 0) ...[
                          const SizedBox(width: 9),
                          UserProfileRankBadge(rank: profile.rank),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              UserProfileIdRow(
                userId: profile.userId,
                onCopyPressed: onCopyPressed,
              ),
              if (profile.isBanned) ...[
                const SizedBox(height: 5),
                const UserBannedLabel(),
              ],
              SizedBox(height: profile.isBanned ? 14 : 20),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.34 : 0.55,
                ),
              ),
              const SizedBox(height: 12),
              Row(
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
            ],
          ),
        ),
        Positioned(
          left: 18,
          top: -20,
          child: UserAvatar(
            imageUrl: profile.avatar,
            isBanned: profile.isBanned,
          ),
        ),
      ],
    );

    if (onProfilePressed == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onProfilePressed,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}
