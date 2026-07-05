<p align="center">
  <img src="https://raw.githubusercontent.com/koorinyaa/magrail_app/main/assets/icons/app_icon_foreground.png" width="128" alt="MaGrail">
</p>

<h1 align="center">MaGrail</h1>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-Android%20%7C%20iOS-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart&logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green">
</p>

MaGrail 是为小圣杯打造的移动客户端，覆盖小圣杯原有全部功能，并针对移动端使用体验进行了重新设计。

## 下载与安装

- Releases：[Releases](https://github.com/koorinyaa/magrail_app/releases)
- `app-arm64-v8a-release.apk`：Android 64 位 ARM 安装包，推荐绝大多数现代手机和平板使用
- `app-armeabi-v7a-release.apk`：Android 32 位 ARM 安装包，适合较老设备
- `app-x86_64-release.apk`：Android x86_64 安装包，主要适合模拟器或少数 x86 设备
- `Magrail-sideload.ipa`：iOS 侧载包，需要自行重签名安装

## 功能一览

- 首页聚合：每周萌王、通天塔、最新连接、最新圣殿
- 角色浏览：英灵殿、幻想乡、所有角色、角色搜索与角色详情
- 排行榜：精炼排行、番市首富、角色股息、市值、涨跌排行
- ICO：ICO 列表、ST 角色、注资、启动 ICO、参与者查看
- 交易与拍卖：买入、卖出、委托订单、竞拍、撤销竞拍、往期拍卖
- 个人资产：余额、资产、持股、圣殿、连接、资金日志、交易记录
- 用户操作：登录授权、退出登录、签到奖励、每周分红、红包、股息预测
- 圣殿管理：精炼、LINK、台词、封面、拆除、星之力与魔法道具操作

## 开发与构建环境

- Flutter SDK
- Dart SDK `>=3.5.0 <4.0.0`
- Android SDK
- JDK 17
- Xcode 15 或更新版本，仅 iOS 构建需要

## 本地开发

安装依赖：

```powershell
flutter pub get
```

运行应用：

```powershell
flutter run
```

静态检查：

```powershell
flutter analyze --no-pub
```

构建 Android debug APK：

```powershell
flutter build apk --debug --no-pub
```

构建 Android release APK：

```powershell
flutter build apk --release --no-pub
```

## iOS 侧载构建

仓库包含 GitHub Actions workflow：

```text
.github/workflows/ios-sideload.yml
```

在 GitHub Actions 页面手动运行 `iOS Sideload IPA` 后，构建产物会上传为：

```text
Magrail-sideload.ipa
```

该 IPA 不包含 App Store 分发签名，安装时需要使用侧载工具重新签名。

## 项目结构

```text
lib/
  main.dart        应用入口
  app/             启动、路由、主题和依赖装配
  core/            网络、授权、存储、反馈、通用组件和工具
  features/        首页、角色、ICO、排行榜、圣殿、用户等业务功能

android/           Android 平台工程
ios/               iOS 平台工程
assets/            图标和静态资源
```

## 打赏

谢谢支持喵~

<p align="center">
  <img src="assets/images/donate/alipay.jpg" width="220" alt="支付宝收款码">
  <img src="assets/images/donate/wechatpay.jpg" width="220" alt="微信支付收款码">
</p>

## 开源协议

本项目采用 [MIT License](LICENSE)，欢迎学习、使用和二次开发。分发修改版本时，请保留原始版权声明和许可证文本。
