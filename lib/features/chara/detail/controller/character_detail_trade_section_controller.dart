import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_data.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';

/// 角色详情交易区控制器
class CharacterDetailTradeSectionController extends ChangeNotifier {
  /// 创建角色详情交易区控制器
  ///
  /// [repository] 角色详情仓库
  /// [characterId] 角色 ID
  /// [currentPrice] 当前价
  CharacterDetailTradeSectionController({
    required CharacterDetailRepository repository,
    required int characterId,
    required double currentPrice,
  })  : _repository = repository,
        _characterId = characterId {
    priceController = TextEditingController(
      text: _formatInputPrice(currentPrice),
    );
    amountController = TextEditingController(text: '0');
    priceController.addListener(_handleInputChanged);
    amountController.addListener(_handleInputChanged);
  }

  final CharacterDetailRepository _repository;
  final int _characterId;
  CharacterDetailTradeDepth _depth = const CharacterDetailTradeDepth.empty();
  CharacterDetailUserTrading _trading =
      const CharacterDetailUserTrading.empty();
  CharacterDetailTradeSide _side = CharacterDetailTradeSide.sell;
  CharacterDetailTradeOrderType _orderType =
      CharacterDetailTradeOrderType.regular;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isDisposed = false;
  int _loadSerial = 0;
  int? _cancellingOrderId;
  String? _loadError;

  /// 价格输入控制器
  late final TextEditingController priceController;

  /// 数量输入控制器
  late final TextEditingController amountController;

  /// 深度信息
  CharacterDetailTradeDepth get depth => _depth;

  /// 当前用户角色交易资料
  CharacterDetailUserTrading get trading => _trading;

  /// 当前交易方向
  CharacterDetailTradeSide get side => _side;

  /// 当前委托类型
  CharacterDetailTradeOrderType get orderType => _orderType;

  /// 是否加载交易资料中
  bool get isLoading => _isLoading;

  /// 是否提交委托中
  bool get isSubmitting => _isSubmitting;

  /// 交易资料加载失败文案
  String? get loadError => _loadError;

  /// 当前用户余额
  double get balance => _trading.balance;

  /// 当前角色可用活股
  int get availableAmount => _trading.amount;

  /// 当前用户有效买入委托
  Iterable<CharacterDetailTradeOrder> get activeBidOrders {
    return _trading.activeBids;
  }

  /// 当前用户有效卖出委托
  Iterable<CharacterDetailTradeOrder> get activeAskOrders {
    return _trading.activeAsks;
  }

  /// 是否存在当前用户委托
  bool get hasActiveOrders => _trading.hasActiveOrders;

  /// 当前用户买入成交记录
  List<CharacterDetailTradeHistoryOrder> get bidTradeRecords {
    return _trading.bidHistory;
  }

  /// 当前用户卖出成交记录
  List<CharacterDetailTradeHistoryOrder> get askTradeRecords {
    return _trading.askHistory;
  }

  /// 判断委托是否正在取消
  ///
  /// [order] 当前委托
  bool isCancellingOrder(CharacterDetailTradeOrder order) {
    return _cancellingOrderId == order.id;
  }

  /// 当前表单合计金额
  double get currentTotal {
    final price = _parsePrice() ?? 0;
    final amount = _parseAmount() ?? 0;
    return price * amount;
  }

  /// 当前买入金额是否超过余额
  bool get isBuyTotalOverBalance {
    return _side == CharacterDetailTradeSide.buy &&
        currentTotal > balance &&
        currentTotal > 0;
  }

  /// 当前卖出数量是否超过可用活股
  bool get isSellAmountOverAvailable {
    final amount = _parseAmount() ?? 0;
    return _side == CharacterDetailTradeSide.sell &&
        amount > availableAmount &&
        amount > 0;
  }

  /// 当前表单是否可以提交
  bool get canSubmit {
    if (_isLoading || _isSubmitting || _loadError != null) {
      return false;
    }

    final price = _parsePrice();
    final amount = _parseAmount();
    if (price == null || price <= 0 || amount == null || amount <= 0) {
      return false;
    }

    return !isBuyTotalOverBalance && !isSellAmountOverAvailable;
  }

  /// 初始化交易区数据
  Future<void> initialize() {
    return reload(showLoading: true);
  }

  /// 重新加载交易区数据
  ///
  /// [showLoading] 是否显示加载骨架
  Future<void> reload({bool showLoading = true}) async {
    final loadSerial = ++_loadSerial;
    if (showLoading) {
      _isLoading = true;
      _loadError = null;
      _notifyListeners();
    }

    try {
      final results = await Future.wait<Object>([
        _repository.fetchCharacterTradeDepth(_characterId),
        _repository.fetchCurrentUserTrading(_characterId),
      ]);
      if (!_isCurrentLoad(loadSerial)) {
        return;
      }

      _depth = results[0] as CharacterDetailTradeDepth;
      _trading = results[1] as CharacterDetailUserTrading;
      _loadError = null;
    } catch (error) {
      if (!_isCurrentLoad(loadSerial)) {
        return;
      }

      _loadError = resolveErrorMessage(
        error,
        fallback: '获取交易资料失败',
      );
    } finally {
      if (_isCurrentLoad(loadSerial)) {
        _isLoading = false;
        _notifyListeners();
      }
    }
  }

