ARCHS := armv7 arm64
TARGET := iphone:clang
TARGET_SDK_VERSION := 8.4
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 9.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MinimalHUD
MinimalHUD_FILES = MinimalHUD.mm
MinimalHUD_INSTALL_PATH = /Library/PreferenceBundles
MinimalHUD_FRAMEWORKS = UIKit
MinimalHUD_PRIVATE_FRAMEWORKS = Preferences
MinimalHUD_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	echo "Creating preferences"
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MinimalHUD.plist$(ECHO_END)
