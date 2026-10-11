#!/bin/bash
# 小幼助手 一键编译脚本（在 macOS 上运行，需已安装 theos）
# 用法：bash build.sh
set -e

# 若未设置 THEOS，尝试常见路径；请按需修改
export THEOS="${THEOS:-/opt/theos}"
if [ ! -d "$THEOS" ]; then
  echo "❌ 未找到 theos，请先安装：https://theos.dev"
  echo "   或修改本脚本里的 THEOS 路径"
  exit 1
fi

echo "==> 使用 theos: $THEOS"
make clean
make package FINALPACKAGE=1

echo ""
echo "✅ 编译完成，生成的 .deb 在 ./packages/ 目录"
ls -lh packages/*.deb 2>/dev/null || true
