import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';

/// 剪切板精确匹配的详情目标
sealed class ClipboardDetailTarget {
  /// 创建剪切板详情目标
  const ClipboardDetailTarget();

  /// 查看详情的按钮文案
  String get confirmText;
}

/// 剪切板匹配的已上市或 ICO 角色
class ClipboardCharacterTarget extends ClipboardDetailTarget {
  /// 创建角色详情目标
  ///
  /// [character] 已精确匹配的角色资料
  const ClipboardCharacterTarget({required this.character});

  /// 已精确匹配的角色资料
  final CharacterDetailBasicInfo character;

  /// 查看角色或 ICO 详情的按钮文案
  @override
  String get confirmText =>
      character.pageType == CharacterDetailPageType.ico ? '查看ICO详情' : '查看角色详情';
}

/// 剪切板匹配的用户
class ClipboardUserTarget extends ClipboardDetailTarget {
  /// 创建用户详情目标
  ///
  /// [user] 已精确匹配的用户资料
  const ClipboardUserTarget({required this.user});

  /// 已精确匹配的用户资料
  final UserDetailProfile user;

  /// 查看用户详情的按钮文案
  @override
  String get confirmText => '查看用户详情';
}
