import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/temple_link_dialog.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_link_card.dart';

/// 显示用户圣殿 LINK 弹窗
///
/// [context] 当前组件树上下文
/// [item] 用户连接接口条目
/// [heroTagPrefix] 封面 Hero 标识前缀
/// [onCharacterTap] 角色名称点击回调
/// [onAssetTap] 圣殿资产入口点击回调
Future<void> showUserTempleLinkDialog(
  BuildContext context, {
  required UserLinkApiItem item,
  required String heroTagPrefix,
  ValueChanged<UserTempleApiItem>? onCharacterTap,
  ValueChanged<UserTempleApiItem>? onAssetTap,
}) {
  return showTempleLinkDialog(
    context,
    maxWidth: UserLinkCard.defaultWidth,
    cardBuilder: (cardWidth) {
      return UserLinkCard(
        item: item,
        width: cardWidth,
        heroTagPrefix: heroTagPrefix,
        showConnectionValue: false,
        onCharacterTap: onCharacterTap,
        onAssetTap: onAssetTap,
      );
    },
  );
}
