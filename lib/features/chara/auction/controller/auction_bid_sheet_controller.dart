import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';

/// 拍卖底部抽屉控制器
class AuctionBidSheetController extends ChangeNotifier {
  /// 创建拍卖底部抽屉控制器
  ///
  /// [repository] 拍卖仓库
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [basePrice] 拍卖底价
  /// [maxAmount] 英灵殿数量
  /// [initialAuction] 初始拍卖详情
  AuctionBidSheetController({
    required AuctionRepository repository,
    required int characterId,
    required String characterName,
    required double basePrice,
    required int maxAmount,
    AuctionApiItem? initialAuction,
  })  : _repository = repository,
        _characterId = characterId,
        _characterName = characterName,
        _basePrice = basePrice,
        _maxAmount = maxAmount,
        _auction = initialAuction {
    _hasUserBid = _hasAuctionBidInfo(initialAuction);
    priceController = TextEditingController(
      text: _formatInputPrice(_resolveInitialPrice()),
    );
    amountController = TextEditingController(
      text: _formatInputAmount(_resolveInitialAmount()),
    );
    priceController.addListener(_handlePriceChanged);
    amountController.addListener(_handleAmountChanged);
    _resetLockedTotal();
  }

  final AuctionRepository _repository;
  final int _characterId;
  final String _characterName;
  final double _basePrice;
  final int _maxAmount;
  AuctionApiItem? _auction;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isCancelling = false;
  bool _lockTotal = false;
  bool _hasUserBid = false;
  bool _isSyncingInput = false;
  bool _isDisposed = false;
  double _lockedTotal = 0;
  String? _loadError;

  /// 价格输入控制器
  late final TextEditingController priceController;

  /// 数量输入控制器
  late final TextEditingController amountController;

  /// 当前拍卖详情
  AuctionApiItem? get auction => _auction;

  /// 英灵殿数量
  int get maxAmount => _maxAmount;

  /// 是否加载拍卖详情中
  bool get isLoading => _isLoading;

  /// 是否提交竞拍中
  bool get isSubmitting => _isSubmitting;

  /// 是否取消竞拍中
  bool get isCancelling => _isCancelling;

  /// 是否锁定总额
  bool get lockTotal => _lockTotal;

  /// 拍卖详情加载失败文案
  String? get loadError => _loadError;

  /// 是否存在可取消的当前竞拍
  bool get canCancelAuction => hasCurrentBid && _cancelAuctionId != null;

  /// 当前合计金额
  double get currentTotal {
    final price = _parsePrice() ?? 0;
    final amount = _parseAmount() ?? 0;
    return price * amount;
  }

  /// 是否已有当前出价
  bool get hasCurrentBid {
    return _hasUserBid && _hasAuctionBidInfo(_auction);
  }

  /// 角色展示名称
  String get displayName {
    final name = TinygrailFormatters.decodeHtmlEntities(
      _characterName,
    ).trim();
    return name.isEmpty ? '#$_characterId' : name;
  }

  double get _minPrice => _basePrice.ceilToDouble();

  int? get _cancelAuctionId => _auction?.id;

  /// 初始化拍卖详情
  Future<void> initialize() {
    return _loadAuctionDetail(showLoading: true, syncInput: true);
  }

  /// 释放拍卖底部抽屉控制器
  @override
  void dispose() {
    _isDisposed = true;
    priceController
      ..removeListener(_handlePriceChanged)
      ..dispose();
    amountController
      ..removeListener(_handleAmountChanged)
      ..dispose();
    super.dispose();
  }

  /// 通知拍卖底部抽屉刷新
  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// 处理锁定总额开关变化
  ///
  /// [value] 是否锁定总额
  void updateLockTotal(bool value) {
    _lockTotal = value;
    if (value) {
      _resetLockedTotal();
    }
    _notifyListeners();
  }

  /// 设置拍满数量
  void fillRemainingAmount() {
    final auctionedAmount = _auction?.type ?? 0;
    final myAmount = hasCurrentBid ? _auction?.amount ?? 0 : 0;
    final remaining = myAmount > 0
        ? _maxAmount - (auctionedAmount - myAmount)
        : _maxAmount - auctionedAmount;
    _setQuickAmount(remaining.clamp(0, _maxAmount).toInt());
  }

  /// 设置英灵殿数量
  void fillMaxAmount() {
    _setQuickAmount(_maxAmount);
  }

  /// 提交竞拍
  Future<String?> submit() async {
    if (_isSubmitting || _isCancelling) {
      return null;
    }

    final price = _parsePrice();
    if (price == null || price <= 0) {
      throw StateError('请输入有效的价格');
    }

    if (price < _minPrice) {
      throw StateError('出价不能低于底价');
    }

    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      throw StateError('请输入有效的数量');
    }

    _isSubmitting = true;
    _notifyListeners();

