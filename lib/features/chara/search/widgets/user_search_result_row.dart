import 'package:flutter/material.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';
import 'package:magrail_app/features/user/widgets/user_profile_card_components.dart';

/// 小圣杯搜索中的用户结果行
class UserSearchResultRow extends StatelessWidget {
  /// 创建用户搜索结果行
  ///
  /// [key] Flutter 组件标识
  /// [profile] 精确匹配的用户资料
  /// [onTap] 打开用户详情的回调
  const UserSearchResultRow({
    super.key,
    required this.profile,
    required this.onTap,
  });

  /// 精确匹配的用户资料
  final UserDetailProfile profile;

  /// 打开用户详情的回调
  final VoidCallback onTap;

  /// 构建头像、昵称、排名与 BGM ID
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nickname = profile.nickname.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              const SizedBox(width: 4),
              UserAvatar(
                imageUrl: profile.avatar,
                isBanned: profile.isBanned,
                size: 38,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nickname.isEmpty ? profile.name : nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: profile.isBanned
                                  ? colorScheme.error
                                  : colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (profile.rank > 0) ...[
                          const SizedBox(width: 6),
                          Text.rich(
                            TextSpan(
                              children: [
                                // 徽标整体随字号缩放，内部文字使用原始尺寸
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: MediaQuery.withNoTextScaling(
                                    child: UserProfileRankBadge(
                                      rank: profile.rank,
                                      isCompact: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(fontSize: 9),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '@${profile.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
