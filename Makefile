ARCHS := armv7 arm64
TARGET := iphone:clang
TARGET_SDK_VERSION := 8.4
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 6.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HUD
HUD_FILES = Tweak.xm
HUD_FRAMEWORKS = UIKit CoreGraphics
HUD_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += minimalhud
include $(THEOS_MAKE_PATH)/aggregate.mk

