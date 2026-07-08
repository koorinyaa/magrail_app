import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_search_item.dart';

/// Next Bangumi 条目路由名称
const nextBangumiSubjectRouteName = 'nextBangumiSubject';

/// 打开 Next Bangumi 条目二级页面
///
/// [context] 当前组件树上下文
/// [subjectId] 条目 ID
void openNextBangumiSubject(
  BuildContext context, {
  required int subjectId,
}) {
  if (subjectId <= 0) {
    return;
  }

  context.pushNamed(
    nextBangumiSubjectRouteName,
    queryParameters: {
      'subjectId': subjectId.toString(),
    },
  );
}

/// 从搜索结果打开 Next Bangumi 条目二级页面
///
/// [context] 当前组件树上下文
/// [item] Bangumi 条目搜索结果
void openNextBangumiSubjectFromSearchItem(
  BuildContext context,
  NextBangumiSubjectSearchItem item,
) {
  openNextBangumiSubject(
    context,
    subjectId: item.subjectId,
  );
}
