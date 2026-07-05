import 'package:flutter/material.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';

/// 每周萌王条目
class TopWeekEntry {
  /// 创建每周萌王条目
  ///
  /// [rank] 排名
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [level] 角色等级
  /// [coverUrl] 封面图片地址
  /// [avatarUrl] 头像图片地址
  /// [surplus] 超出金额
  /// [score] 评分
  /// [bidders] 竞拍人数
  /// [bidAmount] 竞拍股数
  /// [valhallaAmount] 英灵殿股数
  /// [averagePrice] 均价
  /// [basePrice] 拍卖底价
  /// [maxAuctionAmount] 可竞拍数量
  /// [rankColor] 排名颜色
  /// [auction] 当前用户拍卖详情
  const TopWeekEntry({
    required this.rank,
    required this.characterId,
    required this.name,
    required this.level,
    required this.coverUrl,
    required this.avatarUrl,
    required this.surplus,
    required this.score,
    required this.bidders,
    required this.bidAmount,
    required this.valhallaAmount,
    required this.averagePrice,
    required this.basePrice,
    required this.maxAuctionAmount,
    required this.rankColor,
    this.auction,
  });

  /// 排名
  final int rank;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色等级
  final int level;

  /// 圣殿封面图片地址
  final String coverUrl;

  /// 角色头像图片地址
  final String avatarUrl;

  /// 溢出金额展示文案
  final String surplus;

  /// 评分展示文案
  final String score;

  /// 竞拍人数展示文案
  final String bidders;

  /// 竞拍数量展示文案
  final String bidAmount;

  /// 英灵殿数量展示文案
  final String valhallaAmount;

  /// 均价展示文案
  final String averagePrice;

  /// 拍卖底价
  final double basePrice;

  /// 可竞拍数量
  final int maxAuctionAmount;

  /// 排名颜色
  final Color rankColor;

  /// 当前用户拍卖详情
  final AuctionApiItem? auction;

  /// 当前用户是否已有竞拍
  bool get hasUserBid {
    final currentAuction = auction;
    return currentAuction != null &&
        currentAuction.id > 0 &&
        currentAuction.price > 0 &&
        currentAuction.amount > 0;
  }

  /// 复制每周萌王条目并替换拍卖详情
  ///
  /// [auction] 当前用户拍卖详情
  TopWeekEntry copyWithAuction(AuctionApiItem? auction) {
    return TopWeekEntry(
      rank: rank,
      characterId: characterId,
      name: name,
      level: level,
      coverUrl: coverUrl,
      avatarUrl: avatarUrl,
      surplus: surplus,
      score: score,
      bidders: bidders,
      bidAmount: bidAmount,
      valhallaAmount: valhallaAmount,
      averagePrice: averagePrice,
      basePrice: basePrice,
      maxAuctionAmount: maxAuctionAmount,
      rankColor: rankColor,
      auction: auction,
    );
  }
}
