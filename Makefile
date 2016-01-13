ARCHS = armv7 arm64
SDKVERSION = 8.1
TARGET = iphone:8.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HUD
HUD_FILES = Tweak.xm
HUD_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
