import 'package:flutter/material.dart';

/// 用户私有资产显示切换按钮
class UserPrivateAssetVisibilityButton extends StatelessWidget {
  /// 创建用户私有资产显示切换按钮
  ///
  /// [key] Flutter 组件标识
  /// [isHidden] 是否隐藏私有资产数值
  /// [onPressed] 按钮点击回调
  const UserPrivateAssetVisibilityButton({
    super.key,
    required this.isHidden,
    required this.onPressed,
  });

  /// 是否隐藏私有资产数值
  final bool isHidden;

  /// 按钮点击回调
  final VoidCallback onPressed;

  /// 构建用户私有资产显示切换按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kToolbarHeight,
      child: Center(
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            isHidden
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 22,
          ),
        ),
      ),
    );
  }
}
