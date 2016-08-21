export SDKVERSION=8.1

ARCHS := armv7 arm64
TARGET := iphone:clang
TARGET_SDK_VERSION := 8.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 9.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MinimalHUDPreferences
MinimalHUDPreferences_FILES = MinimalHUD.mm $(wildcard *.m)
MinimalHUDPreferences_INSTALL_PATH = /Library/PreferenceBundles
MinimalHUDPreferences_FRAMEWORKS = UIKit
MinimalHUDPreferences_PRIVATE_FRAMEWORKS = Preferences
MinimalHUDPreferences_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MinimalHUD.plist$(ECHO_END)
