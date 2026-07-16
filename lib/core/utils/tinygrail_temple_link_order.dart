import 'package:magrail_app/core/utils/tinygrail_formatters.dart';

/// Tinygrail 圣殿 LINK 展示顺序
final class TinygrailTempleLinkOrder {
  /// 禁止创建圣殿 LINK 展示顺序工具实例
  const TinygrailTempleLinkOrder._();

  /// 判断第一座圣殿是否保留在左侧
  ///
  /// [firstSacrifices] 第一座圣殿的资产上限
  /// [firstCreate] 第一座圣殿的创建时间
  /// [secondSacrifices] 第二座圣殿的资产上限
  /// [secondCreate] 第二座圣殿的创建时间
  static bool keepsFirstOnLeft({
    required int firstSacrifices,
    required String firstCreate,
    required int secondSacrifices,
    required String secondCreate,
  }) {
    if (firstSacrifices != secondSacrifices) {
      return firstSacrifices > secondSacrifices;
    }

    final firstDate = TinygrailFormatters.parseServerTime(firstCreate);
    final secondDate = TinygrailFormatters.parseServerTime(secondCreate);
    if (firstDate != null && secondDate != null) {
      return !firstDate.isBefore(secondDate);
    }

    return true;
  }
}
