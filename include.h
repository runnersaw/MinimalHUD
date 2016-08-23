
#define PREFERENCES_PATH @"/var/mobile/Library/Preferences/com.runnersaw.hud.plist"

// COLOR MODES
typedef NS_ENUM(NSUInteger, MHDColorMode) {
	MHDColorModeTheme,
	MHDColorModeCustom
};

// COLOR THEMES
typedef NS_ENUM(NSUInteger, MHDColorTheme) {
	MHDColorThemeWarm,
	MHDColorThemeRainbow,
	MHDColorThemeTranslucent,
	MHDColorThemeStock
};

// LOCATION MODES
typedef NS_ENUM(NSUInteger, MHDLocationMode) {
	MHDLocationModePreset,
	MHDLocationModeCustom
};

// PRESET LOCATIONS
typedef NS_ENUM(NSUInteger, MHDLocationPreset) {
	MHDLocationPresetTop,
	MHDLocationPresetRight,
	MHDLocationPresetLeft,
	MHDLocationPresetBottom
};
