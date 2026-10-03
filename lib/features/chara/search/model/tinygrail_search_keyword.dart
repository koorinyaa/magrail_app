/// 小圣杯关键词搜索范围
enum TinygrailSearchScope {
  /// 角色、用户与当前用户圣殿
  all,

  /// 角色与当前用户圣殿
  character,

  /// 精确匹配用户
  user,
}

/// 小圣杯搜索关键词及查询范围
class TinygrailSearchKeyword {
  /// 创建搜索关键词
  ///
  /// [keyword] 提取后用于接口查询的关键词
  /// [scope] 查询范围
  const TinygrailSearchKeyword({required this.keyword, required this.scope});

  /// 提取后用于接口查询的关键词
  final String keyword;

  /// 查询范围
  final TinygrailSearchScope scope;

  /// 是否查询角色与当前用户圣殿
  bool get searchCharacters => scope != TinygrailSearchScope.user;

  /// 是否精确查询用户
  bool get searchUsers => scope != TinygrailSearchScope.character;

  /// 解析编号、用户名前缀或地址尾部
  ///
  /// [rawKeyword] 搜索框原始输入，不符合特殊形式时使用普通搜索
  factory TinygrailSearchKeyword.parse(String rawKeyword) {
    final raw = rawKeyword.trim();
    final characterIdPattern = RegExp(r'^[0-9]+$');
    final usernamePattern = RegExp(r'^[A-Za-z0-9_-]+$');
    if (raw.startsWith('#') && characterIdPattern.hasMatch(raw.substring(1))) {
      return TinygrailSearchKeyword(
        keyword: raw.substring(1),
        scope: TinygrailSearchScope.character,
      );
    }

    if (raw.startsWith('@') && usernamePattern.hasMatch(raw.substring(1))) {
      return TinygrailSearchKeyword(
        keyword: raw.substring(1),
        scope: TinygrailSearchScope.user,
      );
    }

    final uri = Uri.tryParse(raw);
    // 仅识别路径结尾，不限制域名，带查询参数、片段或尾斜杠时使用普通搜索
    if (uri != null && !uri.hasQuery && !uri.hasFragment) {
      final List<String> segments;
      try {
        segments = uri.pathSegments;
      } on FormatException {
        // 路径编码无效时保留原输入，避免解析异常中断搜索
        return TinygrailSearchKeyword(
          keyword: raw,
          scope: TinygrailSearchScope.all,
        );
      }
      if (segments.length >= 2) {
        final type = segments[segments.length - 2];
        final identifier = segments.last;
        if (uri.path.endsWith('/$type/$identifier')) {
          if (type == 'character' && characterIdPattern.hasMatch(identifier)) {
            return TinygrailSearchKeyword(
              keyword: identifier,
              scope: TinygrailSearchScope.character,
            );
          }

          if (type == 'user' && usernamePattern.hasMatch(identifier)) {
            return TinygrailSearchKeyword(
              keyword: identifier,
              scope: TinygrailSearchScope.user,
            );
          }
        }
      }
    }

    return TinygrailSearchKeyword(
      keyword: raw,
      scope: TinygrailSearchScope.all,
    );
  }
}
