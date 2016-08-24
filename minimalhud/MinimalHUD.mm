#import <Preferences/Preferences.h>

#import "../include.h"
#import "MHDPreferences.h"

@interface MinimalHUDListController : PSListController

@property (nonatomic, strong) MHDPreferences *preferences;

@end

@implementation MinimalHUDListController

- (MHDPreferences *)preferences
{
	if (!_preferences)
	{
		NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
		_preferences = [[MHDPreferences alloc] initWithSettings:settings];
	}
	return _preferences;
}

- (id)specifiers {
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

	// Location Settings
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode" target:self] retain]];
	if (self.preferences.locationMode == MHDLocationModePreset)
	{
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode_preset" target:self] retain]];
	}
	else
	{
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"location_mode_custom" target:self] retain]];
	}

	// Paypal donation
	[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"paypal_donation" target:self] retain]];

	_specifiers = specs;

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	return [self.preferences valueForKey:(NSString *)specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value forSpecifier:(PSSpecifier*)specifier {
	[self.view endEditing:YES];
	
	[self.preferences updateValue:value forKey:specifier.properties[@"key"]];
	[self.preferences.dictionaryRepresentation writeToFile:PREFERENCES_PATH atomically:NO];

	[self reloadSpecifiers];

	CFStringRef notificationName = (CFStringRef)@"com.runnersaw.hud-preferencesChanged";
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
}

- (void)paypalButtonTapped
{
	[[UIApplication sharedApplication] openURL:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=MJJBDZFUR483S&lc=US&item_name=MinimalHUD&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"];
}

@end

