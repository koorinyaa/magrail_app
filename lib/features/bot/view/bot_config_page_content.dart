part of 'bot_config_page.dart';

/// bot 配置内容构建扩展
extension _BotConfigPageContent on _BotConfigPageState {
  /// 构建配置内容
  ///
  /// [context] 当前组件树上下文
  /// [config] 当前 bot 配置
  Widget _buildConfigContent(BuildContext context, BotConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BotSurface(
          child: Column(
            children: [
              _BotSwitchRow(
                label: '刮刮乐',
                value: config.scratchState,
                onChanged: (value) => _updateConfig(() {
                  config.scratchState = value;
                }),
              ),
              const _BotDivider(),
              _BotSwitchRow(
                label: '每日签到',
                value: config.dailyState,
                onChanged: (value) => _updateConfig(() {
                  config.dailyState = value;
                }),
              ),
              const _BotDivider(),
              _BotSwitchRow(
                label: '每周股息',
                value: config.bonusState,
                onChanged: (value) => _updateConfig(() {
                  config.bonusState = value;
                }),
              ),
              const _BotDivider(),
              _BotSelectRow(
                label: '圣殿黑名单',
                value: config.templeBlacklist.isEmpty
                    ? '未选择'
                    : '已选择 ${config.templeBlacklist.length} 个圣殿',
                onPressed: () => _openTempleBlacklistPicker(config),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _BotSurface(
          child: Column(
            children: [
              _BotSwitchRow(
                label: '混沌魔方',
                value: config.chaosState,
                onChanged: (value) => _updateConfig(() {
                  config.chaosState = value;
                }),
              ),
              if (config.chaosState) ...[
                const _BotDivider(),
                _BotSwitchRow(
                  label: '自动模式',
                  value: config.chaosAutoMode,
                  onChanged: (value) => _updateConfig(() {
                    config.chaosAutoMode = value;
                  }),
                ),
                if (!config.chaosAutoMode) ...[
                  const _BotDivider(),
                  _BotSelectRow(
                    label: '消耗圣殿',
                    value: _templeLabel(config.chaosUseTemple),
                    valueWidget: _templeValueWidget(config.chaosUseTemple),
                    onPressed: () => _openTemplePicker(
                      title: '混沌魔方',
                      selectedId: config.chaosUseTemple,
                      imageAsset: botChaosCubeActionIconAsset,
                      fallbackIcon: Icons.casino_outlined,
                      onSelected: (item) {
                        config.chaosUseTemple = item.characterId;
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _BotSurface(
          child: Column(
            children: [
              _BotSwitchRow(
                label: '虚空道标',
                value: config.guidepostState,
                onChanged: (value) => _updateConfig(() {
                  config.guidepostState = value;
                }),
              ),
              if (config.guidepostState) ...[
                const _BotDivider(),
                _BotSwitchRow(
                  label: '自动模式',
                  value: config.guidepostAutoMode,
                  onChanged: (value) => _updateConfig(() {
                    config.guidepostAutoMode = value;
                  }),
                ),
                if (config.guidepostAutoMode) ...[
                  const _BotDivider(),
                  _BotSwitchRow(
                    label: '葛朗台模式',
                    value: config.guidepostGrandetMode,
                    detail: '只使用比目标角色低两级的圣殿',
                    onChanged: (value) => _updateConfig(() {
                      config.guidepostGrandetMode = value;
                    }),
                  ),
                ] else ...[
                  const _BotDivider(),
                  _BotSelectRow(
                    label: '消耗圣殿',
                    value: _templeLabel(config.guidepostUseTemple),
                    valueWidget: _templeValueWidget(config.guidepostUseTemple),
                    onPressed: () => _openTemplePicker(
                      title: '虚空道标',
                      selectedId: config.guidepostUseTemple,
                      imageAsset: botGuidepostActionIconAsset,
                      fallbackIcon: Icons.assistant_direction_outlined,
                      onSelected: (item) {
                        config.guidepostUseTemple = item.characterId;
                      },
                    ),
                  ),
                ],
                const _BotDivider(),
                _BotSelectRow(
                  label: '目标角色',
                  value: _characterLabel(config.guidepostTarget),
                  valueWidget: _characterValueWidget(config.guidepostTarget),
                  onPressed: () => _openMagicTargetPicker(
                    title: '虚空道标',
                    description: '请选择虚空道标的目标角色',
                    recentStorageKeyPrefix:
                        templeAssetMagicGuidepostRecentCharacterIdsKeyPrefix,
                    imageAsset: botGuidepostActionIconAsset,
                    fallbackIcon: Icons.assistant_direction_outlined,
                    onSelected: (item) {
                      config.guidepostTarget = item.characterId;
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _BotSurface(
          child: Column(
            children: [
              _BotSwitchRow(
                label: '鲤鱼之眼',
                value: config.fishState,
                onChanged: (value) => _updateConfig(() {
                  config.fishState = value;
                }),
              ),
              if (config.fishState) ...[
                const _BotDivider(),
                _BotSwitchRow(
                  label: '自动模式',
                  value: config.fishAutoMode,
                  onChanged: (value) => _updateConfig(() {
                    config.fishAutoMode = value;
                  }),
                ),
                if (!config.fishAutoMode) ...[
                  const _BotDivider(),
                  _BotSelectRow(
                    label: '消耗圣殿',
                    value: _templeLabel(config.fishUseTemple),
                    valueWidget: _templeValueWidget(config.fishUseTemple),
                    onPressed: () => _openTemplePicker(
                      title: '鲤鱼之眼',
                      selectedId: config.fishUseTemple,
                      imageAsset: botFisheyeActionIconAsset,
                      fallbackIcon: Icons.remove_red_eye_outlined,
                      onSelected: (item) {
                        config.fishUseTemple = item.characterId;
                      },
                    ),
                  ),
                ],
                const _BotDivider(),
                _BotSelectRow(
                  label: '目标角色',
                  value: _characterLabel(config.fishTarget),
                  valueWidget: _characterValueWidget(config.fishTarget),
                  onPressed: () => _openMagicTargetPicker(
                    title: '鲤鱼之眼',
                    description: '请选择鲤鱼之眼的目标角色',
                    recentStorageKeyPrefix:
                        templeAssetMagicFisheyeRecentCharacterIdsKeyPrefix,
                    imageAsset: botFisheyeActionIconAsset,
                    fallbackIcon: Icons.remove_red_eye_outlined,
                    useFisheyeSupplement: true,
                    onSelected: (item) {
                      config.fishTarget = item.characterId;
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _BotSurface(
          child: Column(
            children: [
              _BotSwitchRow(
                label: '自动参与 ICO',
                value: config.icoState,
                onChanged: (value) => _updateConfig(() {
                  config.icoState = value;
                }),
              ),
              if (config.icoState) ...[
                const _BotDivider(),
                _BotSelectRow(
                  label: '投入金额',
                  value: Formatters.tinygrailCurrency(
                    config.icoInvestmentAmount,
                  ),
                  onPressed: () => _openIcoAmountEditor(
                    title: '投入金额',
                    controller: _icoInvestmentController,
                    minimum: 5000,
                    invalidMessage: '请输入有效的投入金额',
                    minimumMessage: '投入金额不能低于 5000',
                  ),
                ),
                const _BotDivider(),
                _BotSelectRow(
                  label: '保留金额',
                  value: Formatters.tinygrailCurrency(config.icoReserveAmount),
                  onPressed: () => _openIcoAmountEditor(
                    title: '保留金额',
                    controller: _icoReserveController,
                    minimum: 0,
                    invalidMessage: '请输入有效的保留金额',
                    minimumMessage: '保留金额不能小于 0',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _BotSurface(
          child: _BotSelectRow(
            label: '操作日志',
            value: '',
            onPressed: _openLogPage,
          ),
        ),
      ],
    );
  }
}
