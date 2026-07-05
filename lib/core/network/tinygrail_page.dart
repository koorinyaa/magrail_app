import 'package:magrail_app/core/network/tinygrail_response.dart';

/// Tinygrail 通用分页数据
class TinygrailPage<T> {
  /// 创建 Tinygrail 通用分页数据
  ///
  /// [items] 当前页条目
  /// [currentPage] 当前页码
  /// [totalPages] 总页数
  /// [totalItems] 总条目数
  /// [itemsPerPage] 每页条目数量
  const TinygrailPage({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  /// 从 JSON 创建 Tinygrail 通用分页数据
  ///
  /// [json] 原始分页 JSON
  /// [itemFromJson] 分页条目转换函数
  factory TinygrailPage.fromJson(
    Map<String, Object?> json,
    T Function(Map<String, Object?> json) itemFromJson,
  ) {
    return TinygrailPage(
      items: TinygrailResponseParser.asObjectList(
            json['Items'],
            itemFromJson,
          ) ??
          <T>[],
      currentPage: TinygrailResponseParser.asInt(json['CurrentPage']),
      totalPages: TinygrailResponseParser.asInt(json['TotalPages']),
      totalItems: TinygrailResponseParser.asInt(json['TotalItems']),
      itemsPerPage: TinygrailResponseParser.asInt(json['ItemsPerPage']),
    );
  }
}
