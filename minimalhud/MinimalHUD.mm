#import <Preferences/Preferences.h>

#import "MHDPreferences.h"

@interface MinimalHUDListController : PSListController

@property (nonatomic, strong) MHDPreferences *preferences;

@end

@implementation MinimalHUDListController

- (id)specifiers {
	NSMutableArray *specs = [[NSMutableArray alloc] init];

	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"MinimalHUD" target:self] retain]];
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode" target:self] retain]];
	if (self.preferences.colorMode == MHDColorModeTheme)
	{
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode_theme" target:self] retain]];
	}
	else
	{
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode_custom" target:self] retain]];
	}
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
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	NSLog(@"settings %@", settings);
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value forSpecifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];

	self.preferences = [[MHDPreferences alloc] initWithSettings:settings];
	[self reloadSpecifiers];

	CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

@end

