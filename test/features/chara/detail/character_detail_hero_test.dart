import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';

/// 验证角色详情头像 Hero 标识支持不同入口作用域
void main() {
  test('默认入口与 ICO 二级列表使用不同 Hero 标识', () {
    final source = Object();
    final defaultTag = createCharacterDetailAvatarHeroTag(
      characterId: 123,
      avatarUrl: 'https://example.com/avatar.png',
      source: source,
    );
    final listTag = createCharacterDetailAvatarHeroTag(
      characterId: 123,
      avatarUrl: 'https://example.com/avatar.png',
      source: source,
      heroTagPrefix: 'ico-list-character-detail-avatar',
    );

    expect(defaultTag, startsWith('character-detail-avatar-123-'));
    expect(listTag, startsWith('ico-list-character-detail-avatar-123-'));
    expect(listTag, isNot(equals(defaultTag)));
  });
}
