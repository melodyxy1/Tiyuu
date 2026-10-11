# 小幼助手 (XiaoyouZhushou) —— Makefile
# 在 macOS（已装 theos）下执行 ./build.sh 即可生成 .deb

TARGET = iphone:clang:latest:15.0
ARCHS = arm64 arm64e

export DEBUG = 0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XiaoyouZhushou

XiaoyouZhushou_FILES = XiaoyouZhushou.xm
XiaoyouZhushou_CFLAGS = -fobjc-arc -Wno-error
XiaoyouZhushou_LOGOS_DEFAULT_GENERATOR = internal

export THEOS_STRICT_LOGOS=0
export ERROR_ON_WARNINGS=0
export LOGOS_DEFAULT_GENERATOR=internal

include $(THEOS_MAKE_PATH)/tweak.mk
