part of 'next_bangumi_subject_page.dart';

/// Next Bangumi 条目详情骨架 Sliver
class _NextBangumiSubjectSkeletonSliver extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情骨架 Sliver
  const _NextBangumiSubjectSkeletonSliver();

  /// 构建 Next Bangumi 条目详情骨架 Sliver
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 32;

    return SliverToBoxAdapter(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, bottomPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _subjectContentMaxWidth,
              ),
              child: const Skeletonizer(
                enabled: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Bone(
                      width: _subjectCoverWidth,
                      height: _subjectCoverPlaceholderHeight,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    SizedBox(height: 18),
                    Bone(
                      width: 220,
                      height: 22,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    SizedBox(height: 18),
                    Bone.multiText(lines: 2),
                    SizedBox(height: 16),
                    Bone.multiText(lines: 5),
                    SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 7,
                      children: [
                        Bone(
                          width: 44,
                          height: 22,
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        Bone(
                          width: 58,
                          height: 22,
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        Bone(
                          width: 72,
                          height: 22,
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Bone(
                      width: 72,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