    try {
      final message = await _repository.bidAuction(
        characterId: _characterId,
        price: price,
        amount: amount,
      );
      await _loadAuctionDetail(showLoading: false);
      return message;
    } finally {
      _isSubmitting = false;
      _notifyListeners();
    }
  }

  /// 取消竞拍
  Future<String?> cancelAuction() async {
    if (_isSubmitting || _isCancelling) {
      return null;
    }

    final auctionId = canCancelAuction ? _cancelAuctionId : null;
    if (auctionId == null) {
      throw StateError('没有可取消的竞拍');
    }

    _isCancelling = true;
    _notifyListeners();

    try {
      final message = await _repository.cancelAuction(auctionId);
      _hasUserBid = false;
      await _loadAuctionDetail(showLoading: false);
      return message;
    } finally {
      _isCancelling = false;
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

  /// 解析初始价格
  double _resolveInitialPrice() {
    if (!_hasUserBid) {
      return _minPrice;
    }

    final auctionPrice = _auction?.price ?? 0;
    if (auctionPrice > 0) {
      return auctionPrice;
    }

    return _minPrice;
  }

  /// 解析初始数量，未出价时默认 0
  int _resolveInitialAmount() {
    if (!_hasUserBid) {
      return 0;
    }

    final auctionAmount = _auction?.amount ?? 0;
    final auctionPrice = _auction?.price ?? 0;
    if (auctionPrice > 0 && auctionAmount > 0) {
      return auctionAmount;
    }

    return 0;
  }

  /// 加载当前拍卖详情
  ///
  /// [showLoading] 是否显示加载状态
  /// [syncInput] 是否按拍卖详情同步输入框
  Future<void> _loadAuctionDetail({
    required bool showLoading,
    bool syncInput = false,
  }) async {
    if (showLoading) {
      _isLoading = true;
      _loadError = null;
      _notifyListeners();
    }

    try {
      final auction = await _repository.fetchAuctionDetail(_characterId);
      if (_isDisposed) {
        return;
      }

      final hasUserBid = _hasAuctionBidInfo(auction);
      final shouldResetInput = _hasUserBid && !hasUserBid;
      _auction = auction;
      _hasUserBid = hasUserBid;
      if (!hasUserBid) {
        _lockTotal = false;
        _lockedTotal = 0;
      }
      _loadError = null;
      _isLoading = false;
      if (syncInput && hasUserBid) {
        _syncInputsFromAuction(auction, notify: false);
      } else if (syncInput && shouldResetInput) {
        _resetInputsForEmptyBid(notify: false);
      }
      _notifyListeners();
    } catch (error) {
      if (_isDisposed) {
        return;
      }

      _loadError = resolveErrorMessage(error, fallback: '拍卖详情加载失败');
      _isLoading = false;
      _notifyListeners();
    }
  }

  /// 按拍卖详情同步输入框
  ///
  /// [auction] 当前拍卖详情
  /// [notify] 是否通知界面刷新
  void _syncInputsFromAuction(
    AuctionApiItem? auction, {
    bool notify = true,
  }) {
    final bid = auction;
    if (bid == null || bid.price <= 0 || bid.amount <= 0) {
      return;
    }

    _setPriceText(_formatInputPrice(bid.price));
    _setAmountText(bid.amount.toString());
    _resetLockedTotal();
    if (notify) {
      _notifyListeners();
    }
  }

  /// 重置未出价时的输入框
  ///
  /// [notify] 是否通知界面刷新
  void _resetInputsForEmptyBid({bool notify = true}) {
    _setPriceText(_formatInputPrice(_minPrice));
    _setAmountText('');
    _lockedTotal = 0;
    if (notify) {
      _notifyListeners();
    }
  }

  /// 处理价格输入变化
  void _handlePriceChanged() {
    if (_isSyncingInput) {
      return;
    }

    if (!_lockTotal || _lockedTotal <= 0) {
      _notifyListeners();
      return;
    }

    final price = _parsePrice();
    if (price == null || price <= 0) {
      _notifyListeners();
      return;
    }

    final nextAmount = (_lockedTotal / price).ceil();
    _setAmountText(nextAmount.toString());
    _notifyListeners();
  }

  /// 处理数量输入变化
  void _handleAmountChanged() {
    if (_isSyncingInput) {
      return;
    }

    if (!_lockTotal || _lockedTotal <= 0) {
      _notifyListeners();
      return;
    }

    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      _notifyListeners();
      return;
    }

    final nextPrice = (_lockedTotal / amount * 100).ceil() / 100;
    _setPriceText(_formatInputPrice(nextPrice));
    _notifyListeners();
  }

  /// 设置快捷数量
  ///
  /// [amount] 快捷数量
  void _setQuickAmount(int amount) {
    _setAmountText(amount.toString());
    if (_lockTotal && _lockedTotal > 0 && amount > 0) {
      final nextPrice = (_lockedTotal / amount * 100).ceil() / 100;
      _setPriceText(_formatInputPrice(nextPrice));
    }

    _notifyListeners();
  }

  /// 重置锁定总额
  void _resetLockedTotal() {
    _lockedTotal = currentTotal;
  }

  /// 设置价格输入文本
  ///
  /// [value] 价格文本
  void _setPriceText(String value) {
    _setControllerText(priceController, value);
  }

  /// 设置数量输入文本
  ///
  /// [value] 数量文本
  void _setAmountText(String value) {
    _setControllerText(amountController, value);
  }

  /// 格式化数量输入文本
  ///
  /// [value] 数量数值
  String _formatInputAmount(int value) {
    if (value <= 0) {
      return '';
    }

    return value.toString();
  }

  /// 设置输入框文本并保持光标在末尾
  ///
  /// [controller] 输入控制器
  /// [value] 输入文本
  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }

    _isSyncingInput = true;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _isSyncingInput = false;
  }

  /// 解析价格输入
  double? _parsePrice() {
    return double.tryParse(priceController.text.trim());
  }

  /// 解析数量输入
  int? _parseAmount() {
    return int.tryParse(amountController.text.trim());
  }

  /// 格式化输入价格
  ///
  /// [value] 价格数值
  String _formatInputPrice(double value) {
    if (value.truncateToDouble() == value) {
      return value.toInt().toString();
    }

    return Formatters.groupedNumber(value).replaceAll(',', '');
  }

  /// 拍卖详情是否包含当前用户出价
  ///
  /// [auction] 当前拍卖详情
  bool _hasAuctionBidInfo(AuctionApiItem? auction) {
    return auction != null && auction.price > 0 && auction.amount > 0;
  }
}
