import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_sacrifice_result.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_data.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 角色资产重组底部抽屉控制器
final class CharacterDetailSacrificeSheetController extends ChangeNotifier {
  /// 创建角色资产重组底部抽屉控制器
  ///
  /// [repository] 角色详情仓库
  /// [userRepository] 用户仓库
  /// [characterId] 角色 ID
  /// [currentUserName] 当前登录用户名
  CharacterDetailSacrificeSheetController({
    required CharacterDetailRepository repository,
    required UserRepository userRepository,
    required int characterId,
    required String currentUserName,
  })  : _repository = repository,
        _userRepository = userRepository,
        _characterId = characterId,
        _currentUserName = currentUserName {
    amountController.addListener(_handleAmountChanged);
  }

  final CharacterDetailRepository _repository;
  final UserRepository _userRepository;
  final int _characterId;
  final String _currentUserName;

  var _mode = CharacterDetailSacrificeMode.restructure;
  var _isLoading = true;
  var _isSubmitting = false;
  var _loadErrorMessage = '';
  var _loadRequestId = 0;
  var _isDisposed = false;

  CharacterDetailTradeHeader? _header;
  CharacterDetailUserTrading? _trading;
  UserTempleApiItem? _temple;

  /// 提交数量输入控制器
  final TextEditingController amountController = TextEditingController();

  /// 当前提交类型
  CharacterDetailSacrificeMode get mode => _mode;

  /// 是否正在加载打开时的新数据
  bool get isLoading => _isLoading;

  /// 是否正在提交
  bool get isSubmitting => _isSubmitting;

  /// 加载失败文案
  String get loadErrorMessage => _loadErrorMessage;

  /// 是否加载失败
  bool get hasLoadError => _loadErrorMessage.isNotEmpty;

  /// 已上市角色头部资料
  CharacterDetailTradeHeader? get header => _header;

  /// 当前用户交易资料
  CharacterDetailUserTrading? get trading => _trading;

  /// 当前用户圣殿资料
  UserTempleApiItem? get temple => _temple;

  /// 当前角色可用活股
  int get availableAmount => _trading?.amount ?? 0;

  /// 当前圣殿资产值
  int get templeAssets => _temple?.assets ?? 0;

  /// 当前圣殿资产上限
  int get templeSacrifices => _temple?.sacrifices ?? _trading?.sacrifices ?? 0;

  /// 当前圣殿等级
  int get templeLevel => _temple?.level ?? 0;

  /// 当前输入数量
  int get amount => int.tryParse(amountController.text.trim()) ?? 0;

  /// 当前是否为股权融资
  bool get isFinancing => _mode == CharacterDetailSacrificeMode.financing;

  /// 提交校验文案
  String? get validationMessage {
    if (amount <= 0) {
      return '请输入有效数量';
    }

    if (amount > availableAmount) {
      return '可用活股数量不足';
    }

    return null;
  }

  /// 是否允许提交
  bool get canSubmit {
    return !_isLoading && !hasLoadError && !_isSubmitting;
  }

  /// 初始化并加载底部抽屉数据
  Future<void> initialize() {
    return reload();
  }

  /// 重新加载底部抽屉数据
  Future<void> reload() async {
    final requestId = ++_loadRequestId;
    _isLoading = true;
    _loadErrorMessage = '';
    _notify();

    try {
      final username = _currentUserName.trim();
      if (username.isEmpty) {
        throw StateError('请先授权');
      }

      final results = await Future.wait<Object>([
        _repository.fetchCharacterBasicInfo(_characterId),
        _repository.fetchCurrentUserTrading(_characterId),
        _userRepository.fetchUserTemplePage(
          username: username,
          page: 1,
          pageSize: 1,
          characterIds: <int>[_characterId],
        ),
      ]);
      if (!_isCurrentRequest(requestId)) {
        return;
      }

      final info = results[0] as CharacterDetailBasicInfo;
      final header = info.tradeHeader;
      if (header == null) {
        throw StateError('角色未上市，无法进行资产重组');
      }

      _header = header;
      _trading = results[1] as CharacterDetailUserTrading;
      _temple = _findTemple(
        (results[2] as TinygrailPage<UserTempleApiItem>).items,
      );
    } catch (error) {
      if (!_isCurrentRequest(requestId)) {
        return;
      }

      _loadErrorMessage = _messageForError(error, '资产重组数据加载失败');
    } finally {
      if (_isCurrentRequest(requestId)) {
        _isLoading = false;
        _notify();
      }
    }
  }

  /// 切换提交类型
  ///
  /// [mode] 目标提交类型
  void updateMode(CharacterDetailSacrificeMode mode) {
    if (_mode == mode) {
      return;
    }

    _mode = mode;
    _notify();
  }

  /// 填入快捷提交数量
  ///
  /// [amount] 目标提交数量
  void fillAmount(int amount) {
    _setAmount(amount);
  }

  /// 填入当前全部可用活股
  void fillMaxAmount() {
    _setAmount(availableAmount);
  }

  /// 填入补满当前圣殿余量所需活股
  void fillTempleAmount() {
    _setAmount(math.max(0, (templeSacrifices - templeAssets) ~/ 2));
  }

  /// 提交当前资产重组或股权融资
  Future<CharacterDetailSacrificeResult> submit() async {
    final validation = validationMessage;
    if (validation != null) {
      throw StateError(validation);
    }

    final submittedAmount = amount;
    final submittedIsFinancing = isFinancing;
    _isSubmitting = true;
    _notify();
    try {
      return _repository.sacrificeCharacter(
        characterId: _characterId,
        amount: submittedAmount,
        isFinancing: submittedIsFinancing,
      );
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  /// 释放角色资产重组底部抽屉控制器
  @override
  void dispose() {
    _isDisposed = true;
    amountController
      ..removeListener(_handleAmountChanged)
      ..dispose();
    super.dispose();
  }

  /// 查找当前角色对应圣殿
  ///
  /// [items] 用户圣殿分页条目
  UserTempleApiItem? _findTemple(List<UserTempleApiItem> items) {
    for (final item in items) {
      if (item.characterId == _characterId) {
        return item;
      }
    }

    return null;
  }

  /// 写入提交数量
  ///
  /// [nextAmount] 新数量
  void _setAmount(int nextAmount) {
    final resolvedAmount = math.max(0, nextAmount);
    final nextText = resolvedAmount.toString();
    if (amountController.text == nextText) {
      return;
    }

    amountController.text = nextText;
    amountController.selection = TextSelection.collapsed(
      offset: amountController.text.length,
    );
  }

  /// 处理数量输入变化
  void _handleAmountChanged() {
    _notify();
  }

  /// 判断加载响应是否仍属于当前请求
  ///
  /// [requestId] 请求序号
  bool _isCurrentRequest(int requestId) {
    return !_isDisposed && requestId == _loadRequestId;
  }

  /// 转换异常为展示文案
  ///
  /// [error] 捕获到的异常
  /// [fallback] 兜底文案
  String _messageForError(Object error, String fallback) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }

  /// 通知抽屉状态变化
  void _notify() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