  /// 选择交易方向
  ///
  /// [side] 交易方向
  void selectSide(CharacterDetailTradeSide side) {
    if (_side == side) {
      return;
    }

    _side = side;
    _notifyListeners();
  }

  /// 选择委托类型
  ///
  /// [orderType] 委托类型
  void selectOrderType(CharacterDetailTradeOrderType orderType) {
    if (_orderType == orderType) {
      return;
    }

    _orderType = orderType;
    _notifyListeners();
  }

  /// 使用当前买卖单条目填充表单
  ///
  /// [side] 目标交易方向
  /// [item] 当前买卖单条目
  void fillFromDepth(
    CharacterDetailTradeSide side,
    CharacterDetailTradeDepthItem item,
  ) {
    _side = side;
    if (!item.isIceberg) {
      priceController.text = _formatInputPrice(item.price);
      amountController.text = item.amount.toString();
      _orderType = CharacterDetailTradeOrderType.regular;
    }
    _notifyListeners();
  }

  /// 提交当前交易委托
  Future<String?> submit() async {
    if (_isSubmitting) {
      return null;
    }

    final price = _parsePrice();
    if (price == null || price <= 0) {
      throw StateError('请输入有效的价格');
    }

    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      throw StateError('请输入有效的数量');
    }

    if (_side == CharacterDetailTradeSide.buy && price * amount > balance) {
      throw StateError('余额不足');
    }

    if (_side == CharacterDetailTradeSide.sell && amount > availableAmount) {
      throw StateError('可用活股不足');
    }

    _isSubmitting = true;
    _notifyListeners();

    try {
      final isIceberg = _orderType == CharacterDetailTradeOrderType.iceberg;
      final message = switch (_side) {
        CharacterDetailTradeSide.buy => await _repository.bidCharacter(
            characterId: _characterId,
            price: price,
            amount: amount,
            isIceberg: isIceberg,
          ),
        CharacterDetailTradeSide.sell => await _repository.askCharacter(
            characterId: _characterId,
            price: price,
            amount: amount,
            isIceberg: isIceberg,
          ),
      };
      await reload(showLoading: false);
      return message;
    } finally {
      _isSubmitting = false;
      _notifyListeners();
    }
  }

  /// 取消当前交易委托
  ///
  /// [order] 当前委托
  /// [isBid] 是否为买入委托
  Future<String?> cancelOrder({
    required CharacterDetailTradeOrder order,
    required bool isBid,
  }) async {
    if (_cancellingOrderId != null) {
      return null;
    }

    _cancellingOrderId = order.id;
    _notifyListeners();

    try {
      final message = isBid
          ? await _repository.cancelBidOrder(order.id)
          : await _repository.cancelAskOrder(order.id);
      await reload(showLoading: false);
      return message;
    } finally {
      _cancellingOrderId = null;
      _notifyListeners();
    }
  }

  /// 解析错误提示文案
  ///
  /// [error] 原始错误
  /// [fallback] 兜底文案
  static String resolveErrorMessage(
    Object error, {
    required String fallback,
  }) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }

  /// 释放角色详情交易区控制器
  @override
  void dispose() {
    _isDisposed = true;
    _loadSerial += 1;
    priceController
      ..removeListener(_handleInputChanged)
      ..dispose();
    amountController
      ..removeListener(_handleInputChanged)
      ..dispose();
    super.dispose();
  }

  /// 处理输入变化
  void _handleInputChanged() {
    _notifyListeners();
  }

  /// 判断是否为当前加载请求
  ///
  /// [loadSerial] 加载请求序号
  bool _isCurrentLoad(int loadSerial) {
    return !_isDisposed && _loadSerial == loadSerial;
  }

  /// 通知交易区刷新
  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// 解析价格输入
  double? _parsePrice() {
    final text = priceController.text.replaceAll(',', '').trim();
    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text);
  }

  /// 解析数量输入
  int? _parseAmount() {
    final text = amountController.text.replaceAll(',', '').trim();
    if (text.isEmpty) {
      return null;
    }

    return int.tryParse(text);
  }

  /// 格式化输入框价格
  ///
  /// [price] 原始价格
  String _formatInputPrice(double price) {
    if (price <= 0) {
      return '0';
    }

    return Formatters.groupedNumber(price).replaceAll(',', '');
  }
}
