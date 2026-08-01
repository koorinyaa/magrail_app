part of 'character_quick_entry_bar.dart';

/// 角色入口布局
class _CharacterPortalLayout extends StatelessWidget {
  /// 创建角色入口布局
  ///
  /// [onValhallaTap] 英灵殿入口点击回调
  /// [onGensokyoTap] 幻想乡入口点击回调
  /// [onStTap] ST 入口点击回调
  const _CharacterPortalLayout({
    required this.onValhallaTap,
    required this.onGensokyoTap,
    required this.onStTap,
  });

  final VoidCallback onValhallaTap;
  final VoidCallback onGensokyoTap;
  final VoidCallback onStTap;

  /// 构建角色入口布局
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const cardGap = 8.0;
        const cardHeight = 162.0;
        final primaryWidth = (constraints.maxWidth - cardGap) * 0.6;
        final secondaryWidth = constraints.maxWidth - primaryWidth - cardGap;
        final secondaryHeight = (cardHeight - cardGap) / 2;

        return RepaintBoundary(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _PortalBackdropPainter(
                      lineColor: colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                width: primaryWidth,
                height: cardHeight,
                child: _CharacterPortalCard(
                  sequence: '01',
                  title: '英灵殿',
                  englishTitle: 'VALHALLA',
                  accent: _valhallaAccent,
                  artwork: _PortalArtwork.tinygrailLogo,
                  prominent: true,
                  onTap: onValhallaTap,
                ),
              ),
              Positioned(
                left: primaryWidth + cardGap,
                top: 0,
                width: secondaryWidth,
                height: secondaryHeight,
                child: _CharacterPortalCard(
                  sequence: '02',
                  title: '幻想乡',
                  englishTitle: 'GENSOKYO',
                  accent: _gensokyoAccent,
                  artwork: _PortalArtwork.torii,
                  onTap: onGensokyoTap,
                ),
              ),
              Positioned(
                left: primaryWidth + cardGap,
                top: secondaryHeight + cardGap,
                width: secondaryWidth,
                height: secondaryHeight,
                child: _CharacterPortalCard(
                  sequence: '03',
                  title: '退市',
                  englishTitle: 'ST',
                  accent: _stAccent,
                  artwork: _PortalArtwork.delistingWarning,
                  onTap: onStTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
