part of 'user_asset_snapshot_database.dart';

/// 生成角色 ID 与名称筛选 SQL
///
/// [searchKeyword] 角色 ID 或名称筛选词
({String clause, List<Object?> arguments}) _characterSearchFilter(
  String searchKeyword,
) {
  return _snapshotIdentitySearchFilter(searchKeyword, alias: 'c');
}

/// 生成圣殿角色 ID 与名称筛选 SQL
///
/// [searchKeyword] 角色 ID 或名称筛选词
({String clause, List<Object?> arguments}) _templeSearchFilter(
  String searchKeyword,
) {
  return _snapshotIdentitySearchFilter(searchKeyword, alias: 't');
}

/// 生成资产快照角色 ID 与名称筛选 SQL
///
/// [searchKeyword] 角色 ID 或名称筛选词
/// [alias] 当前查询的表别名
({String clause, List<Object?> arguments}) _snapshotIdentitySearchFilter(
  String searchKeyword, {
  required String alias,
}) {
  final keyword = searchKeyword.trim();
  if (keyword.isEmpty) {
    return (clause: '', arguments: const <Object?>[]);
  }
  // 角色 ID 常用 #123 形式输入，仅纯数字编号去掉前缀参与模糊匹配
  final normalizedKeyword =
      RegExp(r'^#[0-9]+$').hasMatch(keyword) ? keyword.substring(1) : keyword;
  // LIKE 通配符按字面量搜索，避免扩大筛选范围
  final escapedKeyword = normalizedKeyword
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
  final searchPattern = '%$escapedKeyword%';
  return (
    clause: "AND (CAST($alias.character_id AS TEXT) LIKE ? ESCAPE '\\' "
        "OR $alias.name LIKE ? ESCAPE '\\')",
    arguments: <Object?>[searchPattern, searchPattern],
  );
}

/// 生成当前用户圣殿排序 SQL
///
/// [sort] 排序字段
/// [direction] 排序方向
String _templeOrderBy(
  UserTempleSnapshotSort sort,
  UserTempleSnapshotSortDirection direction,
) {
  final resolvedDirection = _templeSqlDirection(direction);
  return switch (sort) {
    UserTempleSnapshotSort.assets =>
      't.sacrifices $resolvedDirection, t.row_order ASC',
    UserTempleSnapshotSort.characterLevel =>
      't.character_level $resolvedDirection, t.row_order ASC',
    UserTempleSnapshotSort.damaged =>
      't.damaged $resolvedDirection, t.row_order ASC',
    UserTempleSnapshotSort.singleDividend =>
      't.single_dividend $resolvedDirection, t.row_order ASC',
    UserTempleSnapshotSort.totalDividend =>
      't.total_dividend $resolvedDirection, t.row_order ASC',
    UserTempleSnapshotSort.starForces =>
      't.star_forces $resolvedDirection, t.row_order ASC',
    UserTempleSnapshotSort.refine =>
      't.refine $resolvedDirection, t.row_order ASC',
    UserTempleSnapshotSort.create =>
      't.create_value $resolvedDirection, t.row_order ASC',
  };
}

/// 生成受控圣殿排序方向 SQL
///
/// [direction] 排序方向
String _templeSqlDirection(UserTempleSnapshotSortDirection direction) {
  return direction == UserTempleSnapshotSortDirection.ascending
      ? 'ASC'
      : 'DESC';
}
