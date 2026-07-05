import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_kill_vote.dart';

/// 角色详情已上市头部资料
class CharacterDetailTradeHeader {
  // 通天塔 500 名外每点星级固定折算为 ₵2
  static const double _outsideTowerDividendPerStar = 2.0;

  /// 创建角色详情已上市头部资料
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [current] 当前价
  /// [total] 流通股份
  /// [rate] 基础股息
  /// [rank] 通天塔排名
  /// [stars] 星级
  /// [fluctuation] 当前价涨跌幅
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [crown] 萌王次数
  /// [bonus] 新番加成剩余期数
  /// [starForces] 星之力
  /// [listedDate] 上市时间原始文本
  /// [valhallaAmount] 英灵殿持股数量
  /// [gensokyoAmount] 幻想乡持股数量
  /// [poolAmount] 奖池数量
  /// [auctionBasePrice] 拍卖底价
  /// [auctionMaxAmount] 可竞拍数量
  /// [canChangeAvatar] 当前用户是否可更换头像
  /// [killVotes] 删除投票记录
  /// [currentUserId] 当前登录用户 ID
  /// [hasCurrentUserKillVote] 当前用户是否已投票删除
  const CharacterDetailTradeHeader({
    required this.characterId,
    required this.name,
    required this.icon,
    required this.current,
    required this.total,
    required this.rate,
    required this.rank,
    required this.stars,
    required this.fluctuation,
    required this.level,
    required this.zeroCount,
    required this.crown,
    required this.bonus,
    required this.starForces,
    required this.listedDate,
    this.valhallaAmount,
    this.gensokyoAmount,
    this.poolAmount,
    this.auctionBasePrice = 0,
    this.auctionMaxAmount = 0,
    this.canChangeAvatar = false,
    this.killVotes = const <CharacterDetailKillVote>[],
    this.currentUserId,
    this.hasCurrentUserKillVote = false,
  });

  /// Tinygrail 删除投票达到 3 票时进入删除流程
  static const int requiredKillVoteCount = 3;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String icon;

  /// 当前价
  final double current;

  /// 流通股份
  final int total;

  /// 基础股息
  final double rate;

  /// 通天塔排名
  final int rank;

  /// 星级
  final int stars;

  /// 当前价涨跌幅
  final double fluctuation;

  /// 角色等级
  final int level;

  /// ST 等级
  final int zeroCount;

  /// 萌王次数
  final int crown;

  /// 新番加成剩余期数
  final int bonus;

  /// 星之力
  final int starForces;

  /// 上市时间原始文本
  final String listedDate;

  /// 英灵殿持股数量
  final int? valhallaAmount;

  /// 幻想乡持股数量
  final int? gensokyoAmount;

  /// 奖池数量
  final int? poolAmount;

  /// 拍卖底价
  final double auctionBasePrice;

  /// 可竞拍数量
  final int auctionMaxAmount;

  /// 当前用户是否可更换头像
  final bool canChangeAvatar;

  /// 删除投票记录
  final List<CharacterDetailKillVote> killVotes;

  /// 当前登录用户 ID
  final int? currentUserId;

  /// 当前用户是否已投票删除
  final bool hasCurrentUserKillVote;

  /// 预估股息
  double get dividend {
    if (rank <= 500) {
      return rate * 0.005 * (601 - rank);
    }

    return stars * _outsideTowerDividendPerStar;
  }

  /// 删除投票数量
  int get killVoteCount => killVotes.length;

  /// 是否存在删除投票
  bool get hasKillVotes => killVotes.isNotEmpty;

  /// 合并已上市头部补充数据
  ///
  /// [valhallaAmount] 英灵殿持股数量
  /// [gensokyoAmount] 幻想乡持股数量
  /// [poolAmount] 奖池数量
  /// [auctionBasePrice] 拍卖底价
  /// [auctionMaxAmount] 可竞拍数量
  /// [canChangeAvatar] 当前用户是否可更换头像
  /// [killVotes] 删除投票记录
  /// [currentUserId] 当前登录用户 ID
  /// [hasCurrentUserKillVote] 当前用户是否已投票删除
  CharacterDetailTradeHeader withSupplementalStats({
    required int? valhallaAmount,
    required int? gensokyoAmount,
    required int? poolAmount,
    required double auctionBasePrice,
    required int auctionMaxAmount,
    required bool canChangeAvatar,
    required List<CharacterDetailKillVote> killVotes,
    required int? currentUserId,
    required bool hasCurrentUserKillVote,
  }) {
    return CharacterDetailTradeHeader(
      characterId: characterId,
      name: name,
      icon: icon,
      current: current,
      total: total,
      rate: rate,
      rank: rank,
      stars: stars,
      fluctuation: fluctuation,
      level: level,
      zeroCount: zeroCount,
      crown: crown,
      bonus: bonus,
      starForces: starForces,
      listedDate: listedDate,
      valhallaAmount: valhallaAmount,
      gensokyoAmount: gensokyoAmount,
      poolAmount: poolAmount,
      auctionBasePrice: auctionBasePrice,
      auctionMaxAmount: auctionMaxAmount,
      canChangeAvatar: canChangeAvatar,
      killVotes: List<CharacterDetailKillVote>.unmodifiable(killVotes),
      currentUserId: currentUserId,
      hasCurrentUserKillVote: hasCurrentUserKillVote,
    );
  }

  /// 从 JSON 创建角色详情已上市头部资料
  ///
  /// [json] 原始角色详情 JSON
  factory CharacterDetailTradeHeader.fromJson(Map<String, Object?> json) {
    final characterId = TinygrailResponseParser.asInt(json['CharacterId']);

    return CharacterDetailTradeHeader(
      characterId: characterId > 0
          ? characterId
          : TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      current: TinygrailResponseParser.asDouble(json['Current']),
      total: TinygrailResponseParser.asInt(json['Total']),
      rate: TinygrailResponseParser.asDouble(json['Rate']),
      rank: TinygrailResponseParser.asInt(json['Rank']),
      stars: TinygrailResponseParser.asInt(json['Stars']),
      fluctuation: TinygrailResponseParser.asDouble(json['Fluctuation']),
      level: TinygrailResponseParser.asInt(json['Level']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      crown: TinygrailResponseParser.asInt(json['Crown']),
      bonus: TinygrailResponseParser.asInt(json['Bonus']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      listedDate: TinygrailResponseParser.asString(json['ListedDate']),
    );
  }
}
