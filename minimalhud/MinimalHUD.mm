#import <Preferences/Preferences.h>

#import "../include.h"
#import "MHDPreferences.h"

@interface MinimalHUDListController : PSListController

@property (nonatomic, strong) MHDPreferences *preferences;

@end

@implementation MinimalHUDListController

- (id)specifiers {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	self.preferences = [[MHDPreferences alloc] initWithSettings:settings];

	NSMutableArray *specs = [[NSMutableArray alloc] init];

	// Enable button
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"MinimalHUD" target:self] retain]];

	// Color settings
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode" target:self] retain]];
	if (self.preferences.colorMode == MHDColorModeTheme)
	{
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode_theme" target:self] retain]];
	}
	else
	{
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode_custom" target:self] retain]];
	}

	// Location settings
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode" target:self] retain]];
	if (self.preferences.locationMode == MHDLocationModePreset)
	{
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode_preset" target:self] retain]];
	}
	else
	{
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode_custom" target:self] retain]];
	}

	_specifiers = specs;

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value forSpecifier:(PSSpecifier*)specifier {
	NSLog(@"%@ %@", value, specifier);
	if (!value)
	{
		return;
	}

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:PREFERENCES_PATH atomically:YES];

	self.preferences = [[MHDPreferences alloc] initWithSettings:settings];
	[self reloadSpecifiers];

	CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

@end

