#import <Preferences/Preferences.h>

@interface MinimalHUDListController: PSListController
@end

@implementation MinimalHUDListController

- (id)specifiers {
	if(_specifiers == nil) {
		NSMutableArray *specs = [[NSMutableArray alloc] init];

		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"MinimalHUD" target:self] retain]];
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode" target:self] retain]];
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode_theme" target:self] retain]];
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode" target:self] retain]];
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode_preset" target:self] retain]];

		_specifiers = specs;
	}

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

@end

