# 小幼助手 (XiaoyouZhushou)

基于开源项目 [WCEhance](https://github.com/huami1314/WCEhance) 改名的微信 UI 个性化越狱 tweak。
插件显示名：**小幼助手**。功能与原项目一致（均为 UI 层面，无破解/作弊逻辑）：

- 菜单文案改写：「订单与卡包」→「卡包」、「支付与服务」→「服务」
- 图片预览：点击左右边缘区域关闭、移除图片阴影
- 隐藏「我」页面「我的二维码」大图

> ⚠️ 仅用于学习交流与个人设备自用。修改第三方 App 客户端可能违反其用户协议，
> 并存在账号风控 / 封号、闪退等风险，请自行评估。

## 文件说明

```
XiaoyouZhushou.xm       核心 Hook 代码（Logos 语法）
Makefile                构建配置
control                 包信息（Name=小幼助手, Package=com.xiaoyou.xiaoyouzhushou）
XiaoyouZhushou.plist    注入过滤（目标微信 com.tencent.xin）
build.sh                macOS 一键编译脚本
```

## 编译为 .deb（必须在 macOS 上）

前置：已安装 [theos](https://theos.dev) 与 Xcode 命令行工具 / iOS SDK。

```bash
cd XiaoyouZhushou
bash build.sh
# 生成的 .deb 位于 ./packages/
```

或手动：

```bash
export THEOS=/opt/theos      # 改成你的 theos 路径
make package FINALPACKAGE=1
```

## 安装到越狱设备

用 Sileo / Zebra / Filza 打开 `packages/*.deb` 安装，重启微信即可生效。

## 清理

如需从设备移除，在包管理器里卸载「小幼助手」即可。
