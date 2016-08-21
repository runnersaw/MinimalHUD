export SDKVERSION=8.1

ARCHS := armv7 armv7s arm64
TARGET := iphone:clang
TARGET_SDK_VERSION := 8.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 8.0
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MinimalHUD
MinimalHUD_FILES = Tweak.xm $(wildcard minimalhud/*.m)
MinimalHUD_FRAMEWORKS = UIKit CoreGraphics
MinimalHUD_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += minimalhud
include $(THEOS_MAKE_PATH)/aggregate.mk
